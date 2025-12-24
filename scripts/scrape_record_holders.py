#!/usr/bin/env python3
"""
Apex Athlete Record Holders Scraper
Scrapes record holder data from apexathleteofficial.com and updates Supabase database

Setup and Usage:
----------------

# Create and activate virtual environment (recommended)
cd scripts && python3 -m venv venv && source venv/bin/activate && pip install -r requirements.txt

# Run in dry-run mode first to see what would be inserted
python scrape_record_holders.py --dry-run

# When ready, run for real
python scrape_record_holders.py

"""

import os
import sys
import logging
import argparse
import json
import re
from datetime import datetime
from typing import List, Dict, Optional
import requests
from bs4 import BeautifulSoup
from dotenv import load_dotenv

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


class ApexRecordHoldersScraper:
    """Scraper for Apex Athlete record holders with Supabase integration"""
    
    BASE_URL = "https://apexathleteofficial.com"
    IFRAME_URL = f"{BASE_URL}/apex_pages/apex_record_holders_page/index.html"
    TABLE_NAME = "apex_record_holders"
    
    def __init__(self, dry_run: bool = False):
        """Initialize scraper with Supabase connection"""
        self.dry_run = dry_run
        self.supabase_url = os.environ.get('SUPABASE_URL')
        self.supabase_key = os.environ.get('SUPABASE_KEY')
        
        if not dry_run and (not self.supabase_url or not self.supabase_key):
            raise ValueError("SUPABASE_URL and SUPABASE_KEY environment variables must be set")
        
        self.session = requests.Session()
        if not dry_run:
            self.session.headers.update({
                'apikey': self.supabase_key,
                'Authorization': f'Bearer {self.supabase_key}'
            })
    
    def fetch_page(self, url: str, retries: int = 3) -> Optional[str]:
        """Fetch a web page with retry logic"""
        for attempt in range(retries):
            try:
                logger.info(f"Fetching: {url} (attempt {attempt + 1}/{retries})")
                response = requests.get(url, headers={
                    'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36'
                }, timeout=30)
                response.raise_for_status()
                return response.text
            except requests.RequestException as e:
                logger.error(f"Error fetching {url}: {e}")
                if attempt < retries - 1:
                    import time
                    time.sleep(2 ** attempt)
                else:
                    return None
        return None
    
    def supabase_request(self, method: str, endpoint: str, data: Optional[Dict] = None, params: Optional[Dict] = None) -> Optional[Dict]:
        """Make a request to Supabase REST API"""
        url = f"{self.supabase_url}/rest/v1/{endpoint}"
        
        try:
            if method.upper() == 'GET':
                response = self.session.get(url, params=params)
            elif method.upper() == 'POST':
                response = self.session.post(url, json=data, headers={'Prefer': 'return=representation'})
            elif method.upper() == 'DELETE':
                response = self.session.delete(url, params=params)
            else:
                raise ValueError(f"Unsupported HTTP method: {method}")
            
            response.raise_for_status()
            return response.json() if response.text else None
            
        except requests.RequestException as e:
            logger.error(f"Supabase request failed: {e}")
            if hasattr(e.response, 'text'):
                logger.error(f"Response: {e.response.text}")
            return None
    
    def clear_existing_records(self) -> bool:
        """Clear all existing records from the table"""
        if self.dry_run:
            logger.info("DRY RUN: Would clear existing records")
            return True
        
        # Delete all records (we'll replace them with fresh data)
        params = {'id': 'gt.0'}  # Match all records
        result = self.supabase_request('DELETE', self.TABLE_NAME, params=params)
        logger.info("Cleared existing records from database")
        return True
    
    def insert_records(self, records: List[Dict]) -> int:
        """Insert record holders into Supabase"""
        if not records:
            return 0
        
        if self.dry_run:
            self._print_dry_run_records(records)
            return len(records)
        
        response = self.supabase_request('POST', self.TABLE_NAME, data=records)
        
        if response:
            inserted = len(response) if isinstance(response, list) else 1
            logger.info(f"Successfully inserted {inserted} records")
            return inserted
        else:
            logger.error("Failed to insert records")
            return 0
    
    def _print_dry_run_records(self, records: List[Dict]):
        """Print records in a formatted way for dry run mode"""
        print("\n" + "="*100)
        print(f"DRY RUN: Would insert {len(records)} record holder entries")
        print("="*100)
        
        # Group by category
        categories = {}
        for record in records:
            cat = record['category']
            if cat not in categories:
                categories[cat] = []
            categories[cat].append(record)
        
        for category, cat_records in categories.items():
            print(f"\n🏆 Category: {category.upper()}")
            print("-"*100)
            
            for rec in cat_records:
                print(f"\n  {rec['event_name']}")
                print(f"    Gender: {rec['gender']}")
                print(f"    Holder: {rec['record_holder']}")
                print(f"    Value: {rec['record_value']}")
                if rec['instagram_handle']:
                    print(f"    Instagram: {rec['instagram_handle']}")
        
        print("\n" + "="*100)
        print("DRY RUN COMPLETE - No data was inserted into the database")
        print("="*100 + "\n")
    
    def scrape_records(self) -> List[Dict]:
        """Scrape record holders from the iframe page"""
        logger.info("Scraping record holders")
        
        # Fetch the iframe HTML
        html_content = self.fetch_page(self.IFRAME_URL)
        if not html_content:
            logger.error("Failed to fetch record holders iframe")
            return []
        
        # Extract the RECORDS array from JavaScript
        records_data = self._extract_records_from_html(html_content)
        if not records_data:
            logger.error("Failed to extract records from HTML")
            return []
        
        # Parse into database format
        db_records = []
        record_details = []  # For logging
        
        for record in records_data:
            # Capitalize category (speed -> Speed, power -> Power, etc.)
            category = record.get('cat', '').capitalize()
            # Title case event name (FAST FORTY -> Fast Forty, THE PULL -> The Pull)
            event_name = record.get('title', '').title()
            
            # Men's record
            men_data = record.get('men', {})
            if men_data and men_data.get('name'):
                db_records.append({
                    'category': category,
                    'event_name': event_name,
                    'gender': 'Men',
                    'record_holder': men_data.get('name', ''),
                    'record_value': men_data.get('value', ''),
                    'instagram_handle': men_data.get('ig', '') if men_data.get('ig') != '—' else None,
                    'last_updated': datetime.now().strftime('%Y-%m-%d')
                })
                record_details.append(f"{event_name} (M): {men_data.get('name', '')} - {men_data.get('value', '')}")
            
            # Women's record
            women_data = record.get('women', {})
            if women_data and women_data.get('name'):
                db_records.append({
                    'category': category,
                    'event_name': event_name,
                    'gender': 'Women',
                    'record_holder': women_data.get('name', ''),
                    'record_value': women_data.get('value', ''),
                    'instagram_handle': women_data.get('ig', '') if women_data.get('ig') != '—' else None,
                    'last_updated': datetime.now().strftime('%Y-%m-%d')
                })
                record_details.append(f"{event_name} (W): {women_data.get('name', '')} - {women_data.get('value', '')}")
        
        logger.info(f"Scraped {len(db_records)} record holder entries")
        
        # Log record details for GitHub Actions to parse
        if record_details:
            logger.info(f"RECORD_DETAILS: {' | '.join(record_details)}")
        
        return db_records
    
    def _extract_records_from_html(self, html_content: str) -> Optional[List[Dict]]:
        """Extract RECORDS array from HTML"""
        # Find the RECORDS JavaScript array
        pattern = r'const RECORDS = \[(.*?)\];'
        match = re.search(pattern, html_content, re.DOTALL)
        
        if not match:
            return None
        
        try:
            json_str = '[' + match.group(1) + ']'
            return json.loads(json_str)
        except json.JSONDecodeError as e:
            logger.error(f"Failed to parse RECORDS JSON: {e}")
            return None
    
    def run(self):
        """Main scraping workflow"""
        mode = "DRY RUN MODE" if self.dry_run else "LIVE MODE"
        logger.info(f"Starting Apex Record Holders Scraper - {mode}")
        
        if self.dry_run:
            print("\n" + "🔍 "*20)
            print("DRY RUN MODE ENABLED - No data will be inserted into the database")
            print("🔍 "*20 + "\n")
        
        # Scrape records
        records = self.scrape_records()
        
        if not records:
            logger.warning("No records found to insert")
            return {'total_records': 0, 'record_details': []}
        
        # Extract record details for notification
        record_details = []
        for record in records:
            detail = f"{record['event_name']} ({record['gender'][0]}): {record['record_holder']} - {record['record_value']}"
            record_details.append(detail)
        
        # Clear existing records and insert new ones
        if not self.dry_run:
            self.clear_existing_records()
        
        inserted = self.insert_records(records)
        
        if self.dry_run:
            print(f"\n✅ Dry run complete. Would have inserted {inserted} record holder entries.")
            return {'total_records': inserted, 'record_details': record_details}
        else:
            logger.info(f"Scraping complete. Total records inserted: {inserted}")
            return {'total_records': inserted, 'record_details': record_details}


def send_slack_notification(result: Dict, success: bool = True):
    """Send Slack notification with scraper results"""
    webhook_url = os.environ.get('SLACK_WEBHOOK_URL')
    if not webhook_url:
        logger.info("No SLACK_WEBHOOK_URL found, skipping notification")
        return
    
    total = result.get('total_records', 0)
    record_details = result.get('record_details', [])
    
    if success:
        details_text = '\n'.join(record_details[:10])  # Show first 10 records
        if len(record_details) > 10:
            details_text += f"\n... and {len(record_details) - 10} more"
        
        message = f":trophy: Apex Records Scraper\nInserted: {total} record holders\n\nRecords:\n{details_text}"
        color = "good"
    else:
        message = ":x: Apex Records Scraper\nStatus: Failed"
        color = "danger"
    
    payload = {
        "attachments": [{
            "color": color,
            "text": message,
            "footer": "GitHub Actions",
            "ts": int(datetime.now().timestamp())
        }]
    }
    
    try:
        response = requests.post(webhook_url, json=payload, timeout=10)
        response.raise_for_status()
        logger.info("Slack notification sent successfully")
    except requests.RequestException as e:
        logger.error(f"Failed to send Slack notification: {e}")


def main():
    """Main entry point"""
    # Load environment variables from .env file
    load_dotenv()
    
    parser = argparse.ArgumentParser(
        description='Scrape Apex Athlete record holders and insert into Supabase',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Normal mode - insert data into Supabase
  python scrape_record_holders.py
  
  # Dry run - see what would be inserted without writing to database
  python scrape_record_holders.py --dry-run
  
  # Dry run with short flag
  python scrape_record_holders.py -d

Environment Variables Required (except in dry-run mode):
  SUPABASE_URL - Your Supabase project URL
  SUPABASE_KEY - Your Supabase service role key
  SLACK_WEBHOOK_URL - Slack webhook for notifications (optional)
  
  You can set these in a .env file in the scripts/ directory:
    SUPABASE_URL=https://xxxxx.supabase.co
    SUPABASE_KEY=your-service-role-key
    SLACK_WEBHOOK_URL=https://hooks.slack.com/services/...
        """
    )
    
    parser.add_argument(
        '--dry-run', '-d',
        action='store_true',
        help='Run in dry-run mode: scrape and display records without inserting into database'
    )
    
    args = parser.parse_args()
    
    result = None
    try:
        # Run scraper
        scraper = ApexRecordHoldersScraper(dry_run=args.dry_run)
        result = scraper.run()
        
        # Send Slack notification (only in live mode)
        if not args.dry_run:
            send_slack_notification(result, success=True)
        
        logger.info("Script completed successfully")
        return 0
        
    except Exception as e:
        logger.error(f"Script failed: {e}", exc_info=True)
        
        # Send failure notification (only in live mode)
        if not args.dry_run:
            send_slack_notification(result or {}, success=False)
        
        return 1


if __name__ == "__main__":
    sys.exit(main())


#!/usr/bin/env python3
"""
Apex Athlete Results Scraper
Scrapes event results from apexathleteofficial.com and updates Supabase database

Setup and Usage:
----------------

# Create and activate virtual environment (recommended)
cd scripts && python3 -m venv venv && source venv/bin/activate && pip install -r requirements.txt

# Run in dry-run mode first to see what would be inserted
python scrape_apex_results.py --dry-run

# When ready, run for real
python scrape_apex_results.py

"""

import os
import sys
import logging
import argparse
import json
from datetime import datetime
from typing import List, Dict, Optional
import requests
from bs4 import BeautifulSoup
import time
from dotenv import load_dotenv

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


class ApexResultsScraper:
    """Scraper for Apex Athlete event results with Supabase integration"""
    
    BASE_URL = "https://apexathleteofficial.com"
    RESULTS_URL = f"{BASE_URL}/events/results/"
    TABLE_NAME = "apex_event_results"
    
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
                'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36',
                'apikey': self.supabase_key,
                'Authorization': f'Bearer {self.supabase_key}'
            })
    
    def fetch_page(self, url: str, retries: int = 3) -> Optional[BeautifulSoup]:
        """Fetch and parse a web page with retry logic"""
        for attempt in range(retries):
            try:
                logger.info(f"Fetching: {url} (attempt {attempt + 1}/{retries})")
                response = requests.get(url, headers={
                    'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36'
                }, timeout=30)
                response.raise_for_status()
                return BeautifulSoup(response.content, 'html.parser')
            except requests.RequestException as e:
                logger.error(f"Error fetching {url}: {e}")
                if attempt < retries - 1:
                    time.sleep(2 ** attempt)  # Exponential backoff
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
            else:
                raise ValueError(f"Unsupported HTTP method: {method}")
            
            response.raise_for_status()
            return response.json() if response.text else None
            
        except requests.RequestException as e:
            logger.error(f"Supabase request failed: {e}")
            if hasattr(e.response, 'text'):
                logger.error(f"Response: {e.response.text}")
            return None
    
    def event_exists(self, event_name: str) -> bool:
        """Check if an event already exists in the database"""
        if self.dry_run:
            return False  # In dry run, check all events
        
        params = {
            'event_name': f'eq.{event_name}',
            'select': 'event_name',
            'limit': 1
        }
        
        result = self.supabase_request('GET', self.TABLE_NAME, params=params)
        return result is not None and len(result) > 0
    
    def insert_results(self, results: List[Dict]) -> int:
        """Insert event results into Supabase"""
        if not results:
            return 0
        
        if self.dry_run:
            # In dry run mode, just print what would be inserted
            self._print_dry_run_results(results)
            return len(results)
        
        # Supabase will handle duplicates via UNIQUE constraint
        response = self.supabase_request('POST', self.TABLE_NAME, data=results)
        
        if response:
            inserted = len(response) if isinstance(response, list) else 1
            logger.info(f"Successfully inserted {inserted} results")
            return inserted
        else:
            logger.error("Failed to insert results")
            return 0
    
    def _print_dry_run_results(self, results: List[Dict]):
        """Print results in a formatted way for dry run mode"""
        print("\n" + "="*80)
        print(f"DRY RUN: Would insert {len(results)} results")
        print("="*80)
        
        # Group by event and gender
        events = {}
        for result in results:
            key = (result['event_name'], result['gender'])
            if key not in events:
                events[key] = []
            events[key].append(result)
        
        for (event_name, gender), event_results in events.items():
            print(f"\n📅 Event: {event_name}")
            print(f"👥 Gender: {gender.upper()}")
            print(f"📊 Date: {event_results[0]['date']}")
            print(f"🏆 Total Athletes: {len(event_results)}")
            print("\n" + "-"*80)
            print(f"{'Rank':<6} {'Name':<40} {'Score':<10}")
            print("-"*80)
            
            # Sort by rank
            sorted_results = sorted(event_results, key=lambda x: x['athlete_rank'])
            
            # Show first 10, then summary if more
            for i, result in enumerate(sorted_results[:10]):
                print(f"{result['athlete_rank']:<6} {result['athlete_name']:<40} {result['apex_score']:<10.2f}")
            
            if len(sorted_results) > 10:
                print(f"... and {len(sorted_results) - 10} more athletes")
        
        print("\n" + "="*80)
        print("DRY RUN COMPLETE - No data was inserted into the database")
        print("="*80 + "\n")
    
    def get_event_links(self) -> List[Dict[str, str]]:
        """Get all event links from the results page iframe"""
        # The actual results are in an iframe
        iframe_url = f"{self.BASE_URL}/apex_pages/apex_results_page/index.html"
        soup = self.fetch_page(iframe_url)
        if not soup:
            logger.error("Failed to fetch results iframe page")
            return []
        
        events = []
        
        # Find event cards
        event_cards = soup.find_all('a', class_='eventCard')
        
        for card in event_cards:
            # Get event title
            title_elem = card.find(class_='eventTitle')
            if not title_elem:
                continue
            
            event_name = title_elem.get_text(strip=True)
            
            # Get event date
            meta_elem = card.find(class_='meta')
            event_date = meta_elem.get_text(strip=True) if meta_elem else "Unknown Date"
            
            # Get the link to the data page (leaderboard.html)
            href = card.get('href', '')
            if not href:
                continue
            
            # Build full data.js URL (where the actual JSON data is)
            base_path = f"{self.BASE_URL}/apex_pages/apex_results_page"
            data_url = f"{base_path}/data.js"
            
            events.append({
                'name': event_name,
                'url': data_url,
                'date': event_date
            })
        
        logger.info(f"Found {len(events)} event(s)")
        return events
    
    def _extract_event_name_from_url(self, url: str) -> str:
        """Extract event name from URL"""
        parts = url.strip('/').split('/')
        if parts:
            return parts[-1].replace('-', ' ').title()
        return "Unknown Event"
    
    def scrape_event_results(self, event_url: str, event_name: str, event_date_str: str) -> List[Dict]:
        """Scrape results from a data.js file"""
        logger.info(f"Scraping event: {event_name}")
        
        # Fetch the JavaScript file
        try:
            response = requests.get(event_url, headers={
                'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36'
            }, timeout=30)
            response.raise_for_status()
            js_content = response.text
        except requests.RequestException as e:
            logger.error(f"Failed to fetch data.js: {e}")
            return []
        
        # Parse the JavaScript to extract JSON data
        results = []
        event_date = self._parse_event_date_from_string(event_date_str)
        
        # Extract MEN array
        men_data = self._extract_json_from_js(js_content, 'const MEN = ')
        if men_data:
            for athlete in men_data:
                if athlete.get('apexScore', 0) > 0:  # Skip athletes with 0 scores
                    results.append(self._parse_athlete_data(athlete, event_name, event_date, 'Men'))
        
        # Extract WOMEN array
        women_data = self._extract_json_from_js(js_content, 'const WOMEN = ')
        if women_data:
            for athlete in women_data:
                if athlete.get('apexScore', 0) > 0:  # Skip athletes with 0 scores
                    results.append(self._parse_athlete_data(athlete, event_name, event_date, 'Women'))
        
        logger.info(f"Scraped {len(results)} total results for {event_name}")
        return results
    
    def _parse_athlete_data(self, athlete: Dict, event_name: str, event_date: str, gender: str) -> Dict:
        """Parse athlete data and extract all fields"""
        return {
            'event_name': event_name,
            'date': event_date,
            'athlete_rank': athlete.get('rank'),
            'athlete_name': athlete.get('name'),
            'apex_score': float(athlete.get('apexScore', 0)),
            'gender': gender,
            'speed_score': athlete.get('speedScore'),
            'power_score': athlete.get('powerScore'),
            'strength_score': athlete.get('strengthScore'),
            'endurance_score': athlete.get('enduranceScore'),
            'fast_forty': athlete.get('fastForty'),
            'max_toss': athlete.get('maxToss'),
            'the_vertical': athlete.get('theVert'),
            'the_broad': athlete.get('theBroad'),
            'the_push': athlete.get('thePush'),
            'the_pull': athlete.get('thePull'),
            'the_mile': athlete.get('theMile'),
            'instagram_handle': athlete.get('instagram', '@handle') if athlete.get('instagram') != '@handle' else None
        }
    
    def _extract_json_from_js(self, js_content: str, prefix: str) -> Optional[List[Dict]]:
        """Extract JSON array from JavaScript variable declaration"""
        import json
        import re
        
        # Find the variable declaration
        pattern = re.escape(prefix) + r'\[(.*?)\];'
        match = re.search(pattern, js_content, re.DOTALL)
        
        if not match:
            return None
        
        try:
            json_str = '[' + match.group(1) + ']'
            return json.loads(json_str)
        except json.JSONDecodeError as e:
            logger.error(f"Failed to parse JSON: {e}")
            return None
    
    def _parse_event_date_from_string(self, date_str: str) -> str:
        """Parse event date string like 'Oct 26, 2025 • Austin, TX' to YYYY-MM-DD"""
        # Extract just the date part (before •)
        date_part = date_str.split('•')[0].strip()
        
        formats = [
            '%b %d, %Y',  # Oct 26, 2025
            '%B %d, %Y',  # October 26, 2025
        ]
        
        for fmt in formats:
            try:
                dt = datetime.strptime(date_part, fmt)
                return dt.strftime('%Y-%m-%d')
            except ValueError:
                continue
        
        # Default to current date if parsing fails
        return datetime.now().strftime('%Y-%m-%d')
    
    def _extract_event_date(self, soup: BeautifulSoup) -> str:
        """Extract event date from page"""
        # Look for common date patterns
        date_patterns = [
            ('time', {'class': lambda x: x and 'date' in x.lower()}),
            ('span', {'class': lambda x: x and 'date' in x.lower()}),
            ('div', {'class': lambda x: x and 'date' in x.lower()}),
        ]
        
        for tag, attrs in date_patterns:
            date_elem = soup.find(tag, attrs)
            if date_elem:
                date_text = date_elem.get_text(strip=True)
                parsed_date = self._parse_date(date_text)
                if parsed_date:
                    return parsed_date
        
        # Default to current date if not found
        return datetime.now().strftime('%Y-%m-%d')
    
    def _parse_date(self, date_text: str) -> Optional[str]:
        """Parse date string to YYYY-MM-DD format"""
        formats = [
            '%B %d, %Y',  # January 1, 2024
            '%b %d, %Y',  # Jan 1, 2024
            '%Y-%m-%d',   # 2024-01-01
            '%m/%d/%Y',   # 01/01/2024
            '%d/%m/%Y',   # 01/01/2024
        ]
        
        for fmt in formats:
            try:
                dt = datetime.strptime(date_text.strip(), fmt)
                return dt.strftime('%Y-%m-%d')
            except ValueError:
                continue
        
        return None
    
    def _scrape_gender_results(self, soup: BeautifulSoup, event_name: str, 
                               event_date: str, gender: str) -> List[Dict]:
        """Scrape results for a specific gender"""
        results = []
        
        # Look for results table or list
        tables = soup.find_all('table')
        
        for table in tables:
            # Check if this table is for the correct gender
            table_context = str(table.parent)
            if gender.lower() not in table_context.lower():
                continue
            
            rows = table.find_all('tr')[1:]  # Skip header row
            
            for row in rows:
                cells = row.find_all(['td', 'th'])
                if len(cells) >= 3:  # At least rank, name, score
                    try:
                        rank = self._clean_rank(cells[0].get_text(strip=True))
                        name = cells[1].get_text(strip=True)
                        score = self._clean_score(cells[2].get_text(strip=True))
                        
                        if rank and name and score:
                            results.append({
                                'event_name': event_name,
                                'date': event_date,
                                'athlete_rank': rank,
                                'athlete_name': name,
                                'apex_score': score,
                                'gender': gender
                            })
                    except Exception as e:
                        logger.warning(f"Error parsing row: {e}")
                        continue
        
        # Alternative: Look for div-based layouts
        if not results:
            results = self._scrape_div_based_results(soup, event_name, event_date, gender)
        
        return results
    
    def _scrape_div_based_results(self, soup: BeautifulSoup, event_name: str,
                                  event_date: str, gender: str) -> List[Dict]:
        """Scrape results from div-based layout"""
        results = []
        
        # Look for result containers
        result_divs = soup.find_all('div', class_=lambda x: x and ('result' in x.lower() or 'athlete' in x.lower()))
        
        for div in result_divs:
            # Check for gender context
            if gender.lower() not in str(div.parent).lower():
                continue
            
            # Extract rank, name, score from nested elements
            rank_elem = div.find(class_=lambda x: x and 'rank' in x.lower())
            name_elem = div.find(class_=lambda x: x and 'name' in x.lower())
            score_elem = div.find(class_=lambda x: x and 'score' in x.lower())
            
            if rank_elem and name_elem and score_elem:
                try:
                    rank = self._clean_rank(rank_elem.get_text(strip=True))
                    name = name_elem.get_text(strip=True)
                    score = self._clean_score(score_elem.get_text(strip=True))
                    
                    if rank and name and score:
                        results.append({
                            'event_name': event_name,
                            'date': event_date,
                            'athlete_rank': rank,
                            'athlete_name': name,
                            'apex_score': score,
                            'gender': gender
                        })
                except Exception as e:
                    logger.warning(f"Error parsing div: {e}")
                    continue
        
        return results
    
    def _clean_rank(self, rank_text: str) -> Optional[int]:
        """Clean and convert rank to integer"""
        import re
        cleaned = re.sub(r'[^\d]', '', rank_text)
        try:
            return int(cleaned) if cleaned else None
        except ValueError:
            return None
    
    def _clean_score(self, score_text: str) -> Optional[float]:
        """Clean and convert score to float"""
        import re
        cleaned = re.sub(r'[^\d.]', '', score_text)
        try:
            return float(cleaned) if cleaned else None
        except ValueError:
            return None
    
    def run(self):
        """Main scraping workflow"""
        mode = "DRY RUN MODE" if self.dry_run else "LIVE MODE"
        logger.info(f"Starting Apex Results Scraper - {mode}")
        
        if self.dry_run:
            print("\n" + "🔍 "*20)
            print("DRY RUN MODE ENABLED - No data will be inserted into the database")
            print("🔍 "*20 + "\n")
        
        # Get all event links
        events = self.get_event_links()
        
        if not events:
            logger.warning("No events found to scrape")
            return {'total_results': 0, 'event_names': 'No events found'}
        
        # Process each event
        total_new_results = 0
        processed_events = []
        
        for event in events:
            event_name = event['name']
            event_url = event['url']
            event_date = event.get('date', '')
            
            # Check if event already exists in database
            if self.event_exists(event_name):
                logger.info(f"Event '{event_name}' already in database, skipping")
                continue
            
            # Scrape event results
            results = self.scrape_event_results(event_url, event_name, event_date)
            
            if results:
                # Insert results into database (or just print in dry run)
                inserted = self.insert_results(results)
                total_new_results += inserted
                if not self.dry_run:
                    logger.info(f"Inserted {inserted} results for '{event_name}'")
                    processed_events.append(event_name)
            
            # Be polite - don't hammer the server
            time.sleep(2)
        
        if self.dry_run:
            print(f"\n✅ Dry run complete. Would have inserted {total_new_results} total results.")
            return {'total_results': total_new_results, 'event_names': ', '.join(processed_events) if processed_events else 'No new events'}
        else:
            logger.info(f"Scraping complete. Total new results: {total_new_results}")
            return {'total_results': total_new_results, 'event_names': ', '.join(processed_events) if processed_events else 'No new events'}


def send_slack_notification(result: Dict, success: bool = True):
    """Send Slack notification with scraper results"""
    webhook_url = os.environ.get('SLACK_WEBHOOK_URL')
    if not webhook_url:
        logger.info("No SLACK_WEBHOOK_URL found, skipping notification")
        return
    
    total = result.get('total_results', 0)
    event_names = result.get('event_names', 'No events')
    
    if success:
        if total > 0:
            message = f":white_check_mark: Apex Events Scraper\nInserted: {total} results\nEvents: {event_names}"
        else:
            message = f":white_check_mark: Apex Events Scraper\nNo new events to process"
        color = "good"
    else:
        message = ":x: Apex Events Scraper\nStatus: Failed"
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
        description='Scrape Apex Athlete event results and insert into Supabase',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Normal mode - insert data into Supabase
  python scrape_apex_results.py
  
  # Dry run - see what would be inserted without writing to database
  python scrape_apex_results.py --dry-run
  
  # Dry run with short flag
  python scrape_apex_results.py -d

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
        help='Run in dry-run mode: scrape and display results without inserting into database'
    )
    
    args = parser.parse_args()
    
    result = None
    try:
        # Run scraper
        scraper = ApexResultsScraper(dry_run=args.dry_run)
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

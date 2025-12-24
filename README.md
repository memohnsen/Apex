# Apex Performance Tracker

A SwiftUI iOS application for tracking and analyzing athlete performance data from Apex competitions. The app provides comprehensive views of athlete scores, event results, leaderboards, and record holders.

[![Watch the screen recording of the app in action!](https://youtube.com/shorts/Y5pV0EAWqjc)](https://youtube.com/shorts/Y5pV0EAWqjc)

## Features

- **Athlete Search**: Browse and filter athletes by gender and competition
- **Leaderboard**: View top performers ranked by Apex Score
- **Event Results**: See results for specific competitions
- **Record Holders**: Track record holders for each event
- **Score Calculator**: Calculate Apex Scores based on performance metrics
- **Athlete Details**: Comprehensive breakdown of individual athlete performance

## Project Structure

```
Apex/
├── ApexApp.swift                 # Main app entry point
├── Backend/
│   └── Supabase/
│       ├── Supabase.swift        # Supabase client configuration
│       ├── FetchResults.swift    
│       └── FetchRecords.swift    
├── Frontend/
│   ├── Components/
│   │   ├── Assets.xcassets/      # Image assets (speed, power, strength, endurance icons)
│   │   ├── CardStyling.swift     # Reusable card styling modifier
│   │   ├── Colors.swift          # Color schemes and gradients
│   │   ├── CustomProgressBar.swift # Progress bar component
│   ├── Logic/
│   │   ├── DateFormatter.swift   # Date formatting utilities
│   │   └── ScoreCalculation.swift # Apex Score calculation logic
│   └── Views/
│       ├── Screens/
│       │   ├── AthleteDetailsView.swift  # Individual athlete performance
│       │   ├── EventResultsView.swift    # Competition-specific results
│       │   ├── RecordsView.swift         # Record holder display
│       │   └── ScoreResultsView.swift    # Score calculation results
│       └── Tabs/
│           ├── HomeView.swift            # Home dashboard
│           ├── AthleteSearchView.swift   # Searchable athlete list
│           ├── LeaderboardView.swift     # Overall leaderboard
│           └── ScoreCalculatorView.swift # Score calculation tool
└── Info.plist

scripts/
├── scrape_apex_results.py        # Python script to scrape competition results
├── scrape_record_holders.py      # Python script to scrape record data
└── requirements.txt              # Python dependencies

```

## Data Models

### Athletes
- `id`: Unique identifier
- `athlete_name`: Athlete's full name
- `apex_score`: Overall Apex Score (optional)

### ApexResults
Complete competition results including:
- Athlete information (name, gender, Instagram handle)
- Event details (name, date, location)
- Performance metrics for all events
- Category scores (speed, power, strength, endurance)
- Overall Apex Score and ranking

### ApexRecords
Record holder information:
- Event name
- Record value
- Record holder name
- Instagram handle
- Gender category

### Events
- Event name
- Date

## Navigation & Routing

The app uses SwiftUI's `NavigationStack` for navigation with multiple entry points to the `AthleteDetailsView`:

### Route 1: From Athlete Search
```swift
AthleteSearchView → AthleteDetailsView(athlete: Athletes)
```
- Passes an `Athletes` object with athlete name
- Fetches full performance data via API call

### Route 2: From Leaderboard
```swift
LeaderboardView → AthleteDetailsView(eventResults: [ApexResults])
```
- Passes specific athlete's result data directly
- No additional API call needed

### Route 3: From Event Results
```swift
EventResultsView → AthleteDetailsView(eventResults: [ApexResults])
```
- Passes specific athlete's result data directly
- No additional API call needed

### Route 4: From Records
```swift
RecordsView → AthleteDetailsView(athlete: Athletes)
```
- Creates `Athletes` object from record holder name
- Fetches full performance data via API call

### Data Source Resolution
`AthleteDetailsView` uses a computed property `displayResults` to determine which data source to use:
- If `eventResults` is provided, use it directly (no API call)
- Otherwise, fetch data using the athlete name from the `athlete` parameter

## Score Calculation

The Apex Score is calculated based on performance across seven events, grouped into four categories:

### Categories & Events

**Speed (250 points max)**
- Fast Forty: 40-yard dash time

**Power (250 points max)**
- Max Toss: Medicine ball throw distance
- The Vertical: Vertical jump height
- The Broad: Broad jump distance

**Strength (250 points max)**
- The Push: Push-up repetitions
- The Pull: Pull-up repetitions

**Endurance (250 points max)**
- The Mile: One-mile run time

### Calculation Method

Each event is scored on a scale where:
- **Maximum performance** = Maximum points for that event
- **Minimum performance** = 0 points
- **Linear interpolation** between min and max

#### Individual Event Scoring

**Speed Events (250 points)**
- Faster times = Higher scores
- Formula: Interpolate between min time (250 pts) and max time (0 pts)

**Power Events (83.33 points each)**
- Greater distance/height = Higher scores
- Three events contribute to 250 total power points

**Strength Events (125 points each)**
- More repetitions = Higher scores
- Two events contribute to 250 total strength points

**Endurance Events (250 points)**
- Faster time = Higher scores
- Formula: Interpolate between min time (250 pts) and max time (0 pts)

#### Total Apex Score
Sum of all category scores with a maximum of 1000 points.

### Score Ranges & Categories

The app uses color-coded categories for score visualization:
- **Elite**: 800-1000 points
- **Advanced**: 600-799 points
- **Intermediate**: 400-599 points
- **Beginner**: 0-399 points

## Backend Integration

### Supabase Configuration

The app connects to Supabase for data storage and retrieval. Configuration is managed through:
- `Config.xcconfig`: Stores API URL and anonymous key
- `Supabase.swift`: Initializes Supabase client

### API Functions

**fetchResults(gender: String)**
- Fetches leaderboard results filtered by gender
- Returns athletes sorted by Apex Score

**fetchResultsByEvent(gender: String, event: String)**
- Fetches results for a specific competition
- Filtered by gender and event name

**fetchAthletes(gender: String)**
- Fetches list of all athletes
- Supports "All" option to retrieve all genders
- Returns athlete names and scores for filtering/sorting

**fetchSpecificAthlete(name: String)**
- Fetches complete performance data for a single athlete
- Used when navigating from athlete search or records

**fetchEvents()**
- Retrieves list of all competitions

**fetchRecords(gender: String)**
- Fetches record holders for each event
- Filtered by gender category

## Filtering & Sorting

### Athlete Search Filters

**Gender Filter**
- Options: All, Men, Women
- Default: All
- Backend handles filtering (omits filter when "All" selected)

**Competition Filter**
- Options: All, [List of Events]
- Default: All
- Currently displays all athletes (event-specific filtering planned)

**Sort Options**
- Name: A-Z (alphabetical ascending)
- Name: Z-A (alphabetical descending)
- Score: 0-1000 (score ascending)
- Score: 1000-0 (score descending)

### Implementation
Filtering and sorting use computed properties:
1. `filteredAthletes`: Applies gender/event filters
2. `sortedAthletes`: Sorts filtered results based on selected criteria

## Data Scraping

Python scripts in the `scripts/` directory automate data collection:

### scrape_apex_results.py
- Scrapes competition results from Apex website
- Parses athlete performance data
- Uploads to Supabase database

### scrape_record_holders.py
- Scrapes record holder information
- Updates record database

### Setup
```bash
cd scripts
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

## Configuration

### Required Setup

1. Create `Config.xcconfig` in project root:
```
SUPABASE_URL = your_supabase_url
SUPABASE_ANON_KEY = your_supabase_anon_key
```

2. Add to `.gitignore`:
```
Config.xcconfig
```

3. Configure Supabase tables:
- `apex_event_results`: Competition results
- `apex_records`: Record holders
- `events`: Competition information

## Requirements

- iOS 26.0+
- Xcode 15.0+
- Swift 5.9+
- Supabase account

## Dependencies

- [Supabase Swift Client](https://github.com/supabase/supabase-swift)

## Installation

1. Clone the repository
```bash
git clone https://github.com/yourusername/apex.git
cd apex
```

2. Install dependencies via Swift Package Manager (handled by Xcode)

3. Configure `Config.xcconfig` with your Supabase credentials

4. Open `Apex.xcodeproj` in Xcode

5. Build and run the project

## Future Enhancements

- Event-specific filtering in athlete search
- Offline data caching
- Performance trend tracking over multiple competitions
- Social sharing of scores
- Push notifications for new records


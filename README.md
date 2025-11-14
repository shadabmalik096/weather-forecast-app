# Weather Forecast Application

A Ruby on Rails application that retrieves and displays weather forecast data with 30-minute caching.

## Features

- Address input with geocoding to coordinates
- Current temperature display
- High/Low temperatures and extended 7-day forecast
- 30-minute cache by zip code
- Cache indicator to show if data is from cache
- Clean, functional UI

## Setup Instructions

### Prerequisites

- Ruby 3.0+ 
- Rails 7.0+
- SQLite3 (default) or PostgreSQL

### Installation

1. **Clone the repository**
```bash
git clone <your-repo-url>
cd weather-forecast-app
```

2. **Install dependencies**
```bash
bundle install
```

3. **Setup database**
```bash
rails db:create
rails db:migrate
```

4. **Start the server**
```bash
rails server
```

5. **Visit the application**
```
http://localhost:3000
```

## API Usage

This application uses:
- **Geocoding API**: [Nominatim OpenStreetMap](https://nominatim.openstreetmap.org/) - Free, no API key required
- **Weather API**: [Open-Meteo](https://open-meteo.com/) - Free, no API key required

Both APIs are free and don't require registration, making setup simple.

## Technical Implementation

### Caching Strategy

- Uses Rails cache store (memory by default)
- Cache key format: `weather_forecast_#{zip_code}`
- 30-minute TTL (Time To Live)
- Cache hit/miss indicator displayed to user

### Architecture

```
app/
├── controllers/
│   └── forecasts_controller.rb    # Handles requests
├── services/
│   ├── geocoding_service.rb       # Address → Coordinates
│   └── weather_service.rb         # Coordinates → Forecast
├── views/
│   └── forecasts/
│       ├── index.html.erb         # Input form
│       └── show.html.erb          # Forecast display
└── models/
    └── forecast.rb                 # Data model (optional)
```

## Usage

1. Enter any US address (e.g., "1 Infinite Loop, Cupertino, CA 95014")
2. View current temperature, high/low, and 7-day forecast
3. Cache indicator shows if data was retrieved from cache
4. Subsequent requests within 30 minutes use cached data

## Testing

```bash
# Run tests
rails test

# Run with coverage
rails test:system
```

## Environment Variables (Optional)

If you want to use alternative APIs:

```bash
# .env
GEOCODING_API_KEY=your_key_here
WEATHER_API_KEY=your_key_here
```

## Deployment

Ready for deployment to:
- Heroku
- Railway
- Render
- Any Rails-compatible platform

For production, consider:
- Using Redis for caching (`gem 'redis'`)
- Setting up proper error handling
- Adding rate limiting

## License

MIT
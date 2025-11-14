class ForecastsController < ApplicationController
  def index
    # Display the input form
  end

  def create
    address = params[:address]

    if address.blank?
      flash[:error] = "Please enter an address"
      redirect_to root_path and return
    end

    # Geocode the address
    binding.pry
    geocoding_service = GeocodingService.new
    location = geocoding_service.geocode(address)

    if location.nil?
      flash[:error] = "Could not find location. Please try a different address."
      redirect_to root_path and return
    end

    # Extract zip code for caching
    zip_code = "110094" # extract_zip_code(address) || location[:zip_code] || "unknown"

    # Check cache first
    cache_key = "weather_forecast_#{zip_code}"
    cached_data = Rails.cache.read(cache_key)

    if cached_data
      @forecast_data = cached_data
      @from_cache = true
      @cache_timestamp = cached_data[:cached_at]
    else
      # Fetch fresh weather data
      weather_service = WeatherService.new
      forecast_data = weather_service.get_forecast(location[:lat], location[:lon])

      if forecast_data.nil?
        flash[:error] = "Could not retrieve weather data. Please try again."
        redirect_to root_path and return
      end

      # Add metadata
      forecast_data[:location_name] = location[:display_name]
      forecast_data[:cached_at] = Time.current

      # Cache for 30 minutes
      # Rails.cache.write(cache_key, forecast_data, expires_in: 30.minutes)

      @forecast_data = forecast_data
      @from_cache = false
    end

    @address = address
    @zip_code = zip_code

    render :show
  end

  def show
    # Shows cached or fresh forecast data
  end

  private

  def extract_zip_code(address)
    # Simple regex to extract 5-digit zip code
    match = address.match(/\b\d{5}\b/)
    match ? match[0] : nil
  end
end

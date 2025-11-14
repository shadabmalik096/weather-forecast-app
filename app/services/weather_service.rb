require "httparty"

class WeatherService
  include HTTParty
  base_uri "api.open-meteo.com"

  def get_forecast(latitude, longitude)
    response = self.class.get("/v1/forecast", query: {
      latitude: latitude,
      longitude: longitude,
      current: "temperature_2m,weather_code",
      daily: "temperature_2m_max,temperature_2m_min,weather_code",
      temperature_unit: "fahrenheit",
      timezone: "America/Los_Angeles"
    })

    return nil unless response.success?

    data = response.parsed_response

    {
      current_temp: data.dig("current", "temperature_2m"),
      current_weather_code: data.dig("current", "weather_code"),
      daily_forecast: parse_daily_forecast(data["daily"])
    }
  rescue StandardError => e
    Rails.logger.error "Weather API error: #{e.message}"
    nil
  end

  private

  def parse_daily_forecast(daily_data)
    return [] unless daily_data

    dates = daily_data["time"]
    max_temps = daily_data["temperature_2m_max"]
    min_temps = daily_data["temperature_2m_min"]
    weather_codes = daily_data["weather_code"]

    dates.each_with_index.map do |date, index|
      {
        date: Date.parse(date),
        high: max_temps[index],
        low: min_temps[index],
        weather_code: weather_codes[index],
        description: weather_description(weather_codes[index])
      }
    end
  end

  def weather_description(code)
    # WMO Weather interpretation codes
    case code
    when 0 then "Clear sky"
    when 1, 2, 3 then "Partly cloudy"
    when 45, 48 then "Foggy"
    when 51, 53, 55 then "Drizzle"
    when 61, 63, 65 then "Rain"
    when 71, 73, 75 then "Snow"
    when 77 then "Snow grains"
    when 80, 81, 82 then "Rain showers"
    when 85, 86 then "Snow showers"
    when 95 then "Thunderstorm"
    when 96, 99 then "Thunderstorm with hail"
    else "Unknown"
    end
  end
end

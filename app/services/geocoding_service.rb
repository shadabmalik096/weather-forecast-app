require "httparty"

class GeocodingService
  include HTTParty
  base_uri "https://nominatim.openstreetmap.org"

  def initialize
    @options = {
      headers: {
        "User-Agent" => "WeatherForecastApp/1.0"
      },
      timeout: 10
    }
    @options[:verify] = false if Rails.env.development?
  end

  def geocode(address)
    response = self.class.get("/search", @options.merge(
      query: {
        q: address,
        format: "json",
        limit: 1,
        addressdetails: 1
      }
    ))

    return nil unless response.success? && response.parsed_response.any?

    result = response.parsed_response.first
    {
      lat: result["lat"].to_f,
      lon: result["lon"].to_f,
      display_name: result["display_name"],
      zip_code: result.dig("address", "postcode")
    }
  rescue StandardError => e
    Rails.logger.error "Geocoding error: #{e.message}"
    nil
  end
end

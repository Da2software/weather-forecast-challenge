require 'uri'

module Apis
    class Weather
        attr_reader :day, :min, :max, :night, :eve, :morn
    
        def initialize(json)
        @day = json["day"]
        @min = json["min"]
        @max = json["max"]
        @night = json["night"]
        @eve = json["eve"]
        @morn = json["morn"]
        end
    end
    class City
        attr_reader :id, :city_slug, :display, :state, :country, :lat, :long, :type
        def initialize(json)
            @id = json["id"]
            @city_slug = json["city_slug"]
            @display = json["display"]
            @state = json["state"]
            @country = json["country"]
            @lat = json["lat"]
            @long = json["long"]
            @type = json["result_type"] || ""
        end 
    end
    class CityWeathers    
        def initialize(city, weathers)
            @city = city
            @weathers = weathers
        end
    
        def get_json
            {
                "city_name": @city.display,
                "weathers": @weathers.map { |weather| { "min" => weather.min, "max" => weather.max } }
            }
        end
    end
    class CitiesAPI
        def initialize()
            @base_url = ENV['API_CITIES']
            @headers = {
                "User-Agent": ENV['API_AGENT']
            }
        end

        def get_cities(query)
            query = URI::encode_www_form_component(query)
            options = {
                query: {
                    q: query,
                },
                headers: {
                    "User-Agent": ENV['API_AGENT']
                }
            }
            res = HTTParty.get("#{@base_url}", options=options)
            if res.code == 201
                cities = JSON.parse(res.body)
                res = cities.map { |item| City.new(item) }
                return res
            else
                puts "Error in get_cities: #{res.code}"
                return nil
            end
        end
    end
    class WeatherAPI
        def initialize()
            @base_url = ENV['API_WEATHER']
            @api_key = ENV['API_KEY']
        end

        def get_forcast(city)
            options = {
                query: {
                    lat: city.lat,
                    lon: city.long,
                    appid: @api_key,
                    exclude: "minutely,hourly,alerts",
                    units: "metric"
                },
                headers: {
                    "User-Agent": ENV['API_AGENT']
                }
            }
            c = CityWeathers.new(nil, nil)
            res = HTTParty.get("#{@base_url}", options=options)
            if res and res.code == 200
                wheaters = JSON.parse(res.body)
                if !wheaters
                    return CityWeathers.new(city, [])
                end
                res = wheaters.map { |item| CityWeathers.new(city, item) }
                return res
            else
                puts "Error get_forcast: #{res.code}"
                return nil
            end
        end
    end
end
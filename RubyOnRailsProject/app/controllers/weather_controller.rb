require './app/services/apis'
require 'concurrent'

class WeatherController < ApplicationController
    def fetch_data(cities)
        results = []
        w_api = Apis::WeatherAPI.new()
        executor = Concurrent::FixedThreadPool.new(cities.size)
        processes = cities.each do |city|
            Concurrent::Future.execute(executor: executor) do
                w_api.get_forcast(city)
            end
        end
        processes.each do |process|
            if (process)
                results << process
            end
        end
        return results
    end
    def forecast
        city_name = params[:city_name]
        
        c_api = Apis::CitiesAPI.new()
        cities = c_api.get_cities(city_name)
        if (!cities)
            return render json: {message: "something went wrong"}, status: :forbidden
        else
            cities_weathers = fetch_data(cities)
            results = []
            cities.each do |item|
                results << item.get_json()
            end
            puts "Res not in time"
            render json: results, status: :ok
        end
    end
end

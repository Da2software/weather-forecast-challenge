require './app/services/apis'
require 'concurrent'

class WeatherController < ApplicationController
    def fetch_data(cities)
        # I got block by this async call, then I will avoid it for now
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
            results = []
            w_api = Apis::WeatherAPI.new()

            cities.each do |city|
                w_res = w_api.get_forcast(city)
                
                results << w_res
            end
            # cities_weathers = fetch_data(cities)
            # results = []
            # cities.each do |item|
            #     results << item.get_json()
            # end
            # puts "Res not in time"
            render json: results, status: :ok
        end
    end
end

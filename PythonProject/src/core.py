from src.apis import OpenWeatherAPI, ReservamosAPI, CityWeathers
import asyncio
from concurrent.futures import ThreadPoolExecutor


class WeatherCore:
    def __init__(self):
        self._weather_api = OpenWeatherAPI()
        self._reservamosA_api = ReservamosAPI()

    async def fetch_weather(self, city):
        loop = asyncio.get_event_loop()
        weathers = await loop.run_in_executor(None,
                                              self._weather_api.get_forecast,
                                              city)
        return weathers

    async def get_7days(self, city_name: str):
        cities = self._reservamosA_api.get_cities(city_name)
        reqs = [self.fetch_weather(city) for city in cities]
        results = await asyncio.gather(*reqs)
        json_res = []
        for res in results:
            if not res:
                json_res.append(None)
                continue
            city_weather: CityWeathers = res
            json_res.append(city_weather.get_json())
        return json_res

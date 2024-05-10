import requests
from typing import List
from src.utils import EnvManager
import urllib.parse

env = EnvManager()


class City:
    def __init__(self, json: dict):
        self.id: str = json.get("id", None)
        self.city_slug: str = json.get("city_slug", None)
        self.display: str = json.get("display", None)
        self.state: str = json.get("state", None)
        self.country: str = json.get("country", None)
        self.lat: str = json.get("lat", None)
        self.long: str = json.get("long", None)
        self.type: str = json.get("result_type", "")

    def __str__(self):
        return f"({self.id}, {self.display}, {self.state}, {self.country})"

    def __repr__(self):
        return f"({self.id}, {self.display}, {self.state}, {self.country})"


class Weather:
    def __init__(self, json: dict):
        self.day = json.get("day", None),
        self.min = json.get("min", None),
        self.max = json.get("max", None),
        self.night = json.get("night", None),
        self.eve = json.get("eve", None),
        self.morn = json.get("morn", None)

    def __str__(self):
        return f"({self.min}, {self.max})"

    def __repr__(self):
        return f"({self.min}, {self.max})"


class CityWeathers:
    def __init__(self, city: City, weathers: List[Weather]):
        self._city = city
        self._weathers = weathers

    def get_json(self) -> dict:
        res = {
            "city_name": self._city.display,
            "weathers": []
        }
        for weather in self._weathers:
            w = {
                "min": weather.min[0],
                "max": weather.max[0]
            }
            res['weathers'].append(w)
        return res


class OpenWeatherAPI:
    def __init__(self) -> None:
        self._base_url: str = env.get_env('api_weather')
        self._api_key = env.get_env('api_key')
        self.headers = {
            'User-Agent': env.get_env("api_agent"),
        }

    def get_forecast(self, city: City):
        paramas = {
            "lat": city.lat,
            "lon": city.long,
            "appid": self._api_key,
            "exclude": "minutely,hourly,alerts",
            "units": "metric"
        }
        res = requests.get(self._base_url + "/onecall", params=paramas,
                           headers=self.headers)

        if res.status_code == 200:
            data = res.json()
            weathers = [Weather(item.get("temp", {})) for item in
                        data.get("daily", [])]
            return CityWeathers(city, weathers)
        else:
            print("Error:", res.status_code)
            return None


class CitiesAPI:
    def __init__(self) -> None:
        self._base_url: str = env.get_env('api_cities')
        self.headers = {
            'User-Agent': env.get_env("api_agent"),
        }

    def get_cities(self, query: str):
        query = urllib.parse.quote(query)
        res = requests.get(self._base_url + "/places",
                           params={"q": query},
                           headers=self.headers)
        if res.status_code == 201:
            cities = res.json()
            return [City(item) for item in cities]
        else:
            print("Error:", res.status_code)
            return None

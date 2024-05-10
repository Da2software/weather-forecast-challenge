from fastapi import FastAPI
from src.core import WeatherCore
app = FastAPI()


@app.get("/weather_days/")
async def weather_days(city_name: str):
    json_res = await WeatherCore().get_7days(city_name)
    return json_res

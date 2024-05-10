from fastapi import FastAPI
from src.core import WeatherCore
app = FastAPI()


@app.get("/weather_days/")
async def weather_days(city_name: str):
    await WeatherCore().get_7days(city_name)
    return {"message": "Hello World"}

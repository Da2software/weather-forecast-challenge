# Requirements

- python 3.10.10+

# Running Project

- ```python -m venv venv```
- ```pip install -r requirements.txt```
- ```cp env.cfg.template env.cfg``` and edit the environment values in the
  env.cfg
- ```fastapi dev main.py```

# Endpoint Example
```http://localhost:8000/weather_days?city_name=mon```
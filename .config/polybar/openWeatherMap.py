#!/usr/bin/python

# OpenWeatherMap service provides open weather data for more than 200,000
# cities and any geo location that is available on our website and through API.

import sys
import math
import requests
from dotenv import load_dotenv
from pathlib import Path
import os
import json

env_path = os.getenv("HOME") + "/.env"
load_dotenv(env_path)

base_url = "http://api.openweathermap.org/data/2.5/weather"
api_key = os.getenv(
    "WEATHER_API"
)  # << Get your API key (APPID) here: http://openweathermap.org/appid

icons = {
    "01d": " ",
    "01n": " ",
    "02d": " ",
    "03d": " ",
    "03n": " ",
    "04d": " ",
    "04n": " ",
    "02n": "  ",
    "09": " ",
    "10d": " ",
    "10n": " ",
    "10n 11n": " ",
    "10d 11d": " ",
    "11": "",
    "13d": " ",
    "13n": " ",
    "50d": " ",
    "50n": " ",
    "04d": " ",
}


data = {}


def check_internet_conn() -> bool:
    try:
        r = requests.get("https://google.com")
        code = r.status_code
        if code == 200:
            return True
        else:
            return False
    except requests.exceptions.RequestException as error:
        data["error"] = "No Internet!"
        print(json.dumps(data["error"]))
        exit(-1)


def get_temperature(city: str):
    if check_internet_conn():
        query = base_url + "?q=%s&units=metric&APPID=%s" % (city, api_key)
        try:
            response = requests.get(query)
            # print("[%s] %s" % (response.status_code, response.url))
            if response.status_code != 200:
                response = "N/A"
                return response
            else:
                weather_data = response.json()
                return weather_data
        except requests.exceptions.RequestException as error:
            print(error)
    else:
        data["error"] = "No Internet!"
        print(json.dumps(data["error"]))


def main():
    location = get_temperature("Toenisvorst")
    code = location["weather"][0]["icon"]
    icon = icons[code]
    data["text"] = icon + str(math.ceil(location["main"]["temp"])) + "°C"
    print(data["text"])


if __name__ == "__main__":
    main()

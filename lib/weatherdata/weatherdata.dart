import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';

num kelvinToCelcius(num tempInKelvin) {
  return tempInKelvin - 273.15;
}

class Weather {
  num id;
  String main;
  String description;
  String icon;

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(description: json["description"], icon: json["icon"], id: json["id"], main: json["main"]);
  }

  Weather({required this.description, required this.icon, required this.id, required this.main});
}

class WeatherParameter {
  num dateTime;
  num? sunrise;
  num? sunset;
  num temp;
  num feelsLike;
  num pressure;
  num humidity;
  num uvi;
  num visibility;
  num windSpeed;
  num windDeg;
  List<Weather> weather;

  factory WeatherParameter.fromJson(Map<String, dynamic> json) {
    return WeatherParameter(
        dateTime: json["dt"],
        feelsLike: kelvinToCelcius(json["feels_like"]),
        humidity: json["humidity"],
        pressure: json["pressure"],
        temp: kelvinToCelcius(json["temp"]),
        uvi: json["uvi"],
        visibility: json["visibility"],
        windDeg: json["wind_deg"],
        windSpeed: json["wind_speed"],
        weather: List<Weather>.from([Weather.fromJson(json["weather"][0])]));
  }

  WeatherParameter(
      {required this.dateTime,
      required this.feelsLike,
      required this.humidity,
      required this.pressure,
      this.sunrise,
      this.sunset,
      required this.temp,
      required this.uvi,
      required this.visibility,
      required this.windDeg,
      required this.windSpeed,
      required this.weather});
}

class WeatherData {
  num? lat;
  num? long;
  String? timeZone;
  num? timeZoneOffset;
  WeatherParameter? currentWeather;
  List<WeatherParameter>? hourlyWeather;
  List<WeatherParameter>? dailyWeather;

  WeatherData(
      {this.currentWeather,
      this.dailyWeather,
      this.hourlyWeather,
      this.lat,
      this.long,
      this.timeZone,
      this.timeZoneOffset});

  Map<int, String> monthToMonthName = {
    1: "January",
    2: "February",
    3: "March",
    4: "April",
    5: "May",
    6: "June",
    7: "July",
    8: "August",
    9: "September",
    10: "October",
    11: "November",
    12: "December"
  };

  Map<int, String> dayToDayName = {
    1: 'Monday',
    2: 'Tuesday',
    3: 'Wednesday',
    4: 'Thursday',
    5: 'Friday',
    6: 'Saturday',
    7: 'Sunday'
  };

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    List<WeatherParameter>? hourly;
    // List<WeatherParameter>? daily;
    try {
      hourly = List<WeatherParameter>.from(json['hourly'].map((data) {
        return WeatherParameter.fromJson(data);
      }).toList());
      // daily = List<WeatherParameter>.from(json['daily'].map((data) {
      //   return WeatherParameter.fromJson(data);
      // }).toList());
    } catch (err) {
      print(err.toString());
    }

    return WeatherData(
        lat: json["lat"],
        long: json["lon"],
        timeZone: json["timezone"],
        timeZoneOffset: json["timezone_offset"],
        currentWeather: WeatherParameter.fromJson(json["current"]),
        hourlyWeather: hourly);
  }

  Future fetchWeatherData() async {
    LocationData? location = await requestUserLocation();
    Uri url = Uri.parse(
        "https://api.openweathermap.org/data/2.5/onecall?lat=${location?.latitude}&lon=${location?.longitude}&appid=${dotenv.get('API_TOKEN', fallback: 'Api key not found')}");

    http.Response response = await http.get(url);
    if (response.statusCode == 200) {
      WeatherData weatherData = WeatherData.fromJson(jsonDecode(response.body));

      return weatherData;
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future requestUserLocation() async {
    Location location = Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    return await location.getLocation();
  }
}

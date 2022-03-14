import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocode/geocode.dart';
import 'package:weatherno/constant.dart';
import 'package:weatherno/weatherdata/weatherdata.dart';

void main() async {
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: EntryPage(),
    );
  }
}

class EntryPage extends StatelessWidget {
  EntryPage({Key? key}) : super(key: key);

  WeatherData weatherData = WeatherData();

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: backgroundColor,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              child: SvgPicture.asset(
                'assets/weathers/Humidity.svg',
                height: 35,
              ),
            ),
          ),
        ],
        leading: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: GestureDetector(child: SvgPicture.asset('assets/MenuIcon.svg')),
        ),
        title: RichText(
            text: TextSpan(
                text: 'Weather', style: orangeHeadline1, children: [TextSpan(text: 'No', style: whiteHeadline1)])),
      ),
      body: SizedBox(
        child: FutureBuilder(
          future: weatherData.fetchWeatherData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.data != null) {
                weatherData = snapshot.data as WeatherData;
              }
              return homeBlock(screenSize, weatherData);
            } else {
              return const Center(child: CircularProgressIndicator.adaptive());
            }
          },
        ),
      ),
    );
  }

  Widget homeBlock(Size screenSize, WeatherData weatherData) {
    DateTime dateTime =
        DateTime.fromMillisecondsSinceEpoch(int.parse(weatherData.currentWeather?.dateTime.toString() ?? '') * 1000);
    int lengthHourlyWeather = weatherData.hourlyWeather?.length ?? 0;
    GeoCode geoCode = GeoCode();

    return SingleChildScrollView(
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          SizedBox(
              width: screenSize.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(left: 25),
                    child: SvgPicture.asset('assets/weathers/${weatherData.currentWeather?.weather[0].icon}.svg',
                        height: 120),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 35),
                    child: AutoSizeText(
                      '${weatherData.currentWeather?.temp.toString().split('.')[0] ?? '--'}°C',
                      style: whiteHeadlineLarge,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 35),
                    child: AutoSizeText(
                      weatherData.currentWeather?.weather[0].main ?? 'No data Available',
                      style: whiteHeadline3,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 35),
                    child: AutoSizeText(
                      weatherData.currentWeather?.weather[0].description ?? 'No data Available',
                      style: fadedHeadline3,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.only(left: 35),
                    child: AutoSizeText(
                      '${weatherData.dayToDayName[dateTime.weekday]},\n${weatherData.monthToMonthName[dateTime.month]} ${dateTime.day}, ${dateTime.year}',
                      style: fadedHeadline3,
                    ),
                  ),
                  const SizedBox(height: 35),
                  Padding(
                    padding: const EdgeInsets.only(left: 25.0),
                    child: Row(children: <Widget>[
                      const Icon(
                        Icons.location_pin,
                        color: sunnyOrange,
                        size: 40,
                      ),
                      const SizedBox(width: 10),
                      FutureBuilder(
                          future: geoCode.reverseGeocoding(
                              latitude: double.parse(weatherData.lat.toString()),
                              longitude: double.parse(weatherData.long.toString())),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.done &&
                                snapshot.hasData &&
                                snapshot.data != null) {
                              Address address = snapshot.data as Address;
                              return AutoSizeText(
                                '${address.city?.toLowerCase()},\n${address.countryName}',
                                style: whiteHeadline2,
                              );
                            } else {
                              return const Text('--');
                            }
                          })
                    ]),
                  ),
                  const SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.only(left: 35),
                    child: AutoSizeText(
                      "Feels like ${weatherData.currentWeather?.feelsLike.toString().split('.')[0] ?? '--'}°C",
                      style: whiteHeadline2,
                    ),
                  ),
                  const SizedBox(height: 25),
                  Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: screenSize.width - 40,
                        height: 110,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: greyGradient),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemBuilder: ((context, index) {
                            DateTime hourlyDateTime = DateTime.fromMillisecondsSinceEpoch(
                                int.parse(weatherData.hourlyWeather?[index + 1].dateTime.toString() ?? '') * 1000);
                            return Container(
                              margin: const EdgeInsets.only(left: 12),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  SvgPicture.asset(
                                      'assets/weathers/${weatherData.hourlyWeather?[index + 1].weather[0].icon}.svg',
                                      height: 30),
                                  AutoSizeText('${hourlyDateTime.hour}', style: fadedHeadline3),
                                  AutoSizeText(
                                      '${weatherData.hourlyWeather?[index + 1].temp.toString().split('.')[0] ?? '--'} °',
                                      style: whiteHeadline3)
                                ],
                              ),
                            );
                          }),
                          itemCount: min(lengthHourlyWeather, 24),
                        ),
                      )),
                  const SizedBox(height: 35),
                  SizedBox(
                    width: screenSize.width,
                    height: 410,
                    child: GridView.builder(
                        itemCount: 4,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, mainAxisSpacing: 20, crossAxisSpacing: 20),
                        itemBuilder: (context, index) {
                          Widget gridIndex;
                          if (index == 0) {
                            gridIndex = humidityGrid();
                          } else if (index == 1) {
                            gridIndex = windGrid();
                          } else if (index == 2) {
                            gridIndex = uvGrid();
                          } else {
                            gridIndex = pressureGrid();
                          }
                          return Container(
                              padding: const EdgeInsets.all(15),
                              margin: EdgeInsets.only(left: index % 2 == 0 ? 20 : 0, right: index % 2 == 0 ? 0 : 20),
                              decoration: BoxDecoration(boxShadow: const [
                                BoxShadow(offset: Offset(0, 0), color: blackShadow, blurRadius: 35)
                              ], borderRadius: BorderRadius.circular(20), gradient: greyGradient),
                              child: gridIndex);
                        }),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: AutoSizeText(
                      'Current timezone - ${weatherData.timeZone?.split('/')[1].replaceAll('_', ' ') ?? '--'}, ${weatherData.timeZone?.split('/')[0].replaceAll('_', ' ') ?? '--'}',
                      style: whiteHeadline4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.center,
                    child: AutoSizeText(
                      'Made with ♥ by WarMac',
                      style: whiteHeadline4,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              )),
          Positioned(
            top: 40,
            right: -100,
            child: SvgPicture.asset('assets/weathers/${weatherData.currentWeather?.weather[0].icon}.svg',
                width: 300, fit: BoxFit.cover),
          ),
        ],
      ),
    );
  }

  Widget humidityGrid() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      SvgPicture.asset('assets/weathers/Humidity.svg', height: 80),
      const SizedBox(height: 25),
      AutoSizeText('${weatherData.currentWeather?.humidity} %', style: fadedHeadline3),
      AutoSizeText('Humidity', style: whiteHeadline2)
    ]);
  }

  Widget windGrid() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      SvgPicture.asset(
        'assets/weathers/Wind Speed.svg',
        height: 80,
        fit: BoxFit.cover,
      ),
      const SizedBox(height: 25),
      AutoSizeText('${weatherData.currentWeather?.windSpeed} mph', style: fadedHeadline3),
      AutoSizeText('Wind Speed', style: whiteHeadline2)
    ]);
  }

  Widget uvGrid() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      SvgPicture.asset('assets/weathers/01d.svg', height: 80),
      const SizedBox(height: 25),
      AutoSizeText('${weatherData.currentWeather?.uvi} uvi', style: fadedHeadline3),
      AutoSizeText('UV Index', style: whiteHeadline2)
    ]);
  }

  Widget pressureGrid() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      SvgPicture.asset('assets/weathers/Pressure.svg', height: 80),
      const SizedBox(height: 25),
      AutoSizeText('${weatherData.currentWeather?.pressure} hpa', style: fadedHeadline3),
      AutoSizeText('Pressure', style: whiteHeadline2)
    ]);
  }
}

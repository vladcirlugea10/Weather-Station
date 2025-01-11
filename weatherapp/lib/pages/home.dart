import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:weatherapp/pages/settings_page.dart';
import 'package:weatherapp/pages/seven_day_history.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:weatherapp/utils/pressure_utils.dart';
import 'package:weatherapp/utils/temperature_utils.dart';
import 'package:weatherapp/utils/weather_icon_utils.dart';

ValueNotifier<String> temperatureUnitNotifier = ValueNotifier<String>('C');
ValueNotifier<String> pressureUnitNotifier = ValueNotifier<String>('hPa');

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  String city = 'Loading...';
  String humidity = "N/A";
  String rain = "N/A";
  double temperature = 0.0; // For conversion
  String pressure = "N/A"; // New variable for pressure

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    fetchLatestData();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          city = 'Location services are disabled';
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            city = 'Location permissions are denied';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          city = 'Location permissions are permanently denied';
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          city = place.locality ?? 'Unknown location';
        });
      } else {
        setState(() {
          city = 'Unknown location';
        });
      }
    } catch (error) {
      print('Error getting location: $error');
    }
  }

  Future<void> fetchLatestData() async {
    try {
      final response = await http.get(
        Uri.parse('https://us-central1-weather-app-fe906.cloudfunctions.net/getNewestEntry'),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData != null && responseData['data'] != null) {
          final dataMap = responseData['data'] as Map<String, dynamic>;
          final firstEntry = dataMap.values.first;

          setState(() {
            humidity = '${firstEntry['humidity']}';
            rain = '${firstEntry['rainPercentage']}';
            temperature = double.tryParse(firstEntry['temperature'].toString()) ?? 0.0;
            pressure = '${firstEntry['pressure']}'; 
          });
        } else {
          setState(() {
            humidity = 'N/A';
            rain = 'N/A';
            temperature = 0.0;
            pressure = 'N/A';
          });
          print('No valid data found.');
        }
      } else {
        setState(() {
          humidity = 'N/A';
          rain = 'N/A';
          temperature = 0.0;
          pressure = 'N/A';
        });
        print('Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching data: $error');
      setState(() {
        humidity = 'N/A';
        rain = 'N/A';
        temperature = 0.0;
        pressure = 'N/A';
      });
    }
  }

  void _navigateToSevenDayHistory() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => SevenDayHistory(city: city)));
  }

  void _navigateToSettings() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 43, 171, 230),
        title: Center(
          child: Text(widget.title),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _navigateToSettings,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            getWeatherIcon(rain),
            const SizedBox(height: 24),
            ValueListenableBuilder<String>(
              valueListenable: temperatureUnitNotifier,
              builder: (context, unit, child) {
                final convertedTemperature = convertToUnit(temperature, unit).round();
                return Column(
                  children: [
                    Text(
                      city,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8), 
                    Text(
                      "${convertedTemperature.toString()}°$unit",
                      style: const TextStyle(fontSize: 36),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24), 
            Column(
              children: [
                const Text("TIME", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(TimeOfDay.now().format(context)),
              ],
            ),
            const SizedBox(height: 24), // Space between Time and row with Humidity, Rain, and Pressure
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    const Text("Humidity", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("${double.tryParse(humidity)?.round() ?? 'N/A'}%"),
                  ],
                ),
                Column(
                  children: [
                    const Text("Rain", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("${double.tryParse(rain)?.round() ?? 'N/A'}%"),
                  ],
                ),
                Column(
                  children: [
                    const Text("Pressure", style: TextStyle(fontWeight: FontWeight.bold)),
                    ValueListenableBuilder<String>(
                      valueListenable: pressureUnitNotifier,
                      builder: (context, unit, child) {
                        final pressureValue = double.tryParse(pressure);
                        final convertedPressure = pressureValue != null
                            ? convertPressureToUnit(pressureValue, unit).round()
                            : 'N/A';
                        return Text("$convertedPressure $unit");
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        width: 120,
        height: 30,
        child: FloatingActionButton(
          onPressed: _navigateToSevenDayHistory,
          tooltip: '7-day History',
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              "7-day History",
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
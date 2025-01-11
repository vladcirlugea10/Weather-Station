import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:weatherapp/pages/seven_day_history.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:weatherapp/utils/temperature_utils.dart';

ValueNotifier<String> temperatureUnitNotifier = ValueNotifier<String>('C');

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
            pressure = '${firstEntry['pressure']}'; // Fetch and set pressure
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
            const Icon(Icons.sunny, size: 100, color: Color.fromRGBO(255, 172, 51, 1)),
            const SizedBox(height: 24),
            ValueListenableBuilder<String>(
              valueListenable: temperatureUnitNotifier,
              builder: (context, unit, child) {
                final convertedTemperature = convertToUnit(temperature, unit);
                return Column(
                  children: [
                    Text(
                      city,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8), // Add space between city and temperature
                    Text(
                      "${convertedTemperature.toStringAsFixed(1)}°$unit",
                      style: const TextStyle(fontSize: 36),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24), // Space between temperature and Time section
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
                    Text("$humidity%"),
                  ],
                ),
                Column(
                  children: [
                    const Text("Rain", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("$rain%"),
                  ],
                ),
                Column(
                  children: [
                    const Text("Pressure", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("$pressure hPa"),
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

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Temperature Unit:', style: TextStyle(fontSize: 18)),
            Row(
              children: [
                Radio<String>(
                  value: 'C',
                  groupValue: temperatureUnitNotifier.value,
                  onChanged: (value) {
                    if (value != null) {
                      temperatureUnitNotifier.value = value;
                    }
                  },
                ),
                const Text('Celsius'),
                Radio<String>(
                  value: 'F',
                  groupValue: temperatureUnitNotifier.value,
                  onChanged: (value) {
                    if (value != null) {
                      temperatureUnitNotifier.value = value;
                    }
                  },
                ),
                const Text('Fahrenheit'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

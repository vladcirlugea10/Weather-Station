import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:weatherapp/pages/seven_day_history.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  String city = 'Fetching location...';
  String humidity = "N/A";
  String rain = "N/A";
  String temperature = "N/A";

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    fetchLatestData();
  }

  Future<void> _getCurrentLocation() async {
    try{
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          city = 'Location services are disabled';
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if(permission == LocationPermission.denied){
        permission = await Geolocator.requestPermission();
        if(permission == LocationPermission.denied){
          setState(() {
            city = 'Location permissions are denied';
          });
          return;
        }
      }

      if(permission == LocationPermission.deniedForever){
        setState(() {
          city = 'Location permissions are permanently denied';
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      if(placemarks.isNotEmpty){
        Placemark place = placemarks[0];
        setState(() {
          city = place.locality ?? 'Unknown location';
        });
      } else {
        setState(() {
          city = 'Unknown location';
        });
      }
    } catch (error){
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
          temperature = '${firstEntry['temperature'].toStringAsFixed(1)}';
        });
      } else {
        setState(() {
          humidity = 'N/A';
          rain = 'N/A';
          temperature = 'N/A';
        });
        print('No valid data found.');
      }
    } else {
      setState(() {
        humidity = 'N/A';
        rain = 'N/A';
        temperature = 'N/A';
      });
      print('Failed to fetch data. Status code: ${response.statusCode}');
    }
  } catch (error) {
    print('Error fetching data: $error');
    setState(() {
      humidity = 'N/A';
      rain = 'N/A';
      temperature = 'N/A';
    });
  }
}

  void _navigateToSevenDayHistory() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => SevenDayHistory(city: city)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 43, 171, 230),
        title: Center(
          child: Text(widget.title),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.sunny, size: 100, color: Color.fromRGBO(255, 172, 51, 1)),
            Text(
              "$city $temperature°C",
              style: TextStyle(fontSize: 36),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    const Text("TIME"),
                    Text(TimeOfDay.now().format(context)),
                  ],
                ),
                const SizedBox(width: 50),
                Column(
                  children: [
                    const Text("Humidity"),
                    Text("$humidity%"),
                  ],
                ),
                const SizedBox(width: 50),
                Column(
                  children: [
                    const Text("RAIN"),
                    Text("$rain%"),
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
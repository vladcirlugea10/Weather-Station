import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:weatherapp/utils/date_utils.dart';
import 'package:weatherapp/utils/pressure_utils.dart';
import 'package:weatherapp/utils/weather_icon_utils.dart';
import 'package:weatherapp/pages/home.dart'; 
import 'package:weatherapp/utils/temperature_utils.dart'; 

class DayCard extends StatefulWidget {
  final String day;
  final String temperature;
  final String humidity;
  final String rain;
  final String pressure;
  final VoidCallback onTap;

  const DayCard({
    super.key,
    required this.day,
    required this.temperature,
    required this.humidity,
    required this.rain,
    required this.pressure,
    required this.onTap,
  });

  @override
  _DayCardState createState() => _DayCardState();
}

class _DayCardState extends State<DayCard> {
  late double minTemperature;
  late double maxTemperature;

  @override
  void initState() {
    super.initState();
    minTemperature = 0.0;
    maxTemperature = 0.0;
    fetchMinMaxTemperatures();
  }

  Future<void> fetchMinMaxTemperatures() async {
    try {
      final String day = extractDate(widget.day);
      final response = await http.get(
        Uri.parse('https://us-central1-weather-app-fe906.cloudfunctions.net/dailyMaximums?day=$day'),
      );

      if (response.statusCode == 200) {
        final temperature = jsonDecode(response.body);
        if (temperature != null) {
          setState(() {
            minTemperature = double.tryParse(temperature['minTemperature'].toString()) ?? 0.0;
            maxTemperature = double.tryParse(temperature['maxTemperature'].toString()) ?? 0.0;
          });
        } else {
          setState(() {
            minTemperature = 0.0;
            maxTemperature = 0.0;
          });
        }
      } else {
        print('Failed to fetch temperature!');
        setState(() {
          minTemperature = 0.0;
          maxTemperature = 0.0;
        });
      }
    } catch (error) {
      print('Failed to fetch temperature: $error');
      setState(() {
        minTemperature = 0.0;
        maxTemperature = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.day,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      ValueListenableBuilder<String>(
                        valueListenable: temperatureUnitNotifier,
                        builder: (context, unit, child) {
                          final convertedMinTemp = convertToUnit(minTemperature, unit);
                          final convertedMaxTemp = convertToUnit(maxTemperature, unit);
                          return Text(
                            "${convertedMaxTemp.toStringAsFixed(1)}°$unit / ${convertedMinTemp.toStringAsFixed(1)}°$unit",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  getWeatherIcon(widget.rain),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      const Icon(Icons.water_drop, color: Colors.blue),
                      const Text(
                        "Humidity",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        "${widget.humidity}%",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Icon(Icons.umbrella, color: Colors.grey),
                      const Text(
                        "Rain",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        "${widget.rain}%",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Icon(Icons.speed, color: Colors.purple),
                      const Text(
                        "Pressure",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      ValueListenableBuilder<String>(
                        valueListenable: pressureUnitNotifier,
                        builder: (context, unit, child) {
                          final double? parsedPressure = double.tryParse(widget.pressure);
                          final convertedPressure = parsedPressure != null
                              ? convertPressureToUnit(parsedPressure, unit).round()
                              : 'N/A';
                          return Text(
                            "${convertedPressure is double ? convertedPressure.round() : convertedPressure} $unit",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

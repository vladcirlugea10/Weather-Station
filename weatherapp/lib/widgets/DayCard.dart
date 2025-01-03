import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:weatherapp/utils/date_utils.dart';
import 'package:weatherapp/utils/weather_icon_utils.dart';

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
  late String minTemperature;
  late String maxTemperature;

  @override
  void initState() {
    super.initState();
    minTemperature = 'Loading';
    maxTemperature = 'Loading';
    fetchMinMaxTemperatures();
  }

  Future<void> fetchMinMaxTemperatures() async {
    try {
      final String day = extractDate(widget.day);
      final response = await http.get(
          Uri.parse('https://us-central1-weather-app-fe906.cloudfunctions.net/dailyMaximums?day=$day'));

      if (response.statusCode == 200) {
        final temperature = jsonDecode(response.body);
        print('Response temperature: $temperature');

        if (temperature != null) {
          setState(() {
            minTemperature = '${temperature['minTemperature'].toStringAsFixed(1)}';
            maxTemperature = '${temperature['maxTemperature'].toStringAsFixed(1)}';
            print("AICI: $minTemperature / $maxTemperature");
          });
        } else {
          setState(() {
            minTemperature = 'N/A';
            maxTemperature = 'N/A';
          });
        }
      } else {
        print('Failed to fetch temperature!');
        setState(() {
          minTemperature = 'N/A';
          maxTemperature = 'N/A';
        });
      }
    } catch (error) {
      print('Failed to fetch temperature $error');
      setState(() {
        minTemperature = 'N/A';
        maxTemperature = 'N/A';
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
                      Text(
                        "$maxTemperature°C / $minTemperature°C",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
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
                      Text(
                        "${widget.pressure} hPa",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
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

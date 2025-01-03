import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:weatherapp/pages/day_details.dart';
import 'package:weatherapp/widgets/DayCard.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;

class SevenDayHistory extends StatefulWidget {
  final String city;
  const SevenDayHistory({
      super.key,
      required this.city,
    });

  @override
  State<SevenDayHistory> createState() => _SevenDayHistoryState();
}

class _SevenDayHistoryState extends State<SevenDayHistory> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> weatherData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getSensorReadings();
  }

  Future<void> _getSensorReadings() async {
  try {
    final response = await http.get(
      Uri.parse('https://us-central1-weather-app-fe906.cloudfunctions.net/getLastSevenDays'),
    );
    
    if(response.statusCode == 200){
      final data = jsonDecode(response.body) as List<dynamic>;

      setState(() {
        weatherData = data.map((entry) {
          return {
            'day': entry['day'] as String,
            'summary':
              'Temp: ${entry['temperature']}°C\n'
              'Pressure: ${entry['pressure']} hPa\n',
            'humidity': entry['humidity'].toString(),
            'rain': entry['rainPercentage'].toString(),
          };
        }).toList();

        weatherData.sort((a, b) => b['day']!.compareTo(a['day']!));

        isLoading = false;
      });
    } else {
      print('Failed to load data');
      setState(() {
        isLoading = false;
      });
    }

  } catch (error) {
    print('Error: $error');
    setState(() {
      isLoading = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('7 Day History'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      widget.city,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: weatherData.length,
                      itemBuilder: (context, index) {
                        final dayData = weatherData[index];
                        return DayCard(
                          day: dayData['day']!,
                          data: dayData['summary']!,
                          humidity: dayData['humidity']!,
                          rain: dayData['rain']!,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DayDetails(
                                  day: dayData['day']!,
                                  summary: dayData['summary']!,
                                  humidity: dayData['humidity']!,
                                  rain: dayData['rain']!,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

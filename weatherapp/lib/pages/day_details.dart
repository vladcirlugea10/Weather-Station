import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:weatherapp/widgets/HourCard.dart';

class DayDetails extends StatefulWidget {
  final String day;
  final String summary;
  final String humidity;
  final String rain;

  const DayDetails({
    super.key,
    required this.day,
    required this.summary,
    required this.humidity,
    required this.rain,
  });

  @override
  State<DayDetails> createState() => _DayDetailsState();
}

class _DayDetailsState extends State<DayDetails> {
  List<Map<String, dynamic>> hourlyData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getDayDetails();
  }

  Future<void> _getDayDetails() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://us-central1-weather-app-fe906.cloudfunctions.net/getHourlyAverages?day=${widget.day}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        setState(() {
          hourlyData = data.map<Map<String, dynamic>>((hour) => {
                "hour": hour['hour'],
                "temperature": double.parse(hour['temperature']).round(),
                "humidity": hour['humidity'],
                "rain": hour['rain'],
              }).toList();
          isLoading = false;
        });
      } else {
        print('Failed to load data');
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      print('Error fetching data: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Details for ${widget.day}'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: hourlyData.length,
              itemBuilder: (context, index) {
                final hour = hourlyData[index];
                return HourCard(
                  day: "${hour['hour']}:00", // Format the hour
                  data: "${hour['temperature']}°C", // Use temperature as data
                  humidity: hour['humidity'], // Use humidity
                  rain: hour['rain'], // Use rain percentage
                  temperature: "${hour['temperature']}", // Use temperature
                  onTap: () {
                    print("Hour ${hour['hour']} clicked!");
                  },
                );
              },
            ),
    );
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:weatherapp/pages/day_details.dart';
import 'package:weatherapp/widgets/DayCard.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

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
              'temperature': entry['temperature'].toString(),
              'humidity': entry['humidity'].toString(),
              'rain': entry['rainPercentage'].toString(),
              'pressure': entry['pressure'].toString(),
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

  List<FlSpot> _generateChartData() {
    return weatherData.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final temperature = double.tryParse(entry.value['temperature']) ?? 0.0; 
      return FlSpot(index, temperature);
    }).toList();
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
                  if (weatherData.isNotEmpty)
                    SizedBox(
                      height: 200,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0), // Adjust padding as needed
                        child: LineChart(
                          LineChartData(
                            minY: 0,
                            maxY: 40,
                            lineBarsData: [
                              LineChartBarData(
                                spots: _generateChartData(),
                                isCurved: true,
                                color: Colors.blue,
                                barWidth: 4,
                                isStrokeCapRound: true,
                                dotData: FlDotData(
                                  show: true, 
                                  checkToShowDot: (FlSpot spot, LineChartBarData barData) {
                                    return true; 
                                  },
                                ),
                                belowBarData: BarAreaData(show: false),
                              ),
                            ],
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    return Text('${value.toInt()}°C', style: const TextStyle(fontSize: 12));
                                  },
                                  reservedSize: 40,
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    final index = value.toInt();
                                    if (index < 0 || index >= weatherData.length) return const SizedBox();
                                    return Transform.rotate(
                                      angle: 0.5, // Tilt the text
                                      child: Text(
                                        weatherData[index]['day'], 
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                    );
                                  },
                                  reservedSize: 50,
                                ),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: false, // Hide top titles
                                ),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: false, // Hide right titles
                                ),
                              ),
                            ),
                            borderData: FlBorderData(
                              border: Border.all(color: Colors.black12, width: 1),
                            ),
                            gridData: FlGridData(show: true),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16), // Add spacing between the chart and the list
                  Expanded(
                    child: ListView.builder(
                      itemCount: weatherData.length,
                      itemBuilder: (context, index) {
                        final dayData = weatherData[index];
                        return DayCard(
                          day: dayData['day']!,
                          temperature: dayData['temperature']!,
                          humidity: dayData['humidity']!,
                          rain: dayData['rain']!,
                          pressure: dayData['pressure']!,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DayDetails(
                                  day: dayData['day']!,
                                  summary: dayData['temperature']!,
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

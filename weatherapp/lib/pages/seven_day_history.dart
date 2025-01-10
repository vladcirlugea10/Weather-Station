import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:weatherapp/pages/day_details.dart';
import 'package:weatherapp/pages/home.dart';
import 'package:weatherapp/widgets/DayCard.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:weatherapp/utils/temperature_utils.dart';

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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;

        Map<String, Map<String, dynamic>> enrichedWeatherDataMap = {};

        for (var entry in data) {
          final String day = entry['day'];

          final minMaxResponse = await http.get(
            Uri.parse('https://us-central1-weather-app-fe906.cloudfunctions.net/dailyMaximums?day=$day'),
          );

          if (minMaxResponse.statusCode == 200) {
            final minMaxData = jsonDecode(minMaxResponse.body);

            enrichedWeatherDataMap[day] = {
              'day': day,
              'temperature': entry['temperature'].toString(),
              'humidity': entry['humidity'].toString(),
              'rain': entry['rainPercentage'].toString(),
              'pressure': entry['pressure'].toString(),
              'minTemperature': double.tryParse(minMaxData['minTemperature'].toString()) ?? 0.0,
              'maxTemperature': double.tryParse(minMaxData['maxTemperature'].toString()) ?? 0.0,
            };
          }
        }

        final enrichedWeatherData = enrichedWeatherDataMap.values.toList();
        enrichedWeatherData.sort((a, b) => a['day']!.compareTo(b['day']!));

        setState(() {
          weatherData = enrichedWeatherData;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  List<FlSpot> _generateMinTemperatureData() {
    return weatherData.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final minTempCelsius = entry.value['minTemperature'] ?? 0.0;
      final convertedTemp = convertToUnit(minTempCelsius, temperatureUnitNotifier.value);
      return FlSpot(index, convertedTemp);
    }).toList();
  }

  List<FlSpot> _generateMaxTemperatureData() {
    return weatherData.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final maxTempCelsius = entry.value['maxTemperature'] ?? 0.0;
      final convertedTemp = convertToUnit(maxTempCelsius, temperatureUnitNotifier.value);
      return FlSpot(index, convertedTemp);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('7 Day History'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
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
                          padding: const EdgeInsets.all(16.0),
                          child: ValueListenableBuilder<String>(
                            valueListenable: temperatureUnitNotifier,
                            builder: (context, unit, child) {
                              final maxTemperature = convertToUnit(40, unit); // Convert 40°C to the current unit
                              return LineChart(
                                LineChartData(
                                  minX: -0.25,
                                  maxX: weatherData.length - 0.75,
                                  minY: 0,
                                  maxY: maxTemperature, // Dynamically set maxY
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: _generateMinTemperatureData(),
                                      isCurved: true,
                                      color: Colors.blue,
                                      barWidth: 4,
                                      isStrokeCapRound: true,
                                      dotData: FlDotData(show: true),
                                      belowBarData: BarAreaData(show: false),
                                    ),
                                    LineChartBarData(
                                      spots: _generateMaxTemperatureData(),
                                      isCurved: true,
                                      color: Colors.orange,
                                      barWidth: 4,
                                      isStrokeCapRound: true,
                                      dotData: FlDotData(show: true),
                                      belowBarData: BarAreaData(show: false),
                                    ),
                                  ],
                                  titlesData: FlTitlesData(
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          return Text('${value.toInt()}°$unit', style: const TextStyle(fontSize: 12));
                                        },
                                        reservedSize: 40,
                                      ),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          final index = value.toInt();
                                          if (value % 1 != 0 || index < 0 || index >= weatherData.length) return const SizedBox();
                                          return Transform.rotate(
                                            angle: 0.5,
                                            child: Text(
                                              weatherData[index]['day'],
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(fontSize: 10),
                                            ),
                                          );
                                        },
                                        reservedSize: 50,
                                        interval: 1,
                                      ),
                                    ),
                                    topTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    rightTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                  ),
                                  borderData: FlBorderData(
                                    border: Border.all(color: Colors.black12, width: 1),
                                  ),
                                  gridData: FlGridData(show: true),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: weatherData.length,
                      itemBuilder: (context, index) {
                        final dayData = weatherData[index];
                        return DayCard(
                          day: dayData['day']!,
                          temperature: '${convertToUnit(double.parse(dayData['temperature']), temperatureUnitNotifier.value).toStringAsFixed(1)}°${temperatureUnitNotifier.value}',
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
                  ],
                ),
              ),
      ),
    );
  }
}

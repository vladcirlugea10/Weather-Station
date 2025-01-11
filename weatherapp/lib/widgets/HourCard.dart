import 'package:flutter/material.dart';
import 'package:weatherapp/utils/pressure_utils.dart';
import 'package:weatherapp/utils/weather_icon_utils.dart';
import 'package:weatherapp/pages/home.dart'; 
import 'package:weatherapp/utils/temperature_utils.dart'; 

class HourCard extends StatefulWidget {
  final String day;
  final String data;
  final String humidity;
  final String rain;
  final String temperature; 
  final String pressure;
  final VoidCallback onTap;

  const HourCard({
    super.key,
    required this.day,
    required this.data,
    required this.humidity,
    required this.rain,
    required this.temperature,
    required this.pressure,
    required this.onTap,
  });

  @override
  HourCardState createState() => HourCardState();
}

class HourCardState extends State<HourCard> {
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
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      ValueListenableBuilder<String>(
                        valueListenable: pressureUnitNotifier, 
                        builder: (context, unit, child) {
                          final rawPressure = double.tryParse(widget.pressure) ?? 0.0;
                          final convertedPressure = convertPressureToUnit(rawPressure, unit).round();
                          return Text(
                            "$convertedPressure $unit",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Icon(Icons.thermostat, color: Colors.red),
                      const Text(
                        "Temp",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      ValueListenableBuilder<String>(
                        valueListenable: temperatureUnitNotifier,
                        builder: (context, unit, child) {
                          final rawTempCelsius = double.tryParse(widget.temperature) ?? 0.0;
                          final convertedTemp = convertToUnit(rawTempCelsius, unit);
                          return Text(
                            "${convertedTemp.toStringAsFixed(1)}°$unit",
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

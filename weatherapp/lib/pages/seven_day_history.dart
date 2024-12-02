import 'package:flutter/material.dart';
import 'package:weatherapp/widgets/DayCard.dart';

class SevenDayHistory extends StatelessWidget {
  const SevenDayHistory({super.key});

  final List<Map<String, String>> weatherData = const [
    {'day': 'Monday', 'summary': 'Sunny, 25°C'},
    {'day': 'Tuesday', 'summary': 'Cloudy, 22°C'},
    {'day': 'Wednesday', 'summary': 'Rainy, 18°C'},
    {'day': 'Thursday', 'summary': 'Sunny, 26°C'},
    {'day': 'Friday', 'summary': 'Windy, 20°C'},
    {'day': 'Saturday', 'summary': 'Snowy, -1°C'},
    {'day': 'Sunday', 'summary': 'Foggy, 10°C'},
  ];

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('7 Day History'),
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            itemCount: weatherData.length,
            itemBuilder: (context, index) {
              final dayData = weatherData[index];
              return Daycard(
                day: dayData['day']!, 
                data: dayData['summary']!, 
                onTap: () {
                  
                });
            }
          ),
        )
    );
  }
}
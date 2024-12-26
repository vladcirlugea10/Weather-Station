import 'package:flutter/material.dart';
<<<<<<< HEAD

class SevenDayHistory extends StatelessWidget {
  const SevenDayHistory({super.key});

  @override
  Widget build(BuildContext context){
=======
import 'package:weatherapp/widgets/DayCard.dart';
import 'package:firebase_database/firebase_database.dart';

class SevenDayHistory extends StatefulWidget {
  const SevenDayHistory({super.key});

  @override
  State<SevenDayHistory> createState() => _SevenDayHistoryState();
}

class _SevenDayHistoryState extends State<SevenDayHistory> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  List<Map<String, String>> weatherData = const [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getSensorReadings();
  }

  Future<void> _getSensorReadings() async {
  try {
    final snapshot = await _database.child('sensor_readings').get();
    if (snapshot.exists) {
      final data = snapshot.value as dynamic;
    
      if (data is Map) {
        setState(() {
          weatherData = data.entries.map((entry) {
            final timestamp = entry.key.toString(); 
            final dayData = entry.value;

            if (dayData is Map) {
              return {
                'day': DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp)).toString(),
                'summary': 
                  'Temp: ${dayData['temperature'] ?? 'N/A'}°C\n'
                  'Pressure: ${dayData['pressure'] ?? 'N/A'} hPa',
                'humidity': dayData['humidity']?.toString() ?? 'N/A',
                'rain': dayData['rainPercentage']?.toString() ?? 'N/A',
              };
            }
            
            return {
              'day': DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp)).toString(),
              'summary': 'Invalid data',
              'humidity': 'N/A',
              'rain': 'N/A',
            };
          }).toList();
          
          isLoading = false;
        });
      } else {
        print('Data is not a map');
        setState(() {
          isLoading = false;
        });
      }
    } else {
      print('No data available');
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
>>>>>>> 7DayHistory
    return Scaffold(
      appBar: AppBar(
        title: const Text('7 Day History'),
      ),
<<<<<<< HEAD
      body: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: const [
              Text(
                'Timisoara',
              ),
            ],
          ),
        )
    );
  }
}
=======
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: weatherData.length,
                itemBuilder: (context, index) {
                  final dayData = weatherData[index];
                  return DayCard(
                    day: dayData['day']!,
                    data: dayData['summary']!,
                    humidity: dayData['humidity']!,
                    rain: dayData['rain']!,
                    onTap: () {},
                  );
                },
              ),
      ),
    );
  }
}
>>>>>>> 7DayHistory

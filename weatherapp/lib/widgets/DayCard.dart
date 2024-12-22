import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:weatherapp/utils/date_utils.dart';

class Daycard extends StatefulWidget {
  final String day;
  final String data;
  final VoidCallback onTap;

  const Daycard({
    super.key,
    required this.day,
    required this.data,
    required this.onTap,
  });

  @override
  _DaycardState createState() => _DaycardState();
}

class _DaycardState extends State<Daycard>{
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
    try{
      final String day = extractDate(widget.day);
      final response = await http.get(Uri.parse('https://us-central1-weather-app-fe906.cloudfunctions.net/dailyMaximums?day=$day'));

      if(response.statusCode == 200){
        final data = jsonDecode(response.body);
        print('Response Data: $data');

        if(data != null){
          setState(() {
            minTemperature = '${data['minTemperature'].toStringAsFixed(1)}';
            maxTemperature = '${data['maxTemperature'].toStringAsFixed(1)}';
            print("AICI: $minTemperature / $maxTemperature");
          });
        } else {
          setState(() {
            minTemperature = 'N/A';
            maxTemperature = 'N/A';
          });
        }
      } else {
        print('Failed to fetch data!');
        setState(() {
          minTemperature = 'N/A';
          maxTemperature = 'N/A';
        });
      }
    } catch(error){
      print('Failed to fetch data $error');
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
          padding: const EdgeInsets.all(8),
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
                  Icon(Icons.sunny, color: Colors.orange, size: 50),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.data,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


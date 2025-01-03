import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
  @override
  void initState() {
    super.initState();
    _getDayDetails();
  }

  Future<void> _getDayDetails() async {
    try{
      final response = await http.get(
        Uri.parse('https://us-central1-weather-app-fe906.cloudfunctions.net/getEntriesForDay?day=${widget.day}'),
      );
      print(response.body);
      if(response.statusCode == 200){
        final data = jsonDecode(response.body) as List<dynamic>;
        print('Data: $data');

      }
    }catch(error){
      print('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Details for ${widget.day}'),
      ),
    );
  }
}
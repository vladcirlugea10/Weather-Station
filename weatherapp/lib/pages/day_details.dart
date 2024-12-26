import 'package:flutter/material.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Details for ${widget.day}'),
      ),
    );
  }
}
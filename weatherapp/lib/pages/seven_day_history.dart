import 'package:flutter/material.dart';

class SevenDayHistory extends StatelessWidget {
  const SevenDayHistory({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('7 Day History'),
      ),
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
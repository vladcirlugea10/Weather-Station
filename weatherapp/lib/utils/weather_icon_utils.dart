import 'package:flutter/material.dart';

Icon getWeatherIcon(String rainPercentage){
  final double? rain = double.tryParse(rainPercentage);

  if(rain == null){
    return Icon(Icons.help_outline, color: Colors.grey);
  }

  if(rain >= 0 && rain <= 30){
    return const Icon(Icons.sunny, color: Colors.orange, size: 50);
  } else if (rain > 30 && rain <= 70){
    return const Icon(Icons.cloud, color: Colors.lightBlue, size: 50);
  } else {
    return const Icon(Icons.thunderstorm, color: Colors.indigo, size: 50);
  }
}
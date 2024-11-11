import 'package:flutter/material.dart';
import 'package:weatherapp/pages/seven_day_history.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Weather App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _navigateToSevenDayHistory() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const SevenDayHistory()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 43, 171, 230),
        title: Center(
          child: Text(widget.title),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.sunny, size: 100, color: Color.fromRGBO(255, 172, 51, 1),),
            const Text(
              'Timisoara',
              style: TextStyle(fontSize: 40),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text("TIME"), 
                    Text(TimeOfDay.now().format(context)),
                  ],
                ),
                SizedBox(width: 50),
                Column(
                  children: [
                    Text("Humidity"), 
                    Text("80%"),
                  ],
                ),
                SizedBox(width: 50),
                Column(
                  children: [
                    Text("RAIN"), 
                    Text("10%"),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),

      floatingActionButton: SizedBox(
          width: 100,
          height: 30,
          child: FloatingActionButton(
            onPressed: _navigateToSevenDayHistory,
            tooltip: '7-day History',
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text("7-day History", textAlign: TextAlign.center,), 
            ),
          ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

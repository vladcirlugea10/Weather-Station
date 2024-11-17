import 'package:flutter/material.dart';
import 'package:weatherapp/pages/seven_day_history.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
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
            const Icon(Icons.sunny, size: 100, color: Color.fromRGBO(255, 172, 51, 1)),
            const Text(
              'Timisoara',
              style: TextStyle(fontSize: 40),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    const Text("TIME"),
                    Text(TimeOfDay.now().format(context)),
                  ],
                ),
                const SizedBox(width: 50),
                const Column(
                  children: [
                    Text("Humidity"),
                    Text("80%"),
                  ],
                ),
                const SizedBox(width: 50),
                const Column(
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
            child: Text(
              "7-day History",
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
import 'package:flutter/material.dart';
import 'home.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Temperature Unit:', style: TextStyle(fontSize: 18)),
            Row(
              children: [
                Radio<String>(
                  value: 'C',
                  groupValue: temperatureUnitNotifier.value,
                  onChanged: (value) {
                    if (value != null) {
                      temperatureUnitNotifier.value = value;
                    }
                  },
                ),
                const Text('Celsius'),
                Radio<String>(
                  value: 'F',
                  groupValue: temperatureUnitNotifier.value,
                  onChanged: (value) {
                    if (value != null) {
                      temperatureUnitNotifier.value = value;
                    }
                  },
                ),
                const Text('Fahrenheit'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

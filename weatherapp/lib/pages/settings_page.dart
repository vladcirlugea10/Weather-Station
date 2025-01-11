import 'package:flutter/material.dart';
import 'home.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedUnit = temperatureUnitNotifier.value;

  void _onUnitChanged(String? value) {
    if (value != null) {
      setState(() {
        _selectedUnit = value;
        temperatureUnitNotifier.value = value;
      });
    }
  }

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
                  groupValue: _selectedUnit,
                  onChanged: _onUnitChanged,
                ),
                const Text('Celsius'),
                Radio<String>(
                  value: 'F',
                  groupValue: _selectedUnit,
                  onChanged: _onUnitChanged,
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

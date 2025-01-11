import 'package:flutter/material.dart';
import 'home.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedTemperatureUnit = temperatureUnitNotifier.value;
  String _selectedPressureUnit = pressureUnitNotifier.value;

  void _onTemperatureUnitChanged(String? value) {
    if (value != null) {
      setState(() {
        _selectedTemperatureUnit = value;
        temperatureUnitNotifier.value = value;
      });
    }
  }

  void _onPressureUnitChanged(String? value) {
    if (value != null) {
      setState(() {
        _selectedPressureUnit = value;
        pressureUnitNotifier.value = value;
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
                  groupValue: _selectedTemperatureUnit,
                  onChanged: _onTemperatureUnitChanged,
                ),
                const Text('Celsius'),
                Radio<String>(
                  value: 'F',
                  groupValue: _selectedTemperatureUnit,
                  onChanged: _onTemperatureUnitChanged,
                ),
                const Text('Fahrenheit'),
              ],
            ),
            const SizedBox(height: 16), 
            const Text('Pressure Unit:', style: TextStyle(fontSize: 18)),
            Row(
              children: [
                Radio<String>(
                  value: 'hPa',
                  groupValue: _selectedPressureUnit,
                  onChanged: _onPressureUnitChanged,
                ),
                const Text('hPa'),
                Radio<String>(
                  value: 'mmHg',
                  groupValue: _selectedPressureUnit,
                  onChanged: _onPressureUnitChanged,
                ),
                const Text('mmHg'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

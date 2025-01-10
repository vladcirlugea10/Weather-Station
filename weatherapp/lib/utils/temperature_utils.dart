double convertToUnit(double tempInCelsius, String unit) {
  if (unit == 'F') {
    return tempInCelsius * 9 / 5 + 32; // Convert to Fahrenheit
  }
  return tempInCelsius; // Keep Celsius
}

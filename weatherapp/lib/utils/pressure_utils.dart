double convertPressureToUnit(double pressureInHpa, String unit) {
  if (unit == 'mmHg') {
    return pressureInHpa * 0.75006; // Convert to mmHg
  }
  return pressureInHpa; // Keep in hPa
}

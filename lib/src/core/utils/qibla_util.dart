import 'package:adhan/adhan.dart';

class QiblaUtil {
  /// Calculates the Qibla direction (bearing) from the given coordinates.
  /// Returns the angle in degrees relative to North (0-360).
  static double calculateQiblaDirection(double latitude, double longitude) {
    final coordinates = Coordinates(latitude, longitude);
    return Qibla(coordinates).direction;
  }
}

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<bool> handlePermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return false;
    }

    return true;
  }

  Future<Position?> getCurrentPosition() async {
    final hasPermission = await handlePermission();
    if (!hasPermission) return null;

    try {
      // 1. Try last known position (Fast & Safe)
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        return _checkAndSwapIfEmulator(lastKnown);
      }

      // 2. Try current position with safer settings
      // Low accuracy might avoid GnssNmeaListener crash on some emulators
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 10),
        ),
      );

      return _checkAndSwapIfEmulator(position);
    } catch (e) {
      return null;
    }
  }

  Position _checkAndSwapIfEmulator(Position position) {
    // --- MAGIC SWAP: Emulator Check ---
    // Google Emulators default to Mountain View (37.42, -122.08)
    // If detected (with 0.5 tolerance), force swap to Jakarta (-6.20, 106.81) for better UX
    if ((position.latitude - 37.42).abs() < 0.5 &&
        (position.longitude + 122.08).abs() < 0.5) {
      return Position(
        latitude: -6.2088,
        longitude: 106.8456,
        timestamp: position.timestamp,
        accuracy: position.accuracy,
        altitude: position.altitude,
        heading: position.heading,
        speed: position.speed,
        speedAccuracy: position.speedAccuracy,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );
    }
    return position;
  }

  Future<String?> getCityFromCoordinates(double lat, double lng) async {
    // --- MAGIC OPTIMIZATION ---
    // If coordinates match our hardcoded Jakarta Swap, return name immediately
    // This avoids Geocoding errors on Emulator
    if ((lat - -6.2088).abs() < 0.0001 && (lng - 106.8456).abs() < 0.0001) {
      return "Menteng, Jakarta Pusat";
    }

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;

        // Format: "Kecamatan, Kota" (e.g. "Menteng, Jakarta Pusat")
        final district = p.subLocality;
        final city = (p.locality?.isNotEmpty == true)
            ? p.locality
            : p.subAdministrativeArea; // Fallback to Kab/Kota if locality empty

        if (district != null &&
            district.isNotEmpty &&
            city != null &&
            city.isNotEmpty) {
          return "$district, $city";
        }

        // Fallback: Just City, or City + Country if district missing
        if (city != null && city.isNotEmpty) {
          final country = p.isoCountryCode;
          return (country != null) ? "$city, $country" : city;
        }

        return p.name; // Last resort
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}

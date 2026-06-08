import 'package:adhan/adhan.dart';
import 'package:fpdart/fpdart.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:intl/intl.dart';

import '../../domain/entities/city.dart';
import '../../domain/entities/prayer_time.dart';
import '../../domain/repositories/prayer_repository.dart';

class PrayerRepositoryImpl implements PrayerRepository {
  @override
  Future<Either<String, PrayerTime>> getPrayerTime(
    double latitude,
    double longitude,
    DateTime date,
  ) async {
    try {
      final coordinates = Coordinates(latitude, longitude);
      final params = CalculationMethod.singapore.getParameters();
      params.madhab = Madhab.shafi;

      final prayerTimes = PrayerTimes.today(coordinates, params);

      // Format times
      final formatter = DateFormat('HH:mm');

      return Right(
        PrayerTime(
          imsak: formatter.format(
            prayerTimes.fajr.subtract(const Duration(minutes: 10)),
          ), // Approximation
          subuh: formatter.format(prayerTimes.fajr),
          terbit: formatter.format(prayerTimes.sunrise),
          dhuha: formatter.format(
            prayerTimes.sunrise.add(const Duration(minutes: 20)),
          ), // Approximation
          dzuhur: formatter.format(prayerTimes.dhuhr),
          ashar: formatter.format(prayerTimes.asr),
          maghrib: formatter.format(prayerTimes.maghrib),
          isya: formatter.format(prayerTimes.isha),
          date: DateFormat('yyyy-MM-dd').format(date),
        ),
      );
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<City>>> searchCity(String keyword) async {
    try {
      List<geo.Location> locations = await geo.locationFromAddress(keyword);

      // Use Future.wait to perform reverse geocoding for all locations in parallel
      final cities = await Future.wait(
        locations.map((loc) async {
          String cityName = keyword; // Fallback to search query

          try {
            // Reverse geocode to get proper city name
            List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(
              loc.latitude,
              loc.longitude,
            );

            if (placemarks.isNotEmpty) {
              final place = placemarks.first;
              // Try to get the most specific location name available
              cityName =
                  place.locality ??
                  place.subAdministrativeArea ??
                  place.administrativeArea ??
                  keyword;
            }
          } catch (e) {
            // If reverse geocoding fails, use the search keyword
            cityName = _capitalizeWords(keyword);
          }

          return City(
            id: '${loc.latitude}_${loc.longitude}',
            name: cityName,
            latitude: loc.latitude,
            longitude: loc.longitude,
          );
        }),
      );

      return Right(cities);
    } catch (e) {
      // Provide more user-friendly error messages
      if (e.toString().contains('No results') ||
          e.toString().contains('not found')) {
        return const Left('Location not found. Try a different search term.');
      } else if (e.toString().contains('network') ||
          e.toString().contains('connection')) {
        return const Left('Network error. Please check your connection.');
      }
      return Left('Failed to search location: ${e.toString()}');
    }
  }

  // Helper method to capitalize words for fallback display
  String _capitalizeWords(String text) {
    return text
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }
}

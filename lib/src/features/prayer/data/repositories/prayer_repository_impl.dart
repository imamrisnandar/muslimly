import 'package:fpdart/fpdart.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:intl/intl.dart';

import '../../../../core/error/failures.dart';
import '../../../settings/domain/repositories/settings_repository.dart';
import '../../domain/entities/city.dart';
import '../../domain/entities/high_latitude_setting.dart';
import '../../domain/entities/prayer_calculation_method.dart';
import '../../domain/entities/prayer_instants.dart';
import '../../domain/entities/prayer_time.dart';
import '../../domain/repositories/prayer_repository.dart';
import '../../domain/utils/prayer_calculator.dart';

class PrayerRepositoryImpl implements PrayerRepository {
  final SettingsRepository _settingsRepository;

  PrayerRepositoryImpl(this._settingsRepository);

  @override
  Future<Either<Failure, PrayerInstants>> getPrayerInstants(
    double latitude,
    double longitude,
    DateTime date,
  ) async {
    try {
      final methodKey = await _settingsRepository.getPrayerCalculationMethod();
      final highLatKey = await _settingsRepository.getHighLatitudeRule();
      return Right(
        PrayerCalculator.instants(
          latitude: latitude,
          longitude: longitude,
          date: date,
          method: PrayerCalculationMethod.fromKey(methodKey),
          highLatitude: HighLatitudeSetting.fromKey(highLatKey),
        ),
      );
    } catch (e) {
      return Left(MessageFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PrayerTime>> getPrayerTime(
    double latitude,
    double longitude,
    DateTime date,
  ) async {
    final result = await getPrayerInstants(latitude, longitude, date);
    return result.map((i) {
      // Format in the device zone, as before.
      final formatter = DateFormat('HH:mm');
      String f(DateTime t) => formatter.format(t.toLocal());
      return PrayerTime(
        imsak: f(i.fajr.subtract(const Duration(minutes: 10))), // Approximation
        subuh: f(i.fajr),
        terbit: f(i.sunrise),
        dhuha: f(i.sunrise.add(const Duration(minutes: 20))), // Approximation
        dzuhur: f(i.dhuhr),
        ashar: f(i.asr),
        maghrib: f(i.maghrib),
        isya: f(i.isha),
        date: i.date,
      );
    });
  }

  @override
  Future<Either<Failure, List<City>>> searchCity(String keyword) async {
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
        return const Left(
          MessageFailure('Location not found. Try a different search term.'),
        );
      } else if (e.toString().contains('network') ||
          e.toString().contains('connection')) {
        return const Left(
          MessageFailure('Network error. Please check your connection.'),
        );
      }
      return Left(MessageFailure('Failed to search location: ${e.toString()}'));
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

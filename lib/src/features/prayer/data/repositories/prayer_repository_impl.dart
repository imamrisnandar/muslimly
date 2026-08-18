import 'package:adhan/adhan.dart';
import 'package:fpdart/fpdart.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:intl/intl.dart';

import '../../../../core/error/failures.dart';
import '../../../settings/domain/repositories/settings_repository.dart';
import '../../domain/entities/city.dart';
import '../../domain/entities/prayer_calculation_method.dart';
import '../../domain/entities/prayer_time.dart';
import '../../domain/repositories/prayer_repository.dart';

class PrayerRepositoryImpl implements PrayerRepository {
  final SettingsRepository _settingsRepository;

  PrayerRepositoryImpl(this._settingsRepository);

  // Kemenag RI publishes the same Fajr/Isha angles as the "Singapore" method
  // (20°/18°); what it adds on top is an ihtiyat (safety margin), which
  // these values follow (the same margins used by common Indonesian
  // falakiyah software, e.g. Winhisab).
  static CalculationParameters _kemenagRIParameters() {
    final params = CalculationParameters(fajrAngle: 20.0, ishaAngle: 18.0);
    params.madhab = Madhab.shafi;
    params.adjustments = PrayerAdjustments(
      fajr: -2,
      sunrise: 1,
      dhuhr: 2,
      asr: 2,
      maghrib: 2,
      isha: 2,
    );
    return params;
  }

  static CalculationParameters _parametersFor(PrayerCalculationMethod method) {
    switch (method) {
      case PrayerCalculationMethod.kemenagRI:
        return _kemenagRIParameters();
      case PrayerCalculationMethod.singapore:
        final params = CalculationMethod.singapore.getParameters();
        params.madhab = Madhab.shafi;
        return params;
    }
  }

  @override
  Future<Either<Failure, PrayerTime>> getPrayerTime(
    double latitude,
    double longitude,
    DateTime date,
  ) async {
    try {
      final coordinates = Coordinates(latitude, longitude);
      final methodKey = await _settingsRepository.getPrayerCalculationMethod();
      final params = _parametersFor(PrayerCalculationMethod.fromKey(methodKey));

      final prayerTimes = PrayerTimes(
        coordinates,
        DateComponents.from(date),
        params,
      );

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
      return Left(MessageFailure(e.toString()));
    }
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

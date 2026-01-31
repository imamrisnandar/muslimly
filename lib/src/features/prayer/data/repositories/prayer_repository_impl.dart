import 'package:adhan/adhan.dart';
import 'package:dartz/dartz.dart';
import 'package:geocoding/geocoding.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/city.dart';
import '../../domain/entities/prayer_time.dart';
import '../../domain/repositories/prayer_repository.dart';

@LazySingleton(as: PrayerRepository)
class PrayerRepositoryImpl implements PrayerRepository {
  PrayerRepositoryImpl();

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

      // Create DateComponents from DateTime
      final dateComponents = DateComponents(date.year, date.month, date.day);

      final prayerTimes = PrayerTimes(coordinates, dateComponents, params);

      final formatter = DateFormat("HH:mm");

      return Right(
        PrayerTime(
          imsak: formatter.format(
            prayerTimes.fajr.subtract(const Duration(minutes: 10)),
          ),
          subuh: formatter.format(prayerTimes.fajr),
          terbit: formatter.format(prayerTimes.sunrise),
          dhuha: formatter.format(
            prayerTimes.sunrise.add(const Duration(minutes: 20)),
          ),
          dzuhur: formatter.format(prayerTimes.dhuhr),
          ashar: formatter.format(prayerTimes.asr),
          maghrib: formatter.format(prayerTimes.maghrib),
          isya: formatter.format(prayerTimes.isha),
          date: DateFormat("d MMM yyyy").format(date),
        ),
      );
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<City>>> searchCity(String keyword) async {
    try {
      // Use Geocoding to find coordinates for the city name
      List<Location> locations = await locationFromAddress(keyword);

      if (locations.isEmpty) {
        return const Right([]);
      }

      final cities = <City>[];
      final limitedLocations = locations.take(5);

      for (var loc in limitedLocations) {
        String displayName = keyword;
        try {
          // Optional: Try to get placemark for better name
          List<Placemark> placemarks = await placemarkFromCoordinates(
            loc.latitude,
            loc.longitude,
          );
          if (placemarks.isNotEmpty) {
            final p = placemarks.first;
            // Short Name Logic: City/County + Country Code
            // Prioritize locality (City) -> subAdmin (County)
            final mainName = p.locality?.isNotEmpty == true
                ? p.locality
                : p.subAdministrativeArea;

            final country = p.isoCountryCode;

            if (mainName != null && mainName.isNotEmpty) {
              displayName = country != null ? "$mainName, $country" : mainName;
            } else {
              // Fallback
              displayName = [
                p.subAdministrativeArea,
                p.country,
              ].where((e) => e != null).join(", ");
            }
          }
        } catch (_) {
          // Ignore reverse geocoding error, stick to keyword
        }

        cities.add(
          City(
            id: "${loc.latitude}_${loc.longitude}",
            name: displayName,
            latitude: loc.latitude,
            longitude: loc.longitude,
          ),
        );
      }

      return Right(cities);
    } catch (e) {
      // Return empty if not found or error (e.g. no internet for geocoding service)
      return const Right(
        [],
      ); // Better to return empty list than error string for search UI
    }
  }
}

import 'package:dartz/dartz.dart';
import '../entities/city.dart';
import '../entities/prayer_time.dart';

abstract class PrayerRepository {
  Future<Either<String, PrayerTime>> getPrayerTime(
    String cityId,
    DateTime date,
  );
  Future<Either<String, List<City>>> searchCity(String keyword);
}

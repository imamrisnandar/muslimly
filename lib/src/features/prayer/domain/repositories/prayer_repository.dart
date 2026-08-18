import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/city.dart';
import '../entities/prayer_time.dart';

abstract class PrayerRepository {
  Future<Either<Failure, PrayerTime>> getPrayerTime(
    double latitude,
    double longitude,
    DateTime date,
  );
  Future<Either<Failure, List<City>>> searchCity(String keyword);
}

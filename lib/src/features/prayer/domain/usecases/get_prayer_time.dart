import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/prayer_time.dart';
import '../repositories/prayer_repository.dart';

class GetPrayerTime {
  final PrayerRepository _repository;

  GetPrayerTime(this._repository);

  Future<Either<Failure, PrayerTime>> call({
    required double latitude,
    required double longitude,
    required DateTime date,
  }) {
    return _repository.getPrayerTime(latitude, longitude, date);
  }
}

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../data/datasources/prayer_remote_data_source.dart';
import '../../data/models/prayer_time_model.dart';
import '../../domain/entities/city.dart';
import '../../domain/entities/prayer_time.dart';
import '../../domain/repositories/prayer_repository.dart';

@LazySingleton(as: PrayerRepository)
class PrayerRepositoryImpl implements PrayerRepository {
  final PrayerRemoteDataSource _dataSource;

  PrayerRepositoryImpl(this._dataSource);

  @override
  Future<Either<String, PrayerTime>> getPrayerTime(
    String cityId,
    DateTime date,
  ) async {
    try {
      final year = date.year.toString();
      final month = date.month.toString().padLeft(2, '0');
      final day = date.day.toString().padLeft(2, '0');

      final response = await _dataSource.getPrayerSchedule(
        cityId,
        year,
        month,
        day,
      );

      if (response.status && response.data != null) {
        final jadwalJson = response.data!.jadwal;
        final model = PrayerTimeModel.fromJson(jadwalJson);

        return Right(
          PrayerTime(
            imsak: model.imsak,
            subuh: model.subuh,
            terbit: model.terbit,
            dhuha: model.dhuha,
            dzuhur: model.dzuhur,
            ashar: model.ashar,
            maghrib: model.maghrib,
            isya: model.isya,
            date: model.date,
          ),
        );
      } else {
        return const Left("Failed to load prayer schedule");
      }
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<City>>> searchCity(String keyword) async {
    try {
      final response = await _dataSource.searchCity(keyword);
      if (response.status && response.data != null) {
        final cities = response.data!
            .map((e) => City(id: e.id, name: e.lokasi))
            .toList();
        return Right(cities);
      } else {
        return const Right([]); // Return empty list if no data or status false
      }
    } catch (e) {
      return Left(e.toString());
    }
  }
}

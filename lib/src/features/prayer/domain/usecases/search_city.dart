import 'package:fpdart/fpdart.dart';
import '../entities/city.dart';
import '../repositories/prayer_repository.dart';

class SearchCity {
  final PrayerRepository _repository;

  SearchCity(this._repository);

  Future<Either<String, List<City>>> call(String keyword) {
    return _repository.searchCity(keyword);
  }
}

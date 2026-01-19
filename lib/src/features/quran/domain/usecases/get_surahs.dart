import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../entities/surah.dart';
import '../repositories/quran_repository.dart';

@injectable
class GetSurahs {
  final QuranRepository _repository;

  GetSurahs(this._repository);

  Future<Either<String, List<Surah>>> call() {
    return _repository.getSurahs();
  }
}

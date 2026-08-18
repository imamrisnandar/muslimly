import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/surah.dart';
import '../repositories/quran_repository.dart';

class GetSurahs {
  final QuranRepository _repository;

  GetSurahs(this._repository);

  Future<Either<Failure, List<Surah>>> call() {
    return _repository.getSurahs();
  }
}

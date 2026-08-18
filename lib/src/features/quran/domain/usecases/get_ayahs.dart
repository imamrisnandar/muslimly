import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/ayah.dart';
import '../repositories/quran_repository.dart';

class GetAyahs {
  final QuranRepository _repository;

  GetAyahs(this._repository);

  Future<Either<Failure, List<Ayah>>> call(int surahId) {
    return _repository.getAyahs(surahId);
  }
}

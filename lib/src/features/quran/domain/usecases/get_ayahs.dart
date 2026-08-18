import 'package:fpdart/fpdart.dart';
import '../entities/ayah.dart';
import '../repositories/quran_repository.dart';

class GetAyahs {
  final QuranRepository _repository;

  GetAyahs(this._repository);

  Future<Either<String, List<Ayah>>> call(int surahId) {
    return _repository.getAyahs(surahId);
  }
}

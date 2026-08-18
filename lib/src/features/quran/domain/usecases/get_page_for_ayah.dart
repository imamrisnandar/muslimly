import '../repositories/quran_repository.dart';

class GetPageForAyah {
  final QuranRepository _repository;

  GetPageForAyah(this._repository);

  Future<int> call(int surahId, int ayahNumber) {
    return _repository.getPageForAyah(surahId, ayahNumber);
  }
}

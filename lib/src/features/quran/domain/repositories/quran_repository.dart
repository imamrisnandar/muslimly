import 'package:dartz/dartz.dart';
import '../entities/ayah.dart';
import '../entities/surah.dart';
import '../entities/search_result.dart';

abstract class QuranRepository {
  Future<Either<String, List<Surah>>> getSurahs();
  Future<Either<String, List<Ayah>>> getAyahs(int surahId);
  Future<int> getPageForAyah(int surahId, int ayahNumber);

  Future<Either<String, List<SearchResult>>> searchAyahs(
    String query, {
    int page = 1,
    String languageCode = 'id',
  });
}

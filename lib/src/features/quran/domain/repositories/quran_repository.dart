import 'package:dartz/dartz.dart';
import '../entities/ayah.dart';
import '../entities/last_read.dart';
import '../entities/surah.dart';
import '../entities/search_response.dart';

abstract class QuranRepository {
  Future<Either<String, List<Surah>>> getSurahs();
  Future<Either<String, List<Ayah>>> getAyahs(int surahId);
  Future<int> getPageForAyah(int surahId, int ayahNumber);

  Future<Either<String, SearchResponse>> searchAyahs(
    String query, {
    int page = 1,
    String languageCode = 'id',
  });

  Future<Either<String, void>> syncLastReadPosition(
    LastRead lastRead,
    String? token, {
    String? deviceId,
  });
  Future<Either<String, void>> syncUnsyncedActivities(
    String? token, {
    String? deviceId,
  });
  Future<Either<String, List<dynamic>>> getReadingHistory(
    String? token, {
    String? deviceId,
  });
}

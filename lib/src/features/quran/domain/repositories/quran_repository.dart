import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/ayah.dart';
import '../entities/last_read.dart';
import '../entities/surah.dart';
import '../entities/search_response.dart';

abstract class QuranRepository {
  Future<Either<Failure, List<Surah>>> getSurahs();
  Future<Either<Failure, List<Ayah>>> getAyahs(int surahId);
  Future<int> getPageForAyah(int surahId, int ayahNumber);

  Future<Either<Failure, SearchResponse>> searchAyahs(
    String query, {
    int page = 1,
    String languageCode = 'id',
  });

  Future<Either<Failure, void>> syncLastReadPosition(
    LastRead lastRead,
    String? token, {
    String? deviceId,
  });
  Future<Either<Failure, void>> syncUnsyncedActivities(
    String? token, {
    String? deviceId,
  });
  Future<Either<Failure, List<dynamic>>> getReadingHistory(
    String? token, {
    String? deviceId,
  });
}

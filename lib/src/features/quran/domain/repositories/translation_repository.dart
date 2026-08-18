import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/word.dart';

abstract class TranslationRepository {
  /// Fetches translation text for a specific Ayah.
  /// [languageCode] e.g., 'id' or 'en'.
  Future<Either<Failure, String>> getTranslation(
    int surahId,
    int ayahId, {
    String languageCode = 'id',
  });

  /// Fetches Tafsir text for a specific Ayah.
  /// [tafsirId] e.g., 'id.jalalayn' or 'en.ibnkathir'.
  Future<Either<Failure, String>> getTafsir(
    int surahId,
    int ayahId, {
    String tafsirId = 'id.jalalayn',
  });

  /// Fetches Word-by-Word breakdown for a specific Ayah.
  Future<Either<Failure, List<Word>>> getWordByWord(
    int surahId,
    int ayahId, {
    String languageCode = 'id',
  });

  /// Fetches all translations for a specific Surah (Bulk).
  /// Returns a Map where key is Ayah Number and value is text.
  Future<Either<Failure, Map<int, String>>> getSurahTranslations(
    int surahId, {
    String languageCode = 'id',
    int? expectedAyahCount,
  });
}

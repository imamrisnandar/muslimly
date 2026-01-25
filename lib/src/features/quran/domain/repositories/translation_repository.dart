import 'package:dartz/dartz.dart';
import '../entities/word.dart';

abstract class TranslationRepository {
  /// Fetches translation text for a specific Ayah.
  /// [languageCode] e.g., 'id' or 'en'.
  Future<Either<String, String>> getTranslation(
    int surahId,
    int ayahId, {
    String languageCode = 'id',
  });

  /// Fetches Tafsir text for a specific Ayah.
  /// [tafsirId] e.g., 'id.jalalayn' or 'en.ibnkathir'.
  Future<Either<String, String>> getTafsir(
    int surahId,
    int ayahId, {
    String tafsirId = 'id.jalalayn',
  });

  /// Fetches Word-by-Word breakdown for a specific Ayah.
  Future<Either<String, List<Word>>> getWordByWord(int surahId, int ayahId);

  /// Fetches all translations for a specific Surah (Bulk).
  /// Returns a Map where key is Ayah Number and value is text.
  Future<Either<String, Map<int, String>>> getSurahTranslations(
    int surahId, {
    String languageCode = 'id',
    int? expectedAyahCount,
  });
}

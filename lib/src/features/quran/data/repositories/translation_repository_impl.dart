import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/database/database_service.dart';
import '../../domain/entities/word.dart';
import '../../domain/repositories/translation_repository.dart';

@LazySingleton(as: TranslationRepository)
class TranslationRepositoryImpl implements TranslationRepository {
  final Dio _dio;
  final DatabaseService _databaseService;

  TranslationRepositoryImpl(this._dio, this._databaseService);

  @override
  Future<Either<String, String>> getTranslation(
    int surahId,
    int ayahId, {
    String languageCode = 'id',
  }) async {
    try {
      // 1. Check Cache
      final cached = await _databaseService.getCachedTranslation(
        surahId,
        ayahId,
        languageCode,
      );
      if (cached != null && cached.isNotEmpty) {
        // Clean cached text: remove footnotes (<sup>1</sup>) and other tags
        final cleanCached = cached
            .replaceAll(RegExp(r'<sup.*?>.*?</sup>'), '')
            .replaceAll(RegExp(r'<[^>]*>'), '');
        return Right(cleanCached);
      }

      // 2. Fetch API (Quran.com)
      final resourceId = languageCode == 'id' ? 33 : 20;
      final url =
          'https://api.quran.com/api/v4/verses/by_key/$surahId:$ayahId?translations=$resourceId';

      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        final data = response.data;
        final translations = data['verse']['translations'] as List;
        if (translations.isNotEmpty) {
          String text = translations[0]['text'];
          // Use smart cleaner
          text = _cleanText(text);

          await _databaseService.cacheTranslation(
            surahId,
            ayahId,
            languageCode,
            text,
          );
          return Right(text);
        }
      }
      return const Left('Translation not found');
    } catch (e) {
      return Left('Failed to load translation: $e');
    }
  }

  @override
  Future<Either<String, String>> getTafsir(
    int surahId,
    int ayahId, {
    String tafsirId = 'id.jalalayn',
  }) async {
    try {
      // 1. Check Cache
      final cached = await _databaseService.getCachedTafsir(
        surahId,
        ayahId,
        tafsirId,
      );
      if (cached != null && cached.isNotEmpty) {
        return Right(cached);
      }

      // 2. Fetch API
      String url;
      bool isQuranCom = false;

      if (tafsirId == 'en.ibnkathir') {
        // Use Verified Quran.com Endpoint for Ibn Kathir
        // Pattern: /api/v4/tafsirs/{resource_id}/by_ayah/{verse_key}
        url =
            'https://api.quran.com/api/v4/tafsirs/169/by_ayah/$surahId:$ayahId';
        isQuranCom = true;
        print('DEBUG: Fetching Ibn Kathir from $url');
      } else {
        // Use Al Quran Cloud (id.jalalayn)
        url =
            'http://api.alquran.cloud/v1/ayah/$surahId:$ayahId/editions/$tafsirId';
      }

      final response = await _dio.get(url);
      print('DEBUG: Response code ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        // print('DEBUG: Data $data'); // Uncomment if needed
        String text = '';

        if (isQuranCom) {
          // Parse Quran.com Response
          // Expected: { "tafsir": { "resource_id": 169, "text": "<html>...</html>" } }
          if (data['tafsir'] != null) {
            text = data['tafsir']['text'] ?? '';
            // Use smart cleaner
            text = _cleanText(text);
          }
        } else {
          // Parse Al Quran Cloud Response
          // { "data": [ { "text": "..." } ] }
          final list = data['data'] as List;
          if (list.isNotEmpty) {
            text = list[0]['text'] as String;
          }
        }

        if (text.isNotEmpty) {
          // 3. Cache Result
          await _databaseService.cacheTafsir(surahId, ayahId, tafsirId, text);
          return Right(text);
        }
      }
      return const Left('Tafsir not found');
    } catch (e) {
      print('DEBUG: Error fetching tafsir: $e');
      return Left('Failed to load tafsir: $e');
    }
  }

  @override
  Future<Either<String, List<Word>>> getWordByWord(
    int surahId,
    int ayahId,
  ) async {
    try {
      // Use language=id for Indonesian
      // Request text_uthmani explicitly to get standard arabic text instead of V1 codes
      final url =
          'https://api.quran.com/api/v4/verses/by_key/$surahId:$ayahId?language=id&words=true&word_fields=text_uthmani';

      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        final data = response.data;
        final wordsJson = data['verse']['words'] as List;

        final words = wordsJson.map((json) => Word.fromJson(json)).toList();
        return Right(words);
      }
      return const Left('Words not found');
    } catch (e) {
      return Left('Failed to load words: $e');
    }
  }

  @override
  Future<Either<String, Map<int, String>>> getSurahTranslations(
    int surahId, {
    String languageCode = 'id',
    int? expectedAyahCount,
  }) async {
    try {
      // 1. Check Cache
      final cachedMap = await _databaseService.getSurahTranslations(
        surahId,
        languageCode,
      );

      // Validate cache completeness
      // Only use cache if:
      // - Cache is not empty AND
      // - Either we don't know expected count OR cache has all expected ayahs
      final isCacheComplete =
          cachedMap.isNotEmpty &&
          (expectedAyahCount == null || cachedMap.length >= expectedAyahCount);

      if (isCacheComplete) {
        // Use smart cleaner on cached data (just in case cache has raw html)
        final cleanedMap = cachedMap.map((key, value) {
          return MapEntry(key, _cleanText(value));
        });
        return Right(cleanedMap);
      }

      // 2. Fetch API (Bulk)
      final resourceId = languageCode == 'id' ? 33 : 20;
      final url =
          'https://api.quran.com/api/v4/quran/translations/$resourceId?chapter_number=$surahId';

      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        final data = response.data;
        final translationsList = data['translations'] as List;

        final Map<int, String> resultMap = {};
        final List<Map<String, dynamic>> batchCacheData = [];

        // API returns a flat list of translations for the chapter.
        // Usually they are in order of Ayah 1..N.
        for (var i = 0; i < translationsList.length; i++) {
          final item = translationsList[i];
          String text = item['text'];
          final ayahNumber = i + 1;

          // Use smart cleaner
          text = _cleanText(text);

          resultMap[ayahNumber] = text;

          batchCacheData.add({
            'surah_number': surahId,
            'ayah_number': ayahNumber,
            'language_code': languageCode,
            'text': text,
          });
        }

        // 3. Cache Batch
        if (batchCacheData.isNotEmpty) {
          await _databaseService.cacheTranslationsBatch(batchCacheData);
        }

        return Right(resultMap);
      }
      return const Left('Failed to fetch translations');
    } catch (e) {
      return Left('Error: $e');
    }
  }

  // --- HELPER: Smart Text Cleaner ---
  String _cleanText(String rawText) {
    if (rawText.isEmpty) return rawText;

    String text = rawText;

    // 1. Decode HTML Entities FIRST
    // (Ensure we work with real chars, e.g. &nbsp; -> space)
    text = text
        .replaceAll('&quot;', '"')
        .replaceAll('&apos;', "'")
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&nbsp;', ' ');

    // 2. SAVE STRUCTURE (HTML Blocks -> Newlines)
    // <br>, <br/> -> \n
    text = text.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
    // </p>, </div> -> \n\n (Paragraph breaks)
    text = text.replaceAll(RegExp(r'</(p|div)>', caseSensitive: false), '\n\n');

    // 3. SAVE CONTEXT (Footnotes)
    // <sup ...>1</sup> -> [1]
    // Capture the content inside sup tag
    text = text.replaceAllMapped(
      RegExp(r'<sup.*?>(.*?)</sup>', caseSensitive: false),
      (match) {
        final content = match.group(1);
        if (content != null && content.isNotEmpty) {
          return ' [$content] '; // Add brackets and spacing
        }
        return '';
      },
    );

    // 4. CLEANUP (Remove remaining tags)
    // Remove all other tags like <i>, <b>, <p>, <div>, <span>
    text = text.replaceAll(RegExp(r'<[^>]*>'), '');

    // 5. TRIM (Remove extra whitespaces)
    // Collapse multiple spaces/newlines
    text = text.trim();
    // Optional: Collapse 3+ newlines to 2
    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    return text;
  }
}

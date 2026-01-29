import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/ayah.dart';
import '../../domain/entities/surah.dart';
import '../../domain/repositories/quran_repository.dart';
import '../datasources/quran_local_data_source.dart';

import 'package:dio/dio.dart';
import '../../../../core/database/database_service.dart';
import '../models/ayah_model.dart';
import '../../domain/entities/search_result.dart'; // Import SearchResult entity

@LazySingleton(as: QuranRepository)
class QuranRepositoryImpl implements QuranRepository {
  final QuranLocalDataSource _localDataSource;
  final DatabaseService _databaseService;
  final Dio _dio;

  QuranRepositoryImpl(this._localDataSource, this._databaseService, this._dio);

  @override
  Future<Either<String, List<Surah>>> getSurahs() async {
    try {
      final surahs = await _localDataSource.getSurahs();
      return Right(surahs);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<Ayah>>> getAyahs(int surahId) async {
    try {
      // 1. Get Local Ayahs (Base Data)
      final List<Ayah> localAyahs = await _localDataSource.getAyahs(surahId);

      // 2. Check Tajweed Cache
      final tajweedMap = await _databaseService.getTajweedBatch(surahId);

      // Validate Cache Completeness
      if (tajweedMap.isNotEmpty && tajweedMap.length >= localAyahs.length) {
        return Right(_mergeTajweed(localAyahs, tajweedMap));
      }

      // 3. Fetch Online if Cache Incomplete
      try {
        final url =
            'https://api.quran.com/api/v4/quran/verses/uthmani_tajweed?chapter_number=$surahId';
        final response = await _dio.get(url);

        if (response.statusCode == 200) {
          final verses = response.data['verses'] as List;
          final List<Map<String, dynamic>> cacheData = [];
          final Map<int, String> newMap = {};

          for (var i = 0; i < verses.length; i++) {
            final v = verses[i];
            // API returns sequential verses for the chapter
            // verse_key: "1:1", "1:2"...
            // Verify verse ID or just use index + 1
            final ayahNum = i + 1;
            final text = v['text_uthmani_tajweed'] as String;

            newMap[ayahNum] = text;
            cacheData.add({
              'surah_number': surahId,
              'ayah_number': ayahNum,
              'text': text,
            });
          }

          // Save to Cache
          await _databaseService.cacheTajweedBatch(cacheData);

          return Right(_mergeTajweed(localAyahs, newMap));
        }
      } catch (e) {
        print('Tajweed fetch failed: $e. Returning offline text.');
        // Don't fail the whole request, return offline data
        return Right(localAyahs);
      }

      return Right(localAyahs);
    } catch (e) {
      return Left(e.toString());
    }
  }

  List<Ayah> _mergeTajweed(List<Ayah> ayahs, Map<int, String> tajweedMap) {
    return ayahs.map((ayah) {
      if (tajweedMap.containsKey(ayah.numberInSurah)) {
        return Ayah(
          number: ayah.number,
          text: ayah.text,
          numberInSurah: ayah.numberInSurah,
          juz: ayah.juz,
          page: ayah.page,
          textTajweed: tajweedMap[ayah.numberInSurah],
        );
      }
      return ayah;
    }).toList();
  }

  @override
  Future<int> getPageForAyah(int surahId, int ayahNumber) async {
    return _localDataSource.getPageForAyah(surahId, ayahNumber);
  }

  @override
  Future<Either<String, List<SearchResult>>> searchAyahs(
    String query, {
    int page = 1,
    String languageCode = 'id',
  }) async {
    try {
      final url =
          'https://api.quran.com/api/v4/search?q=$query&size=20&page=$page&language=$languageCode';
      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        final data = response.data;
        // API Structure:
        // { "search": { "results": [ { "verse_key": "1:1", "text": "...", "translations": [...] } ] } }

        final results = data['search']['results'] as List;
        final List<SearchResult> searchResults = results.map((item) {
          final verseKey = item['verse_key'] as String;
          final parts = verseKey.split(':');
          final surahNum = int.parse(parts[0]);
          final ayahNum = int.parse(parts[1]);
          final text = item['text'] as String; // Arabic or Text content

          // Get highlighted translation if available
          String translation = '';
          if (item['translations'] != null &&
              (item['translations'] as List).isNotEmpty) {
            translation = item['translations'][0]['text'];
          }

          return SearchResult(
            surahNumber: surahNum,
            ayahNumber: ayahNum,
            verseKey: verseKey,
            text: text,
            translation: translation,
          );
        }).toList();

        return Right(searchResults);
      }
      return const Left('Search failed');
    } catch (e) {
      return Left('Search error: $e');
    }
  }
}

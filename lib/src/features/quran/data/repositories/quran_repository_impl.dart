import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/ayah.dart';
import '../../domain/entities/surah.dart';
import '../../domain/repositories/quran_repository.dart';
import '../datasources/quran_local_data_source.dart';

import '../datasources/remote/sync_api_service.dart';
import '../../domain/entities/last_read.dart';

import 'package:dio/dio.dart';
import '../../../../core/database/database_service.dart';
import '../../domain/entities/search_result.dart'; // Import SearchResult entity
import '../../domain/entities/search_response.dart';

@LazySingleton(as: QuranRepository)
class QuranRepositoryImpl implements QuranRepository {
  final QuranLocalDataSource _localDataSource;
  final DatabaseService _databaseService;
  final Dio _dio;
  final SyncApiService _syncApiService;

  QuranRepositoryImpl(
    this._localDataSource,
    this._databaseService,
    this._dio,
    this._syncApiService,
  );

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
        // print('Tajweed fetch failed: $e. Returning offline text.');
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
  Future<Either<String, SearchResponse>> searchAyahs(
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
        // { "search": { "query": "...", "total_results": 2, "current_page": 1, "total_pages": 1, "results": [...] } }

        final searchData = data['search'];
        final results = searchData['results'] as List;
        final totalResults = searchData['total_results'] ?? 0;
        final totalPages = searchData['total_pages'] ?? 1;
        final currentPage = searchData['current_page'] ?? page;

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

        return Right(
          SearchResponse(
            results: searchResults,
            totalResults: totalResults is int
                ? totalResults
                : int.tryParse(totalResults.toString()) ?? 0,
            totalPages: totalPages is int
                ? totalPages
                : int.tryParse(totalPages.toString()) ?? 1,
            currentPage: currentPage is int
                ? currentPage
                : int.tryParse(currentPage.toString()) ?? page,
          ),
        );
      }
      return const Left('Search failed');
    } catch (e) {
      return Left('Search error: $e');
    }
  }

  @override
  Future<Either<String, void>> syncLastReadPosition(
    LastRead lastRead,
    String? token, {
    String? deviceId,
  }) async {
    try {
      final payload = <String, dynamic>{
        'surah_id': lastRead.surahNumber,
        'ayah_number': lastRead.ayahNumber,
        'page_number': lastRead.pageNumber,
        'mode': lastRead.mode,
      };
      if (deviceId != null && deviceId.isNotEmpty) {
        payload['device_id'] = deviceId;
      }

      await _syncApiService.upsertReadingHistory(payload, token);
      return const Right(null);
    } catch (e) {
      return Left('Sync failed: $e');
    }
  }

  @override
  Future<Either<String, void>> syncUnsyncedActivities(
    String? token, {
    String? deviceId,
  }) async {
    try {
      // 1. Get all unsynced activities from local database
      final unsynced = await _databaseService.getUnsyncedActivities();

      if (unsynced.isEmpty) {
        return const Right(null); // Nothing to sync
      }

      // 2. Map to backend DTO payload format
      final payload = unsynced
          .map((activity) => activity.toJsonSync())
          .toList();

      // 3. Send bulk insert request
      await _syncApiService.bulkInsertActivities(
        payload,
        token,
        deviceId: deviceId,
      );

      // 4. If successful, mark them as synced in local DB
      final idsToMark = unsynced.map((a) => a.id!).toList();
      await _databaseService.markActivitiesAsSynced(idsToMark);

      return const Right(null);
    } catch (e) {
      return Left('Bulk sync failed: $e');
    }
  }

  @override
  Future<Either<String, List<dynamic>>> getReadingHistory(
    String? token, {
    String? deviceId,
  }) async {
    try {
      final history = await _syncApiService.getReadingHistory(
        token,
        deviceId: deviceId,
      );
      return Right(history);
    } catch (e) {
      return Left('Failed to fetch remote history: $e');
    }
  }
}

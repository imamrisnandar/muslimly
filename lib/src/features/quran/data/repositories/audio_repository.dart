import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/database/database_service.dart';
import '../../domain/entities/reciter.dart';

abstract class AudioRepository {
  Future<List<Reciter>> fetchReciters();
  Future<String> getAudioUrl(String reciterId, int surahId, int ayahId);
  Future<void> saveLastPlayback(int surahId, String reciterId, int positionMs);
  Future<Map<String, dynamic>?> getLastPlayback();
  Future<List<String>> getSurahAudioUrls(String reciterId, int surahId);
}

@LazySingleton(as: AudioRepository)
class AudioRepositoryImpl implements AudioRepository {
  final Dio _dio;
  final DatabaseService _databaseService;

  static const String _keyLastAudioSurah = 'last_audio_surah';
  static const String _keyLastAudioReciter = 'last_audio_reciter';
  static const String _keyLastAudioPos = 'last_audio_pos';

  AudioRepositoryImpl(this._dio, this._databaseService);

  @override
  Future<List<Reciter>> fetchReciters() async {
    try {
      final results = await Future.wait([
        _fetchQuranComReciters(),
        _fetchAlQuranCloudReciters(),
      ]);
      return [...results[0], ...results[1]];
    } catch (e) {
      // If one fails, try to return the others or empty
      return [];
    }
  }

  Future<List<Reciter>> _fetchQuranComReciters() async {
    try {
      final response = await _dio.get(
        'https://api.quran.com/api/v4/resources/recitations',
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('recitations')) {
          final list = data['recitations'] as List;
          return list.map((e) => Reciter.fromQuranComJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Reciter>> _fetchAlQuranCloudReciters() async {
    try {
      final response = await _dio.get(
        'https://api.alquran.cloud/v1/edition/format/audio',
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          final list = data['data'] as List;
          return list
              .where((e) => e['type'] == 'versebyverse')
              .map((e) => Reciter.fromAlQuranCloudJson(e))
              .toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<String>> getSurahAudioUrls(String reciterId, int surahId) async {
    if (reciterId.startsWith('quran_com_')) {
      // Quran.com (Full Surah)
      final id = reciterId.replaceFirst('quran_com_', '');
      final url = 'https://api.quran.com/api/v4/chapter_recitations/$id';

      try {
        final response = await _dio.get(
          url,
          queryParameters: {'chapter_number': surahId},
        );
        if (response.statusCode == 200) {
          final data = response.data;
          if (data['audio_files'] != null &&
              (data['audio_files'] as List).isNotEmpty) {
            return [data['audio_files'][0]['audio_url'] as String];
          }
        }
      } catch (e) {
        return [];
      }
      return [];
    } else {
      // Al Quran Cloud (Verse by Verse)
      try {
        final response = await _dio.get(
          'https://api.alquran.cloud/v1/surah/$surahId/$reciterId',
        );
        if (response.statusCode == 200) {
          final data = response.data;
          if (data != null && data['data'] != null) {
            final ayahs = data['data']['ayahs'] as List;
            return ayahs.map((e) => e['audio'] as String).toList();
          }
        }
        return [];
      } catch (e) {
        return [];
      }
    }
  }

  @override
  Future<String> getAudioUrl(String reciterId, int surahId, int ayahId) async {
    if (reciterId.startsWith('quran_com_')) {
      // Not supported? Or return Full Surah URL and let UI handle?
      // Currently `getAudioUrl` is used for single ayah play.
      // We can throw Exception("Not supported for this Reciter").
      throw Exception(
        'One-click Ayah play not supported for this Reciter (Full Surah Only)',
      );
    }

    try {
      final response = await _dio.get(
        'https://api.alquran.cloud/v1/ayah/$surahId:$ayahId/$reciterId',
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data['data'] != null) {
          return data['data']['audio'] as String;
        }
      }
      throw Exception('Audio URL not found');
    } catch (e) {
      throw Exception('Failed to fetch audio URL: $e');
    }
  }

  @override
  Future<void> saveLastPlayback(
    int surahId,
    String reciterId,
    int positionMs,
  ) async {
    await _databaseService.saveSetting(_keyLastAudioSurah, surahId.toString());
    await _databaseService.saveSetting(_keyLastAudioReciter, reciterId);
    await _databaseService.saveSetting(_keyLastAudioPos, positionMs.toString());
  }

  @override
  Future<Map<String, dynamic>?> getLastPlayback() async {
    final surahStr = await _databaseService.getSetting(_keyLastAudioSurah);
    final reciterId = await _databaseService.getSetting(_keyLastAudioReciter);
    final posStr = await _databaseService.getSetting(_keyLastAudioPos);

    if (surahStr != null && reciterId != null) {
      return {
        'surahId': int.parse(surahStr),
        'reciterId': reciterId,
        'positionMs': int.parse(posStr ?? '0'),
      };
    }
    return null;
  }
}

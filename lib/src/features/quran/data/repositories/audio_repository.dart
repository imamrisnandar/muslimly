import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/database/database_service.dart';
import '../../domain/entities/reciter.dart';

abstract class AudioRepository {
  Future<List<Reciter>> fetchReciters();
  Future<String> getAudioUrl(int reciterId, int surahId);
  Future<void> saveLastPlayback(int surahId, int reciterId, int positionMs);
  Future<Map<String, int>?> getLastPlayback();
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
      final response = await _dio.get(
        'https://api.quran.com/api/v4/resources/recitations',
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('recitations')) {
          final list = data['recitations'] as List;
          return list.map((e) => Reciter.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      // Return empty list on failure or throw
      // For now, return empty and handle in Bloc
      return [];
    }
  }

  @override
  Future<String> getAudioUrl(int reciterId, int surahId) async {
    try {
      final response = await _dio.get(
        'https://api.quran.com/api/v4/chapter_recitations/$reciterId/$surahId',
      );
      if (response.statusCode == 200) {
        final data = response.data;
        // Expected: { "audio_file": { "audio_url": "..." } }
        if (data is Map<String, dynamic> && data.containsKey('audio_file')) {
          final audioFile = data['audio_file'];
          return audioFile['audio_url'] as String;
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
    int reciterId,
    int positionMs,
  ) async {
    await _databaseService.saveSetting(_keyLastAudioSurah, surahId.toString());
    await _databaseService.saveSetting(
      _keyLastAudioReciter,
      reciterId.toString(),
    );
    await _databaseService.saveSetting(_keyLastAudioPos, positionMs.toString());
  }

  @override
  Future<Map<String, int>?> getLastPlayback() async {
    final surahStr = await _databaseService.getSetting(_keyLastAudioSurah);
    final reciterStr = await _databaseService.getSetting(_keyLastAudioReciter);
    final posStr = await _databaseService.getSetting(_keyLastAudioPos);

    if (surahStr != null && reciterStr != null) {
      return {
        'surahId': int.parse(surahStr),
        'reciterId': int.parse(reciterStr),
        'positionMs': int.parse(posStr ?? '0'),
      };
    }
    return null;
  }
}

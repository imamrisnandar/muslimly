import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/database/database_service.dart';

abstract class SettingsRepository {
  Future<String?> getLanguage();
  Future<void> saveLanguage(String languageCode);

  Future<Map<String, String>> getPrayerNotificationSettings();
  Future<void> savePrayerNotificationSetting(
    String prayerName,
    String soundType,
  );

  Future<int> getDailyReadingTarget();
  Future<void> saveDailyReadingTarget(int pages);

  Future<String> getReadingTargetUnit(); // 'page' or 'ayah'
  Future<void> saveReadingTargetUnit(String unit);

  Future<int> getDailyAyahTarget();
  Future<void> saveDailyAyahTarget(int ayahs);

  Future<String?> getUserName();
  Future<void> saveUserName(String name);

  Future<bool> hasShownPlayerShowcase();
  Future<void> setPlayerShowcaseShown(bool shown);

  Future<List<Map<String, dynamic>>> getHijriAdjustments();
  Future<void> saveHijriAdjustments(List<Map<String, dynamic>> adjustments);
  Future<List<Map<String, dynamic>>> fetchRemoteHijriAdjustments();
}

@LazySingleton(as: SettingsRepository)
class SettingsRepositoryImpl implements SettingsRepository {
  static const String _keyLanguage = 'app_language';
  static const String _keyPrayerPrefix = 'prayer_notify_';
  static const String _keyDailyTarget = 'quran_daily_target';
  static const String _keyDailyAyahTarget = 'quran_daily_ayah_target';
  static const String _keyTargetUnit = 'quran_target_unit';
  static const String _keyUserName = 'user_name';
  static const String _keyPlayerShowcase = 'player_showcase_shown_v3';
  static const String _keyHijriAdjustments = 'hijri_adjustments_list';

  final DatabaseService _databaseService;
  final Dio _dio;

  SettingsRepositoryImpl(this._databaseService, this._dio);

  @override
  Future<String?> getLanguage() async {
    return await _databaseService.getSetting(_keyLanguage);
  }

  @override
  Future<void> saveLanguage(String languageCode) async {
    await _databaseService.saveSetting(_keyLanguage, languageCode);
  }

  @override
  Future<Map<String, String>> getPrayerNotificationSettings() async {
    final prayers = [
      'Imsak',
      'Subuh',
      'Terbit',
      'Dzuhur',
      'Ashar',
      'Maghrib',
      'Isya',
    ]; // Standard names
    final Map<String, String> settings = {};

    for (final name in prayers) {
      final val = await _databaseService.getSetting('$_keyPrayerPrefix$name');
      settings[name] = val ?? 'adhan';
    }
    return settings;
  }

  @override
  Future<void> savePrayerNotificationSetting(
    String prayerName,
    String soundType,
  ) async {
    await _databaseService.saveSetting(
      '$_keyPrayerPrefix$prayerName',
      soundType,
    );
  }

  @override
  Future<int> getDailyReadingTarget() async {
    final val = await _databaseService.getSetting(_keyDailyTarget);
    if (val == null) return 4;
    return int.tryParse(val) ?? 4;
  }

  @override
  Future<void> saveDailyReadingTarget(int pages) async {
    await _databaseService.saveSetting(_keyDailyTarget, pages.toString());
  }

  @override
  Future<String> getReadingTargetUnit() async {
    final val = await _databaseService.getSetting(_keyTargetUnit);
    return val ?? 'page';
  }

  @override
  Future<void> saveReadingTargetUnit(String unit) async {
    await _databaseService.saveSetting(_keyTargetUnit, unit);
  }

  @override
  Future<int> getDailyAyahTarget() async {
    final val = await _databaseService.getSetting(_keyDailyAyahTarget);
    if (val == null) return 20; // Default Ayah Target
    return int.tryParse(val) ?? 20;
  }

  @override
  Future<void> saveDailyAyahTarget(int ayahs) async {
    await _databaseService.saveSetting(_keyDailyAyahTarget, ayahs.toString());
  }

  @override
  Future<String?> getUserName() async {
    return await _databaseService.getSetting(_keyUserName);
  }

  @override
  Future<void> saveUserName(String name) async {
    await _databaseService.saveSetting(_keyUserName, name);
  }

  @override
  Future<bool> hasShownPlayerShowcase() async {
    final val = await _databaseService.getSetting(_keyPlayerShowcase);
    return val == 'true';
  }

  @override
  Future<void> setPlayerShowcaseShown(bool shown) async {
    await _databaseService.saveSetting(_keyPlayerShowcase, shown.toString());
  }

  @override
  Future<List<Map<String, dynamic>>> getHijriAdjustments() async {
    final val = await _databaseService.getSetting(_keyHijriAdjustments);
    if (val == null) return [];
    try {
      // Assuming stored as JSON string "
      // Actually DatabaseService.saveSetting takes String.
      // So we need to encode/decode json.
      // But wait, DatabaseService might not have json support visible here.
      // Let's assume we import dart:convert
      return List<Map<String, dynamic>>.from(json.decode(val));
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> saveHijriAdjustments(
    List<Map<String, dynamic>> adjustments,
  ) async {
    await _databaseService.saveSetting(
      _keyHijriAdjustments,
      json.encode(adjustments),
    );
  }

  @override
  Future<List<Map<String, dynamic>>> fetchRemoteHijriAdjustments() async {
    try {
      final response = await _dio.get('config-hijri-adjust');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['hijri_adjustments'] != null) {
          return List<Map<String, dynamic>>.from(data['hijri_adjustments']);
        }
      }
    } catch (e) {
      // Ignore error
    }
    return [];
  }
}

import 'package:flutter/foundation.dart';
import '../../../../core/utils/app_logger.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/database/database_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../quran/data/datasources/remote/sync_api_service.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  static const String _keyLanguage = 'app_language';
  static const String _keyPrayerPrefix = 'prayer_notify_';
  static const String _keyDailyTarget = 'quran_daily_target';
  static const String _keyPrayerCalculationMethod = 'prayer_calculation_method';
  static const String _keyDailyAyahTarget = 'quran_daily_ayah_target';
  static const String _keyTargetUnit = 'quran_target_unit';
  static const String _keyUserName = 'user_name';
  static const String _keyPlayerShowcase = 'player_showcase_shown_v3';
  static const String _keyHijriAdjustments = 'hijri_adjustments_list';

  final DatabaseService _databaseService;
  final Dio _dio;
  final AuthRepository _authRepository;
  final SyncApiService _syncApiService;

  SettingsRepositoryImpl(
    this._databaseService,
    this._dio,
    this._authRepository,
    this._syncApiService,
  );

  // Helper method to sync a changed setting to the backend in the background
  Future<void> _syncSettingChanges(String key, String value) async {
    try {
      String? token;
      final tokenEither = await _authRepository.getToken();
      tokenEither.fold((_) {}, (t) => token = t);

      final deviceId = await NotificationService.getDeviceId();

      if ((token != null && token!.isNotEmpty) ||
          (deviceId != null && deviceId.isNotEmpty)) {
        await _syncApiService.upsertSettings(
          [
            {'key': key, 'value': value},
          ],
          token,
          deviceId: deviceId,
        );
      }
    } catch (e) {
      // Ignore background sync errors
      debugPrint('❌ [Sync Settings] Failed to sync setting $key: $e');
    }
  }

  @override
  Future<String?> getLanguage() async {
    return await _databaseService.getSetting(_keyLanguage);
  }

  @override
  Future<void> saveLanguage(String languageCode) async {
    await _databaseService.saveSetting(_keyLanguage, languageCode);
    _syncSettingChanges(_keyLanguage, languageCode);
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
    final value = pages.toString();
    await _databaseService.saveSetting(_keyDailyTarget, value);
    _syncSettingChanges(_keyDailyTarget, value);
  }

  @override
  Future<String> getPrayerCalculationMethod() async {
    final val = await _databaseService.getSetting(_keyPrayerCalculationMethod);
    return val ?? 'singapore';
  }

  @override
  Future<void> savePrayerCalculationMethod(String method) async {
    await _databaseService.saveSetting(_keyPrayerCalculationMethod, method);
    _syncSettingChanges(_keyPrayerCalculationMethod, method);
  }

  @override
  Future<String> getReadingTargetUnit() async {
    final val = await _databaseService.getSetting(_keyTargetUnit);
    return val ?? 'page';
  }

  @override
  Future<void> saveReadingTargetUnit(String unit) async {
    await _databaseService.saveSetting(_keyTargetUnit, unit);
    _syncSettingChanges(_keyTargetUnit, unit);
  }

  @override
  Future<int> getDailyAyahTarget() async {
    final val = await _databaseService.getSetting(_keyDailyAyahTarget);
    if (val == null) return 20; // Default Ayah Target
    return int.tryParse(val) ?? 20;
  }

  @override
  Future<void> saveDailyAyahTarget(int ayahs) async {
    final value = ayahs.toString();
    await _databaseService.saveSetting(_keyDailyAyahTarget, value);
    _syncSettingChanges(_keyDailyAyahTarget, value);
  }

  @override
  Future<String?> getUserName() async {
    return await _databaseService.getSetting(_keyUserName);
  }

  @override
  Future<void> saveUserName(String name) async {
    await _databaseService.saveSetting(_keyUserName, name);
    _syncSettingChanges(_keyUserName, name);
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
      AppLogger.warning('Failed to read hijri adjustments from DB', e);
    }
    return [];
  }

  @override
  Future<void> syncSettingsFromRemote() async {
    try {
      String? token;
      final tokenEither = await _authRepository.getToken();
      tokenEither.fold((_) {}, (t) => token = t);

      final deviceId = await NotificationService.getDeviceId();

      if ((token != null && token!.isNotEmpty) ||
          (deviceId != null && deviceId.isNotEmpty)) {
        final remoteSettings = await _syncApiService.getSettings(
          token,
          deviceId: deviceId,
        );

        if (remoteSettings.isNotEmpty) {
          // If server has settings, we overwrite local
          debugPrint(
            '🔄 [Sync Settings] Found ${remoteSettings.length} settings on remote to pull.',
          );
          for (final item in remoteSettings) {
            if (item is Map &&
                item.containsKey('key') &&
                item.containsKey('value')) {
              await _databaseService.saveSetting(item['key'], item['value']);
            }
          }
        } else {
          // If server is empty, let's push our current key local targets to establish baseline
          debugPrint(
            '🔄 [Sync Settings] Remote is empty, pushing local baseline settings.',
          );
          final pageTarget = await getDailyReadingTarget();
          final ayahTarget = await getDailyAyahTarget();
          final unit = await getReadingTargetUnit();

          await _syncApiService.upsertSettings(
            [
              {'key': _keyDailyTarget, 'value': pageTarget.toString()},
              {'key': _keyDailyAyahTarget, 'value': ayahTarget.toString()},
              {'key': _keyTargetUnit, 'value': unit},
            ],
            token,
            deviceId: deviceId,
          );
        }
      }
    } catch (e) {
      debugPrint('❌ [Sync Settings] Failed to sync settings from remote: $e');
    }
  }
}

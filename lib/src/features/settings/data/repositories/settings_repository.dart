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
}

@LazySingleton(as: SettingsRepository)
class SettingsRepositoryImpl implements SettingsRepository {
  static const String _keyLanguage = 'app_language';
  static const String _keyPrayerPrefix = 'prayer_notify_';
  static const String _keyDailyTarget = 'quran_daily_target';

  final DatabaseService _databaseService;

  SettingsRepositoryImpl(this._databaseService);

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
}

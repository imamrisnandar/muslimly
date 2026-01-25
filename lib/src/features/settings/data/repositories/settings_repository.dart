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
}

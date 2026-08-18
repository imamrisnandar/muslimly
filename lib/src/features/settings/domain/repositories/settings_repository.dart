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

  Future<String> getPrayerCalculationMethod(); // 'singapore' or 'kemenag_ri'
  Future<void> savePrayerCalculationMethod(String method);

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

  Future<void> syncSettingsFromRemote();
}

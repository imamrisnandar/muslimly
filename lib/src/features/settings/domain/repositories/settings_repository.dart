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

  /// Mode Anak / "Guided" for Hafalan — synced like the reading targets so
  /// it follows the account across a shared family device.
  Future<bool> getKidsMode();
  Future<void> saveKidsMode(bool enabled);

  /// Opt-in "Rekam suara saat hafalan" (HAFALAN_TRACKER_PLAN.md §F) —
  /// default false, synced the same way as [getKidsMode]/[saveKidsMode].
  /// The recordings themselves stay local-only; only this preference bit
  /// follows the account.
  Future<bool> getRecordHafalan();
  Future<void> saveRecordHafalan(bool enabled);

  /// Highest hafalan streak-day milestone (5/7/14/30) already shown as an
  /// insight banner, and highest total-ayat-hafal milestone already shown —
  /// purely local UI dedup (never synced), same shape as
  /// hasShownPlayerShowcase/setPlayerShowcaseShown above. Defaults to 0
  /// (nothing shown yet).
  Future<int> getLastShownHafalanStreakMilestone();
  Future<void> saveLastShownHafalanStreakMilestone(int milestone);
  Future<int> getLastShownHafalanAyatMilestone();
  Future<void> saveLastShownHafalanAyatMilestone(int milestone);

  Future<List<Map<String, dynamic>>> getHijriAdjustments();
  Future<void> saveHijriAdjustments(List<Map<String, dynamic>> adjustments);
  Future<List<Map<String, dynamic>>> fetchRemoteHijriAdjustments();

  Future<void> syncSettingsFromRemote();
}

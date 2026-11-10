import '../entities/prayer_log.dart';

abstract class PrayerTrackerRepository {
  Future<void> append(PrayerLog log);

  /// Logs for slots on/after [sinceDate] plus all qadha-only rows.
  Future<List<PrayerLog>> logs({String? sinceDate});

  /// Sync support: rows the server has not acknowledged yet (oldest first).
  Future<List<PrayerLog>> unsynced({int limit = 500});
  Future<void> markSynced(List<int> ids);

  /// Adds server rows we lack (by timestamp+kind+prayer); returns how many.
  Future<int> mergeRemote(List<Map<String, Object?>> rows);
}

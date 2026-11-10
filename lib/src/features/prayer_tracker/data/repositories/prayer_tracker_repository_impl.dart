import '../../../../core/database/database_service.dart';
import '../../domain/entities/prayer_log.dart';
import '../../domain/repositories/prayer_tracker_repository.dart';

class PrayerTrackerRepositoryImpl implements PrayerTrackerRepository {
  final DatabaseService _db;
  PrayerTrackerRepositoryImpl(this._db);

  @override
  Future<void> append(PrayerLog log) async {
    await _db.insertPrayerLog(log.toMap());
  }

  @override
  Future<List<PrayerLog>> unsynced({int limit = 500}) async =>
      (await _db.getUnsyncedPrayerLogs(
        limit: limit,
      )).map(PrayerLog.fromMap).toList();

  @override
  Future<void> markSynced(List<int> ids) => _db.markPrayerLogsSynced(ids);

  @override
  Future<int> mergeRemote(List<Map<String, Object?>> rows) =>
      _db.mergeRemotePrayerLogs(rows);

  @override
  Future<List<PrayerLog>> logs({String? sinceDate}) async {
    final rows = await _db.getPrayerLogs(sinceDate: sinceDate);
    return rows.map(PrayerLog.fromMap).toList();
  }
}

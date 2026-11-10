import '../entities/excused_period.dart';

/// Local-only store of excused periods. Intentionally separate from
/// [PrayerTrackerRepository]: nothing here may ever be synced.
abstract class ExcusedPeriodRepository {
  Future<List<ExcusedPeriod>> all();
  Future<void> add(ExcusedPeriod period);
  Future<void> end(int id, String endDate);
  Future<void> delete(int id);
}

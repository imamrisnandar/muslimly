import '../entities/prayer_log.dart';

class QadhaPlanner {
  QadhaPlanner._();

  /// Σ of `qadha_baseline` counts per prayer (signed).
  static Map<TrackedPrayer, int> baselineTotals(Iterable<PrayerLog> logs) {
    final m = {for (final p in TrackedPrayer.values) p: 0};
    for (final l in logs) {
      if (l.kind == PrayerLogKind.qadhaBaseline)
        m[l.prayer] = m[l.prayer]! + l.count;
    }
    return m;
  }

  /// Σ of `qadha_done` counts per prayer (undo entries are negative).
  static Map<TrackedPrayer, int> doneTotals(Iterable<PrayerLog> logs) {
    final m = {for (final p in TrackedPrayer.values) p: 0};
    for (final l in logs) {
      if (l.kind == PrayerLogKind.qadhaDone)
        m[l.prayer] = m[l.prayer]! + l.count;
    }
    return m;
  }

  /// The adjustment entries that move the stored baseline to [target]:
  /// re-running the wizard adds the difference instead of overwriting history.
  /// Zero differences are omitted.
  static Map<TrackedPrayer, int> baselineDelta(
    Iterable<PrayerLog> logs,
    Map<TrackedPrayer, int> target,
  ) {
    final cur = baselineTotals(logs);
    return {
      for (final p in TrackedPrayer.values)
        if ((target[p] ?? 0) - cur[p]! != 0) p: (target[p] ?? 0) - cur[p]!,
    };
  }

  /// Estimated day the debt is cleared at [perDay] prayers a day, or null when
  /// there is no pace or nothing to make up.
  static DateTime? finishDate(int total, int perDay, DateTime today) {
    if (perDay <= 0 || total <= 0) return null;
    final days = (total + perDay - 1) ~/ perDay;
    return DateTime(today.year, today.month, today.day + days);
  }
}

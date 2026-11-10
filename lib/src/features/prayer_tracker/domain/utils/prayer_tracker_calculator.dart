import '../entities/prayer_log.dart';
import '../entities/prayer_slot.dart';

class PrayerStats {
  final int streakDays;
  final int performed;
  final int inJamaah;
  final int missed;

  const PrayerStats({
    required this.streakDays,
    required this.performed,
    required this.inJamaah,
    required this.missed,
  });
}

/// Pure functions over the prayer log. No counters or snapshots are stored:
/// everything below is recomputed from the log.
class PrayerTrackerCalculator {
  PrayerTrackerCalculator._();

  static String _slotKey(String date, TrackedPrayer p) => '$date/${p.key}';

  /// For each slot, the winning `performed`/`missed` entry: the one with the
  /// latest timestamp (a later entry is the user's correction); on a timestamp
  /// tie the larger id wins.
  static Map<String, PrayerLog> winningSlotLogs(Iterable<PrayerLog> logs) {
    final winners = <String, PrayerLog>{};
    for (final log in logs) {
      if (log.slotDate == null) continue;
      if (log.kind != PrayerLogKind.performed &&
          log.kind != PrayerLogKind.missed) {
        continue;
      }
      final key = _slotKey(log.slotDate!, log.prayer);
      final cur = winners[key];
      if (cur == null || _newer(log, cur)) winners[key] = log;
    }
    return winners;
  }

  static bool _newer(PrayerLog a, PrayerLog b) {
    final c = a.timestamp.compareTo(b.timestamp);
    if (c != 0) return c > 0;
    return (a.id ?? 0) > (b.id ?? 0);
  }

  static SlotView viewOf(
    PrayerSlot slot,
    Map<String, PrayerLog> winners,
    DateTime now, {
    bool excused = false,
  }) {
    final log = winners[slot.id];
    if (log != null) {
      if (log.kind == PrayerLogKind.missed) {
        return SlotView(slot: slot, status: SlotStatus.missed);
      }
      return SlotView(
        slot: slot,
        status: SlotStatus.performed,
        inJamaah: log.inJamaah,
        onTime: log.timestamp.isBefore(slot.end),
      );
    }
    if (excused) return SlotView(slot: slot, status: SlotStatus.excused);
    if (now.isBefore(slot.start)) {
      return SlotView(slot: slot, status: SlotStatus.upcoming);
    }
    if (now.isBefore(slot.end)) {
      return SlotView(slot: slot, status: SlotStatus.open);
    }
    return SlotView(slot: slot, status: SlotStatus.unrecorded);
  }

  /// Outstanding qadha per prayer:
  /// Σ baseline + #missed slots − Σ qadha_done, floored at 0.
  static Map<TrackedPrayer, int> qadhaBalance(Iterable<PrayerLog> logs) {
    final list = logs.toList();
    final raw = {for (final p in TrackedPrayer.values) p: 0};
    for (final log in list) {
      if (log.kind == PrayerLogKind.qadhaBaseline) {
        raw[log.prayer] = raw[log.prayer]! + log.count;
      } else if (log.kind == PrayerLogKind.qadhaDone) {
        raw[log.prayer] = raw[log.prayer]! - log.count;
      }
    }
    for (final log in winningSlotLogs(list).values) {
      if (log.kind == PrayerLogKind.missed) {
        raw[log.prayer] = raw[log.prayer]! + 1;
      }
    }
    return {for (final e in raw.entries) e.key: e.value < 0 ? 0 : e.value};
  }

  static int totalQadha(Map<TrackedPrayer, int> balance) =>
      balance.values.fold(0, (a, b) => a + b);

  /// Consecutive days on which all five prayers were performed, ending at
  /// [today] — or at yesterday when today is not yet complete (today in
  /// progress does not break the streak). Days inside an excused period
  /// ([isExcused]) are neutral: they neither count nor break the streak.
  static int streakDays(
    Iterable<PrayerLog> logs,
    String today, {
    bool Function(String date)? isExcused,
  }) {
    final winners = winningSlotLogs(logs);
    bool excused(String d) => isExcused?.call(d) ?? false;
    bool complete(String d) => TrackedPrayer.values.every(
      (p) => winners[_slotKey(d, p)]?.kind == PrayerLogKind.performed,
    );

    var day = _parse(today);
    if (!complete(_fmt(day)) && !excused(_fmt(day))) {
      day = day.subtract(const Duration(days: 1));
    }
    var n = 0;
    // Bounded: an open-ended excused period must not loop forever.
    for (var i = 0; i < 3650; i++) {
      final d = _fmt(day);
      if (excused(d)) {
        // neutral day
      } else if (complete(d)) {
        n++;
      } else {
        break;
      }
      day = day.subtract(const Duration(days: 1));
    }
    return n;
  }

  static PrayerStats stats(
    Iterable<PrayerLog> logs,
    String today, {
    bool Function(String date)? isExcused,
  }) {
    final winners = winningSlotLogs(logs).values;
    return PrayerStats(
      streakDays: streakDays(logs, today, isExcused: isExcused),
      performed: winners.where((l) => l.kind == PrayerLogKind.performed).length,
      inJamaah: winners
          .where((l) => l.kind == PrayerLogKind.performed && l.inJamaah)
          .length,
      missed: winners.where((l) => l.kind == PrayerLogKind.missed).length,
    );
  }

  // Calendar arithmetic in UTC so DST never shifts a date.
  static DateTime _parse(String d) {
    final p = d.split('-').map(int.parse).toList();
    return DateTime.utc(p[0], p[1], p[2]);
  }

  static String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}

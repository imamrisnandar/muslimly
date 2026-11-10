import '../entities/excused_period.dart';
import '../entities/prayer_log.dart';
import '../entities/prayer_slot.dart';

class PlannedNudge {
  final int index; // 0..9 -> notification id offset
  final PrayerSlot slot;
  final DateTime fireAt; // UTC
  const PlannedNudge(this.index, this.slot, this.fireAt);
}

/// Pure: decides which gentle nudges to schedule.
class NudgePlanner {
  NudgePlanner._();

  /// Isha's window runs until the next Fajr; nudging shortly before Fajr would
  /// be a 4 a.m. notification. Cap Isha's nudge at this long after Isha starts.
  static const Duration ishaNudgeCap = Duration(hours: 3);

  /// [slotsByDay]: slots of today first, then tomorrow (2 entries max used).
  /// Only slots that are not yet performed/missed get a nudge, and only if the
  /// fire time is still in the future.
  static List<PlannedNudge> plan({
    required List<List<SlotView>> slotsByDay,
    required DateTime now,
    required Duration before,
  }) {
    final out = <PlannedNudge>[];
    for (var d = 0; d < slotsByDay.length && d < 2; d++) {
      for (final v in slotsByDay[d]) {
        if (v.status == SlotStatus.performed ||
            v.status == SlotStatus.missed ||
            v.status == SlotStatus.excused) {
          continue;
        }
        final fire = fireTime(v.slot, before);
        if (!fire.isAfter(now)) continue;
        out.add(PlannedNudge(d * 5 + v.slot.prayer.index, v.slot, fire));
      }
    }
    return out;
  }

  static DateTime fireTime(PrayerSlot slot, Duration before) {
    var fire = slot.end.subtract(before);
    if (slot.prayer == TrackedPrayer.isha) {
      final cap = slot.start.add(ishaNudgeCap);
      if (cap.isBefore(fire)) fire = cap;
    }
    // Window shorter than the lead time: fire halfway through it instead.
    if (fire.isBefore(slot.start)) {
      fire = slot.start.add(slot.end.difference(slot.start) ~/ 2);
    }
    return fire;
  }

  /// When to remind the user that an excused pause may be over: 08:00 local on
  /// the expected end date of an active period, if still in the future.
  /// [today]/[now] are local. Returns null when there is nothing to schedule.
  static DateTime? excuseEndReminder(
    Iterable<ExcusedPeriod> periods,
    DateTime now,
  ) {
    DateTime? best;
    for (final p in periods) {
      if (!p.isActive || p.expectedEndDate == null) continue;
      final d = DateTime.tryParse(p.expectedEndDate!);
      if (d == null) continue;
      final at = DateTime(d.year, d.month, d.day, 8);
      if (!at.isAfter(now)) continue;
      if (best == null || at.isBefore(best)) best = at;
    }
    return best;
  }
}

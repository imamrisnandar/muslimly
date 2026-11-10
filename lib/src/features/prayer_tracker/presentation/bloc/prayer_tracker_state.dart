import 'package:equatable/equatable.dart';

import '../../domain/entities/excused_period.dart';
import '../../domain/entities/prayer_log.dart';
import '../../domain/entities/prayer_slot.dart';
import '../../domain/utils/prayer_tracker_calculator.dart';

enum PrayerTrackerStatus { initial, loading, ready, error }

class DaySlots {
  final String date; // yyyy-MM-dd
  final List<SlotView> slots;
  const DaySlots(this.date, this.slots);
}

class PrayerTrackerState extends Equatable {
  final PrayerTrackerStatus status;

  /// Oldest first; the last entry is today.
  final List<DaySlots> days;
  final String today;
  final PrayerStats? stats;
  final Map<TrackedPrayer, int> qadha;
  final bool nudgeEnabled;

  /// True when today's times were computed at a fallback latitude (polar
  /// day/night), i.e. they are approximate.
  final bool approximate;

  /// Local-only excused periods, oldest first.
  final List<ExcusedPeriod> periods;

  /// Bumped on every refresh so listeners rebuild even when nothing in the
  /// list is value-comparable.
  final int revision;

  const PrayerTrackerState({
    this.status = PrayerTrackerStatus.initial,
    this.days = const [],
    this.today = '',
    this.stats,
    this.qadha = const {},
    this.nudgeEnabled = true,
    this.approximate = false,
    this.periods = const [],
    this.revision = 0,
  });

  List<SlotView> get todaySlots => days.isEmpty ? const [] : days.last.slots;

  /// Slots from earlier days whose window ended without a log.
  List<SlotView> get unrecordedEarlier => [
    for (final d in days.take(days.length > 0 ? days.length - 1 : 0))
      ...d.slots.where((v) => v.status == SlotStatus.unrecorded),
  ];

  /// Earlier days that still have unrecorded slots, most recent first, each
  /// holding only those slots.
  List<DaySlots> get earlierDays => [
    for (final d
        in days.take(days.isEmpty ? 0 : days.length - 1).toList().reversed)
      if (d.slots.any((v) => v.status == SlotStatus.unrecorded))
        DaySlots(d.date, [
          for (final v in d.slots)
            if (v.status == SlotStatus.unrecorded) v,
        ]),
  ];

  ExcusedPeriod? get activePeriod {
    for (final p in periods) {
      if (p.isActive) return p;
    }
    return null;
  }

  int get totalQadha => PrayerTrackerCalculator.totalQadha(qadha);

  @override
  List<Object?> get props => [
    status,
    today,
    nudgeEnabled,
    approximate,
    revision,
  ];
}

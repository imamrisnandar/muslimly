import 'package:flutter_test/flutter_test.dart';
import 'package:muslimly/src/features/prayer_tracker/domain/entities/prayer_log.dart';
import 'package:muslimly/src/features/prayer_tracker/domain/utils/qadha_estimator.dart';
import 'package:muslimly/src/features/prayer_tracker/domain/utils/qadha_planner.dart';

PrayerLog _l(PrayerLogKind k, TrackedPrayer p, int c) => PrayerLog(
  kind: k,
  prayer: p,
  count: c,
  timestamp: DateTime.utc(2026, 1, 1),
);

void main() {
  group('QadhaEstimator', () {
    final from = DateTime(2020, 1, 1);
    final to = DateTime(2021, 1, 1); // 366 days (2020 is a leap year)

    test('never prayed: every day counts for every prayer', () {
      final r = QadhaEstimator.estimate(QadhaEstimateInput(from: from, to: to));
      expect(r.values.toSet(), {366});
    });

    test('sometimes: scales by days not prayed per week', () {
      final r = QadhaEstimator.estimate(
        QadhaEstimateInput(
          from: DateTime(2020, 1, 1),
          to: DateTime(2020, 1, 15), // 14 days
          pattern: QadhaPattern.sometimes,
          prayedPerWeek: {
            TrackedPrayer.fajr: 0,
            TrackedPrayer.dhuhr: 7,
            TrackedPrayer.asr: 3,
          },
        ),
      );
      expect(r[TrackedPrayer.fajr], 14);
      expect(r[TrackedPrayer.dhuhr], 0);
      expect(r[TrackedPrayer.asr], 8); // 14 * 4/7
      expect(r[TrackedPrayer.isha], 14); // unspecified = 0 per week
    });

    test('excuse correction removes days, never below zero', () {
      final r = QadhaEstimator.estimate(
        QadhaEstimateInput(
          from: DateTime(2020, 1, 1),
          to: DateTime(2020, 4, 1), // 91 days
          excusedDaysPerMonth: 7,
        ),
      );
      // 91 days ≈ 2.99 months → ~21 excused days.
      expect(r[TrackedPrayer.fajr], 91 - 21);

      final all = QadhaEstimator.estimate(
        QadhaEstimateInput(from: from, to: to, excusedDaysPerMonth: 999),
      );
      expect(all[TrackedPrayer.fajr], greaterThanOrEqualTo(0));
    });

    test('reversed or empty range gives zero', () {
      final r = QadhaEstimator.estimate(QadhaEstimateInput(from: to, to: from));
      expect(r.values.toSet(), {0});
      expect(QadhaEstimator.periodDays(from, from), 0);
    });
  });

  group('QadhaPlanner', () {
    test('baselineDelta adds only the difference and omits no-ops', () {
      final logs = [
        _l(PrayerLogKind.qadhaBaseline, TrackedPrayer.fajr, 100),
        _l(PrayerLogKind.qadhaBaseline, TrackedPrayer.fajr, -10),
        _l(PrayerLogKind.qadhaBaseline, TrackedPrayer.asr, 5),
      ];
      final d = QadhaPlanner.baselineDelta(logs, {
        TrackedPrayer.fajr: 90, // unchanged
        TrackedPrayer.asr: 20, // +15
        TrackedPrayer.isha: 7, // new
      });
      expect(d, {TrackedPrayer.asr: 15, TrackedPrayer.isha: 7});
    });

    test('doneTotals nets undo entries', () {
      final logs = [
        _l(PrayerLogKind.qadhaDone, TrackedPrayer.fajr, 1),
        _l(PrayerLogKind.qadhaDone, TrackedPrayer.fajr, 1),
        _l(PrayerLogKind.qadhaDone, TrackedPrayer.fajr, -1),
      ];
      expect(QadhaPlanner.doneTotals(logs)[TrackedPrayer.fajr], 1);
    });

    test('finishDate rounds up and handles no pace', () {
      final today = DateTime(2026, 3, 15);
      expect(QadhaPlanner.finishDate(10, 3, today), DateTime(2026, 3, 19));
      expect(QadhaPlanner.finishDate(10, 0, today), isNull);
      expect(QadhaPlanner.finishDate(0, 5, today), isNull);
    });
  });
}

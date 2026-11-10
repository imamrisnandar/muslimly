import 'package:flutter_test/flutter_test.dart';
import 'package:muslimly/src/features/prayer/domain/entities/prayer_instants.dart';
import 'package:muslimly/src/features/prayer_tracker/domain/entities/prayer_log.dart';
import 'package:muslimly/src/features/prayer_tracker/domain/entities/prayer_slot.dart';
import 'package:muslimly/src/features/prayer_tracker/domain/utils/prayer_slot_resolver.dart';
import 'package:muslimly/src/features/prayer_tracker/domain/utils/prayer_tracker_calculator.dart';

PrayerInstants _day(String date, {int fajrHour = 4}) {
  final d = DateTime.parse('${date}T00:00:00Z');
  DateTime at(int h, [int m = 0]) => d.add(Duration(hours: h, minutes: m));
  return PrayerInstants(
    date: date,
    fajr: at(fajrHour),
    sunrise: at(6),
    dhuhr: at(12),
    asr: at(15),
    maghrib: at(18),
    isha: at(19, 30),
  );
}

PrayerLog _log(
  PrayerLogKind kind,
  TrackedPrayer p,
  String? date,
  DateTime ts, {
  int? id,
  int count = 1,
  bool jamaah = false,
}) => PrayerLog(
  id: id,
  kind: kind,
  prayer: p,
  slotDate: date,
  timestamp: ts,
  count: count,
  inJamaah: jamaah,
);

PrayerLog _done(
  TrackedPrayer p,
  String date,
  DateTime ts, {
  int? id,
  bool jamaah = false,
}) => _log(PrayerLogKind.performed, p, date, ts, id: id, jamaah: jamaah);

void main() {
  final today = _day('2026-03-15');
  final tomorrow = _day('2026-03-16', fajrHour: 5);
  final slots = PrayerSlotResolver.slotsFor(today, tomorrow);

  group('PrayerSlotResolver', () {
    test('windows follow the roadmap table and Isha runs to next Fajr', () {
      expect(slots.map((s) => s.prayer), TrackedPrayer.values);
      expect(slots[0].start, today.fajr);
      expect(slots[0].end, today.sunrise);
      expect(slots[1].end, today.asr);
      expect(slots[2].end, today.maghrib);
      expect(slots[3].end, today.isha);
      expect(slots[4].end, tomorrow.fajr);
      expect(slots.every((s) => s.date == '2026-03-15'), isTrue);
      expect(slots[4].id, '2026-03-15/isha');
    });

    test('Isha after midnight still belongs to the start-date', () {
      final isha = slots[4];
      final afterMidnight = DateTime.utc(2026, 3, 16, 1);
      expect(isha.isOpenAt(afterMidnight), isTrue);
      expect(isha.date, '2026-03-15');
    });
  });

  group('slot status', () {
    final fajr = slots[0];
    test('upcoming / open / unrecorded by time, no logs', () {
      final w = PrayerTrackerCalculator.winningSlotLogs([]);
      SlotStatus at(DateTime t) =>
          PrayerTrackerCalculator.viewOf(fajr, w, t).status;
      expect(
        at(today.fajr.subtract(const Duration(minutes: 1))),
        SlotStatus.upcoming,
      );
      expect(at(today.fajr), SlotStatus.open);
      expect(at(today.sunrise), SlotStatus.unrecorded);
    });

    test('performed inside the window is on-time, after it is not', () {
      final early = _done(
        TrackedPrayer.fajr,
        '2026-03-15',
        today.fajr.add(const Duration(minutes: 5)),
        jamaah: true,
      );
      final late = _done(
        TrackedPrayer.fajr,
        '2026-03-15',
        today.sunrise.add(const Duration(minutes: 5)),
      );
      final now = today.dhuhr;
      final a = PrayerTrackerCalculator.viewOf(
        fajr,
        PrayerTrackerCalculator.winningSlotLogs([early]),
        now,
      );
      final b = PrayerTrackerCalculator.viewOf(
        fajr,
        PrayerTrackerCalculator.winningSlotLogs([late]),
        now,
      );
      expect(a.status, SlotStatus.performed);
      expect(a.onTime, isTrue);
      expect(a.inJamaah, isTrue);
      expect(b.status, SlotStatus.performed);
      expect(b.onTime, isFalse);
    });

    test('latest entry wins; ties go to the larger id', () {
      final t = today.fajr.add(const Duration(minutes: 5));
      final missed = _log(
        PrayerLogKind.missed,
        TrackedPrayer.fajr,
        '2026-03-15',
        t,
        id: 1,
      );
      final performed = _done(
        TrackedPrayer.fajr,
        '2026-03-15',
        t.add(const Duration(minutes: 1)),
        id: 2,
      );
      var w = PrayerTrackerCalculator.winningSlotLogs([missed, performed]);
      expect(w['2026-03-15/fajr']!.kind, PrayerLogKind.performed);
      w = PrayerTrackerCalculator.winningSlotLogs([performed, missed]);
      expect(w['2026-03-15/fajr']!.kind, PrayerLogKind.performed);

      final sameTsPerformed = _done(TrackedPrayer.fajr, '2026-03-15', t, id: 5);
      final sameTsMissed = _log(
        PrayerLogKind.missed,
        TrackedPrayer.fajr,
        '2026-03-15',
        t,
        id: 6,
      );
      w = PrayerTrackerCalculator.winningSlotLogs([
        sameTsMissed,
        sameTsPerformed,
      ]);
      expect(w['2026-03-15/fajr']!.kind, PrayerLogKind.missed);
    });
  });

  group('qadha balance', () {
    final t = DateTime.utc(2026, 3, 15, 10);
    test('baseline + missed − done, floored at zero per prayer', () {
      final logs = [
        _log(
          PrayerLogKind.qadhaBaseline,
          TrackedPrayer.fajr,
          null,
          t,
          count: 10,
        ),
        _log(PrayerLogKind.missed, TrackedPrayer.fajr, '2026-03-14', t),
        _log(PrayerLogKind.missed, TrackedPrayer.asr, '2026-03-14', t),
        _log(PrayerLogKind.qadhaDone, TrackedPrayer.fajr, null, t, count: 3),
        _log(PrayerLogKind.qadhaDone, TrackedPrayer.isha, null, t, count: 2),
      ];
      final b = PrayerTrackerCalculator.qadhaBalance(logs);
      expect(b[TrackedPrayer.fajr], 8);
      expect(b[TrackedPrayer.asr], 1);
      expect(b[TrackedPrayer.isha], 0); // never negative
      expect(PrayerTrackerCalculator.totalQadha(b), 9);
    });

    test('negative baseline reduces; a corrected miss no longer counts', () {
      final missed = _log(
        PrayerLogKind.missed,
        TrackedPrayer.dhuhr,
        '2026-03-14',
        t,
        id: 1,
      );
      final fixed = _done(
        TrackedPrayer.dhuhr,
        '2026-03-14',
        t.add(const Duration(hours: 1)),
        id: 2,
      );
      final logs = [
        _log(
          PrayerLogKind.qadhaBaseline,
          TrackedPrayer.dhuhr,
          null,
          t,
          count: 5,
        ),
        _log(
          PrayerLogKind.qadhaBaseline,
          TrackedPrayer.dhuhr,
          null,
          t,
          count: -2,
        ),
        missed,
        fixed,
      ];
      expect(
        PrayerTrackerCalculator.qadhaBalance(logs)[TrackedPrayer.dhuhr],
        3,
      );
    });
  });

  group('streak', () {
    List<PrayerLog> fullDay(String date) => [
      for (final p in TrackedPrayer.values)
        _done(
          p,
          date,
          DateTime.parse('${date}T00:00:00Z').add(const Duration(hours: 20)),
        ),
    ];

    test('counts consecutive complete days ending today', () {
      final logs = [
        ...fullDay('2026-03-13'),
        ...fullDay('2026-03-14'),
        ...fullDay('2026-03-15'),
      ];
      expect(PrayerTrackerCalculator.streakDays(logs, '2026-03-15'), 3);
    });

    test('today in progress does not break the streak', () {
      final logs = [
        ...fullDay('2026-03-13'),
        ...fullDay('2026-03-14'),
        _done(TrackedPrayer.fajr, '2026-03-15', DateTime.utc(2026, 3, 15, 5)),
      ];
      expect(PrayerTrackerCalculator.streakDays(logs, '2026-03-15'), 2);
    });

    test('a missed prayer or a gap ends the streak; month boundary works', () {
      final broken = [
        ...fullDay('2026-02-27'),
        ...fullDay('2026-02-28'),
        ...fullDay('2026-03-01'),
        // 2026-03-02 incomplete
        _log(
          PrayerLogKind.missed,
          TrackedPrayer.asr,
          '2026-03-02',
          DateTime.utc(2026, 3, 2, 20),
        ),
        ...fullDay('2026-03-03'),
      ];
      expect(PrayerTrackerCalculator.streakDays(broken, '2026-03-03'), 1);
      expect(PrayerTrackerCalculator.streakDays(broken, '2026-03-01'), 3);
      expect(PrayerTrackerCalculator.streakDays([], '2026-03-01'), 0);
    });

    test(
      'excused days are neutral: they neither count nor break the streak',
      () {
        final logs = [
          ...fullDay('2026-03-10'),
          ...fullDay('2026-03-11'),
          // 12th–14th excused, nothing logged
          ...fullDay('2026-03-15'),
        ];
        bool ex(String d) =>
            d.compareTo('2026-03-12') >= 0 && d.compareTo('2026-03-14') <= 0;
        expect(PrayerTrackerCalculator.streakDays(logs, '2026-03-15'), 1);
        expect(
          PrayerTrackerCalculator.streakDays(logs, '2026-03-15', isExcused: ex),
          3,
        );
        // Today excused with nothing logged: streak carries from before.
        expect(
          PrayerTrackerCalculator.streakDays(
            fullDay('2026-03-11'),
            '2026-03-13',
            isExcused: ex,
          ),
          1,
        );
      },
    );

    test('an open-ended excused period terminates', () {
      expect(
        PrayerTrackerCalculator.streakDays(
          [],
          '2026-03-15',
          isExcused: (_) => true,
        ),
        0,
      );
    });

    test(
      'excused flag turns an unlogged slot into excused, log still wins',
      () {
        final w = PrayerTrackerCalculator.winningSlotLogs([]);
        final v = PrayerTrackerCalculator.viewOf(
          slots[0],
          w,
          today.fajr.add(const Duration(minutes: 1)),
          excused: true,
        );
        expect(v.status, SlotStatus.excused);
        final done = PrayerTrackerCalculator.winningSlotLogs([
          _done(TrackedPrayer.fajr, '2026-03-15', today.fajr),
        ]);
        expect(
          PrayerTrackerCalculator.viewOf(
            slots[0],
            done,
            today.sunrise,
            excused: true,
          ).status,
          SlotStatus.performed,
        );
      },
    );

    test('stats tally performed, jama\'ah and missed', () {
      final logs = [
        _done(
          TrackedPrayer.fajr,
          '2026-03-15',
          DateTime.utc(2026, 3, 15, 5),
          jamaah: true,
        ),
        _done(TrackedPrayer.dhuhr, '2026-03-15', DateTime.utc(2026, 3, 15, 12)),
        _log(
          PrayerLogKind.missed,
          TrackedPrayer.asr,
          '2026-03-15',
          DateTime.utc(2026, 3, 15, 19),
        ),
      ];
      final s = PrayerTrackerCalculator.stats(logs, '2026-03-15');
      expect(s.performed, 2);
      expect(s.inJamaah, 1);
      expect(s.missed, 1);
    });
  });

  test('PrayerLog map round-trip', () {
    final l = _log(
      PrayerLogKind.qadhaBaseline,
      TrackedPrayer.maghrib,
      null,
      DateTime.fromMillisecondsSinceEpoch(1700000000000),
      count: -4,
      id: 7,
    );
    final r = PrayerLog.fromMap(l.toMap());
    expect(r.kind, l.kind);
    expect(r.prayer, l.prayer);
    expect(r.slotDate, isNull);
    expect(r.count, -4);
    expect(r.timestamp, l.timestamp);
    expect(r.id, 7);
  });
}

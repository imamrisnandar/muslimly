import 'package:flutter_test/flutter_test.dart';
import 'package:muslimly/src/features/quran/domain/entities/hafalan_session.dart';
import 'package:muslimly/src/features/quran/domain/utils/muraja_ah_scheduler.dart';

HafalanSession _session({
  int surahNumber = 1,
  int pageNumber = 1,
  required double accuracy,
  required int daysAgo,
  required DateTime now,
}) {
  final date = now.subtract(Duration(days: daysAgo));
  return HafalanSession(
    surahNumber: surahNumber,
    pageNumber: pageNumber,
    startAyah: 1,
    endAyah: 5,
    ayahCount: 5,
    accuracy: accuracy,
    date: date.toIso8601String().substring(0, 10),
    timestamp: date.millisecondsSinceEpoch,
  );
}

void main() {
  final now = DateTime(2026, 9, 12);

  group('calculateUnitState', () {
    test('returns null for an empty session list', () {
      expect(MurajaahScheduler.calculateUnitState([]), isNull);
    });

    test('first session (pass or fail) always lands on box 1', () {
      final failing = MurajaahScheduler.calculateUnitState([
        _session(accuracy: 0.1, daysAgo: 0, now: now),
      ]);
      expect(failing!.box, 1);

      final passing = MurajaahScheduler.calculateUnitState([
        _session(accuracy: 0.9, daysAgo: 0, now: now),
      ]);
      expect(passing!.box, 1);
    });

    test('consecutive passes climb the box ladder: 1 → 2 → 3', () {
      final sessions = [
        _session(accuracy: 0.9, daysAgo: 10, now: now), // box 1
        _session(accuracy: 0.9, daysAgo: 5, now: now), // box 2
        _session(accuracy: 0.9, daysAgo: 1, now: now), // box 3
      ];
      final unit = MurajaahScheduler.calculateUnitState(sessions)!;
      expect(unit.box, 3);
      // box 3 → interval +7 days from the last (1 day ago) session.
      expect(unit.dueDate, unit.lastSessionDate.add(const Duration(days: 7)));
    });

    test('a fail resets the box back to 1, even after climbing', () {
      final sessions = [
        _session(accuracy: 0.9, daysAgo: 10, now: now), // box 1
        _session(accuracy: 0.9, daysAgo: 5, now: now), // box 2
        _session(accuracy: 0.2, daysAgo: 1, now: now), // fail → box 1
      ];
      final unit = MurajaahScheduler.calculateUnitState(sessions)!;
      expect(unit.box, 1);
      expect(unit.dueDate, unit.lastSessionDate.add(const Duration(days: 1)));
    });

    test('box is capped at 5 (H+30) and never climbs further', () {
      final sessions = List.generate(
        8,
        (i) => _session(accuracy: 0.95, daysAgo: 50 - i * 5, now: now),
      );
      final unit = MurajaahScheduler.calculateUnitState(sessions)!;
      expect(unit.box, 5);
      expect(unit.dueDate, unit.lastSessionDate.add(const Duration(days: 30)));
    });

    test(
      'replay order does not depend on input order (sorted by timestamp)',
      () {
        final chronological = [
          _session(accuracy: 0.9, daysAgo: 10, now: now),
          _session(accuracy: 0.9, daysAgo: 5, now: now),
        ];
        final shuffled = chronological.reversed.toList();

        final a = MurajaahScheduler.calculateUnitState(chronological)!;
        final b = MurajaahScheduler.calculateUnitState(shuffled)!;
        expect(a.box, b.box);
        expect(a.dueDate, b.dueDate);
      },
    );
  });

  group('calculateDueUnits', () {
    test('a unit due exactly today is included', () {
      // box 1 → +1 day interval; last session 1 day ago → due today.
      final sessions = [_session(accuracy: 0.9, daysAgo: 1, now: now)];
      final due = MurajaahScheduler.calculateDueUnits(sessions, now: now);
      expect(due, hasLength(1));
      expect(due.first.pageNumber, 1);
    });

    test('a unit not yet due is excluded', () {
      // Last session today, box 1 → due tomorrow, not today.
      final sessions = [_session(accuracy: 0.9, daysAgo: 0, now: now)];
      final due = MurajaahScheduler.calculateDueUnits(sessions, now: now);
      expect(due, isEmpty);
    });

    test('different (surah, page) units are scheduled independently', () {
      final sessions = [
        _session(
          surahNumber: 1,
          pageNumber: 1,
          accuracy: 0.9,
          daysAgo: 1,
          now: now,
        ), // due
        _session(
          surahNumber: 2,
          pageNumber: 20,
          accuracy: 0.9,
          daysAgo: 0,
          now: now,
        ), // not due
      ];
      final due = MurajaahScheduler.calculateDueUnits(sessions, now: now);
      expect(due, hasLength(1));
      expect(due.first.surahNumber, 1);
      expect(due.first.pageNumber, 1);
    });

    test('results are sorted most-overdue first', () {
      final sessions = [
        _session(
          surahNumber: 1,
          pageNumber: 1,
          accuracy: 0.9,
          daysAgo: 2,
          now: now,
        ), // due yesterday already (box1, +1d)
        _session(
          surahNumber: 2,
          pageNumber: 20,
          accuracy: 0.9,
          daysAgo: 10,
          now: now,
        ), // very overdue
      ];
      final due = MurajaahScheduler.calculateDueUnits(sessions, now: now);
      expect(due, hasLength(2));
      expect(due.first.pageNumber, 20); // most overdue first
    });
  });
}

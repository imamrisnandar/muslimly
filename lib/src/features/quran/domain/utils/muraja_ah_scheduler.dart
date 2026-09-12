import '../entities/hafalan_session.dart';
import 'arabic_text_matcher.dart';

/// One (surah, halaman) unit's current spaced-repetition state, derived
/// purely from its session history.
class MurajaahUnit {
  final int surahNumber;
  final int pageNumber;

  /// Leitner box level, 1 (review tomorrow) through 5 (review in a month).
  final int box;

  final DateTime lastSessionDate;
  final DateTime dueDate;

  const MurajaahUnit({
    required this.surahNumber,
    required this.pageNumber,
    required this.box,
    required this.lastSessionDate,
    required this.dueDate,
  });
}

/// Leitner-box muraja'ah (review) scheduling, replayed purely from the
/// hafalan_sessions log — no box-level field stored anywhere (see
/// HAFALAN_TRACKER_PLAN.md §C). Same "fold over an immutable log" shape as
/// the reading streak calculation and HafalanProgressCalculator.
///
/// Review unit is (surah, halaman) — matching A's logging granularity, not
/// a whole surah, so box level never gets muddled across pages read on
/// different days.
///
/// Performance note: unlike the streak scan (bounded to ~30-90 days), this
/// replays a unit's ENTIRE history. Compute once per app-session load (e.g.
/// inside HafalanProgressCubit) and cache in memory — never inside a
/// widget's build().
class MurajaahScheduler {
  const MurajaahScheduler._();

  static const Map<int, int> _boxIntervalDays = {
    1: 1,
    2: 3,
    3: 7,
    4: 14,
    5: 30,
  };

  static DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  /// Replays [sessions] for a SINGLE (surah, halaman) unit (any order) and
  /// returns its current Leitner state, or null if [sessions] is empty.
  static MurajaahUnit? calculateUnitState(List<HafalanSession> sessions) {
    if (sessions.isEmpty) return null;

    final sorted = List<HafalanSession>.from(sessions)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    int box = 1;
    for (int i = 0; i < sorted.length; i++) {
      final session = sorted[i];
      if (i == 0) {
        // First-ever session on this unit always lands on box 1, pass or
        // fail — there's nowhere lower to reset to.
        box = 1;
      } else if (ArabicTextMatcher.isPass(session.accuracy)) {
        box = box >= 5 ? 5 : box + 1;
      } else {
        box = 1;
      }
    }

    final last = sorted.last;
    final lastDate = _dateOnly(
      DateTime.fromMillisecondsSinceEpoch(last.timestamp),
    );
    final dueDate = lastDate.add(Duration(days: _boxIntervalDays[box]!));

    return MurajaahUnit(
      surahNumber: last.surahNumber,
      pageNumber: last.pageNumber,
      box: box,
      lastSessionDate: lastDate,
      dueDate: dueDate,
    );
  }

  /// Every (surah, halaman) unit across the full [sessions] log that is due
  /// for review today or overdue, most-overdue first. [now] is injectable
  /// for tests; defaults to the real current time.
  static List<MurajaahUnit> calculateDueUnits(
    List<HafalanSession> sessions, {
    DateTime? now,
  }) {
    final today = _dateOnly(now ?? DateTime.now());

    final byUnit = <String, List<HafalanSession>>{};
    for (final session in sessions) {
      final key = '${session.surahNumber}:${session.pageNumber}';
      byUnit.putIfAbsent(key, () => []).add(session);
    }

    final due = <MurajaahUnit>[];
    for (final unitSessions in byUnit.values) {
      final unit = calculateUnitState(unitSessions);
      if (unit != null && !unit.dueDate.isAfter(today)) {
        due.add(unit);
      }
    }

    due.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return due;
  }
}

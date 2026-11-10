import 'dart:convert';
import 'package:hijri/hijri_calendar.dart';

/// Number of pages in the Madinah mushaf used by the app.
const int kMushafPages = 604;

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// A user-chosen reading plan. [offWeekdays] uses `DateTime.weekday`
/// (1 = Monday ... 7 = Sunday): days the user does not plan to read.
class KhatamPlan {
  final DateTime start;
  final DateTime target;
  final int khatamCount;
  final Set<int> offWeekdays;

  const KhatamPlan({
    required this.start,
    required this.target,
    this.khatamCount = 1,
    this.offWeekdays = const {},
  });

  int get totalPages => kMushafPages * khatamCount;

  Map<String, Object?> toJson() => {
    'start': dateOnly(start).toIso8601String(),
    'target': dateOnly(target).toIso8601String(),
    'khatamCount': khatamCount,
    'off': offWeekdays.toList()..sort(),
  };

  factory KhatamPlan.fromJson(Map<String, dynamic> j) => KhatamPlan(
    start: DateTime.parse(j['start'] as String),
    target: DateTime.parse(j['target'] as String),
    khatamCount: (j['khatamCount'] as num?)?.toInt() ?? 1,
    offWeekdays: ((j['off'] as List?) ?? const [])
        .map((e) => (e as num).toInt())
        .toSet(),
  );

  static KhatamPlan? decode(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      return KhatamPlan.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  String encode() => jsonEncode(toJson());
}

class KhatamProgress {
  final int totalPages;
  final int pagesRead;
  final int pagesRemaining;
  final int remainingReadingDays;

  /// Pages to read today to stay on track (ceil of remaining / days left).
  final int dailyTarget;
  final int pagesPerPrayer;

  /// Pages behind a straight-line schedule. 0 when on track or ahead.
  final int behindBy;
  final bool finished;
  final bool notStarted;

  /// Target date has passed but the plan is not finished.
  final bool overdue;

  const KhatamProgress({
    required this.totalPages,
    required this.pagesRead,
    required this.pagesRemaining,
    required this.remainingReadingDays,
    required this.dailyTarget,
    required this.pagesPerPrayer,
    required this.behindBy,
    required this.finished,
    required this.notStarted,
    required this.overdue,
  });

  double get fraction => totalPages == 0 ? 0 : pagesRead / totalPages;
}

class KhatamCalculator {
  /// Count of days in [from]..[to] (inclusive, date-only) that are not off.
  static int readingDays(DateTime from, DateTime to, Set<int> off) {
    var d = dateOnly(from);
    final end = dateOnly(to);
    var n = 0;
    while (!d.isAfter(end)) {
      if (!off.contains(d.weekday)) n++;
      d = DateTime(d.year, d.month, d.day + 1);
    }
    return n;
  }

  static KhatamProgress compute({
    required KhatamPlan plan,
    required int pagesRead,
    required DateTime today,
  }) {
    final t = dateOnly(today);
    final total = plan.totalPages;
    final read = pagesRead.clamp(0, total);
    final remaining = total - read;
    final startsLater = t.isBefore(dateOnly(plan.start));
    final from = startsLater ? dateOnly(plan.start) : t;
    final remainingDays = readingDays(from, plan.target, plan.offWeekdays);
    final totalDays = readingDays(plan.start, plan.target, plan.offWeekdays);
    final elapsed = startsLater
        ? 0
        : readingDays(
            plan.start,
            DateTime(t.year, t.month, t.day - 1),
            plan.offWeekdays,
          );
    final expected = totalDays == 0 ? 0 : (total * elapsed) ~/ totalDays;
    final behind = (expected - read).clamp(0, total);
    final daily = remaining == 0
        ? 0
        : (remainingDays > 0
              ? (remaining + remainingDays - 1) ~/ remainingDays
              : remaining);
    return KhatamProgress(
      totalPages: total,
      pagesRead: read,
      pagesRemaining: remaining,
      remainingReadingDays: remainingDays,
      dailyTarget: daily,
      pagesPerPrayer: (daily + 4) ~/ 5,
      behindBy: remaining == 0 ? 0 : behind,
      finished: remaining == 0,
      notStarted: startsLater,
      overdue: remaining > 0 && remainingDays == 0 && !startsLater,
    );
  }

  /// First and 29th of Ramadan for the next (or current) Ramadan, as
  /// Gregorian dates. The 29th is used as the conservative end because the
  /// month can have 29 or 30 days. [adjustDays] shifts both for the local
  /// moon-sighting decision.
  static ({DateTime start, DateTime end}) nextRamadan(
    DateTime now, {
    int adjustDays = 0,
  }) {
    var year = HijriCalendar.fromDate(now).hYear;
    ({DateTime start, DateTime end}) build(int y) {
      final cal = HijriCalendar();
      final s = dateOnly(cal.hijriToGregorian(y, 9, 1));
      final e = dateOnly(cal.hijriToGregorian(y, 9, 29));
      return (
        start: DateTime(s.year, s.month, s.day + adjustDays),
        end: DateTime(e.year, e.month, e.day + adjustDays),
      );
    }

    var r = build(year);
    if (r.end.isBefore(dateOnly(now))) r = build(++year);
    return r;
  }
}

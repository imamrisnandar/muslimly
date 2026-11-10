import '../entities/prayer_log.dart';

enum QadhaPattern {
  /// Never prayed during the period: every day counts for every prayer.
  never,

  /// Prayed some days: [QadhaEstimateInput.prayedPerWeek] per prayer.
  sometimes,
}

class QadhaEstimateInput {
  /// First day the obligation applied (e.g. baligh).
  final DateTime from;

  /// Day regular prayer began (exclusive end of the period).
  final DateTime to;
  final QadhaPattern pattern;

  /// For [QadhaPattern.sometimes]: how many days per week each prayer was
  /// prayed (0–7). Missing prayers default to 0.
  final Map<TrackedPrayer, int> prayedPerWeek;

  /// Optional correction: average days per month with a valid excuse (e.g.
  /// haid/nifas) that are NOT owed. 0 = no correction.
  final double excusedDaysPerMonth;

  const QadhaEstimateInput({
    required this.from,
    required this.to,
    this.pattern = QadhaPattern.never,
    this.prayedPerWeek = const {},
    this.excusedDaysPerMonth = 0,
  });
}

/// Pure estimate of an old qadha debt. A recording aid, not a fatwa: rules
/// differ between madhhabs and the user can edit every number afterwards.
class QadhaEstimator {
  QadhaEstimator._();

  static const double _daysPerMonth = 30.4375;

  static int periodDays(DateTime from, DateTime to) {
    final a = DateTime.utc(from.year, from.month, from.day);
    final b = DateTime.utc(to.year, to.month, to.day);
    final d = b.difference(a).inDays;
    return d < 0 ? 0 : d;
  }

  static Map<TrackedPrayer, int> estimate(QadhaEstimateInput i) {
    final days = periodDays(i.from, i.to);
    var excused = (i.excusedDaysPerMonth.clamp(0, 31) * days / _daysPerMonth)
        .round();
    if (excused > days) excused = days;
    final owed = days - excused;

    return {
      for (final p in TrackedPrayer.values)
        p: i.pattern == QadhaPattern.never
            ? owed
            : (owed * (7 - (i.prayedPerWeek[p] ?? 0).clamp(0, 7)) / 7).round(),
    };
  }
}

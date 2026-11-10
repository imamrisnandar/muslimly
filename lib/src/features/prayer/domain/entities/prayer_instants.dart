/// Absolute moments (UTC) of the six daily prayer times, as opposed to the
/// zone-dependent `'HH:mm'` strings in `PrayerTime`. Widgets, the tracker and
/// travel mode need these so they stay correct across time zones.
class PrayerInstants {
  /// Calendar date (`yyyy-MM-dd`) these times were computed for.
  final String date;
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;

  /// Non-null when the sun never rises/sets at the real latitude (polar day or
  /// night) and the times were computed at this nearer latitude instead
  /// (same sign, same longitude). Times are then an approximation, and the UI
  /// should say so.
  final double? fallbackLatitude;

  PrayerInstants({
    required this.date,
    required DateTime fajr,
    required DateTime sunrise,
    required DateTime dhuhr,
    required DateTime asr,
    required DateTime maghrib,
    required DateTime isha,
    this.fallbackLatitude,
  }) : fajr = fajr.toUtc(),
       sunrise = sunrise.toUtc(),
       dhuhr = dhuhr.toUtc(),
       asr = asr.toUtc(),
       maghrib = maghrib.toUtc(),
       isha = isha.toUtc();

  @override
  bool operator ==(Object other) =>
      other is PrayerInstants &&
      other.date == date &&
      other.fajr == fajr &&
      other.sunrise == sunrise &&
      other.dhuhr == dhuhr &&
      other.asr == asr &&
      other.maghrib == maghrib &&
      other.isha == isha &&
      other.fallbackLatitude == fallbackLatitude;

  @override
  int get hashCode => Object.hash(
    date,
    fajr,
    sunrise,
    dhuhr,
    asr,
    maghrib,
    isha,
    fallbackLatitude,
  );

  @override
  String toString() =>
      'PrayerInstants($date fajr=$fajr sunrise=$sunrise dhuhr=$dhuhr '
      'asr=$asr maghrib=$maghrib isha=$isha)';
}

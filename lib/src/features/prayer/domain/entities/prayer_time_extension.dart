import 'package:hijri/hijri_calendar.dart';
import 'prayer_time.dart';

extension PrayerTimeX on PrayerTime {
  String getHijriDate() {
    try {
      final now = DateTime.now();
      final hijri = HijriCalendar.fromDate(now);
      return "${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear} H";
    } catch (e) {
      return "-";
    }
  }

  Map<String, dynamic> getNextPrayer(dynamic l10n) {
    // NOTE: l10n is dynamic to avoid circular dependencies if we import the generated file here directly.
    // In practice, we know it's AppLocalizations.

    final now = DateTime.now();
    // Helper to parse "HH:mm" time strings
    DateTime parseTime(String timeStr) {
      final parts = timeStr.split(':');
      return DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
    }

    final prayers = [
      {'name': 'Subuh', 'time': subuh, 'dt': parseTime(subuh)},
      {'name': 'Dzuhur', 'time': dzuhur, 'dt': parseTime(dzuhur)},
      {'name': 'Ashar', 'time': ashar, 'dt': parseTime(ashar)},
      {'name': 'Maghrib', 'time': maghrib, 'dt': parseTime(maghrib)},
      {'name': 'Isya', 'time': isya, 'dt': parseTime(isya)},
    ];

    // Find next prayer
    for (var p in prayers) {
      final dt = p['dt'] as DateTime;
      if (dt.isAfter(now)) {
        final diff = dt.difference(now);
        final hours = diff.inHours;
        final minutes = diff.inMinutes % 60;

        // Use localization for time left
        final timeLeft = l10n.timeRemaining(hours, minutes);

        return {
          'name':
              p['name'], // Name logic might need update if we want localized prayer names here too
          'time': p['time'],
          'timeLeft': timeLeft,
          'nextPrayerTime': dt,
          'isTomorrow': false,
        };
      }
    }

    // If none found (after Isha), show Fajr for next day
    final fajr = prayers[0];
    final fajrTime = fajr['dt'] as DateTime;
    final nextFajr = fajrTime.add(const Duration(days: 1));

    return {
      'name': fajr['name'],
      'time': fajr['time'],
      'timeLeft': l10n.untilTomorrow,
      'nextPrayerTime': nextFajr,
      'isTomorrow': true,
    };
  }
}

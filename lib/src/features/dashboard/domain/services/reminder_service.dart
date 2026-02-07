import 'package:intl/intl.dart';
import '../../../prayer/domain/services/fasting_service.dart';
import '../../../prayer/domain/entities/prayer_time.dart';
import '../models/reminder_models.dart';

class ReminderService {
  final FastingService _fastingService;

  ReminderService(this._fastingService);

  /// Get complete reminder card data
  ReminderCardData getReminderData(
    PrayerTime prayerTime,
    DateTime currentTime,
  ) {
    // Convert PrayerTime to Map for easier access
    final prayerTimes = {
      'Imsak': prayerTime.imsak,
      'Subuh': prayerTime.subuh,
      'Fajr': prayerTime.subuh,
      'Terbit': prayerTime.terbit,
      'Dzuhur': prayerTime.dzuhur,
      'Dhuhr': prayerTime.dzuhur,
      'Ashar': prayerTime.ashar,
      'Asr': prayerTime.ashar,
      'Maghrib': prayerTime.maghrib,
      'Isya': prayerTime.isya,
      'Isha': prayerTime.isya,
    };

    return ReminderCardData(
      todayFasting: _getTodayFasting(currentTime, prayerTimes),
      nextFasting: _getNextFasting(currentTime),
      morningDzikir: _getMorningDzikirReminder(prayerTimes, currentTime),
      eveningDzikir: _getEveningDzikirReminder(prayerTimes, currentTime),
      currentTime: currentTime,
    );
  }

  /// Get today's fasting info if applicable
  FastingReminder? _getTodayFasting(
    DateTime date,
    Map<String, String> prayerTimes,
  ) {
    final event = _fastingService.getFastingEvent(date);
    if (event == FastingEvent.none) return null;

    final type = _fastingService.getFastingType(date);
    final eventName = _getEventName(event);

    // Get Maghrib time for iftar countdown
    DateTime? iftarTime;
    Duration? timeUntilIftar;

    if (prayerTimes.containsKey('Maghrib')) {
      try {
        final maghribStr = prayerTimes['Maghrib']!;
        final parts = maghribStr.split(':');
        iftarTime = DateTime(
          date.year,
          date.month,
          date.day,
          int.parse(parts[0]),
          int.parse(parts[1]),
        );

        if (iftarTime.isAfter(date)) {
          timeUntilIftar = iftarTime.difference(date);
        }
      } catch (e) {
        // Ignore parsing errors
      }
    }

    return FastingReminder(
      type: eventName,
      event: event,
      fastingTypeName: type.name,
      date: date,
      isToday: true,
      iftarTime: iftarTime,
      timeUntilIftar: timeUntilIftar,
    );
  }

  /// Get next fasting event
  FastingReminder? _getNextFasting(DateTime currentDate) {
    // Check next 30 days for a fasting event
    for (int i = 1; i <= 30; i++) {
      final checkDate = currentDate.add(Duration(days: i));
      final event = _fastingService.getFastingEvent(checkDate);

      if (event != FastingEvent.none) {
        final type = _fastingService.getFastingType(checkDate);
        final eventName = _getEventName(event);

        return FastingReminder(
          type: eventName,
          event: event,
          fastingTypeName: type.name,
          date: checkDate,
          isToday: false,
        );
      }
    }

    return null;
  }

  /// Get morning dzikir reminder
  DzikirReminder _getMorningDzikirReminder(
    Map<String, String> prayerTimes,
    DateTime currentTime,
  ) {
    // Default to 6:00 AM if no Subuh time
    DateTime scheduledTime = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day,
      6,
      0,
    );

    DateTime? endTime;

    // Calculate from Subuh + 15 minutes
    if (prayerTimes.containsKey('Subuh') || prayerTimes.containsKey('Fajr')) {
      try {
        final subuhStr = prayerTimes['Subuh'] ?? prayerTimes['Fajr'] ?? '05:00';
        final parts = subuhStr.split(':');
        scheduledTime = DateTime(
          currentTime.year,
          currentTime.month,
          currentTime.day,
          int.parse(parts[0]),
          int.parse(parts[1]),
        ).add(const Duration(minutes: 15));

        // End time is Dzuhur (morning dzikir should be done before Dzuhur)
        if (prayerTimes.containsKey('Dzuhur') ||
            prayerTimes.containsKey('Dhuhr')) {
          final dzuhurStr =
              prayerTimes['Dzuhur'] ?? prayerTimes['Dhuhr'] ?? '12:00';
          final dzuhurParts = dzuhurStr.split(':');
          endTime = DateTime(
            currentTime.year,
            currentTime.month,
            currentTime.day,
            int.parse(dzuhurParts[0]),
            int.parse(dzuhurParts[1]),
          );
        }
      } catch (e) {
        // Use default
      }
    }

    // Default window until Dzuhur or 6 hours
    final window = endTime != null
        ? endTime.difference(scheduledTime)
        : const Duration(hours: 6);

    return _calculateDzikirStatus(
      DzikirType.morning,
      scheduledTime,
      currentTime,
      window,
    );
  }

  /// Get evening dzikir reminder
  DzikirReminder _getEveningDzikirReminder(
    Map<String, String> prayerTimes,
    DateTime currentTime,
  ) {
    // Default to 4:00 PM if no Ashar time
    DateTime scheduledTime = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day,
      16,
      0,
    );

    DateTime? endTime;

    // Calculate from Ashar + 15 minutes
    if (prayerTimes.containsKey('Ashar') || prayerTimes.containsKey('Asr')) {
      try {
        final asharStr = prayerTimes['Ashar'] ?? prayerTimes['Asr'] ?? '15:30';
        final parts = asharStr.split(':');
        scheduledTime = DateTime(
          currentTime.year,
          currentTime.month,
          currentTime.day,
          int.parse(parts[0]),
          int.parse(parts[1]),
        ).add(const Duration(minutes: 15));

        // End time is Maghrib
        if (prayerTimes.containsKey('Maghrib')) {
          final maghribStr = prayerTimes['Maghrib']!;
          final maghribParts = maghribStr.split(':');
          endTime = DateTime(
            currentTime.year,
            currentTime.month,
            currentTime.day,
            int.parse(maghribParts[0]),
            int.parse(maghribParts[1]),
          );
        }
      } catch (e) {
        // Use default
      }
    }

    // Default window until Maghrib or 2 hours
    final window = endTime != null
        ? endTime.difference(scheduledTime)
        : const Duration(hours: 2);

    return _calculateDzikirStatus(
      DzikirType.evening,
      scheduledTime,
      currentTime,
      window,
    );
  }

  /// Calculate dzikir status based on time
  DzikirReminder _calculateDzikirStatus(
    DzikirType type,
    DateTime scheduledTime,
    DateTime currentTime,
    Duration window,
  ) {
    final endTime = scheduledTime.add(window);

    DzikirStatus status;
    Duration? timeUntil;
    Duration? timeSince;
    bool isActiveNow = false;

    if (currentTime.isBefore(scheduledTime)) {
      // Pending
      status = DzikirStatus.pending;
      timeUntil = scheduledTime.difference(currentTime);
    } else if (currentTime.isAfter(endTime)) {
      // Missed or completed (we'll assume missed, can be updated later)
      status = DzikirStatus.missed;
      timeSince = currentTime.difference(scheduledTime);
    } else {
      // Active
      status = DzikirStatus.active;
      timeSince = currentTime.difference(scheduledTime);
      isActiveNow = true;
    }

    return DzikirReminder(
      type: type,
      scheduledTime: scheduledTime,
      status: status,
      timeUntil: timeUntil,
      timeSince: timeSince,
      isActiveNow: isActiveNow,
    );
  }

  /// Format time duration for display
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '${hours}j ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  /// Format time for display (HH:mm)
  static String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  /// Format date for display
  static String formatDate(DateTime date, String locale) {
    final dayName = DateFormat('EEEE', locale).format(date);
    final dateStr = DateFormat('d MMM', locale).format(date);
    return '$dayName, $dateStr';
  }

  /// Get event name from FastingEvent
  String _getEventName(FastingEvent event) {
    switch (event) {
      case FastingEvent.ramadan:
        return 'Ramadan';
      case FastingEvent.arafah:
        return 'Arafah';
      case FastingEvent.ashura:
        return 'Asyura';
      case FastingEvent.tasua:
        return "Tasu'a";
      case FastingEvent.ayyamulBidh:
        return 'Ayyamul Bidh';
      case FastingEvent.monday:
        return 'Senin';
      case FastingEvent.thursday:
        return 'Kamis';
      case FastingEvent.eidFitr:
        return 'Idul Fitri';
      case FastingEvent.eidAdha:
        return 'Idul Adha';
      case FastingEvent.tasyrik:
        return 'Tasyrik';
      default:
        return '';
    }
  }
}

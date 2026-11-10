import '../../../prayer/domain/entities/prayer_instants.dart';
import '../entities/prayer_log.dart';
import '../entities/prayer_slot.dart';

/// Pure: builds slot windows from absolute prayer instants.
///
///   Fajr    fajr    → sunrise
///   Dhuhr   dhuhr   → asr
///   Asr     asr     → maghrib
///   Maghrib maghrib → isha
///   Isha    isha    → next day's fajr
class PrayerSlotResolver {
  PrayerSlotResolver._();

  static List<PrayerSlot> slotsFor(PrayerInstants day, PrayerInstants nextDay) {
    PrayerSlot s(TrackedPrayer p, DateTime a, DateTime b) =>
        PrayerSlot(date: day.date, prayer: p, start: a, end: b);
    return [
      s(TrackedPrayer.fajr, day.fajr, day.sunrise),
      s(TrackedPrayer.dhuhr, day.dhuhr, day.asr),
      s(TrackedPrayer.asr, day.asr, day.maghrib),
      s(TrackedPrayer.maghrib, day.maghrib, day.isha),
      s(TrackedPrayer.isha, day.isha, nextDay.fajr),
    ];
  }
}

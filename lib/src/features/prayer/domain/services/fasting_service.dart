import 'package:hijri/hijri_calendar.dart';

enum FastingType {
  none,
  wajib, // Ramadan
  sunnah, // Senin-Kamis, Ayyamul Bidh, Arafah, Asyura
  haram, // Eid, Tasyrik
}

enum FastingEvent {
  none,
  ramadan,
  arafah,
  ashura,
  tasua,
  ayyamulBidh,
  monday,
  thursday,
  eidFitr,
  eidAdha,
  tasyrik,
}

class FastingService {
  /// Determine the fasting type for a given Gregorian date
  FastingType getFastingType(DateTime date) {
    final event = getFastingEvent(date);
    switch (event) {
      case FastingEvent.eidFitr:
      case FastingEvent.eidAdha:
      case FastingEvent.tasyrik:
        return FastingType.haram;
      case FastingEvent.ramadan:
        return FastingType.wajib;
      case FastingEvent.arafah:
      case FastingEvent.ashura:
      case FastingEvent.tasua:
      case FastingEvent.ayyamulBidh:
      case FastingEvent.monday:
      case FastingEvent.thursday:
        return FastingType.sunnah;
      default:
        return FastingType.none;
    }
  }

  /// Get the specific fasting event for a date
  FastingEvent getFastingEvent(DateTime date) {
    final hijri = HijriCalendar.fromDate(date);

    // 1. Check Haram Days first (Forbidden to fast)
    // Eid Al-Fitr: 1 Syawal (Month 10, Day 1)
    if (hijri.hMonth == 10 && hijri.hDay == 1) {
      return FastingEvent.eidFitr;
    }
    // Eid Al-Adha: 10 Dzulhijjah (Month 12, Day 10)
    if (hijri.hMonth == 12 && hijri.hDay == 10) {
      return FastingEvent.eidAdha;
    }
    // Tasyrik Days: 11, 12, 13 Dzulhijjah (Month 12)
    if (hijri.hMonth == 12 && (hijri.hDay >= 11 && hijri.hDay <= 13)) {
      return FastingEvent.tasyrik;
    }

    // 2. Check Wajib (Mandatory)
    // Ramadan: Month 9
    if (hijri.hMonth == 9) {
      return FastingEvent.ramadan;
    }

    // 3. Check Sunnah (Recommended)
    // Arafah: 9 Dzulhijjah (Month 12)
    if (hijri.hMonth == 12 && hijri.hDay == 9) {
      return FastingEvent.arafah;
    }
    // Asyura: 10 Muharram (Month 1)
    if (hijri.hMonth == 1 && hijri.hDay == 10) {
      return FastingEvent.ashura;
    }
    // Tasu'a: 9 Muharram (Month 1) - Optional but common sunnah
    if (hijri.hMonth == 1 && hijri.hDay == 9) {
      return FastingEvent.tasua;
    }
    // Ayyamul Bidh: 13, 14, 15 of any month (Except if it overlaps with Haram)
    if (hijri.hDay >= 13 && hijri.hDay <= 15) {
      return FastingEvent.ayyamulBidh;
    }
    // Monday (1) & Thursday (4)
    if (date.weekday == 1) {
      return FastingEvent.monday;
    }
    if (date.weekday == 4) {
      return FastingEvent.thursday;
    }

    return FastingEvent.none;
  }
}

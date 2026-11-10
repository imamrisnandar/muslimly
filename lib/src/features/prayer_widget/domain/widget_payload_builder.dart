import '../../prayer/domain/entities/prayer_instants.dart';
import '../../prayer_tracker/domain/entities/prayer_log.dart';
import '../../prayer_tracker/domain/utils/prayer_slot_resolver.dart';

/// Pure: builds the JSON-able map the Android widget reads from
/// SharedPreferences. The widget never runs Dart, so everything it needs —
/// absolute start/end epochs for several days, plus localized labels — is
/// precomputed here. "Next prayer" is decided natively at render time.
/// Already-localized date strings for one day, shown in the widget header.
class WidgetDateLabels {
  final String hijri; // e.g. "30 Jumada Al-Awwal 1448 H"
  final String gregorian; // e.g. "Selasa, 10 November 2026"
  final String gregorianShort; // e.g. "10 Nov"
  const WidgetDateLabels({
    required this.hijri,
    required this.gregorian,
    required this.gregorianShort,
  });
}

class WidgetPayloadBuilder {
  WidgetPayloadBuilder._();

  /// Days of schedule written ahead, so the widget stays correct for a week
  /// even if the app and the daily job never run.
  static const int daysAhead = 7;

  /// [performedSlotIds] holds `PrayerSlot.id`s (`yyyy-MM-dd/fajr`) the user
  /// checked in. Only a plain done flag reaches the widget: missed/excused
  /// states are deliberately not written to the home screen.
  ///
  /// [days] must hold `daysAhead + 1` consecutive days (the extra day closes
  /// the last Isha window).
  static Map<String, dynamic> build({
    required List<PrayerInstants> days,
    required String cityName,
    required String methodKey,
    required DateTime generatedAt,
    required Map<String, String> labels,
    Set<String> performedSlotIds = const {},
    Map<String, WidgetDateLabels> dateLabels = const {},
  }) {
    assert(days.length >= 2);
    return {
      'generatedAt': generatedAt.toUtc().millisecondsSinceEpoch,
      'cityName': cityName,
      'methodKey': methodKey,
      'labels': labels,
      'days': [
        for (var i = 0; i < days.length - 1; i++)
          {
            'date': days[i].date,
            if (dateLabels[days[i].date] != null) ...{
              'hijri': dateLabels[days[i].date]!.hijri,
              'gregorian': dateLabels[days[i].date]!.gregorian,
              'gregorianShort': dateLabels[days[i].date]!.gregorianShort,
            },
            'prayers': [
              for (final s in PrayerSlotResolver.slotsFor(days[i], days[i + 1]))
                {
                  'key': s.prayer.key,
                  'startEpochMs': s.start.millisecondsSinceEpoch,
                  'endEpochMs': s.end.millisecondsSinceEpoch,
                  'done': performedSlotIds.contains(s.id),
                },
            ],
          },
      ],
    };
  }

  static List<String> get prayerKeys =>
      TrackedPrayer.values.map((p) => p.key).toList();
}

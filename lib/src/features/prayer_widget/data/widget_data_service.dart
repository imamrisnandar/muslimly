import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:home_widget/home_widget.dart';

import '../../../core/database/database_service.dart';
import '../../../core/utils/app_logger.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../prayer/domain/entities/prayer_instants.dart';
import '../../prayer/domain/repositories/prayer_repository.dart';
import '../../prayer_tracker/domain/entities/prayer_log.dart';
import '../../prayer_tracker/domain/repositories/prayer_tracker_repository.dart';
import '../../prayer_tracker/domain/utils/prayer_tracker_calculator.dart';
import '../../settings/domain/repositories/settings_repository.dart';
import '../domain/widget_payload_builder.dart';

/// Writes the next week of prayer windows for the Android home-screen widget
/// and asks it to redraw. Failures never propagate: the widget is a
/// convenience and must not break the screens that trigger it.
class WidgetDataService {
  static const String prefsKey = 'prayer_widget_json';
  static const List<String> androidProviders = [
    'com.muslimly.app.PrayerWidgetProvider',
    'com.muslimly.app.PrayerWidgetStripProvider',
    'com.muslimly.app.PrayerWidgetListProvider',
  ];

  // Same keys the tracker cubit persists its last known location under.
  static const String _kLat = 'prayer_tracker_lat';
  static const String _kLng = 'prayer_tracker_lng';
  static const String _kCity = 'prayer_widget_city';

  final PrayerRepository _prayerRepo;
  final SettingsRepository _settings;
  final DatabaseService _db;
  final PrayerTrackerRepository? _tracker;

  WidgetDataService(
    this._prayerRepo,
    this._settings,
    this._db, [
    this._tracker,
  ]);

  static String _dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// Ids of slots checked in, from [today] on. Tracker trouble must not
  /// blank the countdown, so failures just mean "nothing ticked".
  Future<Set<String>> _performedSlotIds(DateTime today) async {
    final tracker = _tracker;
    if (tracker == null) return {};
    try {
      final logs = await tracker.logs(
        sinceDate: _dateKey(today.subtract(const Duration(days: 1))),
      );
      return {
        for (final e in PrayerTrackerCalculator.winningSlotLogs(logs).entries)
          if (e.value.kind == PrayerLogKind.performed) e.key,
      };
    } catch (_) {
      return {};
    }
  }

  Future<void> update({
    required double latitude,
    required double longitude,
    String? cityName,
  }) async {
    if (!Platform.isAndroid) return;
    try {
      if (cityName != null) await _db.saveSetting(_kCity, cityName);
      final city = cityName ?? await _db.getSetting(_kCity) ?? '';

      final today = DateTime.now();
      final days = <PrayerInstants>[];
      for (var i = 0; i <= WidgetPayloadBuilder.daysAhead; i++) {
        final r = await _prayerRepo.getPrayerInstants(
          latitude,
          longitude,
          DateTime(today.year, today.month, today.day + i),
        );
        final v = r.getRight().toNullable();
        if (v == null) return; // keep the previous data rather than half-write
        days.add(v);
      }

      final l = lookupAppLocalizations(
        Locale(await _settings.getLanguage() ?? 'id'),
      );
      final payload = WidgetPayloadBuilder.build(
        days: days,
        cityName: city,
        methodKey: await _settings.getPrayerCalculationMethod(),
        generatedAt: DateTime.now(),
        performedSlotIds: await _performedSlotIds(today),
        labels: {
          'fajr': l.prayerFajr,
          'dhuhr': l.prayerDhuhr,
          'asr': l.prayerAsr,
          'maghrib': l.prayerMaghrib,
          'isha': l.prayerIsha,
          'next': l.widgetNext,
          'openApp': l.widgetOpenApp,
        },
      );
      await HomeWidget.saveWidgetData<String>(prefsKey, jsonEncode(payload));
      for (final name in androidProviders) {
        await HomeWidget.updateWidget(qualifiedAndroidName: name);
      }
    } catch (e, s) {
      AppLogger.error('Widget data update failed', e, s);
    }
  }

  /// For callers without a location in hand (settings change, daily job).
  Future<void> updateFromStoredLocation() async {
    final lat = double.tryParse(await _db.getSetting(_kLat) ?? '');
    final lng = double.tryParse(await _db.getSetting(_kLng) ?? '');
    if (lat == null || lng == null) return;
    await update(latitude: lat, longitude: lng);
  }
}

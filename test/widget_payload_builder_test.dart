import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:muslimly/src/features/prayer/domain/entities/prayer_instants.dart';
import 'package:muslimly/src/features/prayer_widget/data/widget_launch_handler.dart';
import 'package:muslimly/src/features/prayer_widget/domain/widget_payload_builder.dart';

PrayerInstants _day(DateTime d) {
  DateTime at(int h, [int m = 0]) => d.add(Duration(hours: h, minutes: m));
  final s =
      '${d.year}-${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
  return PrayerInstants(
    date: s,
    fajr: at(4),
    sunrise: at(5, 30),
    dhuhr: at(12),
    asr: at(15),
    maghrib: at(18),
    isha: at(19, 30),
  );
}

void main() {
  final start = DateTime.utc(2026, 3, 15);
  final days = [
    for (var i = 0; i <= WidgetPayloadBuilder.daysAhead; i++)
      _day(start.add(Duration(days: i))),
  ];
  final map = WidgetPayloadBuilder.build(
    days: days,
    cityName: 'Jakarta',
    methodKey: 'kemenag_ri',
    generatedAt: DateTime.utc(2026, 3, 15, 1),
    labels: {'fajr': 'Subuh'},
  );

  test(
    'writes 7 days of 5 prayers; the extra day only closes the last Isha',
    () {
      final d = map['days'] as List;
      expect(d, hasLength(WidgetPayloadBuilder.daysAhead));
      for (final day in d) {
        expect((day as Map)['prayers'], hasLength(5));
      }
      expect((d.first as Map)['date'], '2026-03-15');
      expect((d.last as Map)['date'], '2026-03-21');
    },
  );

  test('windows are absolute epochs; Isha ends at the next Fajr', () {
    final p = ((map['days'] as List).first as Map)['prayers'] as List;
    final fajr = p[0] as Map;
    expect(fajr['key'], 'fajr');
    expect(fajr['startEpochMs'], days[0].fajr.millisecondsSinceEpoch);
    expect(fajr['endEpochMs'], days[0].sunrise.millisecondsSinceEpoch);
    final isha = p[4] as Map;
    expect(isha['key'], 'isha');
    expect(isha['endEpochMs'], days[1].fajr.millisecondsSinceEpoch);
  });

  test('payload is JSON-encodable and carries city, method and labels', () {
    final decoded = jsonDecode(jsonEncode(map)) as Map;
    expect(decoded['cityName'], 'Jakarta');
    expect(decoded['methodKey'], 'kemenag_ri');
    expect((decoded['labels'] as Map)['fajr'], 'Subuh');
    expect(decoded['generatedAt'], isA<int>());
  });

  test('done flag follows performed slot ids, nothing else leaks', () {
    final m = WidgetPayloadBuilder.build(
      days: days,
      cityName: 'Jakarta',
      methodKey: 'kemenag_ri',
      generatedAt: DateTime.utc(2026, 3, 15, 1),
      labels: const {},
      performedSlotIds: {'2026-03-15/fajr', '2026-03-16/isha'},
    );
    final d = m['days'] as List;
    final d0 = ((d[0] as Map)['prayers'] as List).cast<Map>();
    expect(d0.map((p) => p['done']), [true, false, false, false, false]);
    final d1 = ((d[1] as Map)['prayers'] as List).cast<Map>();
    expect(d1.map((p) => p['done']), [false, false, false, false, true]);
    expect((d0.first).keys.toSet(), {
      'key',
      'startEpochMs',
      'endEpochMs',
      'done',
    });
  });

  test('tracker uri recognition', () {
    expect(
      WidgetLaunchHandler.isTrackerUri(Uri.parse('muslimly://tracker')),
      isTrue,
    );
    expect(
      WidgetLaunchHandler.isTrackerUri(Uri.parse('muslimly://prayer')),
      isFalse,
    );
  });

  test('widget launch uri recognition', () {
    expect(
      WidgetLaunchHandler.isPrayerUri(Uri.parse('muslimly://prayer')),
      isTrue,
    );
    expect(
      WidgetLaunchHandler.isPrayerUri(Uri.parse('muslimly://other')),
      isFalse,
    );
    expect(WidgetLaunchHandler.isPrayerUri(null), isFalse);
  });
}

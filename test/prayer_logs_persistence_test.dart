import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:muslimly/src/core/database/database_service.dart';
import 'package:muslimly/src/features/prayer_tracker/data/repositories/excused_period_repository_impl.dart';
import 'package:muslimly/src/features/prayer_tracker/domain/entities/excused_period.dart';
import 'package:muslimly/src/features/prayer_tracker/data/repositories/prayer_tracker_repository_impl.dart';
import 'package:muslimly/src/features/prayer_tracker/domain/entities/prayer_log.dart';

void main() {
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    // Private dir: other test files also use muslimly.db and run in parallel.
    await databaseFactory.setDatabasesPath(
      Directory.systemTemp.createTempSync('prayer_logs_test').path,
    );
  });

  Future<String> freshPath() async {
    final p = join(await getDatabasesPath(), 'muslimly.db');
    if (await File(p).exists()) await File(p).delete();
    return p;
  }

  test('fresh install creates prayer_logs; repository round-trips', () async {
    await freshPath();
    final svc = DatabaseService();
    final repo = PrayerTrackerRepositoryImpl(svc);

    await repo.append(
      PrayerLog(
        kind: PrayerLogKind.performed,
        prayer: TrackedPrayer.fajr,
        slotDate: '2026-03-15',
        inJamaah: true,
        timestamp: DateTime.fromMillisecondsSinceEpoch(1000),
      ),
    );
    await repo.append(
      PrayerLog(
        kind: PrayerLogKind.qadhaBaseline,
        prayer: TrackedPrayer.isha,
        count: 12,
        timestamp: DateTime.fromMillisecondsSinceEpoch(2000),
      ),
    );
    await repo.append(
      PrayerLog(
        kind: PrayerLogKind.performed,
        prayer: TrackedPrayer.asr,
        slotDate: '2026-01-01',
        timestamp: DateTime.fromMillisecondsSinceEpoch(3000),
      ),
    );

    final all = await repo.logs();
    expect(all, hasLength(3));
    expect(all.first.inJamaah, isTrue);
    expect(all.first.id, isNotNull);

    // Since-filter drops old slot rows but keeps slot-less qadha rows.
    final recent = await repo.logs(sinceDate: '2026-03-01');
    expect(recent.map((l) => l.kind), [
      PrayerLogKind.performed,
      PrayerLogKind.qadhaBaseline,
    ]);
  });

  test(
    'excused periods: local table round-trips and isExcusedOn works',
    () async {
      final svc = DatabaseService();
      final repo = ExcusedPeriodRepositoryImpl(svc);
      await repo.add(
        const ExcusedPeriod(
          kind: ExcuseKind.haid,
          startDate: '2026-03-10',
          expectedEndDate: '2026-03-16',
        ),
      );
      var all = await repo.all();
      expect(all, hasLength(1));
      expect(all.single.isActive, isTrue);
      expect(await svc.isExcusedOn('2026-03-10'), isTrue);
      expect(await svc.isExcusedOn('2026-03-09'), isFalse);
      expect(await svc.isExcusedOn('2030-01-01'), isTrue); // still open

      await repo.end(all.single.id!, '2026-03-14');
      expect(await svc.isExcusedOn('2026-03-14'), isTrue);
      expect(await svc.isExcusedOn('2026-03-15'), isFalse);

      // Never leaks into the synced log table.
      final tables =
          (await (await svc.database).rawQuery(
                "SELECT sql FROM sqlite_master WHERE name='prayer_logs'",
              )).single['sql']
              as String;
      expect(tables.contains('excus'), isFalse);

      await repo.delete(all.single.id!);
      all = await repo.all();
      expect(all, isEmpty);
    },
  );

  test(
    'sync support: unsynced / markSynced / mergeRemote dedupe on identity',
    () async {
      // Shared singleton DB: drain what earlier tests left, assert relative counts.
      final svc = DatabaseService();
      final repo = PrayerTrackerRepositoryImpl(svc);
      await repo.markSynced((await repo.unsynced()).map((l) => l.id!).toList());
      final before = (await repo.logs()).length;
      final ts = DateTime.fromMillisecondsSinceEpoch(5000);
      await repo.append(
        PrayerLog(
          kind: PrayerLogKind.performed,
          prayer: TrackedPrayer.fajr,
          slotDate: '2026-03-15',
          timestamp: ts,
        ),
      );
      var pending = await repo.unsynced();
      expect(pending, hasLength(1));
      await repo.markSynced([pending.single.id!]);
      expect(await repo.unsynced(), isEmpty);

      final added = await repo.mergeRemote([
        // same identity as the local row: skipped
        {
          'kind': 'performed',
          'prayer': 'fajr',
          'slot_date': '2026-03-15',
          'count': 1,
          'in_jamaah': 0,
          'timestamp': 5000,
        },
        // same timestamp but a different prayer: a distinct row
        {
          'kind': 'performed',
          'prayer': 'dhuhr',
          'slot_date': '2026-03-15',
          'count': 1,
          'in_jamaah': 1,
          'timestamp': 5000,
        },
        {
          'kind': 'qadha_baseline',
          'prayer': 'isha',
          'slot_date': null,
          'count': 9,
          'in_jamaah': 0,
          'timestamp': 6000,
        },
      ]);
      expect(added, 2);
      expect(await repo.logs(), hasLength(before + 3));
      // Merged rows arrive already synced: they must not be pushed back.
      expect(await repo.unsynced(), isEmpty);
      // Merging the same payload again is a no-op.
      expect(
        await repo.mergeRemote([
          {
            'kind': 'qadha_baseline',
            'prayer': 'isha',
            'slot_date': null,
            'count': 9,
            'in_jamaah': 0,
            'timestamp': 6000,
          },
        ]),
        0,
      );
    },
  );
}

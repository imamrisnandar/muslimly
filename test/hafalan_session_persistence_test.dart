// Verifies the DB persistence primitives that hafalan_page.dart's
// _recordCompletedSession relies on when HafalanBloc reaches
// HafalanStatus.completed (see HafalanBloc — full correct recitation in
// hafalan_bloc_test.dart for the bloc side of that trigger condition).
//
// Runs against a real sqlite engine via sqflite_common_ffi (no platform
// channel / device needed), so it also doubles as an automated check of the
// schema this session verified manually on-device: PRAGMA user_version and
// the hafalan_sessions table shape.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:muslimly/src/core/database/database_service.dart';
import 'package:muslimly/src/features/quran/domain/entities/hafalan_session.dart';

void main() {
  late DatabaseService db;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    // Start from a clean file so assertions below aren't polluted by a
    // leftover db from a previous run.
    final dbPath = join(await getDatabasesPath(), 'muslimly.db');
    if (await File(dbPath).exists()) {
      await File(dbPath).delete();
    }

    db = DatabaseService();
    // Touch the lazy getter once so schema creation happens before tests run.
    await db.database;
  });

  test(
    'schema is created at the expected version with hafalan_sessions',
    () async {
      final database = await db.database;
      final versionRows = await database.rawQuery('PRAGMA user_version');
      expect(versionRows.first.values.first, 16);

      final tableRows = await database.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='hafalan_sessions'",
      );
      expect(tableRows, hasLength(1));
    },
  );

  test(
    'insertHafalanSession → getHafalanSessions round-trips correctly',
    () async {
      final session = HafalanSession(
        surahNumber: 1,
        pageNumber: 1,
        startAyah: 1,
        endAyah: 7,
        ayahCount: 7,
        accuracy: 0.92,
        date: '2026-09-12',
        timestamp: 1757650000000,
      );

      final id = await db.insertHafalanSession(session);
      expect(id, greaterThan(0));

      final sessions = await db.getHafalanSessions(surahNumber: 1);
      final inserted = sessions.firstWhere((s) => s.id == id);

      expect(inserted.pageNumber, 1);
      expect(inserted.startAyah, 1);
      expect(inserted.endAyah, 7);
      expect(inserted.ayahCount, 7);
      expect(inserted.accuracy, 0.92);
      expect(inserted.date, '2026-09-12');
      expect(inserted.isSynced, 0);
    },
  );

  test(
    'sync lifecycle: unsynced → mark synced excludes it next time',
    () async {
      final session = HafalanSession(
        surahNumber: 2,
        pageNumber: 20,
        startAyah: 10,
        endAyah: 12,
        ayahCount: 3,
        accuracy: 1.0,
        date: '2026-09-12',
        timestamp: 1757650100000,
      );
      final id = await db.insertHafalanSession(session);

      final unsyncedBefore = await db.getUnsyncedHafalanSessions();
      expect(unsyncedBefore.any((s) => s.id == id), isTrue);

      await db.markHafalanSessionsSynced([id]);

      final unsyncedAfter = await db.getUnsyncedHafalanSessions();
      expect(unsyncedAfter.any((s) => s.id == id), isFalse);
    },
  );

  test(
    'mergeRemoteHafalanSessions skips a session with a duplicate timestamp',
    () async {
      const sharedTimestamp = 1757650200000;
      final local = HafalanSession(
        surahNumber: 3,
        pageNumber: 30,
        startAyah: 1,
        endAyah: 2,
        ayahCount: 2,
        accuracy: 0.8,
        date: '2026-09-12',
        timestamp: sharedTimestamp,
      );
      await db.insertHafalanSession(local);

      final beforeCount = (await db.getHafalanSessions(surahNumber: 3)).length;

      await db.mergeRemoteHafalanSessions([
        {
          'surah_number': 3,
          'page_number': 30,
          'start_ayah': 1,
          'end_ayah': 2,
          'ayah_count': 2,
          'accuracy': 0.8,
          'date': '2026-09-12',
          'timestamp': sharedTimestamp,
        },
      ]);

      final afterCount = (await db.getHafalanSessions(surahNumber: 3)).length;
      expect(
        afterCount,
        beforeCount,
        reason: 'duplicate timestamp must not be re-inserted',
      );
    },
  );

  group('audio recording columns (§F)', () {
    test('audioFilePath/isAudioSaved round-trip through insert/read', () async {
      final session = HafalanSession(
        surahNumber: 4,
        pageNumber: 40,
        startAyah: 1,
        endAyah: 3,
        ayahCount: 3,
        accuracy: 1.0,
        date: '2026-09-12',
        timestamp: 1757650300000,
        audioFilePath: '/tmp/hafalan_4_40.m4a',
      );
      final id = await db.insertHafalanSession(session);

      final sessions = await db.getHafalanSessions(surahNumber: 4);
      final inserted = sessions.firstWhere((s) => s.id == id);
      expect(inserted.audioFilePath, '/tmp/hafalan_4_40.m4a');
      expect(inserted.isAudioSaved, 0);
    });

    test(
      'getHafalanSessionsWithAudioForUnit only returns sessions with a '
      'non-null audio path for that exact (surah, halaman)',
      () async {
        await db.insertHafalanSession(
          HafalanSession(
            surahNumber: 5,
            pageNumber: 50,
            startAyah: 1,
            endAyah: 2,
            ayahCount: 2,
            accuracy: 1.0,
            date: '2026-09-12',
            timestamp: 1757650400000,
            audioFilePath: '/tmp/has_audio.m4a',
          ),
        );
        await db.insertHafalanSession(
          HafalanSession(
            surahNumber: 5,
            pageNumber: 50,
            startAyah: 1,
            endAyah: 2,
            ayahCount: 2,
            accuracy: 1.0,
            date: '2026-09-12',
            timestamp: 1757650500000,
            // no audioFilePath — recording was off for this session
          ),
        );
        await db.insertHafalanSession(
          HafalanSession(
            surahNumber: 6, // different unit — must not show up
            pageNumber: 60,
            startAyah: 1,
            endAyah: 2,
            ayahCount: 2,
            accuracy: 1.0,
            date: '2026-09-12',
            timestamp: 1757650600000,
            audioFilePath: '/tmp/other_unit.m4a',
          ),
        );

        final withAudio = await db.getHafalanSessionsWithAudioForUnit(5, 50);
        expect(withAudio, hasLength(1));
        expect(withAudio.single.audioFilePath, '/tmp/has_audio.m4a');
      },
    );

    test('clearHafalanAudioFilePath nulls the path but keeps the row', () async {
      final id = await db.insertHafalanSession(
        HafalanSession(
          surahNumber: 7,
          pageNumber: 70,
          startAyah: 1,
          endAyah: 1,
          ayahCount: 1,
          accuracy: 1.0,
          date: '2026-09-12',
          timestamp: 1757650700000,
          audioFilePath: '/tmp/to_clear.m4a',
        ),
      );

      await db.clearHafalanAudioFilePath(id);

      final sessions = await db.getHafalanSessions(surahNumber: 7);
      final row = sessions.firstWhere((s) => s.id == id);
      expect(row.audioFilePath, isNull);
      // The session row itself (accuracy/date history) is untouched.
      expect(row.accuracy, 1.0);
    });

    test('setHafalanAudioSaved toggles the protection flag', () async {
      final id = await db.insertHafalanSession(
        HafalanSession(
          surahNumber: 8,
          pageNumber: 80,
          startAyah: 1,
          endAyah: 1,
          ayahCount: 1,
          accuracy: 1.0,
          date: '2026-09-12',
          timestamp: 1757650800000,
          audioFilePath: '/tmp/saveable.m4a',
        ),
      );

      await db.setHafalanAudioSaved(id, true);
      var row = (await db.getHafalanSessions(
        surahNumber: 8,
      )).firstWhere((s) => s.id == id);
      expect(row.isAudioSaved, 1);

      await db.setHafalanAudioSaved(id, false);
      row = (await db.getHafalanSessions(
        surahNumber: 8,
      )).firstWhere((s) => s.id == id);
      expect(row.isAudioSaved, 0);
    });
  });
}

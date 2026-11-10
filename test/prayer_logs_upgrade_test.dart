import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:muslimly/src/core/database/database_service.dart';

void main() {
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    await databaseFactory.setDatabasesPath(
      Directory.systemTemp.createTempSync('prayer_logs_upgrade').path,
    );
  });

  test('upgrade from v16 adds prayer_logs and keeps existing data', () async {
    final path = join(await getDatabasesPath(), 'muslimly.db');
    // Simulate an installed v16 database.
    final old = await databaseFactoryFfi.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 16,
        onCreate: (db, v) async {
          await db.execute(
            'CREATE TABLE settings (key TEXT PRIMARY KEY, value TEXT)',
          );
          await db.insert('settings', {'key': 'k', 'value': 'v'});
        },
      ),
    );
    await old.close();

    final svc = DatabaseService();
    final db = await svc.database;
    final version = await db.rawQuery('PRAGMA user_version');
    expect(version.first.values.first, 18);
    expect(
      await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE name='prayer_logs'",
      ),
      hasLength(1),
    );
    expect(
      await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE name='prayer_excused_periods'",
      ),
      hasLength(1),
    );
    expect(await db.query('settings'), hasLength(1));
    await db.close();
  });
}

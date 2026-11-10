import 'package:flutter_test/flutter_test.dart';
import 'package:muslimly/src/core/database/database_service.dart';
import 'package:muslimly/src/features/prayer_tracker/domain/entities/prayer_log.dart';
import 'package:muslimly/src/features/prayer_tracker/domain/repositories/prayer_tracker_repository.dart';
import 'package:muslimly/src/features/prayer_tracker/presentation/bloc/qadha_cubit.dart';

class _MemRepo implements PrayerTrackerRepository {
  final rows = <PrayerLog>[];
  @override
  Future<void> append(PrayerLog log) async => rows.add(log);
  @override
  Future<List<PrayerLog>> unsynced({int limit = 500}) async => [];
  @override
  Future<void> markSynced(List<int> ids) async {}
  @override
  Future<int> mergeRemote(List<Map<String, Object?>> rows) async => 0;
  @override
  Future<List<PrayerLog>> logs({String? sinceDate}) async => List.of(rows);
}

class _FakeDb extends DatabaseService {
  _FakeDb() : super.forTesting();
  final s = <String, String>{};
  @override
  Future<void> saveSetting(String k, String v) async => s[k] = v;
  @override
  Future<String?> getSetting(String k) async => s[k];
}

void main() {
  late _MemRepo repo;
  late _FakeDb db;
  late QadhaCubit c;

  setUp(() {
    repo = _MemRepo();
    db = _FakeDb();
    c = QadhaCubit(repo, db, clock: () => DateTime(2026, 3, 15));
  });

  test(
    'wizard result sets the balance; re-running adds only the difference',
    () async {
      await c.saveBaseline({TrackedPrayer.fajr: 100, TrackedPrayer.isha: 40});
      expect(c.state.balance[TrackedPrayer.fajr], 100);
      expect(c.state.total, 140);
      expect(repo.rows, hasLength(2));

      await c.saveBaseline({TrackedPrayer.fajr: 90, TrackedPrayer.isha: 40});
      expect(c.state.balance[TrackedPrayer.fajr], 90);
      // Only fajr changed: one new -10 adjustment, history kept.
      expect(repo.rows, hasLength(3));
      expect(repo.rows.last.count, -10);

      await c.saveBaseline({TrackedPrayer.fajr: 90, TrackedPrayer.isha: 40});
      expect(repo.rows, hasLength(3)); // no-op writes nothing
    },
  );

  test('make up and undo are append-only and bounded', () async {
    await c.saveBaseline({TrackedPrayer.asr: 2});
    await c.undo(TrackedPrayer.asr); // nothing made up yet
    expect(repo.rows, hasLength(1));

    await c.makeUp(TrackedPrayer.asr);
    await c.makeUp(TrackedPrayer.asr);
    await c.makeUp(TrackedPrayer.asr); // balance already 0
    expect(c.state.balance[TrackedPrayer.asr], 0);
    expect(repo.rows, hasLength(3));

    await c.undo(TrackedPrayer.asr);
    expect(c.state.balance[TrackedPrayer.asr], 1);
    expect(repo.rows.last.count, -1);
    expect(repo.rows.last.kind, PrayerLogKind.qadhaDone);
  });

  test('pace persists and yields a finish estimate', () async {
    await c.saveBaseline({TrackedPrayer.dhuhr: 10});
    await c.setPace(3);
    expect(db.s['qadha_daily_pace'], '3');
    expect(c.state.finishDate, DateTime(2026, 3, 19));
    await c.setPace(0);
    expect(c.state.finishDate, isNull);
  });
}

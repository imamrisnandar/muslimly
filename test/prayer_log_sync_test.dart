import 'package:flutter_test/flutter_test.dart';
import 'package:muslimly/src/features/prayer_tracker/data/prayer_log_api_service.dart';
import 'package:muslimly/src/features/prayer_tracker/data/prayer_log_sync_service.dart';
import 'package:muslimly/src/features/prayer_tracker/domain/entities/prayer_log.dart';
import 'package:muslimly/src/features/prayer_tracker/domain/repositories/prayer_tracker_repository.dart';

class _Repo implements PrayerTrackerRepository {
  final rows = <PrayerLog>[];
  final synced = <int>{};
  final merged = <Map<String, Object?>>[];
  int _id = 0;

  void add(PrayerLog l) =>
      rows.add(PrayerLog.fromMap({...l.toMap(), 'id': ++_id}));

  @override
  Future<void> append(PrayerLog log) async => add(log);
  @override
  Future<List<PrayerLog>> logs({String? sinceDate}) async => rows;
  @override
  Future<List<PrayerLog>> unsynced({int limit = 500}) async =>
      rows.where((l) => !synced.contains(l.id)).take(limit).toList();
  @override
  Future<void> markSynced(List<int> ids) async => synced.addAll(ids);
  @override
  Future<int> mergeRemote(List<Map<String, Object?>> r) async {
    merged.addAll(r);
    return r.length;
  }
}

class _Remote implements PrayerLogRemote {
  final pushes = <List<Map<String, Object?>>>[];
  List<Map<String, dynamic>> toPull = [];
  bool Function(Map<String, Object?> row)? rejectIf;
  bool failNetwork = false;
  int pulls = 0;

  @override
  Future<void> push(
    List<Map<String, Object?>> logs,
    String? token, {
    String? deviceId,
  }) async {
    if (failNetwork) throw Exception('offline');
    if (rejectIf != null && logs.any(rejectIf!)) {
      throw const PrayerLogRejected();
    }
    pushes.add(logs);
  }

  @override
  Future<List<Map<String, dynamic>>> pull(String token) async {
    pulls++;
    return toPull;
  }
}

PrayerLog _log(int ts, {String prayer = 'fajr'}) => PrayerLog(
  kind: PrayerLogKind.performed,
  prayer: TrackedPrayer.fromKey(prayer),
  slotDate: '2026-03-15',
  timestamp: DateTime.fromMillisecondsSinceEpoch(ts),
);

void main() {
  late _Repo repo;
  late _Remote remote;
  String? token = 'jwt';
  String? device = 'dev';

  PrayerLogSyncService make() =>
      PrayerLogSyncService(repo, remote, () async => token, () async => device);

  setUp(() {
    repo = _Repo();
    remote = _Remote();
    token = 'jwt';
    device = 'dev';
  });

  test('toSyncJson uses the server wire format', () {
    final j = _log(1700000000000).toSyncJson();
    expect(j, {
      'kind': 'performed',
      'prayer': 'fajr',
      'slot_date': '2026-03-15',
      'count': 1,
      'in_jamaah': false,
      'timestamp': 1700000000000,
    });
    final q = PrayerLog(
      kind: PrayerLogKind.qadhaBaseline,
      prayer: TrackedPrayer.isha,
      count: -3,
      timestamp: DateTime.fromMillisecondsSinceEpoch(5),
    ).toSyncJson();
    expect(q.containsKey('slot_date'), isFalse); // no slot for qadha rows
    expect(q['count'], -3);
  });

  test('pushes unsynced rows once and marks them synced', () async {
    repo.add(_log(1));
    repo.add(_log(2, prayer: 'dhuhr'));
    final r = await make().sync();
    expect(r.ok, isTrue);
    expect(remote.pushes, hasLength(1));
    expect(remote.pushes.single, hasLength(2));
    expect(repo.synced, {1, 2});

    await make().sync(); // nothing left to push
    expect(remote.pushes, hasLength(1));
  });

  test('batches larger than the server cap are split', () async {
    for (var i = 1; i <= PrayerLogSyncService.batchSize + 5; i++) {
      repo.add(_log(i));
    }
    await make().sync();
    expect(remote.pushes.map((b) => b.length), [
      PrayerLogSyncService.batchSize,
      5,
    ]);
    expect(repo.unsynced(), completion(isEmpty));
  });

  test('a network failure leaves rows unsynced for the next attempt', () async {
    repo.add(_log(1));
    remote.failNetwork = true;
    final r = await make().sync();
    expect(r.ok, isFalse);
    expect(repo.synced, isEmpty);

    remote.failNetwork = false;
    expect((await make().sync()).ok, isTrue);
    expect(repo.synced, {1});
  });

  test('one rejected row does not block the others', () async {
    repo.add(_log(1));
    repo.add(_log(2, prayer: 'asr')); // the bad one
    repo.add(_log(3, prayer: 'isha'));
    remote.rejectIf = (row) => row['prayer'] == 'asr';
    final r = await make().sync();
    expect(r.ok, isTrue);
    expect(repo.synced, {1, 3});
  });

  test('guest (device only) pushes but does not pull', () async {
    token = null;
    repo.add(_log(1));
    final r = await make().sync();
    expect(r.ok, isTrue);
    expect(remote.pushes, hasLength(1));
    expect(remote.pulls, 0);
  });

  test('no token and no device id: does nothing', () async {
    token = null;
    device = null;
    repo.add(_log(1));
    expect((await make().sync()).ok, isFalse);
    expect(remote.pushes, isEmpty);
  });

  test('pull merges valid server rows and skips malformed ones', () async {
    remote.toPull = [
      {
        'kind': 'performed',
        'prayer': 'fajr',
        'slot_date': '2026-03-14',
        'count': 1,
        'in_jamaah': true,
        'timestamp': 100,
      },
      {
        'kind': 'qadha_baseline',
        'prayer': 'isha',
        'count': 12,
        'timestamp': 101,
      },
      {'kind': 'nonsense', 'prayer': 'fajr', 'timestamp': 102},
      {'kind': 'performed', 'prayer': 'fajr'}, // no timestamp
    ];
    final r = await make().sync();
    expect(r.merged, 2);
    expect(repo.merged, hasLength(2));
    expect(repo.merged[0]['in_jamaah'], 1);
    expect(repo.merged[1]['slot_date'], isNull);
  });

  test('overlapping sync calls do not run twice', () async {
    repo.add(_log(1));
    final s = make();
    final a = s.sync();
    final b = await s.sync(); // started while `a` is in flight
    expect(b.ok, isFalse);
    expect((await a).ok, isTrue);
    expect(remote.pushes, hasLength(1));
  });
}

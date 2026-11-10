import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:muslimly/src/core/database/database_service.dart';
import 'package:muslimly/src/core/error/failures.dart';
import 'package:muslimly/src/features/prayer/domain/entities/city.dart';
import 'package:muslimly/src/features/prayer/domain/entities/prayer_instants.dart';
import 'package:muslimly/src/features/prayer/domain/entities/prayer_time.dart';
import 'package:muslimly/src/features/prayer/domain/repositories/prayer_repository.dart';
import 'package:muslimly/src/features/prayer_tracker/data/prayer_nudge_service.dart';
import 'package:muslimly/src/features/settings/domain/repositories/settings_repository.dart';
import 'package:muslimly/src/features/prayer_tracker/domain/entities/excused_period.dart';
import 'package:muslimly/src/features/prayer_tracker/domain/entities/prayer_log.dart';
import 'package:muslimly/src/features/prayer_tracker/domain/repositories/excused_period_repository.dart';
import 'package:muslimly/src/features/prayer_tracker/domain/entities/prayer_slot.dart';
import 'package:muslimly/src/features/prayer_tracker/domain/repositories/prayer_tracker_repository.dart';
import 'package:muslimly/src/features/prayer_tracker/domain/utils/nudge_planner.dart';
import 'package:muslimly/src/features/prayer_tracker/presentation/bloc/prayer_tracker_cubit.dart';
import 'package:muslimly/src/features/prayer_tracker/presentation/bloc/prayer_tracker_state.dart';

class _MemExcuses implements ExcusedPeriodRepository {
  final rows = <ExcusedPeriod>[];
  @override
  Future<List<ExcusedPeriod>> all() async => List.of(rows);
  @override
  Future<void> add(ExcusedPeriod p) async => rows.add(
    ExcusedPeriod(
      id: rows.length + 1,
      kind: p.kind,
      startDate: p.startDate,
      endDate: p.endDate,
      expectedEndDate: p.expectedEndDate,
    ),
  );
  @override
  Future<void> end(int id, String endDate) async {
    final i = rows.indexWhere((p) => p.id == id);
    final p = rows[i];
    rows[i] = ExcusedPeriod(
      id: p.id,
      kind: p.kind,
      startDate: p.startDate,
      endDate: endDate,
      expectedEndDate: p.expectedEndDate,
    );
  }

  @override
  Future<void> delete(int id) async => rows.removeWhere((p) => p.id == id);
}

class _MemRepo implements PrayerTrackerRepository {
  final rows = <PrayerLog>[];
  @override
  Future<void> append(PrayerLog log) async =>
      rows.add(PrayerLog.fromMap({...log.toMap(), 'id': rows.length + 1}));
  @override
  Future<List<PrayerLog>> unsynced({int limit = 500}) async => [];
  @override
  Future<void> markSynced(List<int> ids) async {}
  @override
  Future<int> mergeRemote(List<Map<String, Object?>> rows) async => 0;
  @override
  Future<List<PrayerLog>> logs({String? sinceDate}) async => List.of(rows);
}

/// Fixed instants every day: 04:00 05:30 12:00 15:00 18:00 19:30 UTC.
class _FixedPrayerRepo implements PrayerRepository {
  @override
  Future<Either<Failure, PrayerInstants>> getPrayerInstants(
    double lat,
    double lng,
    DateTime date,
  ) async {
    final d = DateTime.utc(date.year, date.month, date.day);
    DateTime at(int h, [int m = 0]) => d.add(Duration(hours: h, minutes: m));
    return Right(
      PrayerInstants(
        date:
            '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}',
        fajr: at(4),
        sunrise: at(5, 30),
        dhuhr: at(12),
        asr: at(15),
        maghrib: at(18),
        isha: at(19, 30),
      ),
    );
  }

  @override
  Future<Either<Failure, PrayerTime>> getPrayerTime(
    double a,
    double b,
    DateTime c,
  ) => throw UnimplementedError();
  @override
  Future<Either<Failure, List<City>>> searchCity(String k) =>
      throw UnimplementedError();
}

class _FakeDb extends DatabaseService {
  _FakeDb() : super.forTesting();
  final settings = <String, String>{};
  @override
  Future<void> saveSetting(String key, String value) async =>
      settings[key] = value;
  @override
  Future<String?> getSetting(String key) async => settings[key];
}

class _RecordingNudges implements PrayerNudgeService {
  final reminderCalls = <List<ExcusedPeriod>>[];
  @override
  Future<void> syncExcuseEndReminder({
    required List<ExcusedPeriod> periods,
    required String languageCode,
  }) async => reminderCalls.add(periods);
  final calls = <({bool enabled, int tomorrowOpen, int todayPerformed})>[];
  @override
  Future<void> sync({
    required List<List<SlotView>> slotsByDay,
    required bool enabled,
    required Duration before,
    required String languageCode,
  }) async {
    calls.add((
      enabled: enabled,
      tomorrowOpen: slotsByDay[1].length,
      todayPerformed: slotsByDay[0]
          .where((v) => v.status == SlotStatus.performed)
          .length,
    ));
  }
}

SlotView _view(
  TrackedPrayer p,
  DateTime start,
  DateTime end, [
  SlotStatus s = SlotStatus.open,
]) => SlotView(
  slot: PrayerSlot(date: '2026-03-15', prayer: p, start: start, end: end),
  status: s,
);

void main() {
  group('NudgePlanner', () {
    final d = DateTime.utc(2026, 3, 15);
    DateTime at(int h, [int m = 0]) => d.add(Duration(hours: h, minutes: m));
    const lead = Duration(minutes: 30);

    test('fires `lead` before the window ends', () {
      final slot = _view(TrackedPrayer.dhuhr, at(12), at(15)).slot;
      expect(NudgePlanner.fireTime(slot, lead), at(14, 30));
    });

    test('Isha is capped so it never nudges just before Fajr', () {
      final slot = PrayerSlot(
        date: '2026-03-15',
        prayer: TrackedPrayer.isha,
        start: at(19, 30),
        end: at(28), // 04:00 next day
      );
      expect(NudgePlanner.fireTime(slot, lead), at(22, 30));
    });

    test('window shorter than lead time fires halfway through', () {
      final slot = _view(TrackedPrayer.maghrib, at(18), at(18, 20)).slot;
      expect(NudgePlanner.fireTime(slot, lead), at(18, 10));
    });

    test('skips recorded slots and past fire times; ids stay in 0..9', () {
      final plan = NudgePlanner.plan(
        slotsByDay: [
          [
            _view(TrackedPrayer.fajr, at(4), at(5, 30), SlotStatus.performed),
            _view(TrackedPrayer.dhuhr, at(12), at(15)),
            _view(TrackedPrayer.asr, at(15), at(18)),
          ],
          [_view(TrackedPrayer.fajr, at(28), at(29, 30), SlotStatus.upcoming)],
        ],
        now: at(14, 45), // dhuhr's 14:30 nudge already passed
        before: lead,
      );
      expect(plan.map((n) => n.index), [2, 5]); // asr today, fajr tomorrow
    });
  });

  group('excused periods', () {
    test(
      'end reminder: 08:00 on the expected end date, active periods only',
      () {
        final now = DateTime(2026, 3, 15, 12);
        final p = ExcusedPeriod(
          kind: ExcuseKind.haid,
          startDate: '2026-03-14',
          expectedEndDate: '2026-03-20',
        );
        expect(
          NudgePlanner.excuseEndReminder([p], now),
          DateTime(2026, 3, 20, 8),
        );
        // already ended -> nothing
        final ended = ExcusedPeriod(
          kind: ExcuseKind.haid,
          startDate: '2026-03-14',
          endDate: '2026-03-16',
          expectedEndDate: '2026-03-20',
        );
        expect(NudgePlanner.excuseEndReminder([ended], now), isNull);
        // expected date in the past or unset -> nothing
        final past = ExcusedPeriod(
          kind: ExcuseKind.sakit,
          startDate: '2026-03-01',
          expectedEndDate: '2026-03-10',
        );
        expect(NudgePlanner.excuseEndReminder([past], now), isNull);
        expect(
          NudgePlanner.excuseEndReminder([
            ExcusedPeriod(kind: ExcuseKind.sakit, startDate: '2026-03-14'),
          ], now),
          isNull,
        );
      },
    );

    test('covers is inclusive and open-ended while active', () {
      final p = ExcusedPeriod(
        kind: ExcuseKind.nifas,
        startDate: '2026-03-10',
        endDate: '2026-03-12',
      );
      expect(p.covers('2026-03-09'), isFalse);
      expect(p.covers('2026-03-10'), isTrue);
      expect(p.covers('2026-03-12'), isTrue);
      expect(p.covers('2026-03-13'), isFalse);
      final open = ExcusedPeriod(
        kind: ExcuseKind.haid,
        startDate: '2026-03-10',
      );
      expect(open.covers('2030-01-01'), isTrue);
    });
  });

  group('PrayerTrackerCubit', () {
    late _MemRepo repo;
    late _MemExcuses excuses;
    late _FakeDb db;
    late _RecordingNudges nudges;
    DateTime now = DateTime.utc(2026, 3, 15, 13);

    PrayerTrackerCubit make() => PrayerTrackerCubit(
      repo,
      excuses,
      _FixedPrayerRepo(),
      nudges,
      db,
      _NoSettings(),
      clock: () => now,
    );

    setUp(() {
      repo = _MemRepo();
      excuses = _MemExcuses();
      db = _FakeDb();
      nudges = _RecordingNudges();
    });

    test(
      'loads three days; check-in updates today and re-syncs nudges',
      () async {
        final c = make();
        await c.load(-6.2, 106.8);
        expect(c.state.status, PrayerTrackerStatus.ready);
        expect(c.state.days, hasLength(PrayerTrackerCubit.lookbackDays + 1));
        expect(db.settings['prayer_tracker_lat'], '-6.2');

        // 13:00 UTC: fajr/sunrise passed, dhuhr open (ignoring zone: clock is
        // an absolute instant).
        final today = c.state.todaySlots;
        expect(today[0].status, SlotStatus.unrecorded);
        expect(today[1].status, SlotStatus.open);
        expect(today[2].status, SlotStatus.upcoming);
        // Earlier days' windows have all ended with no log.
        expect(c.state.unrecordedEarlier, hasLength(10));

        await c.checkIn(today[1].slot, inJamaah: true);
        expect(c.state.todaySlots[1].status, SlotStatus.performed);
        expect(c.state.todaySlots[1].inJamaah, isTrue);
        expect(nudges.calls.last.todayPerformed, 1);

        await c.markMissed(today[0].slot);
        expect(c.state.todaySlots[0].status, SlotStatus.missed);
        expect(c.state.qadha[TrackedPrayer.fajr], 1);
        expect(c.state.totalQadha, 1);
      },
    );

    test('checkInMany records a whole earlier day at once', () async {
      final c = make();
      await c.load(-6.2, 106.8);
      expect(c.state.earlierDays, hasLength(2)); // most recent first
      expect(c.state.earlierDays.first.slots, hasLength(5));
      final day = c.state.earlierDays.first;
      await c.checkInMany([for (final v in day.slots) v.slot]);
      expect(c.state.earlierDays, hasLength(1));
      expect(c.state.unrecordedEarlier, hasLength(5));
      expect(c.state.totalQadha, 0); // nothing became a debt
    });

    test('a later correction replaces an earlier answer', () async {
      final c = make();
      await c.load(0, 0);
      final slot = c.state.todaySlots[0].slot;
      await c.markMissed(slot);
      expect(c.state.qadha[TrackedPrayer.fajr], 1);
      now = now.add(const Duration(minutes: 1));
      await c.checkIn(slot);
      expect(c.state.todaySlots[0].status, SlotStatus.performed);
      expect(c.state.qadha[TrackedPrayer.fajr], 0);
    });

    test('nudge setting persists and is passed to the scheduler', () async {
      final c = make();
      await c.load(0, 0);
      expect(nudges.calls.last.enabled, PrayerTrackerCubit.nudgeDefaultEnabled);
      await c.setNudgeEnabled(false);
      expect(db.settings['prayer_nudge_enabled'], 'false');
      expect(nudges.calls.last.enabled, isFalse);
      expect(c.state.nudgeEnabled, isFalse);
    });

    test(
      'excused pause: slots show excused, nudges skip them, no auto debt',
      () async {
        final c = make();
        await c.load(0, 0);
        await c.startExcuse(
          ExcuseKind.haid,
          expectedEnd: DateTime(2026, 3, 20),
        );
        expect(c.state.activePeriod, isNotNull);
        // Today's slots that were open/unrecorded/upcoming are now excused.
        expect(
          c.state.todaySlots.every((v) => v.status == SlotStatus.excused),
          isTrue,
        );
        expect(
          c.state.unrecordedEarlier,
          hasLength(10),
        ); // earlier days: not covered
        expect(c.state.totalQadha, 0);
        expect(nudges.reminderCalls.last.single.kind, ExcuseKind.haid);
        expect(nudges.calls.last.todayPerformed, 0);

        // A logged entry still wins over the projection.
        final slot = c.state.todaySlots[1].slot;
        await c.checkIn(slot);
        expect(c.state.todaySlots[1].status, SlotStatus.performed);

        await c.endExcuse(c.state.activePeriod!.id!);
        expect(c.state.activePeriod, isNull);
        // The end day itself stays excused (covers is inclusive).
        expect(c.state.todaySlots[0].status, SlotStatus.excused);

        await c.deleteExcuse(1);
        expect(c.state.periods, isEmpty);
        expect(c.state.todaySlots[0].status, isNot(SlotStatus.excused));
      },
    );

    test('loadLastKnown without a stored location reports an error', () async {
      final c = make();
      await c.loadLastKnown();
      expect(c.state.status, PrayerTrackerStatus.error);
    });
  });
}

class _NoSettings implements SettingsRepository {
  @override
  dynamic noSuchMethod(Invocation i) {
    if (i.memberName == #getLanguage) return Future<String?>.value('en');
    return super.noSuchMethod(i);
  }
}

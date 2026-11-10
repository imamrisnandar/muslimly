import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/database_service.dart';
import '../../../prayer/domain/entities/prayer_instants.dart';
import '../../../prayer/domain/repositories/prayer_repository.dart';
import '../../../settings/domain/repositories/settings_repository.dart';
import '../../data/prayer_log_sync_service.dart';
import '../../data/prayer_nudge_service.dart';
import '../../domain/entities/excused_period.dart';
import '../../domain/entities/prayer_log.dart';
import '../../domain/entities/prayer_slot.dart';
import '../../domain/repositories/excused_period_repository.dart';
import '../../domain/repositories/prayer_tracker_repository.dart';
import '../../domain/utils/prayer_slot_resolver.dart';
import '../../domain/utils/prayer_tracker_calculator.dart';
import 'prayer_tracker_state.dart';

class PrayerTrackerCubit extends Cubit<PrayerTrackerState> {
  final PrayerTrackerRepository _repo;
  final ExcusedPeriodRepository _excuses;
  final PrayerRepository _prayerRepo;
  final PrayerNudgeService _nudges;
  final DatabaseService _db;
  final SettingsRepository _settings;
  final DateTime Function() _clock;
  final PrayerLogSyncService? _sync;

  /// Called after the logs changed (check-in, merged sync) so the home-screen
  /// widget can redraw its ticks. Must not throw into the UI.
  final Future<void> Function()? _onLogsChanged;

  static const _kNudgeEnabled = 'prayer_nudge_enabled';
  static const _kLat = 'prayer_tracker_lat';
  static const _kLng = 'prayer_tracker_lng';

  /// Product defaults, still open decision #8 in the roadmap.
  static const Duration nudgeLeadTime = Duration(minutes: 30);
  static const bool nudgeDefaultEnabled = true;

  /// Days before today kept actionable ("not recorded yet").
  static const int lookbackDays = 2;

  double? _lat;
  double? _lng;

  PrayerTrackerCubit(
    this._repo,
    this._excuses,
    this._prayerRepo,
    this._nudges,
    this._db,
    this._settings, {
    DateTime Function()? clock,
    PrayerLogSyncService? sync,
    Future<void> Function()? onLogsChanged,
  }) : _clock = clock ?? DateTime.now,
       _sync = sync,
       _onLogsChanged = onLogsChanged,
       super(const PrayerTrackerState());

  /// Called by the dashboard whenever the prayer location is known/changed.
  Future<void> load(double latitude, double longitude) async {
    _lat = latitude;
    _lng = longitude;
    await _db.saveSetting(_kLat, latitude.toString());
    await _db.saveSetting(_kLng, longitude.toString());
    await refresh();
    _syncInBackground();
  }

  /// Used when opened without a dashboard (e.g. from a notification): falls
  /// back to the last location the dashboard stored.
  Future<void> loadLastKnown() async {
    final lat = double.tryParse(await _db.getSetting(_kLat) ?? '');
    final lng = double.tryParse(await _db.getSetting(_kLng) ?? '');
    if (lat == null || lng == null) {
      emit(
        PrayerTrackerState(
          status: PrayerTrackerStatus.error,
          revision: state.revision + 1,
        ),
      );
      return;
    }
    _lat = lat;
    _lng = lng;
    await refresh();
    _syncInBackground();
  }

  Future<void> refresh() async {
    if (_lat == null || _lng == null) return;
    final now = _clock();
    if (state.status == PrayerTrackerStatus.initial) {
      emit(
        PrayerTrackerState(
          status: PrayerTrackerStatus.loading,
          revision: state.revision + 1,
        ),
      );
    }

    final today = DateTime(now.year, now.month, now.day);
    // Instants for D-lookback .. D+2 (D+2's Fajr closes D+1's Isha).
    final instants = <PrayerInstants>[];
    for (var off = -lookbackDays; off <= 2; off++) {
      final r = await _prayerRepo.getPrayerInstants(
        _lat!,
        _lng!,
        DateTime(today.year, today.month, today.day + off),
      );
      final v = r.getRight().toNullable();
      if (v == null) {
        emit(
          PrayerTrackerState(
            status: PrayerTrackerStatus.error,
            revision: state.revision + 1,
          ),
        );
        return;
      }
      instants.add(v);
    }

    final logs = await _repo.logs();
    final periods = await _excuses.all();
    bool isExcused(String d) => periods.any((p) => p.covers(d));
    final winners = PrayerTrackerCalculator.winningSlotLogs(logs);
    final nowUtc = now.toUtc();

    List<SlotView> viewsFor(int i) => [
      for (final s in PrayerSlotResolver.slotsFor(instants[i], instants[i + 1]))
        PrayerTrackerCalculator.viewOf(
          s,
          winners,
          nowUtc,
          excused: isExcused(s.date),
        ),
    ];

    final days = [
      for (var i = 0; i <= lookbackDays; i++)
        DaySlots(instants[i].date, viewsFor(i)),
    ];
    final tomorrowViews = viewsFor(lookbackDays + 1);
    final todayKey = instants[lookbackDays].date;

    final enabled = await _nudgeEnabled();
    final lang = await _settings.getLanguage() ?? 'id';
    // Nudge scheduling must never break the tracker UI.
    try {
      await _nudges.sync(
        slotsByDay: [days.last.slots, tomorrowViews],
        enabled: enabled,
        before: nudgeLeadTime,
        languageCode: lang,
      );
      await _nudges.syncExcuseEndReminder(periods: periods, languageCode: lang);
    } catch (_) {}

    emit(
      PrayerTrackerState(
        status: PrayerTrackerStatus.ready,
        days: days,
        today: todayKey,
        stats: PrayerTrackerCalculator.stats(
          logs,
          todayKey,
          isExcused: isExcused,
        ),
        periods: periods,
        qadha: PrayerTrackerCalculator.qadhaBalance(logs),
        nudgeEnabled: enabled,
        approximate: instants[lookbackDays].fallbackLatitude != null,
        revision: state.revision + 1,
      ),
    );
  }

  Future<bool> _nudgeEnabled() async {
    final v = await _db.getSetting(_kNudgeEnabled);
    if (v == null) return nudgeDefaultEnabled;
    return v == 'true';
  }

  Future<void> setNudgeEnabled(bool enabled) async {
    await _db.saveSetting(_kNudgeEnabled, enabled.toString());
    await refresh();
  }

  static String _dateKey(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  /// Starts a pause (excused period). Nothing here is ever synced or logged.
  Future<void> startExcuse(
    ExcuseKind kind, {
    DateTime? start,
    DateTime? expectedEnd,
  }) async {
    final startDate = _dateKey(start ?? _clock());
    await _excuses.add(
      ExcusedPeriod(
        kind: kind,
        startDate: startDate,
        expectedEndDate: expectedEnd == null ? null : _dateKey(expectedEnd),
      ),
    );
    await refresh();
  }

  /// Ends the period today (the day itself stays excused).
  Future<void> endExcuse(int id) async {
    await _excuses.end(id, _dateKey(_clock()));
    await refresh();
  }

  Future<void> deleteExcuse(int id) async {
    await _excuses.delete(id);
    await refresh();
  }

  Future<void> checkIn(PrayerSlot slot, {bool inJamaah = false}) =>
      _append(slot, PrayerLogKind.performed, inJamaah: inJamaah);

  /// Records every slot in [slots] as prayed (not in congregation) with one
  /// refresh and one sync, for the "mark the whole day" action.
  Future<void> checkInMany(Iterable<PrayerSlot> slots) async {
    for (final slot in slots) {
      await _repo.append(
        PrayerLog(
          kind: PrayerLogKind.performed,
          prayer: slot.prayer,
          slotDate: slot.date,
          timestamp: _clock(),
        ),
      );
    }
    await refresh();
    _notifyLogsChanged();
    _syncInBackground();
  }

  Future<void> markMissed(PrayerSlot slot) =>
      _append(slot, PrayerLogKind.missed);

  Future<void> _append(
    PrayerSlot slot,
    PrayerLogKind kind, {
    bool inJamaah = false,
  }) async {
    await _repo.append(
      PrayerLog(
        kind: kind,
        prayer: slot.prayer,
        slotDate: slot.date,
        inJamaah: inJamaah,
        timestamp: _clock(),
      ),
    );
    await refresh(); // also drops this slot's nudge
    _notifyLogsChanged();
    _syncInBackground();
  }

  void _notifyLogsChanged() {
    final cb = _onLogsChanged;
    if (cb == null) return;
    cb().catchError((_) {});
  }

  /// Fire-and-forget push/pull; refreshes only if the server had new rows.
  void _syncInBackground() {
    final sync = _sync;
    if (sync == null) return;
    sync.sync().then((r) {
      if (r.merged > 0 && !isClosed) {
        refresh();
        _notifyLogsChanged();
      }
    });
  }
}

String formatSlotTime(DateTime utc) => DateFormat.Hm().format(utc.toLocal());

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/database/database_service.dart';
import '../../data/prayer_log_sync_service.dart';
import '../../domain/entities/prayer_log.dart';
import '../../domain/repositories/prayer_tracker_repository.dart';
import '../../domain/utils/prayer_tracker_calculator.dart';
import '../../domain/utils/qadha_planner.dart';

class QadhaState extends Equatable {
  final bool loaded;
  final Map<TrackedPrayer, int> balance;

  /// Net made-up count per prayer: bounds how far "undo" can go.
  final Map<TrackedPrayer, int> done;
  final Map<TrackedPrayer, int> baseline;

  /// Prayers per day the user aims to make up; 0 = none.
  final int pace;
  final DateTime? finishDate;
  final int revision;

  const QadhaState({
    this.loaded = false,
    this.balance = const {},
    this.done = const {},
    this.baseline = const {},
    this.pace = 0,
    this.finishDate,
    this.revision = 0,
  });

  int get total => PrayerTrackerCalculator.totalQadha(balance);

  @override
  List<Object?> get props => [loaded, pace, finishDate, revision];
}

class QadhaCubit extends Cubit<QadhaState> {
  final PrayerTrackerRepository _repo;
  final DatabaseService _db;
  final DateTime Function() _clock;
  final PrayerLogSyncService? _sync;

  static const _kPace = 'qadha_daily_pace';

  QadhaCubit(
    this._repo,
    this._db, {
    DateTime Function()? clock,
    PrayerLogSyncService? sync,
  }) : _clock = clock ?? DateTime.now,
       _sync = sync,
       super(const QadhaState());

  void _syncInBackground() {
    final sync = _sync;
    if (sync == null) return;
    sync.sync().then((r) {
      if (r.merged > 0 && !isClosed) load();
    });
  }

  Future<void> load() async {
    final logs = await _repo.logs();
    final pace = int.tryParse(await _db.getSetting(_kPace) ?? '') ?? 0;
    final balance = PrayerTrackerCalculator.qadhaBalance(logs);
    emit(
      QadhaState(
        loaded: true,
        balance: balance,
        done: QadhaPlanner.doneTotals(logs),
        baseline: QadhaPlanner.baselineTotals(logs),
        pace: pace,
        finishDate: QadhaPlanner.finishDate(
          PrayerTrackerCalculator.totalQadha(balance),
          pace,
          _clock(),
        ),
        revision: state.revision + 1,
      ),
    );
  }

  Future<void> _append(TrackedPrayer p, PrayerLogKind k, int count) async {
    await _repo.append(
      PrayerLog(kind: k, prayer: p, count: count, timestamp: _clock()),
    );
    await load();
    _syncInBackground();
  }

  /// One made-up prayer. Ignored when nothing is owed for that prayer.
  Future<void> makeUp(TrackedPrayer p) async {
    if ((state.balance[p] ?? 0) <= 0) return;
    await _append(p, PrayerLogKind.qadhaDone, 1);
  }

  /// Reverses a made-up entry by appending -1 (the log stays append-only).
  /// Only possible while the net made-up count is positive.
  Future<void> undo(TrackedPrayer p) async {
    if ((state.done[p] ?? 0) <= 0) return;
    await _append(p, PrayerLogKind.qadhaDone, -1);
  }

  Future<void> setPace(int perDay) async {
    await _db.saveSetting(_kPace, (perDay < 0 ? 0 : perDay).toString());
    await load();
  }

  /// Moves the stored baseline to [target] by appending only the differences.
  Future<void> saveBaseline(Map<TrackedPrayer, int> target) async {
    final delta = QadhaPlanner.baselineDelta(await _repo.logs(), target);
    for (final e in delta.entries) {
      await _repo.append(
        PrayerLog(
          kind: PrayerLogKind.qadhaBaseline,
          prayer: e.key,
          count: e.value,
          timestamp: _clock(),
        ),
      );
    }
    await load();
    _syncInBackground();
  }
}

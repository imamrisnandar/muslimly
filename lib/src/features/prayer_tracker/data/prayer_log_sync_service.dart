import 'package:flutter/foundation.dart';

import '../domain/entities/prayer_log.dart';
import '../domain/repositories/prayer_tracker_repository.dart';
import 'prayer_log_api_service.dart';

class PrayerSyncResult {
  /// False when skipped (no identity, already running) or when anything failed.
  final bool ok;

  /// Rows added locally from the server.
  final int merged;
  const PrayerSyncResult({this.ok = false, this.merged = 0});
}

/// Push local `prayer_logs` rows and (when logged in) pull the server's.
///
/// Only `prayer_logs` are synced. Excused periods are local-only and never
/// touch this class. Best effort: never throws, never logs payloads.
class PrayerLogSyncService {
  final PrayerTrackerRepository _repo;
  final PrayerLogRemote _remote;
  final Future<String?> Function() _token;
  final Future<String?> Function() _deviceId;

  /// Matches the server's per-request cap.
  static const int batchSize = 500;

  bool _running = false;

  PrayerLogSyncService(this._repo, this._remote, this._token, this._deviceId);

  /// A concurrent call returns immediately with `ok: false`.
  Future<PrayerSyncResult> sync() async {
    if (_running) return const PrayerSyncResult();
    _running = true;
    try {
      final token = await _token();
      final deviceId = await _deviceId();
      final hasToken = token != null && token.isNotEmpty;
      final hasDevice = deviceId != null && deviceId.isNotEmpty;
      if (!hasToken && !hasDevice) return const PrayerSyncResult();

      await _push(token, deviceId);
      // Reading back is only possible when logged in (server requires JWT).
      final merged = hasToken ? await _pull(token) : 0;
      return PrayerSyncResult(ok: true, merged: merged);
    } catch (e) {
      debugPrint('Prayer log sync failed: ${e.runtimeType}');
      return const PrayerSyncResult();
    } finally {
      _running = false;
    }
  }

  Future<void> _push(String? token, String? deviceId) async {
    // Loop in batches; stop if a batch makes no progress so a stuck row can
    // never spin forever.
    while (true) {
      final batch = await _repo.unsynced(limit: batchSize);
      if (batch.isEmpty) return;

      try {
        await _remote.push(
          batch.map((l) => l.toSyncJson()).toList(),
          token,
          deviceId: deviceId,
        );
        await _repo.markSynced(batch.map((l) => l.id!).toList());
      } on PrayerLogRejected {
        // The whole batch was refused: find out which rows are the problem so
        // one bad row cannot block the rest. Rejected rows stay unsynced.
        final accepted = await _pushIndividually(batch, token, deviceId);
        if (accepted == 0) return;
        if (accepted < batch.length) return; // leftovers are the bad rows
      }
      if (batch.length < batchSize) return;
    }
  }

  Future<int> _pushIndividually(
    List<PrayerLog> batch,
    String? token,
    String? deviceId,
  ) async {
    var accepted = 0;
    for (final l in batch) {
      try {
        await _remote.push([l.toSyncJson()], token, deviceId: deviceId);
        await _repo.markSynced([l.id!]);
        accepted++;
      } on PrayerLogRejected {
        continue;
      }
    }
    return accepted;
  }

  Future<int> _pull(String token) async {
    final remote = await _remote.pull(token);
    final rows = <Map<String, Object?>>[];
    for (final j in remote) {
      final row = PrayerLog.rowFromRemote(j);
      if (row != null) rows.add(row);
    }
    return rows.isEmpty ? 0 : await _repo.mergeRemote(rows);
  }
}

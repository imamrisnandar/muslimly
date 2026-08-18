import 'dart:async';
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/database/database_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../../quran/data/datasources/remote/sync_api_service.dart';
import '../../../quran/data/repositories/last_read_repository.dart';
import '../../../quran/domain/entities/last_read.dart';
import '../../../../core/utils/surah_names.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final AuthRepository _authRepository;
  final NotificationService _notificationService;
  final DatabaseService _databaseService;
  final LastReadRepository _lastReadRepository;
  final SyncApiService _syncApiService;

  AuthBloc(
    this._loginUseCase,
    this._authRepository,
    this._notificationService,
    this._databaseService,
    this._lastReadRepository,
    this._syncApiService,
  ) : super(AuthInitial()) {
    on<AuthStarted>(_onAuthStarted);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onAuthStarted(
    AuthStarted event,
    Emitter<AuthState> emit,
  ) async {
    final result = await _authRepository.getToken();
    final token = result.getOrElse((_) => null);
    if (token == null || token.isEmpty) return;

    final payload = _decodeJwtPayload(token);
    final exp = payload?['exp'] as int?;
    final isValid = exp != null &&
        DateTime.fromMillisecondsSinceEpoch(exp * 1000).isAfter(DateTime.now());

    if (!isValid) {
      await _authRepository.deleteToken();
      return;
    }

    final user = User(
      id: payload!['user_id'] as String? ?? '',
      email: payload['email'] as String? ?? '',
      name: payload['username'] as String? ?? '',
      token: token,
    );
    emit(AuthAuthenticated(user));
  }

  Map<String, dynamic>? _decodeJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = parts[1];
      final normalized = payload.padRight(
        payload.length + (4 - payload.length % 4) % 4,
        '=',
      );
      final decoded = utf8.decode(base64Url.decode(normalized));
      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _loginUseCase(event.email, event.password);
    await result.fold(
      (failure) async => emit(AuthFailure(failure.message)),
      (user) async {
        if (user.token != null) {
          // Link device to user account (blocking — prerequisite for migration)
          await _notificationService.syncFCMToken(user.token);

          final deviceId = await NotificationService.getDeviceId();
          if (deviceId != null && deviceId.isNotEmpty) {
            // M4: Migrate guest → user (fire & forget)
            unawaited(_syncApiService.migrateGuestData(user.token!, deviceId));
            // M20: Bulk push local bookmarks to server
            unawaited(_bulkPushLocalBookmarks(user.token!));
          }
          // M5: Pull server data → merge to local (fire & forget)
          unawaited(_pullServerData(user.token!));
        }
        emit(AuthAuthenticated(user));
      },
    );
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.deleteToken();
    await _clearUserScopedLocalData();
    emit(AuthLoggedOut());
  }

  // M5: Pull reading histories + bookmarks + activities from server → merge to local
  Future<void> _pullServerData(String token) async {
    await Future.wait([
      _pullReadingHistories(token),
      _pullBookmarks(token),
      _pullActivities(token),
    ]);
  }

  Future<void> _pullReadingHistories(String token) async {
    try {
      final histories = await _syncApiService.getReadingHistory(token);
      if (histories.isEmpty) return;

      // Find the most recently-read entry per mode, save to SharedPreferences
      for (final mode in ['mushaf', 'list']) {
        final forMode = histories
            .cast<Map<String, dynamic>>()
            .where((h) => (h['mode'] as String?) == mode)
            .toList();
        if (forMode.isEmpty) continue;

        // Pick entry with latest last_read_at
        forMode.sort((a, b) {
          final ta = DateTime.tryParse(a['last_read_at'] as String? ?? '') ?? DateTime(0);
          final tb = DateTime.tryParse(b['last_read_at'] as String? ?? '') ?? DateTime(0);
          return tb.compareTo(ta);
        });

        final latest = forMode.first;
        final surahNumber = latest['surah_id'] as int? ?? 1;
        final surahName = (surahNumber >= 1 && surahNumber <= SurahNames.indonesianNames.length)
            ? SurahNames.indonesianNames[surahNumber - 1]
            : '';
        final lastRead = LastRead(
          surahNumber: surahNumber,
          surahName: surahName,
          ayahNumber: latest['ayah_number'] as int? ?? 1,
          pageNumber: latest['page_number'] as int? ?? 1,
          mode: mode,
        );

        // Only overwrite if local is empty (re-login / fresh install)
        final local = await _lastReadRepository.getLastRead(mode: mode);
        if (local == null) {
          await _lastReadRepository.saveLastRead(lastRead, mode: mode);
        }
      }
    } catch (_) {
      // Pull failure must not affect UX
    }
  }

  Future<void> _pullBookmarks(String token) async {
    try {
      // Flush pending deletes first so they don't get re-added by the pull
      final pending = await _databaseService.getPendingBookmarkDeletes();
      for (final serverId in pending) {
        try {
          await _syncApiService.deleteBookmark(token, serverId);
          await _databaseService.removePendingBookmarkDelete(serverId);
        } catch (_) {
          // Still offline — keep in queue
        }
      }

      final remoteBookmarks = await _syncApiService.getBookmarks(token);
      if (remoteBookmarks.isNotEmpty) {
        await _databaseService.mergeRemoteBookmarks(
          remoteBookmarks.cast<Map<String, dynamic>>(),
        );
      }
    } catch (_) {
      // Pull failure must not affect UX
    }
  }

  // M20: Bulk push all local bookmarks that don't have a server_id yet
  Future<void> _bulkPushLocalBookmarks(String token) async {
    try {
      final local = await _databaseService.getBookmarks();
      final unsynced = local.where((b) => b.serverId == null).toList();
      if (unsynced.isEmpty) return;

      final payload = unsynced.map((b) => {
        'surah_number': b.surahNumber,
        'surah_name': b.surahName,
        'page_number': b.pageNumber,
        'ayah_number': b.ayahNumber,
        'mode': b.mode,
      }).toList();

      final results = await _syncApiService.bulkUpsertBookmarks(token, payload);
      // Update server_id for each synced bookmark
      for (var i = 0; i < results.length && i < unsynced.length; i++) {
        final serverId = (results[i] as Map<String, dynamic>?)?['id'] as String?;
        if (serverId != null && unsynced[i].id != null) {
          await _databaseService.updateServerIdForBookmark(unsynced[i].id!, serverId);
        }
      }
    } catch (_) {
      // Bulk push failure is non-fatal
    }
  }

  Future<void> _pullActivities(String token) async {
    try {
      final activities = await _syncApiService.getActivities(token);
      if (activities.isNotEmpty) {
        await _databaseService.mergeRemoteActivities(
          activities.cast<Map<String, dynamic>>(),
        );
      }
    } catch (_) {
      // Pull failure must not affect UX
    }
  }

  Future<void> _clearUserScopedLocalData() async {
    await _databaseService.clearAllBookmarks();
    await _lastReadRepository.clearAll();
  }
}

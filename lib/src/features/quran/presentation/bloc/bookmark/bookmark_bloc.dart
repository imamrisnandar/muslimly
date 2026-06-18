import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/database/database_service.dart';
import '../../../../../core/services/notification_service.dart';
import '../../../../auth/domain/repositories/auth_repository.dart';
import '../../../data/datasources/remote/sync_api_service.dart';
import '../../../data/repositories/last_read_repository.dart';
import '../../../domain/entities/quran_bookmark.dart';
import 'bookmark_event.dart';
import 'bookmark_state.dart';
import 'bookmark_operation_type.dart';

class BookmarkBloc extends Bloc<BookmarkEvent, BookmarkState> {
  final DatabaseService _databaseService;
  final LastReadRepository _lastReadRepository;
  final SyncApiService _syncApiService;
  final AuthRepository _authRepository;

  BookmarkBloc(
    this._databaseService,
    this._lastReadRepository,
    this._syncApiService,
    this._authRepository,
  ) : super(BookmarkInitial()) {
    on<LoadBookmarks>(_onLoadBookmarks);
    on<AddBookmark>(_onAddBookmark);
    on<ToggleBookmark>(_onToggleBookmark);
    on<DeleteBookmark>(_onDeleteBookmark);
    on<SaveLastRead>(_onSaveLastRead);
    on<LoadLastRead>(_onLoadLastRead);
  }

  // M17: Load bookmarks + pull from server and merge
  Future<void> _onLoadBookmarks(
    LoadBookmarks event,
    Emitter<BookmarkState> emit,
  ) async {
    if (state is! BookmarkLoaded) emit(BookmarkLoading());
    try {
      // Pull from server in background (non-blocking)
      _pullAndMergeFromServer();

      final bookmarks = await _databaseService.getBookmarks();
      final lastReadMushaf = await _lastReadRepository.getLastRead(mode: 'mushaf');
      final lastReadList = await _lastReadRepository.getLastRead(mode: 'list');
      emit(BookmarkLoaded(bookmarks, lastReadMushaf: lastReadMushaf, lastReadList: lastReadList));
    } catch (e) {
      emit(BookmarkError('Failed to load data: $e'));
    }
  }

  Future<void> _pullAndMergeFromServer() async {
    try {
      await _flushPendingDeletes();
      final token = await _getToken();
      final deviceId = await NotificationService.getDeviceId();
      final remoteBookmarks = await _syncApiService.getBookmarks(
        token,
        deviceId: (token == null) ? deviceId : null,
      );
      if (remoteBookmarks.isNotEmpty) {
        await _databaseService.mergeRemoteBookmarks(
          remoteBookmarks.cast<Map<String, dynamic>>(),
        );
      }
    } catch (_) {
      // Pull failure is non-fatal
    }
  }

  // M16: Add bookmark + push to server
  Future<void> _onAddBookmark(
    AddBookmark event,
    Emitter<BookmarkState> emit,
  ) async {
    try {
      final localId = await _databaseService.insertBookmark(event.bookmark);
      // Push to server (fire & forget)
      _pushBookmarkToServer(localId, event.bookmark);
      add(LoadBookmarks());
      emit(const BookmarkOperationSuccess(BookmarkOperationType.saved));
    } catch (e) {
      emit(BookmarkError('Failed to add bookmark: $e'));
    }
  }

  Future<void> _pushBookmarkToServer(int localId, QuranBookmark bookmark) async {
    try {
      final token = await _getToken();
      final deviceId = await NotificationService.getDeviceId();
      final payload = <String, dynamic>{
        'surah_number': bookmark.surahNumber,
        'surah_name': bookmark.surahName,
        'page_number': bookmark.pageNumber,
        'ayah_number': bookmark.ayahNumber,
        'mode': bookmark.mode,
        if (token == null && deviceId != null) 'device_id': deviceId,
      };
      final result = await _syncApiService.addBookmark(token, payload);
      if (result != null && result['id'] != null) {
        await _databaseService.updateServerIdForBookmark(localId, result['id'] as String);
      }
    } catch (_) {
      // Push failure is non-fatal — will sync later via bulk
    }
  }

  // M16: Toggle bookmark + push/delete on server
  Future<void> _onToggleBookmark(
    ToggleBookmark event,
    Emitter<BookmarkState> emit,
  ) async {
    try {
      final exists = await _databaseService.isBookmarked(
        surahNumber: event.bookmark.surahNumber,
        ayahNumber: event.bookmark.ayahNumber,
        pageNumber: event.bookmark.pageNumber,
        mode: event.bookmark.mode,
      );

      if (exists) {
        // M18: delete by server_id if available
        final bookmarks = await _databaseService.getBookmarks();
        final match = bookmarks.where((b) => _isSameBookmark(b, event.bookmark)).firstOrNull;
        await _databaseService.deleteBookmarkByDetails(
          surahNumber: event.bookmark.surahNumber,
          ayahNumber: event.bookmark.ayahNumber,
          pageNumber: event.bookmark.pageNumber,
          mode: event.bookmark.mode,
        );
        if (match?.serverId != null) {
          _deleteBookmarkFromServer(match!.serverId!);
        }
        emit(const BookmarkOperationSuccess(BookmarkOperationType.removed));
      } else {
        final localId = await _databaseService.insertBookmark(event.bookmark);
        _pushBookmarkToServer(localId, event.bookmark);
        emit(const BookmarkOperationSuccess(BookmarkOperationType.saved));
      }
      add(LoadBookmarks());
    } catch (e) {
      emit(BookmarkError('Failed to toggle bookmark: $e'));
    }
  }

  Future<void> _deleteBookmarkFromServer(String serverId) async {
    try {
      final token = await _getToken();
      final deviceId = await NotificationService.getDeviceId();
      await _syncApiService.deleteBookmark(
        token,
        serverId,
        deviceId: (token == null) ? deviceId : null,
      );
      await _databaseService.removePendingBookmarkDelete(serverId);
    } catch (_) {
      // Offline — queue for later
      await _databaseService.addPendingBookmarkDelete(serverId);
    }
  }

  Future<void> _flushPendingDeletes() async {
    final pending = await _databaseService.getPendingBookmarkDeletes();
    if (pending.isEmpty) return;
    final token = await _getToken();
    final deviceId = await NotificationService.getDeviceId();
    for (final serverId in pending) {
      try {
        await _syncApiService.deleteBookmark(
          token,
          serverId,
          deviceId: (token == null) ? deviceId : null,
        );
        await _databaseService.removePendingBookmarkDelete(serverId);
      } catch (_) {
        // Still offline — keep in queue
      }
    }
  }

  // M18: Delete by local id + server_id
  Future<void> _onDeleteBookmark(
    DeleteBookmark event,
    Emitter<BookmarkState> emit,
  ) async {
    try {
      final bookmarks = await _databaseService.getBookmarks();
      final match = bookmarks.where((b) => b.id == event.id).firstOrNull;
      await _databaseService.deleteBookmark(event.id);
      if (match?.serverId != null) {
        _deleteBookmarkFromServer(match!.serverId!);
      }
      add(LoadBookmarks());
    } catch (e) {
      emit(BookmarkError('Failed to delete bookmark: $e'));
    }
  }

  Future<void> _onSaveLastRead(
    SaveLastRead event,
    Emitter<BookmarkState> emit,
  ) async {
    try {
      await _lastReadRepository.saveLastRead(event.lastRead, mode: event.mode);
      add(LoadBookmarks());
    } catch (_) {}
  }

  Future<void> _onLoadLastRead(
    LoadLastRead event,
    Emitter<BookmarkState> emit,
  ) async {
    add(LoadBookmarks());
  }

  bool _isSameBookmark(QuranBookmark a, QuranBookmark b) {
    if (a.mode != b.mode) return false;
    if (a.mode == 'list') {
      return a.surahNumber == b.surahNumber && a.ayahNumber == b.ayahNumber;
    }
    return a.pageNumber == b.pageNumber && a.ayahNumber == b.ayahNumber;
  }

  Future<String?> _getToken() async {
    try {
      final result = await _authRepository.getToken();
      return result.getOrElse((_) => null);
    } catch (_) {
      return null;
    }
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/database/database_service.dart';
import 'bookmark_event.dart';
import 'bookmark_state.dart';

import '../../../data/repositories/last_read_repository.dart';

class BookmarkBloc extends Bloc<BookmarkEvent, BookmarkState> {
  final DatabaseService _databaseService;
  final LastReadRepository _lastReadRepository;

  BookmarkBloc(this._databaseService, this._lastReadRepository)
    : super(BookmarkInitial()) {
    on<LoadBookmarks>(_onLoadBookmarks);
    on<AddBookmark>(_onAddBookmark);
    on<DeleteBookmark>(_onDeleteBookmark);
    on<SaveLastRead>(_onSaveLastRead);
    on<LoadLastRead>(_onLoadLastRead); // Explicit Load
  }

  Future<void> _onLoadBookmarks(
    LoadBookmarks event,
    Emitter<BookmarkState> emit,
  ) async {
    if (state is! BookmarkLoaded) {
      emit(BookmarkLoading());
    }
    try {
      final bookmarks = await _databaseService.getBookmarks();
      final lastReadMushaf = await _lastReadRepository.getLastRead(
        mode: 'mushaf',
      );
      final lastReadList = await _lastReadRepository.getLastRead(mode: 'list');

      // We pass both to state.
      // Need to update State first.
      emit(
        BookmarkLoaded(
          bookmarks,
          lastReadMushaf: lastReadMushaf,
          lastReadList: lastReadList,
        ),
      );
    } catch (e) {
      emit(BookmarkError("Failed to load data: $e"));
    }
  }

  Future<void> _onAddBookmark(
    AddBookmark event,
    Emitter<BookmarkState> emit,
  ) async {
    try {
      await _databaseService.insertBookmark(event.bookmark);
      add(LoadBookmarks());
      // Emit success for UI feedback
      emit(const BookmarkOperationSuccess("Bookmark saved"));
    } catch (e) {
      emit(BookmarkError("Failed to add bookmark: $e"));
    }
  }

  Future<void> _onDeleteBookmark(
    DeleteBookmark event,
    Emitter<BookmarkState> emit,
  ) async {
    try {
      await _databaseService.deleteBookmark(event.id);
      add(LoadBookmarks());
    } catch (e) {
      emit(BookmarkError("Failed to delete bookmark: $e"));
    }
  }

  Future<void> _onSaveLastRead(
    SaveLastRead event,
    Emitter<BookmarkState> emit,
  ) async {
    try {
      await _lastReadRepository.saveLastRead(event.lastRead, mode: event.mode);
      // After saving, we should update the state
      // For now, simpler to reload everything to sync both LastReads if we decide to store both in state
      add(LoadBookmarks());
    } catch (e) {
      // Create a specific error or just log
    }
  }

  Future<void> _onLoadLastRead(
    LoadLastRead event,
    Emitter<BookmarkState> emit,
  ) async {
    // Just re-trigger load bookmarks for now as they are coupled in this Bloc
    add(LoadBookmarks());
  }
}

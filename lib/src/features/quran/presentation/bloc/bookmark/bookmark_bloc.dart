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
    // If we're already loaded, we want to keep current data while fetching?
    // For now simple reload
    if (state is! BookmarkLoaded) {
      emit(BookmarkLoading());
    }
    try {
      final bookmarks = await _databaseService.getBookmarks();
      final lastRead = await _lastReadRepository.getLastRead();
      emit(BookmarkLoaded(bookmarks, lastRead: lastRead));
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
      await _lastReadRepository.saveLastRead(event.lastRead);
      // After saving, we should update the state if it's currently loaded
      if (state is BookmarkLoaded) {
        final currentState = state as BookmarkLoaded;
        emit(BookmarkLoaded(currentState.bookmarks, lastRead: event.lastRead));
      } else {
        // If not loaded, reload everything
        add(LoadBookmarks());
      }
    } catch (e) {
      // Create a specific error or just log
      // emit(BookmarkError("Failed to save last read: $e"));
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

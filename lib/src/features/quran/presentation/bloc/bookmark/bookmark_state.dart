import 'package:equatable/equatable.dart';
import '../../../domain/entities/quran_bookmark.dart';
import '../../../domain/entities/last_read.dart';
import 'bookmark_operation_type.dart';

abstract class BookmarkState extends Equatable {
  const BookmarkState();

  @override
  List<Object?> get props => [];
}

class BookmarkInitial extends BookmarkState {}

class BookmarkLoading extends BookmarkState {}

class BookmarkLoaded extends BookmarkState {
  final List<QuranBookmark> bookmarks;
  final LastRead? lastReadMushaf;
  final LastRead? lastReadList;

  // Temporary getter for backward compatibility or simple usage
  // Prefer using specific fields
  LastRead? get lastRead => lastReadMushaf;

  const BookmarkLoaded(
    this.bookmarks, {
    this.lastReadMushaf,
    this.lastReadList,
  });

  @override
  List<Object?> get props => [bookmarks, lastReadMushaf, lastReadList];
}

class BookmarkError extends BookmarkState {
  final String message;

  const BookmarkError(this.message);

  @override
  List<Object?> get props => [message];
}

class BookmarkOperationSuccess extends BookmarkState {
  final BookmarkOperationType type;

  const BookmarkOperationSuccess(this.type);

  @override
  List<Object?> get props => [type];
}

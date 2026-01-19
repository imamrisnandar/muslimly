import 'package:equatable/equatable.dart';
import '../../../domain/entities/quran_bookmark.dart';
import '../../../domain/entities/last_read.dart';

abstract class BookmarkState extends Equatable {
  const BookmarkState();

  @override
  List<Object?> get props => [];
}

class BookmarkInitial extends BookmarkState {}

class BookmarkLoading extends BookmarkState {}

class BookmarkLoaded extends BookmarkState {
  final List<QuranBookmark> bookmarks;
  final LastRead? lastRead;

  const BookmarkLoaded(this.bookmarks, {this.lastRead});

  @override
  List<Object?> get props => [bookmarks, lastRead];
}

class BookmarkError extends BookmarkState {
  final String message;

  const BookmarkError(this.message);

  @override
  List<Object?> get props => [message];
}

class BookmarkOperationSuccess extends BookmarkState {
  final String message;

  const BookmarkOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

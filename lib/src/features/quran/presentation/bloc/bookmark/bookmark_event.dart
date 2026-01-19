import 'package:equatable/equatable.dart';
import '../../../domain/entities/quran_bookmark.dart';
import '../../../domain/entities/last_read.dart';

abstract class BookmarkEvent extends Equatable {
  const BookmarkEvent();

  @override
  List<Object?> get props => [];
}

class LoadBookmarks extends BookmarkEvent {}

class AddBookmark extends BookmarkEvent {
  final QuranBookmark bookmark;

  const AddBookmark(this.bookmark);

  @override
  List<Object?> get props => [bookmark];
}

class DeleteBookmark extends BookmarkEvent {
  final int id;

  const DeleteBookmark(this.id);

  @override
  List<Object?> get props => [id];
}

class LoadLastRead extends BookmarkEvent {}

class SaveLastRead extends BookmarkEvent {
  final LastRead lastRead;

  const SaveLastRead(this.lastRead);

  @override
  List<Object?> get props => [lastRead];
}

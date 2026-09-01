import 'package:equatable/equatable.dart';
import '../../../domain/entities/quran_folder.dart';

abstract class FolderState extends Equatable {
  const FolderState();

  @override
  List<Object?> get props => [];
}

class FolderInitial extends FolderState {}

class FolderLoading extends FolderState {}

class FolderLoaded extends FolderState {
  /// Keyed by mode: 'list' | 'mushaf'.
  final Map<String, List<QuranFolder>> foldersByMode;

  const FolderLoaded(this.foldersByMode);

  List<QuranFolder> forMode(String mode) => foldersByMode[mode] ?? const [];

  @override
  List<Object?> get props => [foldersByMode];
}

class FolderError extends FolderState {
  final String message;

  const FolderError(this.message);

  @override
  List<Object?> get props => [message];
}

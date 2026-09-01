import 'package:equatable/equatable.dart';

abstract class FolderEvent extends Equatable {
  const FolderEvent();

  @override
  List<Object?> get props => [];
}

/// Loads (and lazily seeds, per mode) folders for both 'list' and 'mushaf'.
/// [hapalanLabel]/[bacaanLabel] are the localized names used only the first
/// time a system folder is seeded — FolderBloc has no BuildContext of its
/// own, so the widget supplies them from AppLocalizations when dispatching.
class LoadFolders extends FolderEvent {
  final String hapalanLabel;
  final String bacaanLabel;

  const LoadFolders({this.hapalanLabel = 'Hapalan', this.bacaanLabel = 'Bacaan'});

  @override
  List<Object?> get props => [hapalanLabel, bacaanLabel];
}

class CreateFolder extends FolderEvent {
  final String mode;
  final String name;

  const CreateFolder(this.mode, this.name);

  @override
  List<Object?> get props => [mode, name];
}

class RenameFolder extends FolderEvent {
  final int id;
  final String name;

  const RenameFolder(this.id, this.name);

  @override
  List<Object?> get props => [id, name];
}

class DeleteFolder extends FolderEvent {
  final int id;

  const DeleteFolder(this.id);

  @override
  List<Object?> get props => [id];
}

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/database/database_service.dart';
import '../../../../../core/services/notification_service.dart';
import '../../../../auth/domain/repositories/auth_repository.dart';
import '../../../data/datasources/remote/sync_api_service.dart';
import '../../../domain/entities/quran_folder.dart';
import 'folder_event.dart';
import 'folder_state.dart';

const _kFolderModes = ['list', 'mushaf'];

class FolderBloc extends Bloc<FolderEvent, FolderState> {
  final DatabaseService _databaseService;
  final SyncApiService _syncApiService;
  final AuthRepository _authRepository;

  FolderBloc(
    this._databaseService,
    this._syncApiService,
    this._authRepository,
  ) : super(FolderInitial()) {
    on<LoadFolders>(_onLoadFolders, transformer: sequential());
    on<CreateFolder>(_onCreateFolder, transformer: sequential());
    on<RenameFolder>(_onRenameFolder, transformer: sequential());
    on<DeleteFolder>(_onDeleteFolder, transformer: sequential());
  }

  Future<void> _onLoadFolders(LoadFolders event, Emitter<FolderState> emit) async {
    if (state is! FolderLoaded) emit(FolderLoading());
    try {
      // Local-only: network pull+merge of folders is owned by
      // BookmarkBloc._pullAndMergeFromServer, so folders are always merged
      // BEFORE the bookmarks that reference them, without a cross-bloc
      // ordering race between two independent pull loops.
      for (final mode in _kFolderModes) {
        await _databaseService.ensureDefaultFolders(
          mode,
          hapalanLabel: event.hapalanLabel,
          bacaanLabel: event.bacaanLabel,
        );
      }
      final foldersByMode = <String, List<QuranFolder>>{
        for (final mode in _kFolderModes) mode: await _databaseService.getFolders(mode: mode),
      };
      emit(FolderLoaded(foldersByMode));
    } catch (e) {
      emit(FolderError('Failed to load folders: $e'));
    }
  }

  Future<void> _onCreateFolder(CreateFolder event, Emitter<FolderState> emit) async {
    try {
      final localId = await _databaseService.insertFolder(
        QuranFolder(
          mode: event.mode,
          name: event.name,
          createdAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );
      _pushFolderToServer(localId, event.mode, event.name);
      add(const LoadFolders());
    } catch (e) {
      emit(FolderError('Failed to create folder: $e'));
    }
  }

  Future<void> _pushFolderToServer(int localId, String mode, String name) async {
    try {
      final token = await _getToken();
      final deviceId = await NotificationService.getDeviceId();
      final payload = <String, dynamic>{
        'mode': mode,
        'name': name,
        if (token == null && deviceId != null) 'device_id': deviceId,
      };
      final result = await _syncApiService.addFolder(token, payload);
      if (result != null && result['id'] != null) {
        await _databaseService.updateServerIdForFolder(localId, result['id'] as String);
      }
    } catch (_) {
      // Push failure is non-fatal — will sync later on next load
    }
  }

  Future<void> _onRenameFolder(RenameFolder event, Emitter<FolderState> emit) async {
    try {
      final folder = await _databaseService.getFolderById(event.id);
      await _databaseService.renameFolder(event.id, event.name);
      if (folder?.serverId != null) {
        _pushFolderRenameToServer(folder!.serverId!, event.name);
      }
      add(const LoadFolders());
    } catch (e) {
      emit(FolderError('Failed to rename folder: $e'));
    }
  }

  Future<void> _pushFolderRenameToServer(String serverId, String name) async {
    try {
      final token = await _getToken();
      final deviceId = await NotificationService.getDeviceId();
      await _syncApiService.renameFolder(
        token,
        serverId,
        name,
        deviceId: (token == null) ? deviceId : null,
      );
    } catch (_) {
      // Non-fatal — next rename or reload can retry
    }
  }

  Future<void> _onDeleteFolder(DeleteFolder event, Emitter<FolderState> emit) async {
    try {
      final folder = await _databaseService.getFolderById(event.id);
      await _databaseService.deleteFolder(event.id); // nulls bookmarks.folder_id locally too
      if (folder?.serverId != null) {
        _deleteFolderFromServer(folder!.serverId!);
      }
      add(const LoadFolders());
    } catch (e) {
      emit(FolderError('Failed to delete folder: $e'));
    }
  }

  Future<void> _deleteFolderFromServer(String serverId) async {
    try {
      final token = await _getToken();
      final deviceId = await NotificationService.getDeviceId();
      await _syncApiService.deleteFolder(
        token,
        serverId,
        deviceId: (token == null) ? deviceId : null,
      );
      await _databaseService.removePendingBookmarkFolderDelete(serverId);
    } catch (_) {
      // Offline — queue for later
      await _databaseService.addPendingBookmarkFolderDelete(serverId);
    }
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

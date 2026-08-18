import 'package:flutter/foundation.dart';
import '../../../../core/database/database_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../quran/data/datasources/remote/sync_api_service.dart';
import '../../domain/repositories/name_repository.dart';

class NameRepositoryImpl implements NameRepository {
  static const String _keyName = 'user_name';
  final DatabaseService _databaseService;
  final AuthRepository _authRepository;
  final SyncApiService _syncApiService;

  NameRepositoryImpl(
    this._databaseService,
    this._authRepository,
    this._syncApiService,
  );

  @override
  Future<void> saveName(String name) async {
    await _databaseService.saveSetting(_keyName, name);
    // Sync name to server in background
    _syncNameToServer(name);
  }

  @override
  Future<String?> getName() async {
    return await _databaseService.getSetting(_keyName);
  }

  Future<void> _syncNameToServer(String name) async {
    try {
      String? token;
      final tokenEither = await _authRepository.getToken();
      tokenEither.fold((_) {}, (t) => token = t);

      final deviceId = await NotificationService.getDeviceId();

      if ((token != null && token!.isNotEmpty) ||
          (deviceId != null && deviceId.isNotEmpty)) {
        await _syncApiService.upsertSettings(
          [
            {'key': _keyName, 'value': name},
          ],
          token,
          deviceId: deviceId,
        );
      }
    } catch (e) {
      debugPrint('\u274c [Sync Settings] Failed to sync name: $e');
    }
  }
}

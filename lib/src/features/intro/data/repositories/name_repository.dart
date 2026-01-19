import 'package:injectable/injectable.dart';
import '../../../../core/database/database_service.dart';

abstract class NameRepository {
  Future<void> saveName(String name);
  Future<String?> getName();
}

@LazySingleton(as: NameRepository)
class NameRepositoryImpl implements NameRepository {
  static const String _keyName = 'user_name';
  final DatabaseService _databaseService;

  NameRepositoryImpl(this._databaseService);

  @override
  Future<void> saveName(String name) async {
    await _databaseService.saveSetting(_keyName, name);
  }

  @override
  Future<String?> getName() async {
    return await _databaseService.getSetting(_keyName);
  }
}

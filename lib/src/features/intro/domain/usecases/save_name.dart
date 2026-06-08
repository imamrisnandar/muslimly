import 'package:injectable/injectable.dart';
import '../repositories/name_repository.dart';

@injectable
class SaveName {
  final NameRepository _repository;
  const SaveName(this._repository);

  Future<void> call(String name) => _repository.saveName(name);
}

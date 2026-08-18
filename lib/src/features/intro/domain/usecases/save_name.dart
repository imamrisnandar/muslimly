import '../repositories/name_repository.dart';

class SaveName {
  final NameRepository _repository;
  const SaveName(this._repository);

  Future<void> call(String name) => _repository.saveName(name);
}

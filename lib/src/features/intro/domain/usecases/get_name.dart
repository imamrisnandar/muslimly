import '../repositories/name_repository.dart';

class GetName {
  final NameRepository _repository;
  const GetName(this._repository);

  Future<String?> call() => _repository.getName();
}

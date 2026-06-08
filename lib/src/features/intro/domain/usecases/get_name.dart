import 'package:injectable/injectable.dart';
import '../repositories/name_repository.dart';

@injectable
class GetName {
  final NameRepository _repository;
  const GetName(this._repository);

  Future<String?> call() => _repository.getName();
}

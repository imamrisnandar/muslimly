import 'package:fpdart/fpdart.dart';
import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<Either<String, User>> call(String email, String password) {
    return _repository.login(email, password);
  }
}

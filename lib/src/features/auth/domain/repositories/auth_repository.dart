import 'package:fpdart/fpdart.dart';
import '../entities/auth_entity.dart';

abstract class AuthRepository {
  Future<Either<String, User>> login(String email, String password);
}

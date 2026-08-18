import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String email, String password);
  Future<Either<Failure, String?>> getToken();
  Future<void> saveToken(String token);
  Future<void> deleteToken();
  Future<Either<Failure, void>> forgotPassword(String email);
  Future<Either<Failure, String>> verifyOTP(String email, String otp);
  Future<Either<Failure, void>> resetPassword(String resetToken, String newPassword);
}

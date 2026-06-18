import 'package:fpdart/fpdart.dart';
import '../entities/auth_entity.dart';

abstract class AuthRepository {
  Future<Either<String, User>> login(String email, String password);
  Future<Either<String, String?>> getToken();
  Future<void> saveToken(String token);
  Future<void> deleteToken();
  Future<Either<String, void>> forgotPassword(String email);
  Future<Either<String, String>> verifyOTP(String email, String otp);
  Future<Either<String, void>> resetPassword(String resetToken, String newPassword);
}

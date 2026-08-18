import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

const _tokenKey = 'auth_token';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;
  final FlutterSecureStorage _secureStorage;

  AuthRepositoryImpl(this._dataSource, this._secureStorage);

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      final response = await _dataSource.login({
        'email': email,
        'password': password,
      });
      final user = response.toEntity();
      if (user.token != null) {
        await saveToken(user.token!);
      }
      return Right(user);
    } on DioException catch (e) {
      return Left(_dioError(e));
    } catch (e) {
      return const Left(MessageFailure('Terjadi kesalahan. Silakan coba lagi.'));
    }
  }

  @override
  Future<Either<Failure, String?>> getToken() async {
    try {
      final token = await _secureStorage.read(key: _tokenKey);
      return Right(token);
    } catch (e) {
      return Left(MessageFailure(e.toString()));
    }
  }

  @override
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  @override
  Future<void> deleteToken() async {
    await _secureStorage.delete(key: _tokenKey);
  }

  @override
  Future<Either<Failure, void>> forgotPassword(String email) async {
    try {
      await _dataSource.forgotPassword({'email': email});
      return const Right(null);
    } on DioException catch (e) {
      return Left(_dioError(e));
    } catch (_) {
      return const Left(MessageFailure('Terjadi kesalahan. Silakan coba lagi.'));
    }
  }

  @override
  Future<Either<Failure, String>> verifyOTP(String email, String otp) async {
    try {
      final response = await _dataSource.verifyOTP({'email': email, 'otp': otp});
      return Right(response.resetToken);
    } on DioException catch (e) {
      return Left(_dioError(e));
    } catch (_) {
      return const Left(MessageFailure('Terjadi kesalahan. Silakan coba lagi.'));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword(String resetToken, String newPassword) async {
    try {
      await _dataSource.resetPassword({'reset_token': resetToken, 'new_password': newPassword});
      return const Right(null);
    } on DioException catch (e) {
      return Left(_dioError(e));
    } catch (_) {
      return const Left(MessageFailure('Terjadi kesalahan. Silakan coba lagi.'));
    }
  }

  Failure _dioError(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic> && data['message'] is String) {
      return MessageFailure(data['message'] as String);
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return const MessageFailure('Tidak ada koneksi internet. Periksa jaringan Anda.');
    }
    return const MessageFailure('Terjadi kesalahan. Silakan coba lagi.');
  }
}

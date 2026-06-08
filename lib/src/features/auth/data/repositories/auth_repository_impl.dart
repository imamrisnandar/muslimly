import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

const _tokenKey = 'auth_token';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;
  final FlutterSecureStorage _secureStorage;

  AuthRepositoryImpl(this._dataSource, this._secureStorage);

  @override
  Future<Either<String, User>> login(String email, String password) async {
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
      return Left(e.message ?? 'Unknown error occurred');
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, String?>> getToken() async {
    try {
      final token = await _secureStorage.read(key: _tokenKey);
      return Right(token);
    } catch (e) {
      return Left(e.toString());
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
}

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/auth_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  @override
  Future<Either<String, User>> login(String email, String password) async {
    try {
      final response = await _dataSource.login({
        'email': email,
        'password': password,
      });
      return Right(response.toEntity());
    } on DioException catch (e) {
      // Handle generic errors or parse API errors
      return Left(e.message ?? 'Unknown error occurred');
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, String?>> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      // Adjust key if it differs in actual prod app
      return Right(token);
    } catch (e) {
      return Left(e.toString());
    }
  }
}

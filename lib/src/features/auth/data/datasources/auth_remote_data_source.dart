import 'package:dio/dio.dart' hide Headers;
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';
import '../models/auth_model.dart';

part 'auth_remote_data_source.g.dart';

@RestApi()
@injectable
abstract class AuthRemoteDataSource {
  @factoryMethod
  factory AuthRemoteDataSource(Dio dio) = _AuthRemoteDataSource;

  @POST('/auth/login')
  @Headers({'X-Device-ID': 'web'})
  Future<AuthModel> login(@Body() Map<String, dynamic> body);
}

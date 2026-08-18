import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import '../models/auth_model.dart';

part 'auth_remote_data_source.g.dart';

@RestApi()
abstract class AuthRemoteDataSource {
  factory AuthRemoteDataSource(Dio dio) = _AuthRemoteDataSource;

  @POST('/auth/login')
  @Headers({'X-Device-ID': 'web'})
  Future<AuthModel> login(@Body() Map<String, dynamic> body);

  @POST('/auth/forgot-password')
  Future<void> forgotPassword(@Body() Map<String, dynamic> body);

  @POST('/auth/verify-otp')
  Future<VerifyOTPModel> verifyOTP(@Body() Map<String, dynamic> body);

  @POST('/auth/reset-password')
  Future<void> resetPassword(@Body() Map<String, dynamic> body);
}

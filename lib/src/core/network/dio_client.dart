import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../config/app_urls.dart';

@module
abstract class NetworkModule {
  @lazySingleton
  Dio get dio => Dio(
    BaseOptions(
      baseUrl: AppUrls.baseApi,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );
}

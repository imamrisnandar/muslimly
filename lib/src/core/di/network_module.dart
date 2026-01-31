import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'dart:io';
import 'package:flutter/foundation.dart';

@module
abstract class NetworkModule {
  @lazySingleton
  Dio get dio {
    // String baseUrl = 'http://localhost:3031';
    String baseUrl = 'https://api.muslimbiker.id/v1/mbi-be';

    // if (!kIsWeb) {
    //   if (Platform.isAndroid) {
    //     baseUrl = 'http://10.0.2.2:3031';
    //   }
    // }

    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Device-ID': kIsWeb
              ? 'web'
              : Platform.isAndroid
              ? 'android'
              : 'ios',
        },
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
          responseHeader: true,
        ),
      );
    }

    return dio;
  }
}

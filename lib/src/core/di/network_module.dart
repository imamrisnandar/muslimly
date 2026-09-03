import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/app_urls.dart';

// --- Transport security for api.muslimly.id ---
//
// We deliberately DO NOT pin a certificate here. The API sits behind Cloudflare
// (SSL/TLS mode "Full (strict)" + HSTS), so:
//   - client -> Cloudflare edge: cert issued by Cloudflare (currently Google
//     Trust Services, rotates, not user-selectable on the plan we're on)
//   - Cloudflare -> origin: validated against the origin's Let's Encrypt cert
//
// Pinning a specific leaf/intermediate broke twice already: Let's Encrypt
// rotating its intermediate (E7 -> YE1 -> YE2, not selectable via
// --preferred-chain), and then Cloudflare fronting the domain with a different
// CA entirely. Cloudflare itself recommends against pinning the edge cert.
//
// System trust-store validation is what we rely on. If we ever need pinning
// back, pin the *root* CAs (ISRG Root X1/X2 + Google Trust Services R1/R4) via
// SecurityContext(withTrustedRoots: false) + setTrustedCertificatesBytes — roots
// are stable for decades, unlike intermediates — and be ready to update it if
// Cloudflare adds another CA partner.

abstract class NetworkModule {
  Dio get dio {
    final dio = Dio(
      BaseOptions(
        baseUrl: '${AppUrls.baseApi}/',
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
          responseBody: false,
          requestHeader: false,
          responseHeader: false,
        ),
      );
    }

    return dio;
  }
}

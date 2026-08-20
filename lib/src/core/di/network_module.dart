import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import '../config/app_urls.dart';

// --- SSL Pinning: Let's Encrypt YE1 Intermediate CA ---
// Strategy : Pin intermediate CA → tidak perlu update saat leaf cert direnew
// CA expiry : 2028-09-02
// SPKI Hash : brzvtCELCIZUo4sD/qPX0ccRtPsd3DY6RfmxpOU9oB4=
// Update    : Hanya perlu jika Let's Encrypt retire YE1.
//             Jalankan: openssl s_client -connect api.muslimly.id:443 -showcerts 2>/dev/null
//               | awk '/BEGIN CERT/{c++} c==2{print} /END CERT/ && c==2{exit}'
//               | openssl x509 -outform PEM
//             Ganti _letsEncryptYE1Pem di bawah dengan output tersebut.
// Riwayat   : sebelumnya pin ke E7 (ISRG Root X1) — Let's Encrypt sudah tidak
//             lagi menerbitkan lewat chain itu (dicek 2026-08-20, --preferred-chain
//             "ISRG Root X1" tidak lagi tersedia sebagai alternate chain), semua
//             cert baru/renew keluar lewat "Root YE" → intermediate YE1.
const _letsEncryptYE1Pem = '''-----BEGIN CERTIFICATE-----
MIICizCCAhGgAwIBAgIQXd1w3TH4AchcGGp6BLgK/jAKBggqhkjOPQQDAzAuMQsw
CQYDVQQGEwJVUzENMAsGA1UEChMESVNSRzEQMA4GA1UEAxMHUm9vdCBZRTAeFw0y
NTA5MDMwMDAwMDBaFw0yODA5MDIyMzU5NTlaMDMxCzAJBgNVBAYTAlVTMRYwFAYD
VQQKEw1MZXQncyBFbmNyeXB0MQwwCgYDVQQDEwNZRTEwdjAQBgcqhkjOPQIBBgUr
gQQAIgNiAAQHZVB1/mimla2hfSurylScjPMZaOJXLz/NnAc2sylm8WDyhU9Ccp+z
ASQi5vSwGGJjSGklkD9fdPR8GpyDIOIjCEfrnbt/v+ZSEPLLEGbaM6EccDbN7p9x
teIm2Avf+ryjge4wgeswDgYDVR0PAQH/BAQDAgGGMBMGA1UdJQQMMAoGCCsGAQUF
BwMBMBIGA1UdEwEB/wQIMAYBAf8CAQAwHQYDVR0OBBYEFLsgykcL/tflnPmPCSqj
jDdFsbzYMB8GA1UdIwQYMBaAFKPIJlqOoUzQNWP8myPIOq5W809WMDIGCCsGAQUF
BwEBBCYwJDAiBggrBgEFBQcwAoYWaHR0cDovL3llLmkubGVuY3Iub3JnLzATBgNV
HSAEDDAKMAgGBmeBDAECATAnBgNVHR8EIDAeMBygGqAYhhZodHRwOi8veWUuYy5s
ZW5jci5vcmcvMAoGCCqGSM49BAMDA2gAMGUCMQDgjUEahFT/h3DRakqiPZpLvPgf
Zwkt6K2EOMmh1nvEzl83eMLYcod4GCl3b0J1Nn0CMBNYmEQJb4CEG5WoOe7aRn/L
VKu6saHmHEynI7ysIPd8zQsK1HdmhlHKlw9Z5GpGvA==
-----END CERTIFICATE-----''';

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

    if (!kIsWeb) {
      _configureSslPinning(dio);
    }

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

void _configureSslPinning(Dio dio) {
  (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
    // Debug: standard validation only (allows Charles/Proxyman intercept)
    if (kDebugMode) {
      return HttpClient()
        ..badCertificateCallback =
            (X509Certificate cert, String host, int port) => false;
    }

    // Release: trust ONLY the pinned E7 intermediate CA, not the OS trust
    // store. withTrustedRoots: true would let any system-trusted CA (or a
    // maliciously/corporately installed one) validate the connection too,
    // defeating the point of pinning. This Dio instance is only ever used
    // for muslimly.my.id (auth/sync/settings/article) — third-party APIs
    // (Quran.com, CDNs) use their own separate, unpinned Dio instances — so
    // narrowing the trust store here doesn't affect them.
    final certBytes = utf8.encode(_letsEncryptYE1Pem);
    final context = SecurityContext(withTrustedRoots: false);
    try {
      context.setTrustedCertificatesBytes(certBytes);
    } catch (_) {
      // Already in system store — safe to continue
    }

    return HttpClient(context: context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => false;
  };
}

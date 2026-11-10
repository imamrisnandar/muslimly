import 'package:dio/dio.dart';

/// Thrown when the server rejects a batch as invalid (HTTP 400) — retrying the
/// same batch can never succeed.
class PrayerLogRejected implements Exception {
  const PrayerLogRejected();
}

/// Remote side of prayer-log sync. Deliberately does not log payloads or
/// response bodies: prayer records are sensitive and must stay out of
/// Crashlytics/analytics.
abstract class PrayerLogRemote {
  Future<void> push(
    List<Map<String, Object?>> logs,
    String? token, {
    String? deviceId,
  });

  Future<List<Map<String, dynamic>>> pull(String token);
}

class PrayerLogApiService implements PrayerLogRemote {
  final Dio _dio;
  PrayerLogApiService(this._dio);

  Options _auth(String? token) => Options(
    headers: {
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    },
  );

  @override
  Future<void> push(
    List<Map<String, Object?>> logs,
    String? token, {
    String? deviceId,
  }) async {
    if (logs.isEmpty) return;
    try {
      final res = await _dio.post(
        '/sync/prayer-logs',
        data: {
          'logs': logs,
          if (deviceId != null && deviceId.isNotEmpty) 'device_id': deviceId,
        },
        options: _auth(token),
      );
      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception('prayer log push failed (${res.statusCode})');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) throw const PrayerLogRejected();
      throw Exception('prayer log push failed (${e.type.name})');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> pull(String token) async {
    try {
      final res = await _dio.get('/sync/prayer-logs', options: _auth(token));
      if (res.statusCode != 200) {
        throw Exception('prayer log pull failed (${res.statusCode})');
      }
      final data = res.data['data'];
      if (data is! List) return const [];
      return data
          .whereType<Map>()
          .map((m) => m.cast<String, dynamic>())
          .toList();
    } on DioException catch (e) {
      throw Exception('prayer log pull failed (${e.type.name})');
    }
  }
}

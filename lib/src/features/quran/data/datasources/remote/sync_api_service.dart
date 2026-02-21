import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class SyncApiService {
  final Dio _dio;

  SyncApiService(this._dio);

  Future<void> upsertReadingHistory(
    Map<String, dynamic> lastReadPayload,
    String? token,
  ) async {
    try {
      print('🌐 [API] POST /api/v1/sync/reading - Payload: $lastReadPayload');
      final response = await _dio.post(
        '/sync/reading',
        data: lastReadPayload,
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
        ),
      );
      print(
        '🌐 [API] POST /api/v1/sync/reading - Success: ${response.statusCode}',
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to upsert reading history');
      }
    } on DioException catch (e) {
      print(
        '❌ [API] POST /sync/reading Error: ${e.message} - ${e.response?.data}',
      );
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<List<dynamic>> getReadingHistory(
    String? token, {
    String? deviceId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (deviceId != null && deviceId.isNotEmpty) {
        queryParams['device_id'] = deviceId;
      }

      final response = await _dio.get(
        '/sync/reading',
        queryParameters: queryParams,
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data['data'] ?? [];
      } else {
        throw Exception('Failed to get reading history');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<void> bulkInsertActivities(
    List<Map<String, dynamic>> activities,
    String? token, {
    String? deviceId,
  }) async {
    if (activities.isEmpty) return;

    try {
      final payload = <String, dynamic>{'activities': activities};
      if (deviceId != null && deviceId.isNotEmpty) {
        payload['device_id'] = deviceId;
      }

      print(
        '🌐 [API] POST /api/v1/sync/activity - Activities count: ${activities.length}, DeviceID: $deviceId',
      );
      final response = await _dio.post(
        '/sync/activity',
        data: payload,
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
        ),
      );
      print(
        '🌐 [API] POST /api/v1/sync/activity - Success: ${response.statusCode}',
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to bulk insert activities');
      }
    } on DioException catch (e) {
      print(
        '❌ [API] POST /sync/activity Error: ${e.message} - ${e.response?.data}',
      );
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<void> upsertSettings(
    List<Map<String, String>> settings,
    String? token, {
    String? deviceId,
  }) async {
    if (settings.isEmpty) return;

    try {
      final payload = <String, dynamic>{'settings': settings};
      if (deviceId != null && deviceId.isNotEmpty) {
        payload['device_id'] = deviceId;
      }

      print(
        '🌐 [API] POST /sync/settings - Settings count: ${settings.length}, DeviceID: $deviceId',
      );
      final response = await _dio.post(
        '/sync/settings',
        data: payload,
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
        ),
      );
      print('🌐 [API] POST /sync/settings - Success: ${response.statusCode}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to upsert settings');
      }
    } on DioException catch (e) {
      print(
        '❌ [API] POST /sync/settings Error: ${e.message} - ${e.response?.data}',
      );
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<List<dynamic>> getSettings(String? token, {String? deviceId}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (deviceId != null && deviceId.isNotEmpty) {
        queryParams['device_id'] = deviceId;
      }

      final response = await _dio.get(
        '/sync/settings',
        queryParameters: queryParams,
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data['data'] ?? [];
      } else {
        throw Exception('Failed to get settings');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }
}

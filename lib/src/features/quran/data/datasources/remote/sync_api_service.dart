import 'package:flutter/foundation.dart';
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
      debugPrint('🌐 [API] POST /api/v1/sync/reading - Payload: $lastReadPayload');
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
      debugPrint(
        '🌐 [API] POST /api/v1/sync/reading - Success: ${response.statusCode}',
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to upsert reading history');
      }
    } on DioException catch (e) {
      debugPrint(
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

      debugPrint(
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
      debugPrint(
        '🌐 [API] POST /api/v1/sync/activity - Success: ${response.statusCode}',
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to bulk insert activities');
      }
    } on DioException catch (e) {
      debugPrint(
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

      debugPrint(
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
      debugPrint('🌐 [API] POST /sync/settings - Success: ${response.statusCode}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to upsert settings');
      }
    } on DioException catch (e) {
      debugPrint(
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

  Future<List<dynamic>> getActivities(String token, {int days = 365}) async {
    try {
      final response = await _dio.get(
        '/sync/activities',
        queryParameters: {'days': days},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode == 200) {
        return response.data['data'] ?? [];
      }
      return [];
    } on DioException {
      return [];
    }
  }

  Future<List<dynamic>> getBookmarks(String? token, {String? deviceId}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (deviceId != null && deviceId.isNotEmpty) {
        queryParams['device_id'] = deviceId;
      }
      final response = await _dio.get(
        '/sync/bookmarks',
        queryParameters: queryParams,
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
        ),
      );
      if (response.statusCode == 200) {
        return (response.data['data'] as List?) ?? [];
      }
      return [];
    } on DioException catch (e) {
      debugPrint('⚠️ [API] getBookmarks failed: ${e.message}');
      return [];
    }
  }

  Future<Map<String, dynamic>?> addBookmark(
    String? token,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await _dio.post(
        '/sync/bookmarks',
        data: payload,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
        ),
      );
      if (response.statusCode == 201) {
        return response.data['data'] as Map<String, dynamic>?;
      }
      return null;
    } on DioException catch (e) {
      debugPrint('⚠️ [API] addBookmark failed: ${e.message}');
      return null;
    }
  }

  Future<void> deleteBookmark(String? token, String serverId, {String? deviceId}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (deviceId != null && deviceId.isNotEmpty) {
        queryParams['device_id'] = deviceId;
      }
      await _dio.delete(
        '/sync/bookmarks/$serverId',
        queryParameters: queryParams,
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
        ),
      );
    } on DioException catch (e) {
      debugPrint('⚠️ [API] deleteBookmark failed: ${e.message}');
    }
  }

  Future<List<dynamic>> bulkUpsertBookmarks(
    String? token,
    List<Map<String, dynamic>> bookmarks, {
    String? deviceId,
  }) async {
    try {
      final response = await _dio.post(
        '/sync/bookmarks/bulk',
        data: {
          if (deviceId != null && deviceId.isNotEmpty) 'device_id': deviceId,
          'bookmarks': bookmarks,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
        ),
      );
      if (response.statusCode == 200) {
        return (response.data['data'] as List?) ?? [];
      }
      return [];
    } on DioException catch (e) {
      debugPrint('⚠️ [API] bulkUpsertBookmarks failed: ${e.message}');
      return [];
    }
  }

  Future<void> migrateGuestData(String token, String deviceId) async {
    try {
      await _dio.post(
        '/sync/migrate-guest',
        data: {'device_id': deviceId},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
    } on DioException catch (e) {
      debugPrint('⚠️ [API] migrate-guest failed (non-fatal): ${e.message}');
    }
  }
}

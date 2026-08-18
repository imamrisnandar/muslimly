import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/tajweed_model.dart';

abstract class TajweedRepository {
  Future<List<TajweedCategory>> getTajweedContent(String languageCode);
}

class TajweedRepositoryImpl implements TajweedRepository {
  @override
  Future<List<TajweedCategory>> getTajweedContent(String languageCode) async {
    try {
      // Determine file path based on language code
      // Default to 'id' if not 'en' (or stick to 'en' as default, user pref)
      // Assuming 'id' is standard for Indonesian
      final String fileName = (languageCode == 'id')
          ? 'tajweed_data_id.json'
          : 'tajweed_data_en.json';

      final String jsonString = await rootBundle.loadString(
        'assets/quran/json/$fileName',
      );
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => TajweedCategory.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load Tajweed content: $e');
    }
  }
}

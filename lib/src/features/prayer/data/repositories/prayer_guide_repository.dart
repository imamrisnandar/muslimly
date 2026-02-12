import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/prayer_guide_model.dart';

class PrayerGuideRepository {
  Future<List<PrayerGuideCategory>> getPrayerContent(String locale) async {
    try {
      final String fileName = (locale == 'id')
          ? 'prayer_guide_id.json'
          : 'prayer_guide_en.json';

      final String jsonString = await rootBundle.loadString(
        'assets/quran/json/$fileName',
      );

      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((json) => PrayerGuideCategory.fromJson(json))
          .toList();
    } catch (e) {
      // Fallback or rethrow
      // For safety during dev if file missing, return empty or throw
      print('Error loading prayer guide: $e');
      return [];
    }
  }
}

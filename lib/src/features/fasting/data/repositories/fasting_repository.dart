import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/fasting_model.dart';

abstract class FastingRepository {
  Future<List<FastingModel>> getFastingContent(String locale);
}

class FastingRepositoryImpl implements FastingRepository {
  @override
  Future<List<FastingModel>> getFastingContent(String locale) async {
    try {
      final String fileName = locale == 'id'
          ? 'assets/quran/json/fasting_data_id.json'
          : 'assets/quran/json/fasting_data_en.json';

      final String jsonString = await rootBundle.loadString(fileName);

      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => FastingModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load fasting content: $e');
    }
  }
}

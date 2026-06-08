import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/zikir_item.dart';
import '../../domain/repositories/zikir_repository.dart';

@LazySingleton(as: ZikirRepository)
class ZikirLocalRepository implements ZikirRepository {
  Future<List<ZikirItem>> _loadData(String category, Locale locale) async {
    try {
      final languageCode = locale.languageCode == 'id' ? 'id' : 'en';
      final jsonString = await rootBundle.loadString(
        'assets/quran/json/zikir_data_$languageCode.json',
      );
      final Map<String, dynamic> data = json.decode(jsonString);
      final List<dynamic> list = data[category] as List<dynamic>;
      return list.map((e) => ZikirItem.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error loading Zikir data: $e');
      return [];
    }
  }

  @override
  Future<List<ZikirItem>> getMorningZikir(Locale locale) =>
      _loadData('morning', locale);

  @override
  Future<List<ZikirItem>> getEveningZikir(Locale locale) =>
      _loadData('evening', locale);

  @override
  Future<List<ZikirItem>> getPrayerZikir(Locale locale) =>
      _loadData('prayer', locale);

  @override
  Future<List<ZikirItem>> getDailyDzikir(Locale locale) =>
      _loadData('daily', locale);
}

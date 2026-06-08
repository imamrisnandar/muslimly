import 'package:flutter/material.dart';
import '../entities/zikir_item.dart';

abstract interface class ZikirRepository {
  Future<List<ZikirItem>> getMorningZikir(Locale locale);
  Future<List<ZikirItem>> getEveningZikir(Locale locale);
  Future<List<ZikirItem>> getPrayerZikir(Locale locale);
  Future<List<ZikirItem>> getDailyDzikir(Locale locale);
}

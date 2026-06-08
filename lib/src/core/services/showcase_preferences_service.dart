import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class ShowcaseKeys {
  static const String dashboard = 'hasShownDashboardShowcase';
  static const String quranList = 'hasShownQuranListShowcase';
  static const String surahDetail = 'hasShownSurahDetailShowcase';
  static const String mushaf = 'hasShownMushafShowcase';
  static const String mushafPlayer = 'hasShownMushafPlayerShowcase';
  static const String audioPlayer = 'hasShownPlayerShowcase';
}

@lazySingleton
class ShowcasePreferencesService {
  Future<bool> hasShown(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false;
  }

  Future<void> markShown(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, true);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('hasShown')).toList();
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}

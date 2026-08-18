import 'package:shared_preferences/shared_preferences.dart';

/// Named ShowcaseView scopes, one per page *instance* that registers a
/// ShowcaseView. Scope names must be unique per State instance: re-registering
/// an existing name replaces its ShowcaseScope with an empty one, and any
/// still-alive Showcase widget bound to the old instance then crashes with a
/// null-check in ShowcaseService.getController on its next rebuild.
abstract class ShowcaseScopes {
  static int _counter = 0;

  static String surahDetail() => 'surahDetailScope-${++_counter}';
  static String mushaf() => 'mushafScope-${++_counter}';
}

abstract class ShowcaseKeys {
  static const String dashboard = 'hasShownDashboardShowcase';
  static const String quranList = 'hasShownQuranListShowcase';
  static const String surahDetail = 'hasShownSurahDetailShowcase';
  static const String mushaf = 'hasShownMushafShowcase';
  static const String mushafPlayer = 'hasShownMushafPlayerShowcase';
  static const String audioPlayer = 'hasShownPlayerShowcase';
}

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

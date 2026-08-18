import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/last_read.dart';

class LastReadRepository {
  static const String _keyMushaf = 'last_read_quran_mushaf';
  static const String _keyList = 'last_read_quran_list';
  static const String _keyMushafPendingSync = 'last_read_quran_mushaf_pending_sync';
  static const String _keyListPendingSync = 'last_read_quran_list_pending_sync';

  // Legacy key check could be done but simplistic approach is better for new architecture

  Future<void> saveLastRead(LastRead lastRead, {String mode = 'mushaf'}) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(lastRead.toJson());
    // Mode: 'mushaf' or 'list'
    final key = mode == 'list' ? _keyList : _keyMushaf;
    await prefs.setString(key, jsonString);
  }

  // Tracks whether the last saved position for [mode] has been pushed to the
  // backend yet, so a failed background sync (e.g. no network) can be
  // retried later instead of silently losing that update.
  Future<void> markPendingSync(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
      mode == 'list' ? _keyListPendingSync : _keyMushafPendingSync,
      true,
    );
  }

  Future<void> clearPendingSync(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(
      mode == 'list' ? _keyListPendingSync : _keyMushafPendingSync,
    );
  }

  Future<bool> hasPendingSync(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(
          mode == 'list' ? _keyListPendingSync : _keyMushafPendingSync,
        ) ??
        false;
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyMushaf);
    await prefs.remove(_keyList);
  }

  Future<LastRead?> getLastRead({String mode = 'mushaf'}) async {
    final prefs = await SharedPreferences.getInstance();
    final key = mode == 'list' ? _keyList : _keyMushaf;
    final jsonString = prefs.getString(key);

    if (jsonString != null) {
      try {
        final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
        return LastRead.fromJson(jsonMap);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/last_read.dart';

class LastReadRepository {
  static const String _keyMushaf = 'last_read_quran_mushaf';
  static const String _keyList = 'last_read_quran_list';

  // Legacy key check could be done but simplistic approach is better for new architecture

  Future<void> saveLastRead(LastRead lastRead, {String mode = 'mushaf'}) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(lastRead.toJson());
    // Mode: 'mushaf' or 'list'
    final key = mode == 'list' ? _keyList : _keyMushaf;
    await prefs.setString(key, jsonString);
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

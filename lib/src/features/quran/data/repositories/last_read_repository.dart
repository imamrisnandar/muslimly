import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/last_read.dart';

class LastReadRepository {
  static const String _key = 'last_read_quran';

  Future<void> saveLastRead(LastRead lastRead) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(lastRead.toJson());
    await prefs.setString(_key, jsonString);
  }

  Future<LastRead?> getLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
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

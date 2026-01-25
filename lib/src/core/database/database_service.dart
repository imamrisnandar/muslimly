import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../features/quran/domain/entities/reading_activity.dart';
import '../../features/quran/domain/entities/quran_bookmark.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'muslimly.db');

    return await openDatabase(
      path,
      version: 7, // Upgraded for Ayah Bookmark
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create settings table
    await db.execute('''
      CREATE TABLE app_settings (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');

    // Reading Activity Table
    await db.execute('''
      CREATE TABLE reading_activity (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        page_number INTEGER NOT NULL,
        surah_number INTEGER,
        duration_seconds INTEGER DEFAULT 0,
        timestamp INTEGER NOT NULL,
        start_ayah INTEGER,
        end_ayah INTEGER,
        total_ayahs INTEGER,
        mode TEXT DEFAULT 'page'
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_reading_date ON reading_activity (date)',
    );

    // Bookmarks Table
    await db.execute('''
      CREATE TABLE bookmarks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        surah_number INTEGER NOT NULL,
        surah_name TEXT NOT NULL,
        page_number INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        ayah_number INTEGER
      )
    ''');

    // Translation Cache
    await _createTranslationTable(db);

    // Tafsir Cache
    await _createTafsirTable(db);

    // Tajweed Cache
    await _createTajweedTable(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createBookmarksTable(db);
    }
    if (oldVersion < 3) {
      // Add settings table for v3
      await db.execute('''
        CREATE TABLE app_settings (
          key TEXT PRIMARY KEY,
          value TEXT
        )
      ''');
    }
    if (oldVersion < 4) {
      await _createTranslationTable(db);
      await _createTafsirTable(db);
    }
    if (oldVersion < 5) {
      await _createTajweedTable(db);
    }
    if (oldVersion < 6) {
      // Add columns for Ayah Tracking
      await db.execute(
        'ALTER TABLE reading_activity ADD COLUMN start_ayah INTEGER',
      );
      await db.execute(
        'ALTER TABLE reading_activity ADD COLUMN end_ayah INTEGER',
      );
      await db.execute(
        'ALTER TABLE reading_activity ADD COLUMN total_ayahs INTEGER',
      );
      await db.execute(
        "ALTER TABLE reading_activity ADD COLUMN mode TEXT DEFAULT 'page'",
      );
    }
    if (oldVersion < 7) {
      // Add ayah_number to bookmarks
      await db.execute('ALTER TABLE bookmarks ADD COLUMN ayah_number INTEGER');
    }
  }

  Future<void> _createBookmarksTable(Database db) async {
    await db.execute('''
      CREATE TABLE bookmarks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        surah_number INTEGER NOT NULL,
        surah_name TEXT NOT NULL,
        page_number INTEGER NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');
  }

  Future<void> _createTranslationTable(Database db) async {
    await db.execute('''
      CREATE TABLE translations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        surah_number INTEGER NOT NULL,
        ayah_number INTEGER NOT NULL,
        language_code TEXT NOT NULL, 
        text TEXT NOT NULL,
        UNIQUE(surah_number, ayah_number, language_code)
      )
    ''');
  }

  Future<void> _createTafsirTable(Database db) async {
    await db.execute('''
      CREATE TABLE tafsirs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        surah_number INTEGER NOT NULL,
        ayah_number INTEGER NOT NULL,
        tafsir_id TEXT NOT NULL,
        text TEXT NOT NULL,
        UNIQUE(surah_number, ayah_number, tafsir_id)
      )
    ''');
  }

  Future<void> _createTajweedTable(Database db) async {
    await db.execute('''
      CREATE TABLE tajweeds (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        surah_number INTEGER NOT NULL,
        ayah_number INTEGER NOT NULL,
        text TEXT NOT NULL,
        UNIQUE(surah_number, ayah_number)
      )
    ''');
  }

  // --- Settings Methods ---

  Future<void> saveSetting(String key, String value) async {
    final db = await database;
    await db.insert('app_settings', {
      'key': key,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> getSetting(String key) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'app_settings',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (maps.isNotEmpty) {
      return maps.first['value'] as String;
    }
    return null;
  }

  // --- CRUD Operations for Reading Activity ---

  /// Inserts a new reading log.
  Future<int> insertActivity(ReadingActivity activity) async {
    final db = await database;
    return await db.insert('reading_activity', activity.toMap());
  }

  /// Get total pages read for a specific date (e.g., today).
  /// Count distinct pages to avoid double counting same page read multiple times in a day?
  /// Strategy: Usually target is "4 pages". If I read page 1 twice, does it count as 2?
  /// Let's count *Unique Pages* to be stricter, OR just count entries.
  /// For now, distinct page numbers seems fairer for "completing 4 pages".
  Future<int> getDailyPageCount(String date) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(DISTINCT page_number) as count FROM reading_activity WHERE date = ?',
      [date],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getDailyAyahCount(String date) async {
    final db = await database;
    // We sum the total_ayahs column for a specific date
    final result = await db.rawQuery(
      'SELECT SUM(total_ayahs) as count FROM reading_activity WHERE date = ?',
      [date],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Get all activities for a date (for history detail)
  Future<List<ReadingActivity>> getActivitiesByDate(String date) async {
    final db = await database;
    final maps = await db.query(
      'reading_activity',
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'timestamp DESC',
    );
    return maps.map((e) => ReadingActivity.fromMap(e)).toList();
  }

  /// Get generic history with pagination
  Future<List<ReadingActivity>> getReadingHistory({
    int limit = 50,
    int offset = 0,
  }) async {
    final db = await database;
    final maps = await db.query(
      'reading_activity',
      orderBy: 'timestamp DESC',
      limit: limit,
      offset: offset,
    );
    return maps.map((e) => ReadingActivity.fromMap(e)).toList();
  }

  /// Get progress for the 7 days ending on [endDate] (inclusive)
  /// If [mode] is 'page', counts distinct pages.
  /// If [mode] is 'ayah', sums total_ayahs.
  Future<Map<String, int>> getWeeklyProgress({
    DateTime? endDate,
    String mode = 'page',
  }) async {
    final db = await database;
    final end = endDate ?? DateTime.now();
    final start = end.subtract(const Duration(days: 6));

    final startStr = start.toIso8601String().substring(0, 10);
    final endStr = end.toIso8601String().substring(0, 10);

    String query;
    if (mode == 'ayah') {
      query = '''
        SELECT date, SUM(total_ayahs) as count 
        FROM reading_activity 
        WHERE date >= ? AND date <= ?
        GROUP BY date
      ''';
    } else {
      query = '''
        SELECT date, COUNT(DISTINCT page_number) as count 
        FROM reading_activity 
        WHERE date >= ? AND date <= ? AND mode = 'page'
        GROUP BY date
      ''';
    }

    final result = await db.rawQuery(query, [startStr, endStr]);

    final Map<String, int> progressMap = {};
    for (var row in result) {
      progressMap[row['date'] as String] = (row['count'] as int?) ?? 0;
    }
    return progressMap;
  }

  // --- CRUD Operations for Bookmarks ---

  Future<int> insertBookmark(QuranBookmark bookmark) async {
    final db = await database;
    return await db.insert('bookmarks', bookmark.toMap());
  }

  Future<List<QuranBookmark>> getBookmarks() async {
    final db = await database;
    final maps = await db.query('bookmarks', orderBy: 'created_at DESC');
    return maps.map((e) => QuranBookmark.fromMap(e)).toList();
  }

  Future<int> deleteBookmark(int id) async {
    final db = await database;
    return await db.delete('bookmarks', where: 'id = ?', whereArgs: [id]);
  }

  // --- CRUD for Translations & Tafsir ---

  Future<void> cacheTranslation(
    int surahId,
    int ayahId,
    String lang,
    String text,
  ) async {
    final db = await database;
    await db.insert('translations', {
      'surah_number': surahId,
      'ayah_number': ayahId,
      'language_code': lang,
      'text': text,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> getCachedTranslation(
    int surahId,
    int ayahId,
    String lang,
  ) async {
    final db = await database;
    final maps = await db.query(
      'translations',
      where: 'surah_number = ? AND ayah_number = ? AND language_code = ?',
      whereArgs: [surahId, ayahId, lang],
    );
    if (maps.isNotEmpty) return maps.first['text'] as String;
    return null;
  }

  Future<void> cacheTafsir(
    int surahId,
    int ayahId,
    String tafsirId,
    String text,
  ) async {
    final db = await database;
    await db.insert('tafsirs', {
      'surah_number': surahId,
      'ayah_number': ayahId,
      'tafsir_id': tafsirId,
      'text': text,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> getCachedTafsir(
    int surahId,
    int ayahId,
    String tafsirId,
  ) async {
    final db = await database;
    final maps = await db.query(
      'tafsirs',
      where: 'surah_number = ? AND ayah_number = ? AND tafsir_id = ?',
      whereArgs: [surahId, ayahId, tafsirId],
    );
    if (maps.isNotEmpty) return maps.first['text'] as String;
    return null;
  }

  Future<Map<int, String>> getSurahTranslations(
    int surahId,
    String lang,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'translations',
      columns: ['ayah_number', 'text'],
      where: 'surah_number = ? AND language_code = ?',
      whereArgs: [surahId, lang],
    );

    final Map<int, String> result = {};
    for (var map in maps) {
      result[map['ayah_number'] as int] = map['text'] as String;
    }
    return result;
  }

  Future<void> cacheTranslationsBatch(
    List<Map<String, dynamic>> translations,
  ) async {
    final db = await database;
    final batch = db.batch();

    for (var t in translations) {
      batch.insert(
        'translations',
        t,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  // --- CRUD for Tajweed ---

  Future<void> cacheTajweedBatch(List<Map<String, dynamic>> data) async {
    final db = await database;
    final batch = db.batch();
    for (var item in data) {
      batch.insert('tajweeds', {
        'surah_number': item['surah_number'],
        'ayah_number': item['ayah_number'],
        'text': item['text'],
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<Map<int, String>> getTajweedBatch(int surahId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'tajweeds',
        where: 'surah_number = ?',
        whereArgs: [surahId],
      );

      final Map<int, String> result = {};
      for (var map in maps) {
        final ayahNum = map['ayah_number'] as int;
        final text = map['text'] as String;
        result[ayahNum] = text;
      }
      return result;
    } catch (e) {
      print('DEBUG: Error querying tajweed: $e');
      return {};
    }
  }
}

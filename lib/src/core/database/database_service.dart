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
      version: 3, // Upgraded version
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
        timestamp INTEGER NOT NULL
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_reading_date ON reading_activity (date)',
    );

    // Bookmarks Table
    await _createBookmarksTable(db);
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
  /// Returns Map { '2023-01-01': 4, ... }
  Future<Map<String, int>> getWeeklyProgress({DateTime? endDate}) async {
    final db = await database;
    final end = endDate ?? DateTime.now();
    final start = end.subtract(const Duration(days: 6));

    final startStr = start.toIso8601String().substring(0, 10);
    final endStr = end.toIso8601String().substring(0, 10);

    // We filter by range
    final result = await db.rawQuery(
      '''
      SELECT date, COUNT(DISTINCT page_number) as count 
      FROM reading_activity 
      WHERE date >= ? AND date <= ?
      GROUP BY date
    ''',
      [startStr, endStr],
    );

    final Map<String, int> progressMap = {};
    for (var row in result) {
      progressMap[row['date'] as String] = row['count'] as int;
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
}

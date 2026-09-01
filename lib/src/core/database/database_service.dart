import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../utils/app_logger.dart';
import '../../features/quran/domain/entities/reading_activity.dart';
import '../../features/quran/domain/entities/quran_bookmark.dart';
import '../../features/quran/domain/entities/quran_folder.dart';

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
      version: 14, // v14: bookmark_folders per-mode folders + bookmarks.folder_id
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
        mode TEXT DEFAULT 'page',
        is_synced INTEGER DEFAULT 0
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_reading_date ON reading_activity (date)',
    );

    // Bookmark Folders Table (per-mode; 'list' and 'mushaf' have independent folders)
    await db.execute('''
      CREATE TABLE bookmark_folders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mode TEXT NOT NULL,
        name TEXT NOT NULL,
        is_system INTEGER NOT NULL DEFAULT 0,
        system_key TEXT,
        created_at INTEGER NOT NULL,
        server_id TEXT UNIQUE
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_bookmark_folders_mode ON bookmark_folders(mode)',
    );
    await db.execute(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_bookmark_folders_system ON bookmark_folders(mode, system_key) WHERE is_system = 1',
    );

    // Bookmarks Table
    await db.execute('''
      CREATE TABLE bookmarks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        surah_number INTEGER NOT NULL,
        surah_name TEXT NOT NULL,
        page_number INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        ayah_number INTEGER,
        mode TEXT DEFAULT 'list',
        server_id TEXT UNIQUE,
        folder_id INTEGER REFERENCES bookmark_folders(id)
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_bookmarks_server_id ON bookmarks(server_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_bookmarks_folder_id ON bookmarks(folder_id)',
    );

    // Pending bookmark deletes queue (offline support)
    await db.execute('''
      CREATE TABLE pending_bookmark_deletes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id TEXT NOT NULL UNIQUE,
        created_at INTEGER NOT NULL
      )
    ''');

    // Pending bookmark FOLDER deletes queue (offline support)
    await db.execute('''
      CREATE TABLE pending_bookmark_folder_deletes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id TEXT NOT NULL UNIQUE,
        created_at INTEGER NOT NULL
      )
    ''');

    // Translation Cache
    await _createTranslationTable(db);

    // Tafsir Cache
    await _createTafsirTable(db);

    // Tajweed Cache
    await _createTajweedTable(db);

    // Article Cache
    await _createArticlesTable(db);
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
    if (oldVersion < 8) {
      // Add mode to bookmarks
      await db.execute(
        "ALTER TABLE bookmarks ADD COLUMN mode TEXT DEFAULT 'list'",
      );
      // Logic: If ayah_number is NULL, it's a page bookmark (Mushaf Mode)
      await db.execute(
        "UPDATE bookmarks SET mode = 'mushaf' WHERE ayah_number IS NULL",
      );
    }
    if (oldVersion < 9) {
      // Create Articles Table
      await _createArticlesTable(db);
    }
    if (oldVersion < 10) {
      await db.execute(
        'ALTER TABLE reading_activity ADD COLUMN is_synced INTEGER DEFAULT 0',
      );
    }
    if (oldVersion < 11) {
      await db.execute('ALTER TABLE bookmarks ADD COLUMN server_id TEXT');
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_bookmarks_server_id ON bookmarks(server_id)',
      );
    }
    if (oldVersion < 12) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS pending_bookmark_deletes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          server_id TEXT NOT NULL UNIQUE,
          created_at INTEGER NOT NULL
        )
      ''');
    }
    if (oldVersion < 13) {
      // Fresh installs at v12 (before _onCreate fix) missed server_id on bookmarks
      try {
        await db.execute('ALTER TABLE bookmarks ADD COLUMN server_id TEXT UNIQUE');
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_bookmarks_server_id ON bookmarks(server_id)',
        );
      } catch (_) {
        // Column already exists (users who upgraded through v11)
      }
    }
    if (oldVersion < 14) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS bookmark_folders (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          mode TEXT NOT NULL,
          name TEXT NOT NULL,
          is_system INTEGER NOT NULL DEFAULT 0,
          system_key TEXT,
          created_at INTEGER NOT NULL,
          server_id TEXT UNIQUE
        )
      ''');
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_bookmark_folders_mode ON bookmark_folders(mode)',
      );
      await db.execute(
        'CREATE UNIQUE INDEX IF NOT EXISTS idx_bookmark_folders_system ON bookmark_folders(mode, system_key) WHERE is_system = 1',
      );
      try {
        await db.execute(
          'ALTER TABLE bookmarks ADD COLUMN folder_id INTEGER REFERENCES bookmark_folders(id)',
        );
      } catch (_) {
        // Column already exists (re-run safety, mirrors the v13 pattern above)
      }
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_bookmarks_folder_id ON bookmarks(folder_id)',
      );
      await db.execute('''
        CREATE TABLE IF NOT EXISTS pending_bookmark_folder_deletes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          server_id TEXT NOT NULL UNIQUE,
          created_at INTEGER NOT NULL
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
        created_at INTEGER NOT NULL,
        mode TEXT DEFAULT 'list'
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

  Future<void> _createArticlesTable(Database db) async {
    await db.execute('''
      CREATE TABLE articles (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        summary TEXT NOT NULL,
        category TEXT NOT NULL,
        author TEXT NOT NULL,
        published_at TEXT NOT NULL,
        order_priority INTEGER NOT NULL
      )
    ''');
  }

  // --- CRUD for Articles ---

  Future<void> cacheArticles(List<Map<String, dynamic>> articles) async {
    final db = await database;
    final batch = db.batch();

    // Clear oldcache? Maybe simpler to just replace
    // Or we could execute a delete all first if we want full sync
    // Let's assume full sync strategy
    await db.delete('articles');

    for (var article in articles) {
      batch.insert(
        'articles',
        article,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getCachedArticles() async {
    final db = await database;
    return await db.query(
      'articles',
      orderBy: 'order_priority DESC, published_at DESC',
    );
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
      "SELECT COUNT(DISTINCT page_number) as count FROM reading_activity WHERE date = ? AND mode = 'page'",
      [date],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getDailyAyahCount(String date) async {
    final db = await database;
    // We sum the total_ayahs column for a specific date, filtering only 'ayah' mode
    final result = await db.rawQuery(
      "SELECT SUM(total_ayahs) as count FROM reading_activity WHERE date = ? AND mode = 'ayah'",
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

  /// Get all unsynced activities
  Future<List<ReadingActivity>> getUnsyncedActivities() async {
    final db = await database;
    final maps = await db.query(
      'reading_activity',
      where: 'is_synced = ?',
      whereArgs: [0],
      orderBy: 'timestamp ASC', // Sync older ones first
    );
    return maps.map((e) => ReadingActivity.fromMap(e)).toList();
  }

  /// Mark specific activities as synced using their local IDs
  Future<void> markActivitiesAsSynced(List<int> ids) async {
    if (ids.isEmpty) return;

    final db = await database;
    final placeholders = List.filled(ids.length, '?').join(',');

    await db.update(
      'reading_activity',
      {'is_synced': 1},
      where: 'id IN ($placeholders)',
      whereArgs: ids,
    );
  }

  Future<void> mergeRemoteActivities(List<Map<String, dynamic>> remoteActivities) async {
    final db = await database;
    for (final a in remoteActivities) {
      final timestamp = a['timestamp'] as int?;
      if (timestamp == null) continue;
      final existing = await db.query(
        'reading_activity',
        where: 'timestamp = ?',
        whereArgs: [timestamp],
        limit: 1,
      );
      if (existing.isNotEmpty) continue;
      await db.insert('reading_activity', {
        'date': a['date'] as String? ?? '',
        'page_number': a['page_number'] as int? ?? 0,
        'surah_number': a['surah_number'] as int? ?? 0,
        'duration_seconds': a['duration_seconds'] as int? ?? 0,
        'timestamp': timestamp,
        'start_ayah': a['start_ayah'] as int? ?? 0,
        'end_ayah': a['end_ayah'] as int? ?? 0,
        'total_ayahs': a['total_ayahs'] as int? ?? 0,
        'mode': a['mode'] as String? ?? 'page',
        'is_synced': 1,
      });
    }
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

  /// Get progress for the [days] days ending on [endDate] (inclusive)
  /// If [mode] is 'page', counts distinct pages.
  /// If [mode] is 'ayah', sums total_ayahs.
  Future<Map<String, int>> getWeeklyProgress({
    DateTime? endDate,
    String mode = 'page',
    int days = 7,
  }) async {
    final db = await database;
    final end = endDate ?? DateTime.now();
    final start = end.subtract(Duration(days: days - 1));

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

  Future<void> clearAllBookmarks() async {
    final db = await database;
    await db.delete('bookmarks');
    await db.delete('pending_bookmark_deletes');
  }

  Future<void> addPendingBookmarkDelete(String serverId) async {
    final db = await database;
    await db.insert(
      'pending_bookmark_deletes',
      {'server_id': serverId, 'created_at': DateTime.now().millisecondsSinceEpoch},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<List<String>> getPendingBookmarkDeletes() async {
    final db = await database;
    final rows = await db.query('pending_bookmark_deletes', columns: ['server_id']);
    return rows.map((r) => r['server_id'] as String).toList();
  }

  Future<void> removePendingBookmarkDelete(String serverId) async {
    final db = await database;
    await db.delete('pending_bookmark_deletes', where: 'server_id = ?', whereArgs: [serverId]);
  }

  Future<void> updateServerIdForBookmark(int localId, String serverId) async {
    final db = await database;
    await db.update(
      'bookmarks',
      {'server_id': serverId},
      where: 'id = ?',
      whereArgs: [localId],
    );
  }

  // Merge server bookmarks into local — inserts missing, updates server_id for existing
  Future<void> mergeRemoteBookmarks(List<Map<String, dynamic>> remoteBookmarks) async {
    final db = await database;
    for (final remote in remoteBookmarks) {
      final serverId = remote['id'] as String?;
      if (serverId == null) continue;

      final mode = remote['mode'] as String? ?? 'list';
      final surahNumber = remote['surah_number'] as int? ?? 0;
      final ayahNumber = remote['ayah_number'] as int?;
      final pageNumber = remote['page_number'] as int? ?? 0;

      // Resolve remote folder_id (server UUID) to a local int id. If the
      // referenced folder hasn't been merged locally yet (ordering edge case),
      // fall back to null (uncategorized) rather than failing the merge — this
      // self-heals on a later pull once the folder exists locally.
      int? localFolderId;
      final remoteFolderServerId = remote['folder_id'] as String?;
      if (remoteFolderServerId != null) {
        final folderRows = await db.query(
          'bookmark_folders',
          where: 'server_id = ?',
          whereArgs: [remoteFolderServerId],
        );
        if (folderRows.isNotEmpty) {
          localFolderId = folderRows.first['id'] as int?;
        }
      }

      // Build where clause by type
      String whereClause;
      List<dynamic> whereArgs;
      if (mode == 'list') {
        whereClause = 'surah_number = ? AND ayah_number = ? AND mode = ?';
        whereArgs = [surahNumber, ayahNumber, 'list'];
      } else if (ayahNumber != null) {
        whereClause = 'surah_number = ? AND ayah_number = ? AND mode = ?';
        whereArgs = [surahNumber, ayahNumber, 'mushaf'];
      } else {
        whereClause = 'page_number = ? AND ayah_number IS NULL AND mode = ?';
        whereArgs = [pageNumber, 'mushaf'];
      }

      final existing = await db.query(
        'bookmarks',
        where: whereClause,
        whereArgs: whereArgs,
      );

      if (existing.isNotEmpty) {
        // Update server_id for existing local bookmark. folder_id is only
        // included when remote actually resolved one — a local-only folder
        // assignment that hasn't synced yet (remote folder_id still null,
        // e.g. its own push failed or the folder isn't deployed server-side)
        // must not be clobbered back to null just because remote hasn't
        // caught up.
        final updateData = <String, dynamic>{'server_id': serverId};
        if (localFolderId != null) {
          updateData['folder_id'] = localFolderId;
        }
        await db.update(
          'bookmarks',
          updateData,
          where: 'id = ?',
          whereArgs: [existing.first['id']],
        );
      } else {
        // Insert new bookmark from server
        await db.insert('bookmarks', {
          'surah_number': surahNumber,
          'surah_name': remote['surah_name'] ?? '',
          'page_number': pageNumber,
          'ayah_number': ayahNumber,
          'mode': mode,
          'server_id': serverId,
          'folder_id': localFolderId,
          'created_at': DateTime.now().millisecondsSinceEpoch,
        });
      }
    }
  }

  // --- CRUD Operations for Bookmark Folders ---

  Future<int> insertFolder(QuranFolder folder) async {
    final db = await database;
    return await db.insert('bookmark_folders', folder.toMap());
  }

  Future<List<QuranFolder>> getFolders({required String mode}) async {
    final db = await database;
    final maps = await db.query(
      'bookmark_folders',
      where: 'mode = ?',
      whereArgs: [mode],
      orderBy: 'created_at ASC',
    );
    return maps.map(QuranFolder.fromMap).toList();
  }

  Future<QuranFolder?> getFolderById(int id) async {
    final db = await database;
    final maps = await db.query('bookmark_folders', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return QuranFolder.fromMap(maps.first);
  }

  /// Idempotent lazy seeding of system default folders for [mode]. Safe to
  /// call on every load — the unique index on (mode, system_key) makes the
  /// insert a no-op after the first successful seed.
  Future<void> ensureDefaultFolders(
    String mode, {
    required String hapalanLabel,
    required String bacaanLabel,
  }) async {
    final db = await database;
    final defaults = [('hapalan', hapalanLabel), ('bacaan', bacaanLabel)];
    for (final (key, name) in defaults) {
      await db.insert(
        'bookmark_folders',
        {
          'mode': mode,
          'name': name,
          'is_system': 1,
          'system_key': key,
          'created_at': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  Future<void> renameFolder(int id, String name) async {
    final db = await database;
    await db.update('bookmark_folders', {'name': name}, where: 'id = ?', whereArgs: [id]);
  }

  /// Deletes the folder and nulls out `folder_id` on any bookmarks that
  /// referenced it — bookmarks become uncategorized, not deleted.
  Future<void> deleteFolder(int id) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.update('bookmarks', {'folder_id': null}, where: 'folder_id = ?', whereArgs: [id]);
      await txn.delete('bookmark_folders', where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<void> assignBookmarkToFolder(int bookmarkId, int? folderId) async {
    final db = await database;
    await db.update(
      'bookmarks',
      {'folder_id': folderId},
      where: 'id = ?',
      whereArgs: [bookmarkId],
    );
  }

  Future<void> updateServerIdForFolder(int localId, String serverId) async {
    final db = await database;
    await db.update(
      'bookmark_folders',
      {'server_id': serverId},
      where: 'id = ?',
      whereArgs: [localId],
    );
  }

  /// Merge server folders into local. System folders (Hapalan/Bacaan) match
  /// on (mode, system_key) rather than server_id — the client's own
  /// ensureDefaultFolders may have already created a local row before ever
  /// talking to the server (offline-first), so matching on system_key
  /// reconciles that pre-existing row instead of creating a duplicate.
  /// Custom folders always match on server_id.
  Future<void> mergeRemoteFolders(List<Map<String, dynamic>> remoteFolders) async {
    final db = await database;
    for (final remote in remoteFolders) {
      final serverId = remote['id'] as String?;
      if (serverId == null) continue;
      final mode = remote['mode'] as String? ?? 'list';
      final isSystem = remote['is_system'] as bool? ?? false;
      final systemKey = remote['system_key'] as String?;

      final existing = (isSystem && systemKey != null)
          ? await db.query(
              'bookmark_folders',
              where: 'mode = ? AND system_key = ? AND is_system = 1',
              whereArgs: [mode, systemKey],
            )
          : await db.query('bookmark_folders', where: 'server_id = ?', whereArgs: [serverId]);

      if (existing.isNotEmpty) {
        await db.update(
          'bookmark_folders',
          {'server_id': serverId, 'name': remote['name']},
          where: 'id = ?',
          whereArgs: [existing.first['id']],
        );
      } else {
        await db.insert('bookmark_folders', {
          'mode': mode,
          'name': remote['name'] ?? '',
          'is_system': isSystem ? 1 : 0,
          'system_key': systemKey,
          'server_id': serverId,
          'created_at': DateTime.now().millisecondsSinceEpoch,
        });
      }
    }
  }

  Future<void> clearAllFolders() async {
    final db = await database;
    await db.delete('bookmark_folders');
    await db.delete('pending_bookmark_folder_deletes');
  }

  Future<void> addPendingBookmarkFolderDelete(String serverId) async {
    final db = await database;
    await db.insert(
      'pending_bookmark_folder_deletes',
      {'server_id': serverId, 'created_at': DateTime.now().millisecondsSinceEpoch},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<List<String>> getPendingBookmarkFolderDeletes() async {
    final db = await database;
    final rows = await db.query('pending_bookmark_folder_deletes', columns: ['server_id']);
    return rows.map((r) => r['server_id'] as String).toList();
  }

  Future<void> removePendingBookmarkFolderDelete(String serverId) async {
    final db = await database;
    await db.delete(
      'pending_bookmark_folder_deletes',
      where: 'server_id = ?',
      whereArgs: [serverId],
    );
  }

  Future<bool> isBookmarked({
    int? surahNumber,
    int? ayahNumber,
    int? pageNumber,
    required String mode,
  }) async {
    final db = await database;
    String whereClause;
    List<dynamic> whereArgs;

    if (mode == 'list') {
      whereClause = 'surah_number = ? AND ayah_number = ? AND mode = ?';
      whereArgs = [surahNumber, ayahNumber, 'list'];
    } else {
      // Mushaf mode - check page AND ayah if provided (Granular Mushaf Bookmarks)
      if (ayahNumber != null) {
        whereClause = 'page_number = ? AND mode = ? AND ayah_number = ?';
        whereArgs = [pageNumber, 'mushaf', ayahNumber];
      } else {
        whereClause = 'page_number = ? AND mode = ? AND ayah_number IS NULL';
        whereArgs = [pageNumber, 'mushaf'];
      }
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'bookmarks',
      where: whereClause,
      whereArgs: whereArgs,
    );
    return maps.isNotEmpty;
  }

  Future<int> deleteBookmarkByDetails({
    int? surahNumber,
    int? ayahNumber,
    int? pageNumber,
    required String mode,
  }) async {
    final db = await database;
    String whereClause;
    List<dynamic> whereArgs;

    if (mode == 'list') {
      whereClause = 'surah_number = ? AND ayah_number = ? AND mode = ?';
      whereArgs = [surahNumber, ayahNumber, 'list'];
    } else {
      if (ayahNumber != null) {
        whereClause = 'page_number = ? AND mode = ? AND ayah_number = ?';
        whereArgs = [pageNumber, 'mushaf', ayahNumber];
      } else {
        whereClause = 'page_number = ? AND mode = ? AND ayah_number IS NULL';
        whereArgs = [pageNumber, 'mushaf'];
      }
    }

    return await db.delete(
      'bookmarks',
      where: whereClause,
      whereArgs: whereArgs,
    );
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
      AppLogger.warning('Failed to query tajweed data', e);
      return {};
    }
  }
}

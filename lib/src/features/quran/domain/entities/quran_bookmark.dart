class QuranBookmark {
  final int? id;
  final int surahNumber;
  final String surahName;
  final int pageNumber;
  final int createdAt;
  final int? ayahNumber;
  final String mode; // 'list' or 'mushaf'
  final String? serverId; // UUID from BE — null = not yet synced
  final int? folderId; // local bookmark_folders.id — null = uncategorized

  QuranBookmark({
    this.id,
    required this.surahNumber,
    required this.surahName,
    required this.pageNumber,
    required this.createdAt,
    this.ayahNumber,
    this.mode = 'list',
    this.serverId,
    this.folderId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'surah_number': surahNumber,
      'surah_name': surahName,
      'page_number': pageNumber,
      'created_at': createdAt,
      'ayah_number': ayahNumber,
      'mode': mode,
      'server_id': serverId,
      'folder_id': folderId,
    };
  }

  factory QuranBookmark.fromMap(Map<String, dynamic> map) {
    return QuranBookmark(
      id: map['id'],
      surahNumber: map['surah_number'],
      surahName: map['surah_name'],
      pageNumber: map['page_number'],
      createdAt: map['created_at'],
      ayahNumber: map['ayah_number'],
      mode: map['mode'] ?? 'list',
      serverId: map['server_id'] as String?,
      folderId: map['folder_id'] as int?,
    );
  }

  /// [folderId] sets a new folder; pass [clearFolderId] to explicitly move
  /// the bookmark to "no folder" (a plain null [folderId] means "leave
  /// unchanged", since it can't otherwise be told apart from clearing).
  QuranBookmark copyWith({
    String? serverId,
    int? folderId,
    bool clearFolderId = false,
  }) {
    return QuranBookmark(
      id: id,
      surahNumber: surahNumber,
      surahName: surahName,
      pageNumber: pageNumber,
      createdAt: createdAt,
      ayahNumber: ayahNumber,
      mode: mode,
      serverId: serverId ?? this.serverId,
      folderId: clearFolderId ? null : (folderId ?? this.folderId),
    );
  }
}

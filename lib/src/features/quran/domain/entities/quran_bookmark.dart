class QuranBookmark {
  final int? id;
  final int surahNumber;
  final String surahName;
  final int pageNumber;
  final int createdAt;
  final int? ayahNumber;
  final String mode; // 'list' or 'mushaf'
  final String? serverId; // UUID from BE — null = not yet synced

  QuranBookmark({
    this.id,
    required this.surahNumber,
    required this.surahName,
    required this.pageNumber,
    required this.createdAt,
    this.ayahNumber,
    this.mode = 'list',
    this.serverId,
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
    );
  }

  QuranBookmark copyWith({String? serverId}) {
    return QuranBookmark(
      id: id,
      surahNumber: surahNumber,
      surahName: surahName,
      pageNumber: pageNumber,
      createdAt: createdAt,
      ayahNumber: ayahNumber,
      mode: mode,
      serverId: serverId ?? this.serverId,
    );
  }
}

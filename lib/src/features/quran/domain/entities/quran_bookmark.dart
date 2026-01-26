class QuranBookmark {
  final int? id;
  final int surahNumber;
  final String surahName;
  final int pageNumber;
  final int createdAt;
  final int? ayahNumber;
  final String mode; // 'list' or 'mushaf'

  QuranBookmark({
    this.id,
    required this.surahNumber,
    required this.surahName,
    required this.pageNumber,
    required this.createdAt,
    this.ayahNumber,
    this.mode = 'list',
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
      mode: map['mode'] ?? 'list', // Default for legacy data
    );
  }
}

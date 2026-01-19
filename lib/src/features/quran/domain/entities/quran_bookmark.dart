class QuranBookmark {
  final int? id;
  final int surahNumber;
  final String surahName;
  final int pageNumber;
  final int createdAt;

  QuranBookmark({
    this.id,
    required this.surahNumber,
    required this.surahName,
    required this.pageNumber,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'surah_number': surahNumber,
      'surah_name': surahName,
      'page_number': pageNumber,
      'created_at': createdAt,
    };
  }

  factory QuranBookmark.fromMap(Map<String, dynamic> map) {
    return QuranBookmark(
      id: map['id'],
      surahNumber: map['surah_number'],
      surahName: map['surah_name'],
      pageNumber: map['page_number'],
      createdAt: map['created_at'],
    );
  }
}

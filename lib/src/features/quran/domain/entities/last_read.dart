class LastRead {
  final int pageNumber;
  final String surahName;
  final int surahNumber;
  final int ayahNumber; // Optional, defaults to 1 for page start

  LastRead({
    required this.pageNumber,
    required this.surahName,
    required this.surahNumber,
    this.ayahNumber = 1,
  });

  Map<String, dynamic> toJson() {
    return {
      'pageNumber': pageNumber,
      'surahName': surahName,
      'surahNumber': surahNumber,
      'ayahNumber': ayahNumber,
    };
  }

  factory LastRead.fromJson(Map<String, dynamic> json) {
    return LastRead(
      pageNumber: json['pageNumber'] as int,
      surahName: json['surahName'] as String,
      surahNumber: json['surahNumber'] as int,
      ayahNumber: json['ayahNumber'] as int? ?? 1,
    );
  }
}

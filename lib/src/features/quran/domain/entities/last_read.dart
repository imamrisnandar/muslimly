class LastRead {
  final int pageNumber;
  final String surahName;
  final int surahNumber;
  final int ayahNumber; // Optional, defaults to 1 for page start
  final int timestamp; // To track recency

  LastRead({
    required this.pageNumber,
    required this.surahName,
    required this.surahNumber,
    this.ayahNumber = 1,
    int? timestamp,
  }) : timestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch;

  Map<String, dynamic> toJson() {
    return {
      'pageNumber': pageNumber,
      'surahName': surahName,
      'surahNumber': surahNumber,
      'ayahNumber': ayahNumber,
      'timestamp': timestamp,
    };
  }

  factory LastRead.fromJson(Map<String, dynamic> json) {
    return LastRead(
      pageNumber: json['pageNumber'] as int,
      surahName: json['surahName'] as String,
      surahNumber: json['surahNumber'] as int,
      ayahNumber: json['ayahNumber'] as int? ?? 1,
      timestamp: json['timestamp'] as int?,
    );
  }
}

class ReadingActivity {
  final int? id;
  final String date;
  final int pageNumber;
  final int? surahNumber;
  final int durationSeconds;
  final int timestamp;

  ReadingActivity({
    this.id,
    required this.date,
    required this.pageNumber,
    this.surahNumber,
    required this.durationSeconds,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'page_number': pageNumber,
      'surah_number': surahNumber,
      'duration_seconds': durationSeconds,
      'timestamp': timestamp,
    };
  }

  factory ReadingActivity.fromMap(Map<String, dynamic> map) {
    return ReadingActivity(
      id: map['id'],
      date: map['date'],
      pageNumber: map['page_number'],
      surahNumber: map['surah_number'],
      durationSeconds: map['duration_seconds'],
      timestamp: map['timestamp'],
    );
  }
}

class ReadingActivity {
  final int? id;
  final String date;
  final int pageNumber;
  final int? surahNumber;
  final int durationSeconds;
  final int timestamp;
  final int? startAyah;
  final int? endAyah;
  final int? totalAyahs;
  final String mode; // 'page' or 'ayah'
  final int isSynced; // 0 for false, 1 for true

  ReadingActivity({
    this.id,
    required this.date,
    required this.pageNumber,
    this.surahNumber,
    required this.durationSeconds,
    required this.timestamp,
    this.startAyah,
    this.endAyah,
    this.totalAyahs,
    this.mode = 'page',
    this.isSynced = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'page_number': pageNumber,
      'surah_number': surahNumber,
      'duration_seconds': durationSeconds,
      'timestamp': timestamp,
      'start_ayah': startAyah,
      'end_ayah': endAyah,
      'total_ayahs': totalAyahs,
      'mode': mode,
      'is_synced': isSynced,
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
      startAyah: map['start_ayah'],
      endAyah: map['end_ayah'],
      totalAyahs: map['total_ayahs'],
      mode: map['mode'] ?? 'page',
      isSynced: map['is_synced'] ?? 0,
    );
  }

  // Used only for sending data to the backend API
  Map<String, dynamic> toJsonSync() {
    return {
      'date': date,
      'duration_seconds': durationSeconds,
      'page_number': pageNumber,
      'surah_number': surahNumber,
      'start_ayah': startAyah,
      'end_ayah': endAyah,
      'total_ayahs': totalAyahs,
      'mode': mode,
      'timestamp': timestamp,
    };
  }
}

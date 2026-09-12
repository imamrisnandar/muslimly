class HafalanSession {
  final int? id;
  final int surahNumber;
  final int pageNumber;
  final int startAyah;
  final int endAyah;
  final int ayahCount;
  final double accuracy;
  final String date;
  final int timestamp;
  final int isSynced; // 0 for false, 1 for true

  /// Local-only .m4a path of this session's opt-in recording
  /// (HAFALAN_TRACKER_PLAN.md §F) — never synced to the backend, see
  /// toJsonSync() below.
  final String? audioFilePath;

  /// Whether the recording is protected from auto-purge (see
  /// DatabaseService.purgeOldAudioForUnit) — 0 for false, 1 for true.
  final int isAudioSaved;

  HafalanSession({
    this.id,
    required this.surahNumber,
    required this.pageNumber,
    required this.startAyah,
    required this.endAyah,
    required this.ayahCount,
    required this.accuracy,
    required this.date,
    required this.timestamp,
    this.isSynced = 0,
    this.audioFilePath,
    this.isAudioSaved = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'surah_number': surahNumber,
      'page_number': pageNumber,
      'start_ayah': startAyah,
      'end_ayah': endAyah,
      'ayah_count': ayahCount,
      'accuracy': accuracy,
      'date': date,
      'timestamp': timestamp,
      'is_synced': isSynced,
      'audio_file_path': audioFilePath,
      'is_audio_saved': isAudioSaved,
    };
  }

  factory HafalanSession.fromMap(Map<String, dynamic> map) {
    return HafalanSession(
      id: map['id'],
      surahNumber: map['surah_number'],
      pageNumber: map['page_number'],
      startAyah: map['start_ayah'],
      endAyah: map['end_ayah'],
      ayahCount: map['ayah_count'],
      accuracy: (map['accuracy'] as num).toDouble(),
      date: map['date'],
      timestamp: map['timestamp'],
      isSynced: map['is_synced'] ?? 0,
      audioFilePath: map['audio_file_path'],
      isAudioSaved: map['is_audio_saved'] ?? 0,
    );
  }

  // Used only for sending data to the backend API — audio is local-only for
  // v1 (see HAFALAN_TRACKER_PLAN.md §F), a local file path has no meaning
  // on the backend so it's deliberately excluded here.
  Map<String, dynamic> toJsonSync() {
    return {
      'surah_number': surahNumber,
      'page_number': pageNumber,
      'start_ayah': startAyah,
      'end_ayah': endAyah,
      'ayah_count': ayahCount,
      'accuracy': accuracy,
      'date': date,
      'timestamp': timestamp,
    };
  }
}

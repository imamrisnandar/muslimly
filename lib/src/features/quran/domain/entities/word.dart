class Word {
  final int position;
  final String arabic;
  final String translation;
  final String transliteration;

  const Word({
    required this.position,
    required this.arabic,
    required this.translation,
    required this.transliteration,
  });

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      position: json['position'] ?? 0,
      arabic: json['text_uthmani'] ?? json['text'] ?? '',
      translation: json['translation']?['text'] ?? '',
      transliteration: json['transliteration']?['text'] ?? '',
    );
  }
}

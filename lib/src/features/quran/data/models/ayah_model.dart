import '../../domain/entities/ayah.dart';

class AyahModel extends Ayah {
  const AyahModel({
    required super.number,
    required super.text,
    required super.numberInSurah,
    required super.juz,
    required super.page,
    super.textTajweed,
  });

  factory AyahModel.fromJson(Map<String, dynamic> json) {
    return AyahModel(
      // API might return 'verseId' or 'numberInSurah' but maybe not 'number'
      // Defaulting to 0 if null, or using alternate keys.
      number: (json['number'] ?? json['verseId'] ?? 0) as int,
      text:
          (json['textArabic'] ?? json['text'] ?? json['ayah'] ?? '') as String,
      numberInSurah: (json['numberInSurah'] ?? json['verseId'] ?? 0) as int,
      juz: (json['juz'] ?? 0) as int,
      page: (json['page'] ?? 0) as int,
      textTajweed:
          (json['text_uthmani_tajweed'] ??
                  json['textTajweed'] ??
                  json['tajweed'])
              as String?,
    );
  }

  // Helper to copy with new data
  AyahModel copyWith({String? textTajweed}) {
    return AyahModel(
      number: number,
      text: text,
      numberInSurah: numberInSurah,
      juz: juz,
      page: page,
      textTajweed: textTajweed ?? this.textTajweed,
    );
  }
}

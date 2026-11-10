import 'dart:convert';
import 'package:flutter/services.dart';

class AsmaulHusnaName {
  final int number;
  final String arabic;
  final String transliteration;
  final String meaningId;
  final String meaningEn;

  const AsmaulHusnaName({
    required this.number,
    required this.arabic,
    required this.transliteration,
    required this.meaningId,
    required this.meaningEn,
  });

  factory AsmaulHusnaName.fromJson(Map<String, dynamic> j) => AsmaulHusnaName(
    number: j['n'] as int,
    arabic: j['ar'] as String,
    transliteration: j['tr'] as String,
    meaningId: j['id'] as String,
    meaningEn: j['en'] as String,
  );

  String meaning(String lang) => lang == 'id' ? meaningId : meaningEn;
}

class Hadith {
  final int id;
  final String arabic;
  final String source;
  final String sourceEn;
  final String textId;
  final String textEn;

  const Hadith({
    required this.id,
    required this.arabic,
    required this.source,
    required this.sourceEn,
    required this.textId,
    required this.textEn,
  });

  factory Hadith.fromJson(Map<String, dynamic> j) => Hadith(
    id: j['id'] as int,
    arabic: j['ar'] as String,
    source: j['source'] as String,
    sourceEn: j['source_en'] as String,
    textId: j['id_text'] as String,
    textEn: j['en_text'] as String,
  );

  String text(String lang) => lang == 'id' ? textId : textEn;
  String sourceFor(String lang) => lang == 'id' ? source : sourceEn;
}

/// Picks the hadith of the day: stable for a calendar day, rotating daily.
Hadith hadithOfDay(List<Hadith> all, DateTime day) {
  final dayOfYear = day.difference(DateTime(day.year, 1, 1)).inDays;
  return all[dayOfYear % all.length];
}

/// Loads the bundled offline content.
class DhikrContentRepository {
  Future<List<AsmaulHusnaName>> asmaulHusna() async {
    final raw = await rootBundle.loadString(
      'assets/quran/json/asmaul_husna.json',
    );
    return (jsonDecode(raw)['names'] as List)
        .map((e) => AsmaulHusnaName.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Hadith>> hadiths() async {
    final raw = await rootBundle.loadString(
      'assets/quran/json/hadith_daily.json',
    );
    return (jsonDecode(raw)['hadiths'] as List)
        .map((e) => Hadith.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

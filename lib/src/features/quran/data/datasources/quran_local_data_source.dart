import 'package:injectable/injectable.dart';

import '../models/ayah_model.dart';
import '../models/surah_model.dart';
import 'local/quran_library/quran.dart' as quran;

abstract class QuranLocalDataSource {
  Future<List<SurahModel>> getSurahs();
  Future<List<AyahModel>> getAyahs(int surahId);
}

@LazySingleton(as: QuranLocalDataSource)
class QuranLocalDataSourceImpl implements QuranLocalDataSource {
  @override
  Future<List<SurahModel>> getSurahs() async {
    List<SurahModel> surahs = [];
    for (int i = 1; i <= quran.totalSurahCount; i++) {
      surahs.add(
        SurahModel(
          number: i,
          name: quran.getSurahNameArabic(i),
          englishName: quran.getSurahNameEnglish(i),
          englishNameTranslation: quran.getSurahNameEnglish(
            i,
          ), // Using same for now
          numberOfAyahs: quran.getVerseCount(i),
          revelationType: quran.getPlaceOfRevelation(i),
        ),
      );
    }
    return surahs;
  }

  @override
  Future<List<AyahModel>> getAyahs(int surahId) async {
    List<AyahModel> ayahs = [];
    int count = quran.getVerseCount(surahId);
    for (int i = 1; i <= count; i++) {
      ayahs.add(
        AyahModel(
          number:
              i, // We use local number if global is not easy/needed, or calc it
          text: quran.getVerse(surahId, i),
          numberInSurah: i,
          juz: quran.getJuzNumber(surahId, i),
          page: quran.getPageNumber(surahId, i),
        ),
      );
    }
    return ayahs;
  }
}

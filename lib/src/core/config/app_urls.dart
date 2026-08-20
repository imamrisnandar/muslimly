abstract class AppUrls {
  // --- Backend API ---
  static const String baseApi = 'https://api.muslimly.id/api/v1';

  // --- Quran.com API ---
  static const String quranComApi = 'https://api.quran.com/api/v4';
  static const String quranComImages = 'https://static.quran.com/images/quran/surah';

  // --- AlQuran Cloud API ---
  static const String alQuranCloudApi = 'https://api.alquran.cloud/v1';

  // --- Islamic Network CDN (audio) ---
  static const String islamicNetworkAudio = 'https://cdn.islamic.network/quran/audio';

  // --- Font CDN ---
  static const String qpcFontsCdn =
      'https://kencana.basic.box.cloudeka.id/tijar-market-o0mzhs/qpc';

  // --- Quran.com share links ---
  static String quranComJuz(int juzNumber) =>
      'https://quran.com/juz/$juzNumber';
  static String quranComSurah(int surahNumber) =>
      'https://quran.com/$surahNumber';
  static String quranComAyah(int surahNumber, int verseNumber) =>
      'https://quran.com/$surahNumber/$verseNumber';

  // --- Audio URLs ---
  static String surahAudioHigh(String reciterId, int surahNumber) =>
      'https://cdn.islamic.network/quran/audio-surah/64/$reciterId/$surahNumber.mp3';
  static String ayahAudioHigh(String reciterId, int verseNum) =>
      '$islamicNetworkAudio/128/$reciterId/$verseNum.mp3';
  static String ayahAudioLow(String reciterId, int verseNum) =>
      '$islamicNetworkAudio/64/$reciterId/$verseNum.mp3';
}

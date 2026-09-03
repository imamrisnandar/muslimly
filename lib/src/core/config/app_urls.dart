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
  // QPC v2 per-page mushaf fonts (QCF2001.ttf .. QCF2604.ttf), self-hosted on
  // cdn.muslimly.id (VPS origin, cached at the Cloudflare edge for a year).
  // Version lives in the path so a future font revision (v4, ...) gets a fresh
  // URL instead of fighting stale caches.
  static const String qpcFontsCdn = 'https://cdn.muslimly.id/qpc/v2';
  static const String qpcFontsManifest =
      'https://cdn.muslimly.id/qpc/v2/manifest.json';

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

import '../../data/quran_glyph_data.dart';
import '../../data/page_data.dart';

class GlyphHelper {
  /// Returns a list of glyph data for the given page.
  /// Each item in the list represents an ayah (or basmalah/header).
  /// Returns: List<Map<String, dynamic>> where keys are 'sura', 'ayah', 'glyph', 'is_basmalah', etc.
  static List<Map<String, dynamic>> getPageGlyphs(int pageNumber) {
    if (pageNumber < 1 || pageNumber > 604) return [];

    final pageAyahs = quranPageData[pageNumber - 1]; // List<Map<String, int>>

    // pageAyahs structure: [{"surah": 1, "start": 1, "end": 7}]

    List<Map<String, dynamic>> glyphs = [];

    for (var entry in pageAyahs) {
      int surah = entry['surah']!;
      int start = entry['start']!;
      int end = entry['end']!;

      for (int i = start; i <= end; i++) {
        // Find glyph in quranGlyphData
        // quranGlyphData is a List<Map>. We can optimize this by pre-indexing if slow,
        // but for <10 items per page, filtering is fine?
        // Actually quranGlyphData is 6236 items. Linear search 6236 times per page render is BAD.
        // We should index `quranGlyphData` or just loop once if sorted?
        // Relying on `firstWhere` might be slow if called repeatedly.
        // But let's look at `quranGlyphData` structure. It's sorted.
        // We can just use a helper to find it.

        final verseData = _findVerse(surah, i);
        if (verseData != null) {
          glyphs.add({
            'surah': surah,
            'ayah': i,
            'glyph': verseData['qcfData'],
            'text': verseData['content'], // Normal text if needed
          });
        }
      }
    }
    return glyphs;
  }

  static Map<String, dynamic>? _findVerse(int surah, int ayah) {
    // Optimization: Since it's sorted, we could do binary search or similar.
    // For now, simple list lookup.
    try {
      return quranGlyphData.firstWhere(
        (element) =>
            element['surah_number'] == surah && element['verse_number'] == ayah,
      );
    } catch (e) {
      return null;
    }
  }
}

void main() {
  const clean = 'بِسْمِ <tajweed class=ham_wasl>ٱ';

  // Dump characters codes
  // Space is 32. < is 60. t is 116.
  print('String codes: ${clean.runes.toList()}');

  final r1 = RegExp(r'<tajweed');
  print('Has <tajweed (r1): ${r1.hasMatch(clean)}');

  final r2 = RegExp(r'class=');
  print('Has class= (r2): ${r2.hasMatch(clean)}');

  final r3 = RegExp(r'<tajweed\s+class=');
  print('Has <tajweed space class= (r3): ${r3.hasMatch(clean)}');

  // Original fails?
  final rOriginal = RegExp(
    r'<(tajweed|span)[^>]+class=["'
    ']?([\w_]+)["'
    ']?[^>]*>(.*?)<\/(tajweed|span)>',
    caseSensitive: false,
  );
  // Test simplified version of original
  // <tajweed [^>]+ class=
  final rTest = RegExp(r'<tajweed[^>]+class=');
  print('Has <tajweed [^>]+ class= (rTest): ${rTest.hasMatch(clean)}');
}

void main() {
  // Regex: Use [a-zA-Z0-9_] instead of \w to avoid escaping issues
  final reg = RegExp(
    r'<(tajweed|span)[^>]*?class=["'
    ']?([a-zA-Z0-9_]+)["'
    ']?[^>]*>(.*?)<\/(?:tajweed|span)>',
    caseSensitive: false,
    dotAll: true,
  );

  const text =
      'بِسْمِ <tajweed class=ham_wasl>ٱ</tajweed>للَّهِ <tajweed class=ham_wasl>ٱ</tajweed><tajweed class=laam_shamsiyah>ل</tajweed>رَّحْمَ<tajweed class=madda_normal>ـٰ</tajweed>نِ';

  print('Regex: ${reg.pattern}');
  print('Text matches: ${reg.hasMatch(text)}');

  int count = 0;
  for (final m in reg.allMatches(text)) {
    count++;
    print(
      'Match $count: Tag=${m.group(1)}, Class=${m.group(2)}, Content="${m.group(3)}"',
    );
  }
}

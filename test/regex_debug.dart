void main() {
  const text = 'Start <tajweed class=ham_wasl>Content</tajweed> End';

  // 1. Current Regex
  final r1 = RegExp(
    r'<(tajweed|span)\s+class=["'
    ']?([^"'
    '\s>]+)["'
    ']?>(.*?)<\/\1>',
    caseSensitive: false,
    dotAll: true,
  );
  print('Regex 1 (Current): ${r1.hasMatch(text)}');
  if (r1.hasMatch(text)) {
    final m = r1.firstMatch(text)!;
    print('  Group 1: ${m.group(1)}'); // Tag
    print('  Group 2: ${m.group(2)}'); // Class
    print('  Group 3: ${m.group(3)}'); // Content
  }

  // 2. No Backreference
  final r2 = RegExp(
    r'<(tajweed|span)\s+class=["'
    ']?([^"'
    '\s>]+)["'
    ']?>(.*?)<\/(?:tajweed|span)>',
    caseSensitive: false,
    dotAll: true,
  );
  print('Regex 2 (No Backref): ${r2.hasMatch(text)}');
  if (r2.hasMatch(text)) {
    final m = r2.firstMatch(text)!;
    print('  Group 1: ${m.group(1)}');
    print('  Group 2: ${m.group(2)}');
    print('  Group 3: ${m.group(3)}');
  }

  // 3. Simple
  final r3 = RegExp(
    r'<tajweed class=([\w_]+)>(.*?)</tajweed>',
    caseSensitive: false,
    dotAll: true,
  );
  print('Regex 3 (Simple): ${r3.hasMatch(text)}');

  // 4. All Matches Test
  print('\n-- All Matches Test (R2) --');
  final longText =
      'A <tajweed class=one>1</tajweed> B <span class=end>2</span>';
  for (final m in r2.allMatches(longText)) {
    print('Match: ${m.group(0)}');
  }
}

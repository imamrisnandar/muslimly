import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslimly/src/core/utils/tajweed_parser.dart';

void main() {
  test('Tajweed Parser Test with Al-Fatihah Data', () {
    // Exact data from API Log
    const rawText =
        'بِسْمِ <tajweed class=ham_wasl>ٱ</tajweed>للَّهِ <tajweed class=ham_wasl>ٱ</tajweed><tajweed class=laam_shamsiyah>ل</tajweed>رَّحْمَ<tajweed class=madda_normal>ـٰ</tajweed>نِ <tajweed class=ham_wasl>ٱ</tajweed><tajweed class=laam_shamsiyah>ل</tajweed>رَّح<tajweed class=madda_permissible>ِي</tajweed>مِ <span class=end>١</span>';

    final span = TajweedParser.parse(rawText);

    print('DEBUG: Parsed Children Count: ${span.children?.length}');

    if (span.children != null) {
      for (var child in span.children!) {
        if (child is TextSpan) {
          final color = child.style?.color;
          final colorHex = color != null
              ? '0x${color.value.toRadixString(16).toUpperCase()}'
              : 'null';
          print('DEBUG: Span Text: "${child.text}" | Color: $colorHex');
        }
      }
    }

    // Assertions
    expect(span.children, isNotNull);
    expect(span.children!.length, greaterThan(1));
  });
}

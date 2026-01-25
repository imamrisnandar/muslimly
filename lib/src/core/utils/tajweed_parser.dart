import 'package:flutter/material.dart';

class TajweedParser {
  // Color Mapping based on Quran.com V4 class names
  static final Map<String, Color> _colorMap = {
    // Green: Ghunnah
    'ghunnah': const Color(0xFF169278),
    'idgham_with_ghunnah': const Color(0xFF169278),
    'idgham_ghunnah': const Color(0xFF169278),
    'ikhfa_syafawi': const Color(0xFF169278),
    'ghunnah_mushaddadah': const Color(0xFF169278),
    'ghunne_mushaddadah': const Color(0xFF169278),

    // Ikhfa (Yellow) - As per user request (User prefers Yellow over Orange)
    'ikhafa': const Color(0xFFFFD54F),
    'ikhfa': const Color(0xFFFFD54F),

    // Qalqalah (Blue)
    'qalqalah': const Color(0xFF3B83BD),
    'qalaqah': const Color(0xFF3B83BD),

    // Iqlab (Cyan)
    'iqlb': const Color(0xFF26BFFD),
    'iqlab': const Color(0xFF26BFFD),

    // Mad (Red/Pink/Purple)
    'madda_necessary': const Color(0xFFE52C2C),
    'madda_obligatory': const Color(0xFFE52C2C),
    'madda_permissible': const Color(0xFFD8572A), // Mad Jaiz (Orange-Red)
    'madda_normal': const Color(0xFF9E9E9E),
    'madda_tabee': const Color(0xFF9E9E9E),

    // Gray / Silent
    'idgham_wo_ghunnah': const Color(0xFFA1A1A1),
    'idgham_no_ghunnah': const Color(0xFFA1A1A1),
    'silent': const Color(0xFFA1A1A1),
    'lam_shamsyiah': const Color(0xFFA1A1A1),
    'laam_shamsiyah': const Color(0xFFA1A1A1),
    'ham_wasl': const Color(0xFFA1A1A1),
  };

  static TextSpan parse(String text, {TextStyle? style}) {
    if (text.isEmpty) return const TextSpan(text: '');

    final List<TextSpan> spans = [];

    // Regex Safe Version (No backslash \w reliance, explicit ranges)
    final RegExp tagExp = RegExp(
      r'<(tajweed|span)[^>]*?class=["'
      ']?([a-zA-Z0-9_]+)["'
      ']?[^>]*>(.*?)<\/(?:tajweed|span)>',
      caseSensitive: false,
      dotAll: true,
    );

    int lastMatchEnd = 0;

    for (final match in tagExp.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        spans.add(
          TextSpan(
            text: text.substring(lastMatchEnd, match.start),
            style: style,
          ),
        );
      }

      final String ruleClass = match.group(2) ?? '';
      final String content = match.group(3) ?? '';

      Color? color;
      if (ruleClass.toLowerCase() == 'end') {
        color = null;
      } else {
        color = _colorMap[ruleClass.toLowerCase()];
      }

      final effectiveStyle =
          style?.copyWith(color: color) ?? TextStyle(color: color);

      spans.add(TextSpan(text: content, style: effectiveStyle));

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd), style: style));
    }

    return TextSpan(children: spans);
  }
}

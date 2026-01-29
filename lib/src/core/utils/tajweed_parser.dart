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
    'slnt': const Color(0xFFA1A1A1), // Added slnt
  };

  static TextSpan parse(String text, {TextStyle? style}) {
    if (text.isEmpty) return const TextSpan(text: '');

    final List<TextSpan> spans = [];
    final List<TextStyle> styleStack = [style ?? const TextStyle()];

    // Regex to find start or end tags
    // Start tag: <(tajweed|span) class="xyz">
    // End tag: </(tajweed|span)>
    // We search for the next tag, append text before it, then handle the tag.

    final RegExp tagPattern = RegExp(
      r'(<\/?(?:tajweed|span)(?:\s+class\s*=\s*["'
      ']?([a-zA-Z0-9_\-]+)["'
      ']?)?[^>]*>)',
      caseSensitive: false,
    );

    int currentIndex = 0;

    for (final match in tagPattern.allMatches(text)) {
      // 1. Text before this tag
      if (match.start > currentIndex) {
        final content = text.substring(currentIndex, match.start);
        spans.add(TextSpan(text: content, style: styleStack.last));
      }

      final String tag = match.group(0)!; // Full tag string
      final String? className = match.group(2); // Capture group for class

      if (tag.startsWith('</')) {
        // Closing tag: Pop style
        if (styleStack.length > 1) {
          styleStack.removeLast();
        }
      } else {
        // Opening tag: Push style
        if (className != null) {
          Color? color;
          final key = className.toLowerCase();

          if (key == 'end') {
            // 'end' might be special, or just ignore for now if purely visual marker
            color = null;
          } else {
            color = _colorMap[key];
          }

          // Merge with current parent style
          final parentStyle = styleStack.last;
          final newStyle = parentStyle.copyWith(color: color);
          styleStack.add(newStyle);
        } else {
          // Tag without class (unlikely for our API, but treat as neutral)
          styleStack.add(styleStack.last);
        }
      }

      currentIndex = match.end;
    }

    // Append remaining text
    if (currentIndex < text.length) {
      spans.add(
        TextSpan(text: text.substring(currentIndex), style: styleStack.last),
      );
    }

    return TextSpan(children: spans);
  }
}

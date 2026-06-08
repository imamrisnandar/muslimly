import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary accent
  static const Color accent = Color(0xFF00E676);
  static const Color accentDark = Color(0xFF1DE9B6);
  static const Color accentGreen = Color(0xFF169278);

  // Background gradient
  static const Color bgGradientStart = Color(0xFF0F2027);
  static const Color bgGradientMid = Color(0xFF203A43);
  static const Color bgGradientEnd = Color(0xFF2C5364);

  // Card / surface
  static const Color cardDark = Color(0xFF1C2A30);
  static const Color cardDarker = Color(0xFF1E2F36);
  static const Color cardAlt = Color(0xFF1A2C33);
  static const Color surfaceDark = Color(0xFF2D3436);

  // Islamic feature colors
  static const Color quranBrown = Color(0xFF4E342E);
  static const Color quranGreen = Color(0xFF1B5E20);
  static const Color quranGreenDark = Color(0xFF2E7D32);
  static const Color quranTeal = Color(0xFF00796B);

  // Warning / highlight
  static const Color gold = Color(0xFFFFC107);
  static const Color goldLight = Color(0xFFFFD54F);
  static const Color goldPale = Color(0xFFFFB74D);
  static const Color creamBg = Color(0xFFFFF8E1);

  // Neutral
  static const Color textMuted = Color(0xFFA1A1A1);
  static const Color textDisabled = Color(0xFF636E72);

  // --- Gradient helpers ---
  static const List<Color> bgGradientColors = [
    bgGradientStart,
    bgGradientMid,
    bgGradientEnd,
  ];

  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: bgGradientColors,
  );

  static BoxDecoration get bgGradientDecoration => const BoxDecoration(
        gradient: bgGradient,
      );
}

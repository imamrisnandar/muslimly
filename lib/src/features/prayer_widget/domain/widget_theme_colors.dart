import 'dart:ui';
import 'widget_settings.dart';

/// Mirrors the native drawables (widget_bg_*.xml) and colours in
/// PrayerWidgetTheme.kt. Used for the in-app preview only.
class WidgetThemeColors {
  final Color bgStart;
  final Color bgEnd;
  final Color text;
  final Color subtext;
  final Color accent;
  const WidgetThemeColors(
    this.bgStart,
    this.bgEnd,
    this.text,
    this.subtext,
    this.accent,
  );

  static const _light = Color(0xFF1B2B2A);

  static WidgetThemeColors of(WidgetThemeId id) => switch (id) {
    WidgetThemeId.emerald => const WidgetThemeColors(
      Color(0xFF0F4A40),
      Color(0xFF08161E),
      Color(0xFFFFFFFF),
      Color(0xB3FFFFFF),
      Color(0xFFFFD54F),
    ),
    WidgetThemeId.ocean => const WidgetThemeColors(
      Color(0xFF12456E),
      Color(0xFF07182B),
      Color(0xFFFFFFFF),
      Color(0xB3FFFFFF),
      Color(0xFFFFD54F),
    ),
    WidgetThemeId.violet => const WidgetThemeColors(
      Color(0xFF3B2A6B),
      Color(0xFF150F2E),
      Color(0xFFFFFFFF),
      Color(0xB3FFFFFF),
      Color(0xFFFFCA28),
    ),
    WidgetThemeId.amber => const WidgetThemeColors(
      Color(0xFF5C3A0E),
      Color(0xFF1E1206),
      Color(0xFFFFFFFF),
      Color(0xB3FFFFFF),
      Color(0xFFFFE082),
    ),
    WidgetThemeId.light => const WidgetThemeColors(
      Color(0xFFF5F1E6),
      Color(0xFFDCE9E4),
      _light,
      Color(0x991B2B2A),
      Color(0xFFB26A00),
    ),
  };
}

import 'dart:convert';

/// Colour themes of the home-screen widget. The ids are also used natively
/// (PrayerWidgetTheme.kt), so keep them in sync.
enum WidgetThemeId { emerald, ocean, violet, amber, light }

/// User options for the home-screen widget. Stored as JSON in the
/// home_widget SharedPreferences, where the Kotlin side reads it, so the
/// widget keeps working without the app running.
class WidgetSettings {
  static const String prefsKey = 'prayer_widget_settings';

  final WidgetThemeId theme;

  /// Background opacity, 30..100 (percent). Text always stays fully opaque.
  final int opacity;

  /// 0 = small, 1 = normal, 2 = large.
  final int textSize;
  final bool showHijri;
  final bool showGregorian;
  final bool showLocation;

  /// "3/5 done" and when the current prayer window ends.
  final bool showProgress;

  const WidgetSettings({
    this.theme = WidgetThemeId.emerald,
    this.opacity = 100,
    this.textSize = 1,
    this.showHijri = true,
    this.showGregorian = true,
    this.showLocation = true,
    this.showProgress = true,
  });

  WidgetSettings copyWith({
    WidgetThemeId? theme,
    int? opacity,
    int? textSize,
    bool? showHijri,
    bool? showGregorian,
    bool? showLocation,
    bool? showProgress,
  }) => WidgetSettings(
    theme: theme ?? this.theme,
    opacity: (opacity ?? this.opacity).clamp(30, 100),
    textSize: (textSize ?? this.textSize).clamp(0, 2),
    showHijri: showHijri ?? this.showHijri,
    showGregorian: showGregorian ?? this.showGregorian,
    showLocation: showLocation ?? this.showLocation,
    showProgress: showProgress ?? this.showProgress,
  );

  Map<String, Object?> toJson() => {
    'theme': theme.name,
    'opacity': opacity,
    'textSize': textSize,
    'showHijri': showHijri,
    'showGregorian': showGregorian,
    'showLocation': showLocation,
    'showProgress': showProgress,
  };

  String encode() => jsonEncode(toJson());

  /// Tolerant of missing/garbled data: anything unknown falls back to the
  /// default so a bad value never blanks the widget.
  factory WidgetSettings.decode(String? raw) {
    if (raw == null || raw.isEmpty) return const WidgetSettings();
    try {
      final j = jsonDecode(raw) as Map<String, dynamic>;
      return const WidgetSettings().copyWith(
        theme: WidgetThemeId.values.firstWhere(
          (t) => t.name == j['theme'],
          orElse: () => WidgetThemeId.emerald,
        ),
        opacity: (j['opacity'] as num?)?.toInt(),
        textSize: (j['textSize'] as num?)?.toInt(),
        showHijri: j['showHijri'] as bool?,
        showGregorian: j['showGregorian'] as bool?,
        showLocation: j['showLocation'] as bool?,
        showProgress: j['showProgress'] as bool?,
      );
    } catch (_) {
      return const WidgetSettings();
    }
  }
}

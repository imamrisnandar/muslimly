import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/presentation/widgets/gradient_page.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../data/widget_data_service.dart';
import '../../domain/widget_settings.dart';
import '../../domain/widget_theme_colors.dart';

/// Lets the user restyle the Android home-screen widget. Every change is
/// written to the shared preferences the widget reads and the widget is
/// redrawn immediately.
class WidgetSettingsPage extends StatefulWidget {
  const WidgetSettingsPage({super.key});

  @override
  State<WidgetSettingsPage> createState() => _WidgetSettingsPageState();
}

class _WidgetSettingsPageState extends State<WidgetSettingsPage> {
  WidgetSettings _s = const WidgetSettings();
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    WidgetDataService.loadSettings().then((v) {
      if (mounted) {
        setState(() {
          _s = v;
          _loaded = true;
        });
      }
    });
  }

  void _apply(WidgetSettings n, {bool persist = true}) {
    setState(() => _s = n);
    if (persist) WidgetDataService.saveSettings(n);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final label = TextStyle(color: Colors.white, fontSize: 15.sp);
    return GradientPage(
      title: l10n.widgetSettingsTitle,
      child: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(16.r),
              children: [
                _Preview(s: _s),
                SizedBox(height: 20.h),
                Text(l10n.widgetSettingsTheme, style: label),
                SizedBox(height: 10.h),
                Wrap(
                  spacing: 14.w,
                  children: [
                    for (final t in WidgetThemeId.values)
                      _ThemeDot(
                        id: t,
                        selected: _s.theme == t,
                        onTap: () => _apply(_s.copyWith(theme: t)),
                      ),
                  ],
                ),
                SizedBox(height: 20.h),
                Text(
                  '${l10n.widgetSettingsOpacity}: ${_s.opacity}%',
                  style: label,
                ),
                Slider(
                  min: 30,
                  max: 100,
                  divisions: 14,
                  value: _s.opacity.toDouble(),
                  onChanged: (v) =>
                      _apply(_s.copyWith(opacity: v.round()), persist: false),
                  onChangeEnd: (v) => _apply(_s.copyWith(opacity: v.round())),
                ),
                Text(l10n.widgetSettingsTextSize, style: label),
                SizedBox(height: 8.h),
                SegmentedButton<int>(
                  style: SegmentedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    selectedForegroundColor: Colors.black87,
                    selectedBackgroundColor: AppColors.accent,
                    side: const BorderSide(color: Colors.white24),
                  ),
                  segments: [
                    ButtonSegment(
                      value: 0,
                      label: Text(l10n.widgetSettingsSizeSmall),
                    ),
                    ButtonSegment(
                      value: 1,
                      label: Text(l10n.widgetSettingsSizeNormal),
                    ),
                    ButtonSegment(
                      value: 2,
                      label: Text(l10n.widgetSettingsSizeLarge),
                    ),
                  ],
                  selected: {_s.textSize},
                  onSelectionChanged: (v) =>
                      _apply(_s.copyWith(textSize: v.first)),
                ),
                SizedBox(height: 20.h),
                Text(l10n.widgetSettingsInfo, style: label),
                _sw(
                  l10n.widgetSettingsHijri,
                  _s.showHijri,
                  (v) => _apply(_s.copyWith(showHijri: v)),
                ),
                _sw(
                  l10n.widgetSettingsGregorian,
                  _s.showGregorian,
                  (v) => _apply(_s.copyWith(showGregorian: v)),
                ),
                _sw(
                  l10n.widgetSettingsLocation,
                  _s.showLocation,
                  (v) => _apply(_s.copyWith(showLocation: v)),
                ),
                _sw(
                  l10n.widgetSettingsProgress,
                  _s.showProgress,
                  (v) => _apply(_s.copyWith(showProgress: v)),
                ),
                SizedBox(height: 8.h),
                Text(
                  l10n.widgetSettingsNote,
                  style: TextStyle(color: Colors.white38, fontSize: 11.sp),
                ),
              ],
            ),
    );
  }

  Widget _sw(String title, bool v, ValueChanged<bool> on) => SwitchListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(title, style: const TextStyle(color: Colors.white70)),
    value: v,
    onChanged: on,
  );
}

class _ThemeDot extends StatelessWidget {
  final WidgetThemeId id;
  final bool selected;
  final VoidCallback onTap;
  const _ThemeDot({
    required this.id,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = WidgetThemeColors.of(id);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44.r,
        height: 44.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [c.bgStart, c.bgEnd],
          ),
          border: Border.all(
            color: selected ? AppColors.accent : Colors.white24,
            width: selected ? 3 : 1,
          ),
        ),
        child: selected
            ? Icon(Icons.check, color: c.text, size: 20.r)
            : Container(
                margin: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  color: c.accent,
                  shape: BoxShape.circle,
                ),
              ),
      ),
    );
  }
}

/// Approximation of the list (4x3) widget, driven by the current options.
class _Preview extends StatelessWidget {
  final WidgetSettings s;
  const _Preview({required this.s});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = WidgetThemeColors.of(s.theme);
    final k = const [0.88, 1.0, 1.15][s.textSize];
    final a = s.opacity / 100;
    final info = [
      if (s.showGregorian) l10n.widgetPreviewGregorian,
      if (s.showHijri) l10n.widgetPreviewHijri,
    ].join(' · ');
    final info2 = [
      if (s.showLocation) l10n.widgetPreviewCity,
      if (s.showProgress) l10n.widgetPreviewProgress,
    ].join(' · ');
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            c.bgStart.withValues(alpha: a),
            c.bgEnd.withValues(alpha: a),
          ],
        ),
        border: Border.all(color: c.accent.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.widgetNext.toUpperCase(),
                      style: TextStyle(
                        color: c.subtext,
                        fontSize: 10 * k,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      l10n.prayerAsr,
                      style: TextStyle(
                        color: c.text,
                        fontSize: 20 * k,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: c.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: c.accent.withValues(alpha: 0.35)),
                ),
                child: Text(
                  '01:23:45',
                  style: TextStyle(
                    color: c.accent,
                    fontSize: 16 * k,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (info.isNotEmpty) ...[
            SizedBox(height: 6.h),
            Text(
              info,
              style: TextStyle(color: c.subtext, fontSize: 11 * k),
            ),
          ],
          if (info2.isNotEmpty)
            Text(
              info2,
              style: TextStyle(color: c.subtext, fontSize: 11 * k),
            ),
          SizedBox(height: 8.h),
          for (final r in [
            (l10n.prayerDhuhr, '11:58', false, true),
            (l10n.prayerAsr, '15:12', true, false),
            (l10n.prayerMaghrib, '17:51', false, false),
          ])
            Container(
              margin: EdgeInsets.only(bottom: 3.h),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: r.$3 ? c.accent.withValues(alpha: 0.12) : null,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      r.$4 ? '✓ ${r.$1}' : r.$1,
                      style: TextStyle(
                        color: r.$3 ? c.accent : c.text,
                        fontSize: 14 * k,
                      ),
                    ),
                  ),
                  Text(
                    r.$2,
                    style: TextStyle(
                      color: r.$3 ? c.accent : c.text,
                      fontSize: 14 * k,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:muslimly/src/core/utils/thousands_input_formatter.dart';
import 'package:muslimly/src/features/prayer_widget/domain/widget_settings.dart';
import 'package:flutter/services.dart';

void main() {
  group('WidgetSettings', () {
    test('defaults when nothing or garbage is stored', () {
      expect(WidgetSettings.decode(null).theme, WidgetThemeId.emerald);
      expect(WidgetSettings.decode('').opacity, 100);
      expect(WidgetSettings.decode('{{bad').showHijri, isTrue);
    });

    test('round trips every field', () {
      const s = WidgetSettings(
        theme: WidgetThemeId.light,
        opacity: 55,
        textSize: 2,
        showHijri: false,
        showGregorian: false,
        showLocation: false,
        showProgress: false,
      );
      final back = WidgetSettings.decode(s.encode());
      expect(back.theme, WidgetThemeId.light);
      expect(back.opacity, 55);
      expect(back.textSize, 2);
      expect(back.showHijri, isFalse);
      expect(back.showGregorian, isFalse);
      expect(back.showLocation, isFalse);
      expect(back.showProgress, isFalse);
    });

    test('out-of-range values are clamped, unknown theme falls back', () {
      final s = WidgetSettings.decode(
        '{"theme":"nope","opacity":5,"textSize":9}',
      );
      expect(s.theme, WidgetThemeId.emerald);
      expect(s.opacity, 30);
      expect(s.textSize, 2);
    });
  });

  group('ThousandsInputFormatter', () {
    TextEditingValue run(String text, [int? caret]) =>
        const ThousandsInputFormatter().formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(
            text: text,
            selection: TextSelection.collapsed(offset: caret ?? text.length),
          ),
        );

    test('groups digits by thousands', () {
      expect(run('1500000').text, '1.500.000');
      expect(run('999').text, '999');
      expect(run('1000').text, '1.000');
    });

    test('strips non-digits and leading zeros', () {
      expect(run('Rp 12abc34').text, '1.234');
      expect(run('00012').text, '12');
      expect(run('').text, '');
    });

    test('digits() recovers the raw number', () {
      expect(ThousandsInputFormatter.digits('1.500.000'), '1500000');
    });

    test('caret stays after the same digit when text is reformatted', () {
      // typing a digit at the end of "1.000" -> "10000" -> "10.000"
      final r = run('10000');
      expect(r.text, '10.000');
      expect(r.selection.end, r.text.length);
    });
  });
}

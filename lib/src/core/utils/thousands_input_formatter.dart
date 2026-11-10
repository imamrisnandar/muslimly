import 'package:flutter/services.dart';

/// Formats digits typed into a money field with thousand separators
/// ("1500000" -> "1.500.000"), keeping the caret after the same digit.
class ThousandsInputFormatter extends TextInputFormatter {
  final String separator;
  const ThousandsInputFormatter({this.separator = '.'});

  /// Digits only; what to parse and persist.
  static String digits(String s) => s.replaceAll(RegExp(r'[^0-9]'), '');

  static String format(String digitsOnly, {String separator = '.'}) {
    final d = digitsOnly.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    final b = StringBuffer();
    for (var i = 0; i < d.length; i++) {
      if (i > 0 && (d.length - i) % 3 == 0) b.write(separator);
      b.write(d[i]);
    }
    return b.toString();
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = digits(newValue.text);
    if (raw.isEmpty) return const TextEditingValue();
    if (raw.length > 15) return oldValue; // far beyond any real amount
    final text = format(raw, separator: separator);
    // Caret: keep it after the same number of digits as before formatting.
    final digitsBeforeCaret = digits(
      newValue.text.substring(0, newValue.selection.end.clamp(0, newValue.text.length)),
    ).length;
    var pos = 0, seen = 0;
    while (pos < text.length && seen < digitsBeforeCaret) {
      if (RegExp(r'\d').hasMatch(text[pos])) seen++;
      pos++;
    }
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: pos),
    );
  }
}

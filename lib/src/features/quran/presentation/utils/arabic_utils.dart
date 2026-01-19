class ArabicUtils {
  static String toArabicDigits(int number) {
    const arabics = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number
        .toString()
        .split('')
        .map((digit) {
          return arabics[int.parse(digit)];
        })
        .join('');
  }
}

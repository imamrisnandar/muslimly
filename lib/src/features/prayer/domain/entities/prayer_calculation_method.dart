enum PrayerCalculationMethod {
  singapore,
  kemenagRI;

  static const String settingsKeySingapore = 'singapore';
  static const String settingsKeyKemenagRI = 'kemenag_ri';

  static PrayerCalculationMethod fromKey(String? key) {
    switch (key) {
      case settingsKeyKemenagRI:
        return PrayerCalculationMethod.kemenagRI;
      case settingsKeySingapore:
      default:
        return PrayerCalculationMethod.singapore;
    }
  }

  String get key {
    switch (this) {
      case PrayerCalculationMethod.kemenagRI:
        return settingsKeyKemenagRI;
      case PrayerCalculationMethod.singapore:
        return settingsKeySingapore;
    }
  }
}

import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';

import '../entities/high_latitude_setting.dart';
import '../entities/prayer_calculation_method.dart';
import '../entities/prayer_instants.dart';

/// Pure prayer-time calculation. Single source of truth: the repository's
/// `'HH:mm'` strings are derived from [instants], never computed separately.
class PrayerCalculator {
  PrayerCalculator._();

  // Kemenag RI publishes the same Fajr/Isha angles as the "Singapore" method
  // (20°/18°); what it adds on top is an ihtiyat (safety margin), which
  // these values follow (the same margins used by common Indonesian
  // falakiyah software, e.g. Winhisab).
  static CalculationParameters _kemenagRIParameters() {
    final params = CalculationParameters(fajrAngle: 20.0, ishaAngle: 18.0);
    params.madhab = Madhab.shafi;
    params.adjustments = PrayerAdjustments(
      fajr: -2,
      sunrise: 1,
      dhuhr: 2,
      asr: 2,
      maghrib: 2,
      isha: 2,
    );
    return params;
  }

  static CalculationParameters parametersFor(
    PrayerCalculationMethod method,
    HighLatitudeSetting highLatitude,
    double latitude,
  ) {
    final CalculationParameters params;
    switch (method) {
      case PrayerCalculationMethod.kemenagRI:
        params = _kemenagRIParameters();
        break;
      case PrayerCalculationMethod.singapore:
        params = CalculationMethod.singapore.getParameters();
        params.madhab = Madhab.shafi;
        break;
    }
    params.highLatitudeRule = highLatitude.resolve(latitude);
    return params;
  }

  /// Latitude step used when searching for the nearest computable latitude.
  static const double _fallbackStepDegrees = 0.5;

  /// Computes the prayer instants for the calendar day of [date]
  /// (only its year/month/day are used).
  ///
  /// At polar day/night `adhan` cannot produce sunrise/sunset and throws. In
  /// that case the nearest latitude (stepping toward the equator, same
  /// longitude) where the sun does rise and set is used, and the result carries
  /// [PrayerInstants.fallbackLatitude]. The high-latitude rule is re-resolved
  /// for the fallback latitude. Product/fiqh decision still open.
  static PrayerInstants instants({
    required double latitude,
    required double longitude,
    required DateTime date,
    PrayerCalculationMethod method = PrayerCalculationMethod.singapore,
    HighLatitudeSetting highLatitude = HighLatitudeSetting.auto,
  }) {
    try {
      return _compute(latitude, longitude, date, method, highLatitude, null);
    } on ArgumentError {
      // Polar day/night: walk toward the equator until computable.
      final sign = latitude < 0 ? -1.0 : 1.0;
      for (
        var lat = latitude.abs() - _fallbackStepDegrees;
        lat >= 0;
        lat -= _fallbackStepDegrees
      ) {
        try {
          return _compute(
            sign * lat,
            longitude,
            date,
            method,
            highLatitude,
            sign * lat,
          );
        } on ArgumentError {
          continue;
        }
      }
      rethrow;
    }
  }

  static PrayerInstants _compute(
    double latitude,
    double longitude,
    DateTime date,
    PrayerCalculationMethod method,
    HighLatitudeSetting highLatitude,
    double? fallbackLatitude,
  ) {
    final params = parametersFor(method, highLatitude, latitude);
    final times = PrayerTimes(
      Coordinates(latitude, longitude),
      DateComponents.from(date),
      params,
    );
    return PrayerInstants(
      date: DateFormat('yyyy-MM-dd').format(date),
      fajr: times.fajr,
      sunrise: times.sunrise,
      dhuhr: times.dhuhr,
      asr: times.asr,
      maghrib: times.maghrib,
      isha: times.isha,
      fallbackLatitude: fallbackLatitude,
    );
  }
}

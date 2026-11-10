import 'package:adhan/adhan.dart';

/// User-facing choice of how Fajr/Isha are bounded at high latitudes, where the
/// sun may never reach the Fajr/Isha twilight angle (or never set at all).
enum HighLatitudeSetting {
  /// Pick a rule from the latitude: [autoThresholdDegrees] and beyond use
  /// 1/7th of the night, below that the `adhan` default (middle of the night).
  auto,
  middleOfTheNight,
  seventhOfTheNight,
  twilightAngle;

  /// |latitude| above which [auto] switches to the 1/7th-of-the-night rule.
  /// Product decision still open (48° vs 55°, see ROADMAP "Keputusan terbuka" #6).
  static const double autoThresholdDegrees = 48.0;

  static const String settingsKeyAuto = 'auto';
  static const String settingsKeyMiddleOfTheNight = 'middle_of_the_night';
  static const String settingsKeySeventhOfTheNight = 'seventh_of_the_night';
  static const String settingsKeyTwilightAngle = 'twilight_angle';

  static HighLatitudeSetting fromKey(String? key) {
    switch (key) {
      case settingsKeyMiddleOfTheNight:
        return HighLatitudeSetting.middleOfTheNight;
      case settingsKeySeventhOfTheNight:
        return HighLatitudeSetting.seventhOfTheNight;
      case settingsKeyTwilightAngle:
        return HighLatitudeSetting.twilightAngle;
      case settingsKeyAuto:
      default:
        return HighLatitudeSetting.auto;
    }
  }

  String get key {
    switch (this) {
      case HighLatitudeSetting.auto:
        return settingsKeyAuto;
      case HighLatitudeSetting.middleOfTheNight:
        return settingsKeyMiddleOfTheNight;
      case HighLatitudeSetting.seventhOfTheNight:
        return settingsKeySeventhOfTheNight;
      case HighLatitudeSetting.twilightAngle:
        return settingsKeyTwilightAngle;
    }
  }

  /// Resolves this setting to a concrete `adhan` rule for [latitude].
  HighLatitudeRule resolve(double latitude) {
    switch (this) {
      case HighLatitudeSetting.auto:
        return latitude.abs() > autoThresholdDegrees
            ? HighLatitudeRule.seventh_of_the_night
            : HighLatitudeRule.middle_of_the_night;
      case HighLatitudeSetting.middleOfTheNight:
        return HighLatitudeRule.middle_of_the_night;
      case HighLatitudeSetting.seventhOfTheNight:
        return HighLatitudeRule.seventh_of_the_night;
      case HighLatitudeSetting.twilightAngle:
        return HighLatitudeRule.twilight_angle;
    }
  }
}

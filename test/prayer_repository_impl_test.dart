import 'package:flutter_test/flutter_test.dart';
import 'package:muslimly/src/features/prayer/data/repositories/prayer_repository_impl.dart';
import 'package:muslimly/src/features/settings/data/repositories/settings_repository.dart';

class _StubSettingsRepository implements SettingsRepository {
  _StubSettingsRepository(this.calculationMethod);

  final String calculationMethod;

  @override
  Future<String> getPrayerCalculationMethod() async => calculationMethod;

  @override
  Future<void> savePrayerCalculationMethod(String method) =>
      throw UnimplementedError();

  @override
  Future<String?> getLanguage() => throw UnimplementedError();
  @override
  Future<void> saveLanguage(String languageCode) => throw UnimplementedError();
  @override
  Future<Map<String, String>> getPrayerNotificationSettings() =>
      throw UnimplementedError();
  @override
  Future<void> savePrayerNotificationSetting(
    String prayerName,
    String soundType,
  ) =>
      throw UnimplementedError();
  @override
  Future<int> getDailyReadingTarget() => throw UnimplementedError();
  @override
  Future<void> saveDailyReadingTarget(int pages) => throw UnimplementedError();
  @override
  Future<String> getReadingTargetUnit() => throw UnimplementedError();
  @override
  Future<void> saveReadingTargetUnit(String unit) =>
      throw UnimplementedError();
  @override
  Future<int> getDailyAyahTarget() => throw UnimplementedError();
  @override
  Future<void> saveDailyAyahTarget(int ayahs) => throw UnimplementedError();
  @override
  Future<String?> getUserName() => throw UnimplementedError();
  @override
  Future<void> saveUserName(String name) => throw UnimplementedError();
  @override
  Future<bool> hasShownPlayerShowcase() => throw UnimplementedError();
  @override
  Future<void> setPlayerShowcaseShown(bool shown) =>
      throw UnimplementedError();
  @override
  Future<List<Map<String, dynamic>>> getHijriAdjustments() =>
      throw UnimplementedError();
  @override
  Future<void> saveHijriAdjustments(
    List<Map<String, dynamic>> adjustments,
  ) =>
      throw UnimplementedError();
  @override
  Future<List<Map<String, dynamic>>> fetchRemoteHijriAdjustments() =>
      throw UnimplementedError();
  @override
  Future<void> syncSettingsFromRemote() => throw UnimplementedError();
}

// Minutes-since-midnight for an "HH:mm" string, wrapping so a Kemenag ihtiyat
// that pushes a time past 23:59 (or before 00:00) still diffs correctly.
int _minutesOfDay(String hhmm) {
  final parts = hhmm.split(':');
  return int.parse(parts[0]) * 60 + int.parse(parts[1]);
}

int _diffMinutes(String kemenag, String singapore) {
  return (_minutesOfDay(kemenag) - _minutesOfDay(singapore) + 1440) % 1440;
}

void main() {
  // Jakarta coordinates; the specific date doesn't matter for this test since
  // it only checks the ihtiyat *offset* between methods, not absolute times.
  const latitude = -6.2088;
  const longitude = 106.8456;
  final date = DateTime(2026, 3, 15);

  test('kemenag_ri applies the expected ihtiyat offsets over singapore', () async {
    final singaporeRepo = PrayerRepositoryImpl(
      _StubSettingsRepository('singapore'),
    );
    final kemenagRepo = PrayerRepositoryImpl(
      _StubSettingsRepository('kemenag_ri'),
    );

    final singaporeResult = await singaporeRepo.getPrayerTime(
      latitude,
      longitude,
      date,
    );
    final kemenagResult = await kemenagRepo.getPrayerTime(
      latitude,
      longitude,
      date,
    );

    final singapore = singaporeResult.getRight().toNullable()!;
    final kemenag = kemenagResult.getRight().toNullable()!;

    // Fajr angle/madhab are identical between the two methods, so the only
    // difference should be Kemenag RI's ihtiyat (safety margin) minutes.
    expect(_diffMinutes(kemenag.subuh, singapore.subuh), 1438); // -2 min
    expect(_diffMinutes(kemenag.terbit, singapore.terbit), 1); // +1 min
    expect(_diffMinutes(kemenag.dzuhur, singapore.dzuhur), 1); // +2 - 1 (singapore's own +1 dhuhr adjustment)
    expect(_diffMinutes(kemenag.ashar, singapore.ashar), 2); // +2 min
    expect(_diffMinutes(kemenag.maghrib, singapore.maghrib), 2); // +2 min
    expect(_diffMinutes(kemenag.isya, singapore.isya), 2); // +2 min
  });

  test('date argument is honored instead of always using today', () async {
    final repo = PrayerRepositoryImpl(_StubSettingsRepository('singapore'));

    final result = await repo.getPrayerTime(
      latitude,
      longitude,
      DateTime(2026, 1, 1),
    );

    final prayerTime = result.getRight().toNullable()!;
    expect(prayerTime.date, '2026-01-01');
  });
}

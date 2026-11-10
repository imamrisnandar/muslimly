import 'package:adhan/adhan.dart' show HighLatitudeRule;
import 'package:flutter_test/flutter_test.dart';
import 'package:muslimly/src/features/prayer/domain/entities/high_latitude_setting.dart';
import 'package:muslimly/src/features/prayer/domain/entities/prayer_calculation_method.dart';
import 'package:muslimly/src/features/prayer/domain/entities/prayer_instants.dart';
import 'package:muslimly/src/features/prayer/domain/utils/prayer_calculator.dart';

PrayerInstants _calc(
  double lat,
  double lng,
  DateTime date, {
  PrayerCalculationMethod method = PrayerCalculationMethod.singapore,
  HighLatitudeSetting rule = HighLatitudeSetting.auto,
}) => PrayerCalculator.instants(
  latitude: lat,
  longitude: lng,
  date: date,
  method: method,
  highLatitude: rule,
);

List<DateTime> _inOrder(PrayerInstants i) => [
  i.fajr,
  i.sunrise,
  i.dhuhr,
  i.asr,
  i.maghrib,
  i.isha,
];

void expectNonDecreasing(PrayerInstants i) {
  final t = _inOrder(i);
  for (var k = 1; k < t.length; k++) {
    expect(
      t[k].isBefore(t[k - 1]),
      isFalse,
      reason: 'prayer #$k is before #${k - 1}: $i',
    );
  }
}

void main() {
  group('HighLatitudeSetting', () {
    test('key round-trips and unknown keys fall back to auto', () {
      for (final s in HighLatitudeSetting.values) {
        expect(HighLatitudeSetting.fromKey(s.key), s);
      }
      expect(HighLatitudeSetting.fromKey(null), HighLatitudeSetting.auto);
      expect(HighLatitudeSetting.fromKey('garbage'), HighLatitudeSetting.auto);
    });

    test(
      'auto switches to 1/7th strictly above the threshold, both hemispheres',
      () {
        const t = HighLatitudeSetting.autoThresholdDegrees;
        const auto = HighLatitudeSetting.auto;
        expect(auto.resolve(0), HighLatitudeRule.middle_of_the_night);
        expect(auto.resolve(t), HighLatitudeRule.middle_of_the_night);
        expect(auto.resolve(t + 0.1), HighLatitudeRule.seventh_of_the_night);
        expect(auto.resolve(-(t + 0.1)), HighLatitudeRule.seventh_of_the_night);
        expect(auto.resolve(-t), HighLatitudeRule.middle_of_the_night);
      },
    );

    test('explicit settings ignore latitude', () {
      expect(
        HighLatitudeSetting.twilightAngle.resolve(0),
        HighLatitudeRule.twilight_angle,
      );
      expect(
        HighLatitudeSetting.middleOfTheNight.resolve(80),
        HighLatitudeRule.middle_of_the_night,
      );
    });
  });

  group('PrayerInstants', () {
    test('all instants are UTC', () {
      final i = _calc(-6.2088, 106.8456, DateTime(2026, 3, 15));
      for (final t in _inOrder(i)) {
        expect(t.isUtc, isTrue);
      }
      expect(i.date, '2026-03-15');
      expect(i.fallbackLatitude, isNull);
    });

    test('Jakarta 2026-03-15 is ordered and in a plausible WIB range', () {
      final i = _calc(-6.2088, 106.8456, DateTime(2026, 3, 15));
      expectNonDecreasing(i);
      // Convert to WIB (UTC+7) explicitly so the test is device-zone proof.
      String wib(DateTime t) {
        final w = t.add(const Duration(hours: 7));
        return '${w.hour.toString().padLeft(2, '0')}:'
            '${w.minute.toString().padLeft(2, '0')}';
      }

      // Regression values from this implementation (singapore method, shafi).
      // NOT yet validated against the official Kemenag schedule — the roadmap
      // asks for that golden check; it needs the published table for this date.
      expect(wib(i.fajr), '04:40');
      expect(wib(i.sunrise), '05:57');
      expect(wib(i.dhuhr), '12:03');
      expect(wib(i.asr), '15:09');
      expect(wib(i.maghrib), '18:06');
      expect(wib(i.isha), '19:15');
    });

    test('high-latitude rule does not change a low-latitude city', () {
      final date = DateTime(2026, 3, 15);
      final base = _calc(-6.2088, 106.8456, date);
      for (final r in HighLatitudeSetting.values) {
        expect(_calc(-6.2088, 106.8456, date, rule: r), base);
      }
    });

    test(
      'Kemenag method differs from Singapore (ihtiyat) but stays ordered',
      () {
        final date = DateTime(2026, 3, 15);
        final k = _calc(
          -6.2088,
          106.8456,
          date,
          method: PrayerCalculationMethod.kemenagRI,
        );
        final s = _calc(-6.2088, 106.8456, date);
        expect(k.fajr, isNot(s.fajr));
        expectNonDecreasing(k);
      },
    );
  });

  group('high latitude', () {
    final juneSolstice = DateTime(2026, 6, 21);
    final decSolstice = DateTime(2026, 12, 21);
    const osloLat = 59.9139, osloLng = 10.7522;

    test(
      'Oslo June: 1/7th rule pulls Isha earlier and Fajr later than 1/2',
      () {
        final seventh = _calc(
          osloLat,
          osloLng,
          juneSolstice,
          rule: HighLatitudeSetting.seventhOfTheNight,
        );
        final half = _calc(
          osloLat,
          osloLng,
          juneSolstice,
          rule: HighLatitudeSetting.middleOfTheNight,
        );
        expect(seventh.isha.isBefore(half.isha), isTrue);
        expect(seventh.fajr.isAfter(half.fajr), isTrue);
        // Isha is bounded by 1/7 of the night after maghrib, so well under 2h.
        expect(
          seventh.isha.difference(seventh.maghrib),
          lessThan(const Duration(hours: 2)),
        );
        expect(seventh.fallbackLatitude, isNull);
      },
    );

    test('Oslo June: auto (59.9° > 48°) equals the 1/7th rule', () {
      expect(
        _calc(osloLat, osloLng, juneSolstice),
        _calc(
          osloLat,
          osloLng,
          juneSolstice,
          rule: HighLatitudeSetting.seventhOfTheNight,
        ),
      );
    });

    test('Oslo December is computable and ordered for every rule', () {
      for (final r in HighLatitudeSetting.values) {
        final i = _calc(osloLat, osloLng, decSolstice, rule: r);
        expectNonDecreasing(i);
        expect(i.fallbackLatitude, isNull);
      }
    });

    test(
      'Tromsø June (midnight sun): adhan throws, fallback latitude is used',
      () {
        const lat = 69.6492, lng = 18.9553;
        for (final r in HighLatitudeSetting.values) {
          final i = _calc(lat, lng, juneSolstice, rule: r);
          expect(i.fallbackLatitude, isNotNull);
          expect(i.fallbackLatitude!, lessThan(lat));
          expect(i.fallbackLatitude!, greaterThan(60));
          expectNonDecreasing(i);
          // Solar noon should still track the real longitude (~10:47 UTC).
          expect(i.dhuhr.hour, 10);
        }
      },
    );

    test('Svalbard in December (polar night) and the pole still resolve', () {
      final dec = _calc(78.2232, 15.6267, decSolstice);
      expectNonDecreasing(dec);
      final pole = _calc(90, 0, juneSolstice);
      expect(pole.fallbackLatitude, isNotNull);
      expectNonDecreasing(pole);
    });

    test('southern hemisphere polar fallback keeps the sign', () {
      final i = _calc(-78.0, 166.0, decSolstice); // Antarctica, midnight sun
      expect(i.fallbackLatitude, isNotNull);
      expect(i.fallbackLatitude!, isNegative);
    });
  });
}

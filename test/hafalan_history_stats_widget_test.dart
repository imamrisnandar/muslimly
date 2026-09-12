import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:muslimly/src/features/quran/presentation/widgets/hafalan_history_stats_widget.dart';

void main() {
  group('generateHafalanInsight', () {
    test('returns null when nothing crosses a new threshold', () {
      final insight = generateHafalanInsight(
        streak: 3,
        totalAyatHafal: 4,
        lastShownStreakMilestone: 0,
        lastShownAyatMilestone: 0,
      );
      expect(insight, isNull);
    });

    test('streak reaching the first threshold returns a streak insight', () {
      final insight = generateHafalanInsight(
        streak: 5,
        totalAyatHafal: 0,
        lastShownStreakMilestone: 0,
        lastShownAyatMilestone: 0,
      );
      expect(insight, isNotNull);
      expect(insight!['type'], 'streak');
      expect(insight['milestone'], 5);
    });

    test(
      'already-shown milestone is not re-shown even though streak still qualifies',
      () {
        final insight = generateHafalanInsight(
          streak: 5,
          totalAyatHafal: 0,
          lastShownStreakMilestone: 5,
          lastShownAyatMilestone: 0,
        );
        expect(insight, isNull);
      },
    );

    test(
      'unlike the exact-equality reading bug, skipping straight past a '
      'threshold (streak 8, never having been exactly 7) still fires it',
      () {
        final insight = generateHafalanInsight(
          streak: 8,
          totalAyatHafal: 0,
          lastShownStreakMilestone: 5,
          lastShownAyatMilestone: 0,
        );
        expect(insight, isNotNull);
        // Highest crossed-and-unshown threshold is 7, not 5 (already shown)
        // and not 8 (not a real milestone value).
        expect(insight!['milestone'], 7);
      },
    );

    test('picks the HIGHEST unshown streak milestone, not the lowest', () {
      final insight = generateHafalanInsight(
        streak: 30,
        totalAyatHafal: 0,
        lastShownStreakMilestone: 0,
        lastShownAyatMilestone: 0,
      );
      expect(insight!['milestone'], 30);
    });

    test('streak milestone takes priority over an ayat milestone', () {
      final insight = generateHafalanInsight(
        streak: 5,
        totalAyatHafal: 10,
        lastShownStreakMilestone: 0,
        lastShownAyatMilestone: 0,
      );
      expect(insight!['type'], 'streak');
    });

    test('ayat milestone fires once the streak one is already shown', () {
      final insight = generateHafalanInsight(
        streak: 5,
        totalAyatHafal: 10,
        lastShownStreakMilestone: 5,
        lastShownAyatMilestone: 0,
      );
      expect(insight, isNotNull);
      expect(insight!['type'], 'ayat');
      expect(insight['milestone'], 10);
    });

    test(
      'insight message copy (ARB) never mentions points/score framing',
      () {
        // generateHafalanInsight() itself only returns type+milestone (it
        // has no BuildContext to resolve l10n) — the actual displayed text
        // lives in the ARB files, resolved by HafalanInsightSection.build.
        // Checking both ARB source files directly still verifies the
        // Riset #2 framing guarantee end-to-end.
        for (final path in [
          'lib/src/l10n/arb/app_id.arb',
          'lib/src/l10n/arb/app_en.arb',
        ]) {
          final arb =
              jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
          for (final key in [
            'hafalanInsightStreakMessage',
            'hafalanInsightAyatMessage',
          ]) {
            final message = (arb[key] as String).toLowerCase();
            expect(
              message.contains('poin') ||
                  message.contains('point') ||
                  message.contains('skor') ||
                  message.contains('score') ||
                  message.contains('pahala'),
              isFalse,
              reason: '$path[$key] = "$message"',
            );
          }
        }
      },
    );
  });
}

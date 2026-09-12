import 'package:flutter_test/flutter_test.dart';
import 'package:muslimly/src/features/quran/domain/entities/hafalan_session.dart';
import 'package:muslimly/src/features/quran/domain/utils/hafalan_progress_calculator.dart';

HafalanSession _session({
  required int surahNumber,
  required int pageNumber,
  required double accuracy,
  int timestamp = 0,
  String date = '2026-09-12',
  int? id,
  String? audioFilePath,
  bool isAudioSaved = false,
}) {
  return HafalanSession(
    id: id,
    surahNumber: surahNumber,
    pageNumber: pageNumber,
    startAyah: 1,
    endAyah: 5,
    ayahCount: 5,
    accuracy: accuracy,
    date: date,
    timestamp: timestamp,
    audioFilePath: audioFilePath,
    isAudioSaved: isAudioSaved ? 1 : 0,
  );
}

String _fmt(DateTime dt) =>
    '${dt.year.toString().padLeft(4, '0')}-'
    '${dt.month.toString().padLeft(2, '0')}-'
    '${dt.day.toString().padLeft(2, '0')}';

/// [daysAgo] relative to "now", formatted as a hafalan_sessions date string —
/// keeps streak tests independent of a hardcoded calendar date.
String _daysAgo(int daysAgo) =>
    _fmt(DateTime.now().subtract(Duration(days: daysAgo)));

void main() {
  group('calculateSurahProgress', () {
    test('surah with no sessions is belum', () {
      final result = HafalanProgressCalculator.calculateSurahProgress([]);
      final fatihah = result.firstWhere((p) => p.surahNumber == 1);
      expect(fatihah.status, SurahHafalanStatus.belum);
      expect(fatihah.lastSessionTimestamp, isNull);
    });

    test('surah with a passing session on every page is sudah', () {
      // Al-Fatihah is entirely on page 1.
      final sessions = [
        _session(surahNumber: 1, pageNumber: 1, accuracy: 0.8, timestamp: 100),
      ];
      final result = HafalanProgressCalculator.calculateSurahProgress(sessions);
      final fatihah = result.firstWhere((p) => p.surahNumber == 1);
      expect(fatihah.status, SurahHafalanStatus.sudah);
      expect(fatihah.lastSessionTimestamp, 100);
    });

    test('a low-accuracy session never downgrades an already-sudah surah', () {
      // First a passing read, then a bad re-read of the same page — the
      // plan is explicit this must not flip sudah back to sedang.
      final sessions = [
        _session(surahNumber: 1, pageNumber: 1, accuracy: 0.9, timestamp: 100),
        _session(surahNumber: 1, pageNumber: 1, accuracy: 0.2, timestamp: 200),
      ];
      final result = HafalanProgressCalculator.calculateSurahProgress(sessions);
      final fatihah = result.firstWhere((p) => p.surahNumber == 1);
      expect(fatihah.status, SurahHafalanStatus.sudah);
      // Last-touched timestamp still reflects the most recent attempt.
      expect(fatihah.lastSessionTimestamp, 200);
    });

    test(
      'a surah spanning multiple pages is only sudah once ALL pages pass',
      () {
        // Al-Baqarah spans pages 2..49. Passing just page 2 should read as
        // sedang, not sudah.
        final sessions = [
          _session(
            surahNumber: 2,
            pageNumber: 2,
            accuracy: 0.9,
            timestamp: 100,
          ),
        ];
        final result = HafalanProgressCalculator.calculateSurahProgress(
          sessions,
        );
        final baqarah = result.firstWhere((p) => p.surahNumber == 2);
        expect(baqarah.status, SurahHafalanStatus.sedang);
      },
    );

    test('a failing-only session marks the surah sedang, not sudah', () {
      final sessions = [
        _session(surahNumber: 1, pageNumber: 1, accuracy: 0.3, timestamp: 100),
      ];
      final result = HafalanProgressCalculator.calculateSurahProgress(sessions);
      final fatihah = result.firstWhere((p) => p.surahNumber == 1);
      expect(fatihah.status, SurahHafalanStatus.sedang);
    });

    test('returns exactly 114 surahs', () {
      final result = HafalanProgressCalculator.calculateSurahProgress([]);
      expect(result.length, 114);
    });

    test('no session has audio: latestAudioFilePath stays null', () {
      final sessions = [
        _session(surahNumber: 1, pageNumber: 1, accuracy: 1.0, timestamp: 100),
      ];
      final result = HafalanProgressCalculator.calculateSurahProgress(sessions);
      final fatihah = result.firstWhere((p) => p.surahNumber == 1);
      expect(fatihah.latestAudioFilePath, isNull);
      expect(fatihah.latestAudioSessionId, isNull);
      expect(fatihah.latestAudioIsSaved, isFalse);
    });

    test(
      'latestAudioFilePath picks the most recent session WITH audio, not '
      'simply the most recent session overall',
      () {
        final sessions = [
          _session(
            id: 1,
            surahNumber: 1,
            pageNumber: 1,
            accuracy: 1.0,
            timestamp: 100,
            audioFilePath: '/tmp/first.m4a',
          ),
          // Most recent attempt, but recording was off — must NOT win.
          _session(
            id: 2,
            surahNumber: 1,
            pageNumber: 1,
            accuracy: 0.9,
            timestamp: 200,
          ),
        ];
        final result = HafalanProgressCalculator.calculateSurahProgress(
          sessions,
        );
        final fatihah = result.firstWhere((p) => p.surahNumber == 1);
        expect(fatihah.latestAudioSessionId, 1);
        expect(fatihah.latestAudioFilePath, '/tmp/first.m4a');
      },
    );

    test('latestAudioIsSaved reflects that specific session\'s flag', () {
      final sessions = [
        _session(
          id: 1,
          surahNumber: 1,
          pageNumber: 1,
          accuracy: 1.0,
          timestamp: 100,
          audioFilePath: '/tmp/saved.m4a',
          isAudioSaved: true,
        ),
      ];
      final result = HafalanProgressCalculator.calculateSurahProgress(
        sessions,
      );
      final fatihah = result.firstWhere((p) => p.surahNumber == 1);
      expect(fatihah.latestAudioIsSaved, isTrue);
    });
  });

  group('calculateJuzProgress', () {
    test('returns exactly 30 juz summing to a sane page count', () {
      final result = HafalanProgressCalculator.calculateJuzProgress([]);
      expect(result.length, 30);
      expect(result.every((j) => j.percentage == 0.0), isTrue);
    });

    test('juz 1 percentage reflects passing pages within it', () {
      // Juz 1 spans pages 1..21 (juz 2 starts at page 22) — 21 pages total.
      final sessions = [
        _session(surahNumber: 1, pageNumber: 1, accuracy: 1.0, timestamp: 1),
        _session(surahNumber: 2, pageNumber: 2, accuracy: 1.0, timestamp: 2),
      ];
      final result = HafalanProgressCalculator.calculateJuzProgress(sessions);
      final juz1 = result.firstWhere((j) => j.juzNumber == 1);
      expect(juz1.percentage, closeTo(2 / 21, 0.0001));
    });
  });

  group('calculateTotalAyatHafal', () {
    test('sums ayahCount once per passing page, not once per session', () {
      final sessions = [
        _session(surahNumber: 1, pageNumber: 1, accuracy: 0.2, timestamp: 1),
        _session(surahNumber: 1, pageNumber: 1, accuracy: 0.9, timestamp: 2),
      ];
      expect(
        HafalanProgressCalculator.calculateTotalAyatHafal(sessions),
        5, // ayahCount of the fixture is 5, counted once for page 1
      );
    });

    test('a failing-only page contributes nothing', () {
      final sessions = [
        _session(surahNumber: 1, pageNumber: 1, accuracy: 0.4, timestamp: 1),
      ];
      expect(HafalanProgressCalculator.calculateTotalAyatHafal(sessions), 0);
    });
  });

  group('calculateHafalanStreak', () {
    test('no sessions is a zero streak', () {
      expect(HafalanProgressCalculator.calculateHafalanStreak([]), 0);
    });

    test('a session neither today nor yesterday is a broken streak', () {
      final sessions = [
        _session(surahNumber: 1, pageNumber: 1, accuracy: 1.0, date: _daysAgo(3)),
      ];
      expect(HafalanProgressCalculator.calculateHafalanStreak(sessions), 0);
    });

    test('a single session today is a streak of 1', () {
      final sessions = [
        _session(surahNumber: 1, pageNumber: 1, accuracy: 1.0, date: _daysAgo(0)),
      ];
      expect(HafalanProgressCalculator.calculateHafalanStreak(sessions), 1);
    });

    test('still alive with the most recent session yesterday', () {
      final sessions = [
        _session(surahNumber: 1, pageNumber: 1, accuracy: 1.0, date: _daysAgo(1)),
      ];
      expect(HafalanProgressCalculator.calculateHafalanStreak(sessions), 1);
    });

    test('3 consecutive days ending today is a streak of 3', () {
      final sessions = [
        _session(surahNumber: 1, pageNumber: 1, accuracy: 1.0, date: _daysAgo(0)),
        _session(surahNumber: 1, pageNumber: 1, accuracy: 1.0, date: _daysAgo(1)),
        _session(surahNumber: 1, pageNumber: 1, accuracy: 1.0, date: _daysAgo(2)),
      ];
      expect(HafalanProgressCalculator.calculateHafalanStreak(sessions), 3);
    });

    test(
      'a single gap day within the first 7 days is shielded, not broken',
      () {
        // Sessions today, yesterday, then a gap at daysAgo(2), then
        // consecutive back through daysAgo(6) — the gap day itself doesn't
        // count, but doesn't reset the streak either.
        final sessions = [
          for (final d in [0, 1, 3, 4, 5, 6])
            _session(surahNumber: 1, pageNumber: 1, accuracy: 1.0, date: _daysAgo(d)),
        ];
        // Days walked: 0(hit,1) 1(hit,2) 2(gap,shielded) 3(hit,3) 4(hit,4)
        // 5(hit,5) 6(hit,6) = streak 6, shield consumed once.
        expect(HafalanProgressCalculator.calculateHafalanStreak(sessions), 6);
      },
    );

    test('two gap days in the same week breaks the streak at the second', () {
      final sessions = [
        for (final d in [0, 1, 3, 5, 6])
          _session(surahNumber: 1, pageNumber: 1, accuracy: 1.0, date: _daysAgo(d)),
      ];
      // Days walked: 0(hit,1) 1(hit,2) 2(gap,shielded) 3(hit,3) 4(gap,no
      // shield left this week) -> break. Streak = 3.
      expect(HafalanProgressCalculator.calculateHafalanStreak(sessions), 3);
    });

    test('the shield refills after a full 7-day week', () {
      // Hit every day except day 2 and day 9 (one gap per week).
      final days = [0, 1, 3, 4, 5, 6, 7, 8, 10, 11, 12, 13];
      final sessions = [
        for (final d in days)
          _session(surahNumber: 1, pageNumber: 1, accuracy: 1.0, date: _daysAgo(d)),
      ];
      // Week 1 (days 0-6): gap at day 2, shielded. Week 2 (days 7-13): gap
      // at day 9, shield refilled at day 7 (daysWalked % 7 == 0) so it's
      // shielded too. Streak counts every hit day: 12 total.
      expect(HafalanProgressCalculator.calculateHafalanStreak(sessions), 12);
    });
  });
}

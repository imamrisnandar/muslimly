// Drives HafalanBloc purely through SpeechResultReceived events — no
// speech_to_text platform channel involved. This works because InitSpeech
// is never dispatched: SpeechToText's cancel()/stop() no-op until a
// successful initialize() (see speech_to_text's `_initWorked` guard), so
// the bloc's ayah/page completion transitions never touch the plugin.
//
// This exists because a real emulator can't be given real recitation audio
// without host-level virtual audio routing (see HAFALAN_TRACKER_PLAN.md) —
// this is the deterministic, repeatable stand-in for "read a page correctly
// end to end" and "read a page with mistakes end to end".
import 'package:flutter_test/flutter_test.dart';
import 'package:muslimly/src/features/quran/domain/entities/ayah.dart';
import 'package:muslimly/src/features/quran/presentation/bloc/hafalan/hafalan_bloc.dart';
import 'package:muslimly/src/features/quran/presentation/bloc/hafalan/hafalan_event.dart';
import 'package:muslimly/src/features/quran/presentation/bloc/hafalan/hafalan_state.dart';

void main() {
  // A short two-ayah "page" — real Arabic words (Al-Fatihah 1-2 without full
  // diacritics), just short enough to keep the test fast.
  final ayahs = [
    const Ayah(
      number: 1,
      text: 'بسم الله الرحمن الرحيم',
      numberInSurah: 1,
      juz: 1,
      page: 1,
    ),
    const Ayah(
      number: 2,
      text: 'الحمد لله رب العالمين',
      numberInSurah: 2,
      juz: 1,
      page: 1,
    ),
  ];

  group('HafalanBloc — full correct recitation', () {
    test('reaches HafalanStatus.completed with perfect accuracy', () async {
      final bloc = HafalanBloc();
      addTearDown(bloc.close);
      bloc.setAyahs(ayahs);

      // The ayah1→ayah2 transition carries a real (unmocked) ~200ms delay
      // inside the bloc before the next ayah's event is even dequeued
      // (transformer: sequential()), so wait on the actual state condition
      // rather than a guessed sleep.
      final completedFuture = bloc.stream.firstWhere(
        (s) => s.status == HafalanStatus.completed,
      );

      // Recite each ayah exactly as written, as a single final STT result —
      // mirrors what a correct, unhurried recitation looks like once STT
      // finalizes its buffer.
      for (final ayah in ayahs) {
        bloc.add(SpeechResultReceived(ayah.text, isFinal: true));
      }

      final finalState = await completedFuture.timeout(
        const Duration(seconds: 5),
      );

      expect(finalState.status, HafalanStatus.completed);
      expect(finalState.completedAyahs, {1, 2});
      expect(finalState.ayahAccuracies, [1.0, 1.0]);
      expect(finalState.overallAccuracy, 1.0);
      // No word should ever have been marked mismatched on a clean read.
      expect(finalState.mismatchedWords.values.every((s) => s.isEmpty), isTrue);
    });
  });

  group('HafalanBloc — partial/skipped recitation', () {
    test('SkipAyah marks the remainder mismatched and still reaches completed '
        'with a reduced overall accuracy', () async {
      final bloc = HafalanBloc();
      addTearDown(bloc.close);
      bloc.setAyahs(ayahs);

      // Ayah 1 recited correctly...
      bloc.add(SpeechResultReceived(ayahs[0].text, isFinal: true));
      final ayah1Done = await bloc.stream
          .firstWhere((s) => s.completedAyahs.contains(1))
          .timeout(const Duration(seconds: 5));
      expect(ayah1Done.completedAyahs, {1});
      expect(ayah1Done.status, HafalanStatus.listening);

      // ...ayah 2 given up on (child stalls / walks away) — SkipAyah is
      // what the UI's skip control and the forced-mismatch timeout both
      // ultimately drive.
      final completedFuture = bloc.stream.firstWhere(
        (s) => s.status == HafalanStatus.completed,
      );
      bloc.add(SkipAyah());
      final finalState = await completedFuture.timeout(
        const Duration(seconds: 5),
      );

      expect(finalState.status, HafalanStatus.completed);
      expect(finalState.completedAyahs, {1, 2});
      expect(finalState.ayahAccuracies, [1.0, 0.0]);
      expect(finalState.overallAccuracy, 0.5);
      expect(
        finalState.mismatchedWords[2]?.length,
        ayahs[1].text.split(' ').length,
      );
    });
  });
}

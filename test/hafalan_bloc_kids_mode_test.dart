// Verifies HafalanBloc's Mode Anak guarantee from HAFALAN_TRACKER_PLAN.md
// §D: "tidak ada forced-timeout di mode anak" — an unresolved/unrecognized
// word must NEVER get force-marked as a mismatch after the 2s silence
// window, only ever via an explicit SkipAyah.
//
// _onForceEvaluateMismatch (the timer's target) only acts while
// state.isListening is true, which HafalanBloc only sets via a successful
// StartListening → speech_to_text initialize(). Reaching that for real
// means mocking the plugin's MethodChannel — there is no lighter-weight
// path to a meaningful test of this guard, since the guard's whole job is
// to protect a state that's otherwise unreachable in a bare test process.
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslimly/src/features/quran/domain/entities/ayah.dart';
import 'package:muslimly/src/features/quran/presentation/bloc/hafalan/hafalan_bloc.dart';
import 'package:muslimly/src/features/quran/presentation/bloc/hafalan/hafalan_event.dart';
import 'package:muslimly/src/features/quran/presentation/bloc/hafalan/hafalan_state.dart';

const _speechChannel = MethodChannel('plugin.csdcorp.com/speech_to_text');

void _mockSpeechChannel() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_speechChannel, (call) async {
        switch (call.method) {
          case 'initialize':
          case 'listen':
          case 'has_permission':
            return true;
          case 'cancel':
          case 'stop':
            return null;
          default:
            return null;
        }
      });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final ayahs = [
    const Ayah(
      number: 1,
      text: 'بسم الله الرحمن الرحيم',
      numberInSurah: 1,
      juz: 1,
      page: 1,
    ),
  ];

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_speechChannel, null);
  });

  /// Brings the bloc to a genuinely-listening state the same way the real
  /// UI does: InitSpeech (mocked to succeed) then StartListening.
  Future<void> startListening(HafalanBloc bloc) async {
    bloc.add(InitSpeech());
    await bloc.stream.firstWhere((s) => s.speechAvailable);
    bloc.add(StartListening());
    await bloc.stream.firstWhere((s) => s.isListening);
  }

  test('strict mode (default): an unresolved word gets force-marked mismatched '
      'after the silence timeout', () async {
    _mockSpeechChannel();
    final bloc = HafalanBloc(); // kidsMode defaults to false
    addTearDown(bloc.close);
    bloc.setAyahs(ayahs);
    await startListening(bloc);

    // A word that cannot match "بسم" (current), any overlap, or any
    // look-ahead target — genuinely unresolved.
    bloc.add(const SpeechResultReceived('zzz', isFinal: false));

    final state = await bloc.stream
        .firstWhere((s) => (s.mismatchedWords[1] ?? const {}).isNotEmpty)
        .timeout(const Duration(seconds: 5));

    expect(state.mismatchedWords[1], contains(0));
  });

  test('Mode Anak: the same unresolved word is NEVER force-marked, even after '
      'waiting well past the strict-mode timeout', () async {
    _mockSpeechChannel();
    final bloc = HafalanBloc(kidsMode: true);
    addTearDown(bloc.close);
    bloc.setAyahs(ayahs);
    await startListening(bloc);

    bloc.add(const SpeechResultReceived('zzz', isFinal: false));

    // Wait well past the 2s strict-mode timeout, then assert nothing
    // changed — there is no "success" event to wait on here, only the
    // absence of one, so a real wait is the honest way to test this.
    await Future<void>.delayed(const Duration(milliseconds: 2500));

    expect(bloc.state.mismatchedWords[1] ?? const {}, isEmpty);
    expect(bloc.state.status, isNot(HafalanStatus.error));
  });

  test(
    'Mode Anak: SkipAyah still works as the manual way to move on',
    () async {
      _mockSpeechChannel();
      final bloc = HafalanBloc(kidsMode: true);
      addTearDown(bloc.close);
      bloc.setAyahs(ayahs);
      await startListening(bloc);

      bloc.add(const SpeechResultReceived('zzz', isFinal: false));
      await Future<void>.delayed(const Duration(milliseconds: 200));

      bloc.add(SkipAyah());
      final state = await bloc.stream
          .firstWhere((s) => s.status == HafalanStatus.completed)
          .timeout(const Duration(seconds: 5));

      expect(state.completedAyahs, {1});
    },
  );
}

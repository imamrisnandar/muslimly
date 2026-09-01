import 'dart:async';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../../domain/utils/arabic_text_matcher.dart';
import '../../../domain/entities/ayah.dart';
import 'hafalan_event.dart';
import 'hafalan_state.dart';

/// Internal event: auto-restart speech engine when it stops mid-ayah
class _AutoRestartListening extends HafalanEvent {
  const _AutoRestartListening();

  @override
  List<Object?> get props => [];
}

class HafalanBloc extends Bloc<HafalanEvent, HafalanState> {
  final SpeechToText _speech = SpeechToText();
  List<Ayah> _ayahs = [];

  /// Expected words (normalized) for the current ayah — cached for performance
  List<String> _currentExpectedWords = [];

  /// Original (with diacritics) words for display
  List<String> _currentOriginalWords = [];

  /// Cache normalized words to avoid re-normalizing on every partial result (#5)
  final Map<String, String> _normCache = {};

  /// Last non-final STT tokens after replay trimming.
  /// Used to prevent final-result tail hallucinations from revealing words
  /// beyond the stable partial frontier.
  List<String> _lastPartialWords = const [];

  /// How many already-processed tail words were trimmed from the current STT
  /// chunk. Used to recognize "replay + speculative continuation" partials
  /// such as "بنهر | فمن" right after the user pauses on "بنهر".
  int _lastTailReplayTrimCount = 0;

  /// Debounce tracking for partial speech results (#6)
  DateTime _lastProcessedAt = DateTime.fromMillisecondsSinceEpoch(0);

  /// Consecutive final-result mismatches at the same cursor position.
  /// Only auto-advance (mark red) after >= 2 consecutive mismatches,
  /// giving the speech engine time to correct itself  int _currentExpectedWordsLength = 0;

  Timer? _silenceTimer;
  bool _isTransitioning = false; // Suppress auto-restart during deliberate transitions

  /// Known huruf muqatta'ah patterns (normalized, without diacritics)
  /// These are special Quranic opening letters that speech recognition
  /// spells out differently (e.g., الم → "ألف لام ميم")
  static final Set<String> _hurufMuqattaah = {
    'الم',
    'المص',
    'الر',
    'المر',
    'كهيعص',
    'طه',
    'طسم',
    'طس',
    'يس',
    'ص',
    'حم',
    'عسق',
    'ق',
    'ن',
  };

  /// Check if the current ayah is huruf muqatta'ah
  bool get _isCurrentAyahHurufMuqattaah {
    if (_currentExpectedWords.isEmpty) return false;
    // Huruf muqatta'ah are typically 1-2 words
    if (_currentExpectedWords.length > 2) return false;
    final combined = _currentExpectedWords.join();
    return _hurufMuqattaah.contains(combined);
  }

  HafalanBloc() : super(const HafalanState()) {
    // Handlers below await (speech engine calls, transition delays) while
    // mutating shared instance fields like _currentExpectedWords and
    // _lastPartialWords. flutter_bloc processes same-type events concurrently
    // by default, so two overlapping SpeechResultReceived events (STT fires
    // partials every ~150ms) could previously start mutating that state
    // before the prior one finished — exactly what the replay-trim/phantom-
    // word logic below exists to prevent. `sequential()` queues each event
    // type's own handler invocations so they never overlap with each other.
    // Cross-type interaction between SpeechResultReceived and
    // _AutoRestartListening is separately guarded by the _isTransitioning
    // checks further down.
    on<InitSpeech>(_onInitSpeech, transformer: sequential());
    on<StartListening>(_onStartListening, transformer: sequential());
    on<StopListening>(_onStopListening, transformer: sequential());
    on<SpeechResultReceived>(_onSpeechResult, transformer: sequential());
    on<SkipAyah>(_onSkipAyah, transformer: sequential());
    on<ForceEvaluateMismatch>(_onForceEvaluateMismatch, transformer: sequential());
    on<TogglePeek>(_onTogglePeek, transformer: sequential());
    on<ResetHafalan>(_onResetHafalan, transformer: sequential());
    on<SetCurrentAyah>(_onSetCurrentAyah, transformer: sequential());
    on<_AutoRestartListening>(_onAutoRestart, transformer: sequential());
  }

  /// Set the ayahs for the current page (called from the Page widget)
  void setAyahs(List<Ayah> ayahs) {
    _ayahs = ayahs;
    _prepareCurrentAyahWords();
  }

  /// Prepare normalized + original word lists for current ayah
  void _prepareCurrentAyahWords() {
    if (state.currentAyahIndex >= 0 && state.currentAyahIndex < _ayahs.length) {
      final text = _ayahs[state.currentAyahIndex].text;
      _currentOriginalWords = text
          .split(RegExp(r'\s+'))
          .where((w) => w.isNotEmpty)
          .toList();
      _currentExpectedWords = _currentOriginalWords
          .map((w) => ArabicTextMatcher.normalizeArabic(w))
          .toList();
    } else {
      _currentExpectedWords = [];
      _currentOriginalWords = [];
    }
  }

  /// Get the current ayah number (numberInSurah)
  int? get currentAyahNumber {
    if (state.currentAyahIndex < 0 || state.currentAyahIndex >= _ayahs.length) {
      return null;
    }
    return _ayahs[state.currentAyahIndex].numberInSurah;
  }

  /// Get the expected words (original with diacritics) for a given ayah
  List<String> getExpectedWordsForAyah(int ayahNumber) {
    final ayah = _ayahs.firstWhere(
      (a) => a.numberInSurah == ayahNumber,
      orElse: () => _ayahs.first,
    );
    return ayah.text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
  }

  Future<void> _onInitSpeech(
    InitSpeech event,
    Emitter<HafalanState> emit,
  ) async {
    try {
      final available = await _speech.initialize();

      // SpeechToText is a singleton. Its initialize() returns immediately if
      // already initialized WITHOUT updating callbacks. To support navigating
      // away and back (which creates a new HafalanBloc), we MUST explicitly
      // overwrite the listeners so they point to this new Bloc instance.
      _speech.errorListener = (error) {
        // Guard: don't add events after bloc is closed
        if (isClosed) return;
        // On error during active listening, try to auto-restart
        if (state.isListening) {
          add(const _AutoRestartListening());
        }
      };

      _speech.statusListener = (status) {
        if (isClosed) return;
        if (status == 'done' || status == 'notListening') {
          if (state.isListening && state.status != HafalanStatus.completed && !_isTransitioning) {
            // Auto-restart only when WE didn't deliberately stop it
            add(const _AutoRestartListening());
          }
        }
      };

      emit(
        state.copyWith(
          speechAvailable: available,
          status: available ? HafalanStatus.ready : HafalanStatus.error,
          errorMessage: available ? null : 'Speech recognition not available',
          clearError: available,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: HafalanStatus.error,
          errorMessage: 'Failed to initialize speech: $e',
        ),
      );
    }
  }

  Future<void> _onStartListening(
    StartListening event,
    Emitter<HafalanState> emit,
  ) async {
    if (!state.speechAvailable) {
      emit(
        state.copyWith(
          status: HafalanStatus.error,
          errorMessage: 'Speech recognition not available',
        ),
      );
      return;
    }

    if (state.status == HafalanStatus.completed) return;

    // Check if resuming from paused state
    final bool isResume = state.status == HafalanStatus.paused;

    if (!isResume) {
      // Fresh start — prepare words for current ayah
      _resetInternalState();
      _prepareCurrentAyahWords();
      emit(
        state.copyWith(
          status: HafalanStatus.listening,
          isListening: true,
          spokenText: '',
          currentMatchedWordCount: 0,
          currentTotalWordCount: _currentExpectedWords.length,
          clearError: true,
          clearMismatch: true,
        ),
      );
    } else {
      // Resume from paused — keep matched progress, just restart engine
      _prepareCurrentAyahWords();
      emit(
        state.copyWith(
          status: HafalanStatus.listening,
          isListening: true,
          spokenText: '',
          clearError: true,
          clearMismatch: true,
        ),
      );
    }

    await _startSpeechEngine();
  }

  /// Auto-restart listening (called by onStatus or after ayah completion)
  Future<void> _onAutoRestart(
    _AutoRestartListening event,
    Emitter<HafalanState> emit,
  ) async {
    if (state.status == HafalanStatus.completed) return;
    if (!state.isListening) return; // User paused manually
    if (_isTransitioning) return; // We're handling transition ourselves

    // Cancel first to suppress the beep, then restart
    await _speech.cancel();
    await Future.delayed(const Duration(milliseconds: 150));
    if (!state.isListening || isClosed) return;
    final success = await _startSpeechEngine();
    // Retry once if restart failed
    if (!success && state.isListening && !isClosed) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (state.isListening && !isClosed) {
        await _startSpeechEngine();
      }
    }
  }

  /// Start speech engine. Returns true if successful, false if failed.
  Future<bool> _startSpeechEngine() async {
    try {
      await _speech.listen(
        onResult: (result) {
          if (isClosed) return;
          add(
            SpeechResultReceived(
              result.recognizedWords,
              isFinal: result.finalResult,
            ),
          );
        },
        localeId: 'ar-SA',
        // Extended durations for Quran recitation with elongated vowels (mad)
        // Set listenFor very high and pauseFor to 30s to prevent abrupt STT
        // engine restarts (which trigger the annoying Android 'beep' sound).
        listenFor: const Duration(seconds: 300),
        pauseFor: const Duration(seconds: 30),
        listenOptions: SpeechListenOptions(
          listenMode: ListenMode.dictation,
          cancelOnError: false,
          partialResults: true,
          // On-device recognition may not have Arabic model available
          // on all devices — keep false to use cloud recognition as fallback
          onDevice: false,
          autoPunctuation: false,
          enableHapticFeedback: false,
        ),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _onStopListening(
    StopListening event,
    Emitter<HafalanState> emit,
  ) async {
    await _speech.stop();
    emit(
      state.copyWith(
        isListening: false,
        status: state.status == HafalanStatus.completed
            ? HafalanStatus.completed
            : HafalanStatus.paused, // Paused — can resume
      ),
    );
  }

  Future<void> _onSpeechResult(
    SpeechResultReceived event,
    Emitter<HafalanState> emit,
  ) async {
    _silenceTimer?.cancel();

    if (_currentExpectedWords.isEmpty) return;

    // Debounce partial results — process immediately for final (#6)
    if (!event.isFinal) {
      final now = DateTime.now();
      if (now.difference(_lastProcessedAt).inMilliseconds < 150) return;
      _lastProcessedAt = now;
    }

    // Use cached normalization for spoken words (#5)
    var spokenWords = event.text
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .map(
          (w) => _normCache.putIfAbsent(
            w,
            () => ArabicTextMatcher.normalizeArabic(w),
          ),
        )
        .where((w) => w.isNotEmpty)
        .toList();

    if (spokenWords.isEmpty) return;

    final int expectedLen = _currentExpectedWords.length;
    final ayahNum = currentAyahNumber;
    if (ayahNum == null) return;

    // ═══ DEBUG LOGGING ═══
    debugPrint('[HAFALAN] ayahIdx=${state.currentAyahIndex} ayahNum=$ayahNum isFinal=${event.isFinal}');
    debugPrint('[HAFALAN] spoken: ${spokenWords.join(" | ")}');
    debugPrint('[HAFALAN] expected: ${_currentExpectedWords.join(" | ")}');

    // ═══ HURUF MUQATTA'AH: auto-complete when any speech is detected ═══
    // Letters like الم are read as "alif lam mim" (elongated individual letters)
    // which speech recognition outputs differently than the stored text.
    // When we detect ANY speech for these special ayahs, auto-complete them.
    if (_isCurrentAyahHurufMuqattaah) {
      final int alreadyMatched = state.revealedWords[ayahNum]?.length ?? 0;
      if (alreadyMatched < expectedLen) {
        // Auto-complete: reveal all words and mark as completed
        final newRevealed = Map<int, Set<int>>.from(state.revealedWords);
        newRevealed[ayahNum] = Set<int>.from(
          List.generate(expectedLen, (i) => i),
        );
        final newCompleted = Set<int>.from(state.completedAyahs)..add(ayahNum);
        final newAccuracies = List<double>.from(state.ayahAccuracies)..add(1.0);

        final nextIndex = state.currentAyahIndex + 1;
        final isAllCompleted = nextIndex >= _ayahs.length;

        emit(
          state.copyWith(
            spokenText: event.text,
            revealedWords: newRevealed,
            completedAyahs: newCompleted,
            currentMatchedWordCount: expectedLen,
            ayahAccuracies: newAccuracies,
            currentAyahIndex: isAllCompleted
                ? state.currentAyahIndex
                : nextIndex,
            status: isAllCompleted
                ? HafalanStatus.completed
                : HafalanStatus.listening,
            clearMismatch: true,
          ),
        );

        if (!isAllCompleted) {
          _prepareCurrentAyahWords();
          emit(
            state.copyWith(
              spokenText: '',
              currentMatchedWordCount: 0,
              currentTotalWordCount: _currentExpectedWords.length,
            ),
          );
          // Cancel and restart STT for a clean buffer on the next ayah
          _isTransitioning = true;
          await _speech.cancel();
          await Future.delayed(const Duration(milliseconds: 200));
          if (state.isListening && !isClosed) {
            await _startSpeechEngine();
          }
          _isTransitioning = false;
        } else {
          _speech.stop();
          emit(state.copyWith(isListening: false));
        }
        return;
      }
    }

    // Count already-processed words (both matched + mismatched)
    final int alreadyRevealed = state.revealedWords[ayahNum]?.length ?? 0;
    final int alreadyMismatched = state.mismatchedWords[ayahNum]?.length ?? 0;
    final int alreadyProcessed = alreadyRevealed + alreadyMismatched;

    bool replayTrimmed = false;

    // STT often replays part of the previous buffer after a pause.
    // On ayahs with repeated words (for example multiple "ولا"), that stale
    // replay can accidentally match the NEXT expected repeated word and make
    // the UI jump ahead. Trim obvious overlap against the already-processed
    // prefix/suffix before running the live matcher.
    _lastTailReplayTrimCount = 0;
    if (alreadyProcessed > 0 && spokenWords.isNotEmpty) {
      final originalSpokenLen = spokenWords.length;
      spokenWords = _trimReplayedSpokenPrefix(spokenWords, alreadyProcessed);
      replayTrimmed = spokenWords.length != originalSpokenLen;
      if (spokenWords.isEmpty) return;
    }

    if (!event.isFinal &&
        _lastTailReplayTrimCount == 1 &&
        spokenWords.length <= 2) {
      debugPrint(
        '[HAFALAN] ⏸️ Deferred short continuation after single-word replay: '
        '${spokenWords.join(" | ")}',
      );
      return;
    }

    if (event.isFinal) {
      spokenWords = _capFinalToLastStablePartial(
        spokenWords,
        alreadyProcessed: alreadyProcessed,
        expectedLen: expectedLen,
      );
      _lastPartialWords = const [];
      if (spokenWords.isEmpty) return;
    } else {
      _lastPartialWords = List<String>.from(spokenWords);
    }

    // ═══ Per-word matching with matched/mismatched tracking ═══
    // Strategy 1 (from start) — for reference count only
    int matchedFromStart = 0;
    // Strategy 2 (from offset) — primary, tracks per-word status
    int cursor = alreadyProcessed; // Current expected word position
    final Set<int> newMatchedIndices = {};
    final Set<int> newMismatchedIndices = {};
    bool hasUnresolvedWord = false; // Track if any spoken word failed ALL matching
    bool allPreviousWereOverlap = (alreadyProcessed > 0) && !replayTrimmed;
    // If replay was already trimmed away, the remaining batch is at the live
    // frontier. Treating it as "all overlaps" would incorrectly drop the first
    // genuine continuation token as a phantom word.

    for (int i = 0; i < spokenWords.length; i++) {
      if (cursor >= expectedLen) break;
      final word = spokenWords[i];

      // Strategy 1: from beginning (count only, for best-of comparison)
      if (matchedFromStart < expectedLen &&
          ArabicTextMatcher.wordsMatch(
            word,
            _currentExpectedWords[matchedFromStart],
          )) {
        matchedFromStart++;
      }

      // Strategy 2: from offset with look-ahead and per-word status
      if (cursor < expectedLen) {
        hasUnresolvedWord = false; // Reset for each word. Only the final state of the buffer dictates if we are stuck.
        final expectedWord = _currentExpectedWords[cursor];
        
        if (ArabicTextMatcher.wordsMatch(word, expectedWord)) {
          // Direct match — word is correct (green)
          newMatchedIndices.add(cursor);
          cursor++;
          debugPrint('[HAFALAN] ✅ word[$i] "$word" matched expected[${cursor - 1}] "$expectedWord"');
        } else {
          if (i + 1 < spokenWords.length &&
              cursor + 1 < expectedLen &&
              _isContextualNearMatch(
                word,
                expectedWord,
                spokenWords[i + 1],
                _currentExpectedWords[cursor + 1],
              )) {
            newMatchedIndices.add(cursor);
            cursor++;
            debugPrint(
              '[HAFALAN] ≈ word[$i] "$word" near-matched expected[${cursor - 1}] "$expectedWord"',
            );
            continue;
          }

          // ═══ Muqatta'ah Component Swallow ═══
          // If the PREVIOUS expected word was a muqatta'ah (like الرا) and STT 
          // is still spelling out its components (like لام or ر), they will fail
          // against the CURRENT expected word.
          // If this happens, we just "swallow" the extra muqatta'ah component.
          if (cursor > 0 && 
              ArabicTextMatcher.isMuqattaahWord(_currentExpectedWords[cursor - 1]) &&
              ArabicTextMatcher.isMuqattaahComponent(word)) {
            debugPrint('[HAFALAN] 🔄 word[$i] "$word" swallowed as trailing component for "${_currentExpectedWords[cursor - 1]}"');
            hasUnresolvedWord = false; // It's not genuinely unresolved, it belongs to previous
            continue;
          }

          // ═══ WORD-MERGE: try joining current + next spoken word ═══
          // Speech engine may split a word during mad (elongation), e.g.
          // الضالين → "الضا" + "لين". Try merging adjacent spoken words.
          bool mergedMatch = false;
          if (i + 1 < spokenWords.length) {
            final merged = word + spokenWords[i + 1];
            if (ArabicTextMatcher.wordsMatch(
              merged,
              _currentExpectedWords[cursor],
            )) {
              newMatchedIndices.add(cursor);
              cursor++;
              i++; // Skip next spoken word (already consumed in merge)
              mergedMatch = true;
            }
          }

          if (!mergedMatch) {
            // ═══ OVERLAP CHECK — before look-ahead ═══
            bool isOverlap = false;
            // Check ALL already-processed words (not just last 5)
            // Long ayahs like Al-Maidah 5:1 (23 words) need full lookback
            for (int k = 0; k < alreadyProcessed; k++) {
              if (ArabicTextMatcher.wordsMatch(
                word,
                _currentExpectedWords[k],
              )) {
                isOverlap = true;
                break;
              }
            }
            if (!isOverlap) {
              for (final idx in newMatchedIndices) {
                if (ArabicTextMatcher.wordsMatch(
                  word,
                  _currentExpectedWords[idx],
                )) {
                  isOverlap = true;
                  break;
                }
              }
            }

            if (isOverlap) {
              continue;
            }

            // STT sometimes replays the very last already-read word with a
            // tiny typo before continuing to the true next word
            // (for example "مبترىكم" after "مبتلىكم"). If we treat that as a
            // brand-new token, the phantom-word guard will break the batch and
            // block the actual next word from being processed.
            if (!event.isFinal &&
                allPreviousWereOverlap &&
                _looksLikeStaleReplayTail(word, alreadyProcessed)) {
              debugPrint('[HAFALAN] ↩️ Ignored stale replay tail "$word"');
              continue;
            }

            if (allPreviousWereOverlap &&
                _isIgnorablePostOverlapNoise(word, cursor)) {
              debugPrint('[HAFALAN] 🫥 Ignored post-overlap noise "$word"');
              continue;
            }

            // If we get here, it's a NEW (non-overlap) word.
            // ═══ Phantom word prevention ═══
            // If ALL words processed so far in this partial result were overlaps
            // (meaning the user paused, and STT is just playing back old buffer),
            // and suddenly a new word appears, it is highly likely a phantom prediction
            // from trailing audio. We drop it here. It will be confirmed in the next
            // batch or final result if it was genuine.
            if (!event.isFinal && allPreviousWereOverlap) {
              debugPrint('[HAFALAN] 🛡️ Dropped potential phantom word "$word" after overlaps');
              break;
            }
            allPreviousWereOverlap = false;

            // Not overlap — try look-ahead for waqf gap.
            // Important: only allow this on FINAL STT results.
            // Partial Arabic STT often predicts a likely continuation while the
            // user is still paused mid-ayah, which makes the UI jump ahead
            // (green/red) before the spokenText visually reflects that intent.
            // By deferring look-ahead until final results, partial updates stay
            // conservative: they only reveal words that were directly matched.
            if (event.isFinal && alreadyProcessed > 0) {
              final remaining = expectedLen - cursor - 1;
              final lookAheadLimit = remaining < 3 ? remaining : 3;
              for (int ahead = 1; ahead <= lookAheadLimit; ahead++) {
                if (ArabicTextMatcher.wordsMatch(
                  word,
                  _currentExpectedWords[cursor + ahead],
                )) {
                  for (int skip = cursor; skip < cursor + ahead; skip++) {
                    newMismatchedIndices.add(skip);
                  }
                  newMatchedIndices.add(cursor + ahead);
                  cursor = cursor + ahead + 1;
                  break;
                }
              }
            }

            // If word didn't match anything (not overlap, not look-ahead, not merge),
            // mark it as unresolved so the silence timer can evaluate it.
            if (!isOverlap && cursor == alreadyProcessed + newMatchedIndices.length + newMismatchedIndices.length) {
              // cursor didn't advance for this word — genuinely unresolved
              hasUnresolvedWord = true;
              debugPrint('[HAFALAN] ❓ word[$i] "$word" unresolved (no match found)');
              // Be conservative: once a new unresolved word appears, do not
              // process later tokens from the same STT batch. On pauses, STT
              // often hallucinates likely continuation words at the tail of a
              // final result; continuing past the first unresolved token can
              // make future words turn green/red before they were recited.
              break;
            }
          }
        }
      }
    }

    // ═══ SILENCE EVALUATION TIMER ═══
    // Only fire when a spoken word genuinely didn't match any expected word.
    // This prevents false mismatch when the user pauses mid-ayah at a waqf point.
    if (hasUnresolvedWord && cursor < expectedLen) {
      debugPrint('[HAFALAN] ⏰ Setting 2s silence timer. cursor=$cursor expectedLen=$expectedLen');
      _silenceTimer = Timer(const Duration(milliseconds: 2000), () {
        if (!isClosed) add(ForceEvaluateMismatch());
      });
    }

    // Strategy 1 (continuous match from start) is no longer used to override Strategy 2
    // because it loses per-word status tracking (green vs red). We must always
    // rely on Strategy 2's output to correctly display omitted/skipped words.

    // ═══ SAFETY: remove conflicts ═══
    // If a word is in BOTH matched and mismatched (e.g. from look-ahead), 
    // mismatched wins to prevent false green.
    newMatchedIndices.removeAll(newMismatchedIndices);

    // Strategy 2 result — with per-word matched/mismatched status
    if (newMatchedIndices.isEmpty && newMismatchedIndices.isEmpty) {
      return; // No progress
    }

    // Build updated revealed & mismatched maps
    final newRevealed = Map<int, Set<int>>.from(state.revealedWords);
    final ayahRevealed = Set<int>.from(newRevealed[ayahNum] ?? <int>{});
    ayahRevealed.addAll(newMatchedIndices);
    newRevealed[ayahNum] = ayahRevealed;

    final newMismatched = Map<int, Set<int>>.from(state.mismatchedWords);
    final ayahMismatched = Set<int>.from(newMismatched[ayahNum] ?? <int>{});
    ayahMismatched.addAll(newMismatchedIndices);
    newMismatched[ayahNum] = ayahMismatched;

    final int totalProcessed = ayahRevealed.length + ayahMismatched.length;
    final bool ayahComplete = totalProcessed >= expectedLen;

    debugPrint('[HAFALAN] matched=${newMatchedIndices} mismatched=${newMismatchedIndices} complete=$ayahComplete');
    debugPrint('[HAFALAN] STATE ayah$ayahNum revealed=${ayahRevealed.toList()..sort()} mismatchedState=${ayahMismatched.toList()..sort()}');

    await _emitProgress(
      emit,
      event,
      ayahNum,
      newRevealed,
      newMismatched,
      totalProcessed,
      expectedLen,
      ayahComplete,
    );
  }

  List<String> _trimReplayedSpokenPrefix(
    List<String> spokenWords,
    int alreadyProcessed,
  ) {
    if (spokenWords.isEmpty || alreadyProcessed <= 0) {
      return spokenWords;
    }

    // Case 1: STT returns the transcript again from the start of the ayah.
    // This needs to understand split tokens like "يا | ايها" matching one
    // expected word "ياايها", otherwise we trim only "يا" and the matcher
    // gets stuck on "ايها" against the next cursor word.
    int spokenCursor = 0;
    int expectedCursor = 0;
    while (spokenCursor < spokenWords.length && expectedCursor < alreadyProcessed) {
      final expectedWord = _currentExpectedWords[expectedCursor];

      if (ArabicTextMatcher.wordsMatch(spokenWords[spokenCursor], expectedWord)) {
        spokenCursor++;
        expectedCursor++;
        continue;
      }

      if (spokenCursor + 1 < spokenWords.length) {
        final merged = spokenWords[spokenCursor] + spokenWords[spokenCursor + 1];
        if (ArabicTextMatcher.wordsMatch(merged, expectedWord)) {
          spokenCursor += 2;
          expectedCursor++;
          continue;
        }
      }

      break;
    }
    if (expectedCursor > 0) {
      return spokenWords.sublist(spokenCursor);
    }

    // Case 2: STT replays only the tail end of the already-read buffer.
    int bestTailOverlap = 0;
    final int tailLimit = spokenWords.length < alreadyProcessed
        ? spokenWords.length
        : alreadyProcessed;
    for (int overlap = tailLimit; overlap >= 1; overlap--) {
      bool matches = true;
      final int expectedStart = alreadyProcessed - overlap;
      for (int i = 0; i < overlap; i++) {
        if (!ArabicTextMatcher.wordsMatch(
          spokenWords[i],
          _currentExpectedWords[expectedStart + i],
        )) {
          matches = false;
          break;
        }
      }
      if (matches) {
        bestTailOverlap = overlap;
        break;
      }
    }

    // Trim a single-word tail replay only when it clearly belongs to the
    // PREVIOUS word and cannot also be the CURRENT expected word. This keeps
    // repeated words like "ولا ... ولا" safe, while still stripping stale
    // replays such as "بنهار" right after "بنهر".
    if (bestTailOverlap == 1) {
      final currentExpected = alreadyProcessed < _currentExpectedWords.length
          ? _currentExpectedWords[alreadyProcessed]
          : null;
      final canAlsoBeCurrent = currentExpected != null &&
          ArabicTextMatcher.wordsMatch(spokenWords.first, currentExpected);
      if (!canAlsoBeCurrent) {
        _lastTailReplayTrimCount = 1;
        return spokenWords.sublist(1);
      }
    }

    // Require at least 2-word tail overlap otherwise, to avoid trimming a
    // genuine new repeated short word at the start of fresh speech.
    if (bestTailOverlap >= 2) {
      _lastTailReplayTrimCount = bestTailOverlap;
      return spokenWords.sublist(bestTailOverlap);
    }

    return spokenWords;
  }

  List<String> _capFinalToLastStablePartial(
    List<String> finalWords, {
    required int alreadyProcessed,
    required int expectedLen,
  }) {
    if (_lastPartialWords.isEmpty || finalWords.length <= _lastPartialWords.length) {
      return finalWords;
    }

    bool sameStablePrefix = true;
    for (int i = 0; i < _lastPartialWords.length; i++) {
      if (!ArabicTextMatcher.wordsMatch(finalWords[i], _lastPartialWords[i])) {
        sameStablePrefix = false;
        break;
      }
    }

    // If the final result is simply the previous partial plus extra tail words,
    // trust only the stable partial frontier. Arabic STT frequently appends
    // speculative continuation words at the end of the final result when the
    // reader pauses, which is exactly what causes premature green highlights.
    if (sameStablePrefix) {
      final bool completesAyah = alreadyProcessed + finalWords.length >= expectedLen;
      // Only allow the extra tail through when it finishes the ayah.
      // This keeps endings like "هدى للمتقين" working, while preventing
      // mid-ayah tails such as "بنهر فمن" from turning future words green.
      if (completesAyah) {
        return finalWords;
      }
      return finalWords.sublist(0, _lastPartialWords.length);
    }

    return finalWords;
  }

  bool _looksLikeStaleReplayTail(String word, int alreadyProcessed) {
    if (alreadyProcessed <= 0) return false;

    final int start = alreadyProcessed - 3 < 0 ? 0 : alreadyProcessed - 3;
    for (int i = start; i < alreadyProcessed; i++) {
      if (_isLooseReplayMatch(word, _currentExpectedWords[i])) {
        return true;
      }
    }
    return false;
  }

  bool _isIgnorablePostOverlapNoise(String word, int cursor) {
    // After a replayed last word, Arabic STT sometimes inserts a short
    // muqatta'ah-like noise token such as "يا" before the real continuation:
    //   بنهار | يا | فمن | شرب ...
    // That token should not block the cursor or trigger a forced mismatch.
    if (!ArabicTextMatcher.isMuqattaahComponent(word)) {
      return false;
    }

    if (cursor < _currentExpectedWords.length &&
        ArabicTextMatcher.wordsMatch(word, _currentExpectedWords[cursor])) {
      return false;
    }

    final int remaining = _currentExpectedWords.length - cursor - 1;
    final int lookAheadLimit = remaining < 2 ? remaining : 2;
    for (int ahead = 1; ahead <= lookAheadLimit; ahead++) {
      if (ArabicTextMatcher.wordsMatch(
        word,
        _currentExpectedWords[cursor + ahead],
      )) {
        return false;
      }
    }

    return true;
  }

  bool _isContextualNearMatch(
    String spoken,
    String expected,
    String nextSpoken,
    String nextExpected,
  ) {
    // Very short bridge words are frequently off by one letter in Arabic STT:
    //   فمن -> فما
    // We only accept this when the NEXT spoken word already matches the NEXT
    // expected word, so the local context confirms the intended phrase.
    if (!ArabicTextMatcher.wordsMatch(nextSpoken, nextExpected)) {
      return false;
    }

    if (spoken.length != expected.length || spoken.length < 2 || spoken.length > 3) {
      return false;
    }

    if (_levenshteinDistance(spoken, expected) != 1) {
      return false;
    }

    int diffIndex = -1;
    for (int i = 0; i < spoken.length; i++) {
      if (spoken[i] != expected[i]) {
        if (diffIndex != -1) return false;
        diffIndex = i;
      }
    }

    // Keep this narrow: only tolerate a single trailing-letter confusion.
    return diffIndex == spoken.length - 1;
  }

  bool _isLooseReplayMatch(String a, String b) {
    if (a == b) return true;

    final lenDiff = (a.length - b.length).abs();
    if (lenDiff > 1) return false;

    final distance = _levenshteinDistance(a, b);
    return distance <= 1;
  }

  int _levenshteinDistance(String s, String t) {
    final m = s.length;
    final n = t.length;

    if (m == 0) return n;
    if (n == 0) return m;

    final d = List.generate(m + 1, (_) => List.filled(n + 1, 0));

    for (int i = 0; i <= m; i++) {
      d[i][0] = i;
    }
    for (int j = 0; j <= n; j++) {
      d[0][j] = j;
    }

    for (int i = 1; i <= m; i++) {
      for (int j = 1; j <= n; j++) {
        final cost = s[i - 1] == t[j - 1] ? 0 : 1;
        d[i][j] = [
          d[i - 1][j] + 1,
          d[i][j - 1] + 1,
          d[i - 1][j - 1] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return d[m][n];
  }

  Future<void> _onForceEvaluateMismatch(
    ForceEvaluateMismatch event,
    Emitter<HafalanState> emit,
  ) async {
    if (state.status == HafalanStatus.completed || !state.isListening) return;

    debugPrint('[HAFALAN] ⚠️ ForceEvaluateMismatch fires! ayahIdx=${state.currentAyahIndex}');

    final ayahNum = currentAyahNumber;
    if (ayahNum == null) return;
    final expectedWords = _currentExpectedWords;
    final expectedLen = expectedWords.length;

    final alreadyRevealed = state.revealedWords[ayahNum]?.length ?? 0;
    final alreadyMismatched = state.mismatchedWords[ayahNum]?.length ?? 0;
    final cursor = alreadyRevealed + alreadyMismatched;

    if (cursor < expectedLen) {
      // Force current word to be mismatched (red) because of 2s stuck silence
      final newMismatchedIndices = {cursor};

      final newRevealed = Map<int, Set<int>>.from(state.revealedWords);
      final newMismatched = Map<int, Set<int>>.from(state.mismatchedWords);
      final ayahMismatched = Set<int>.from(newMismatched[ayahNum] ?? <int>{});
      
      ayahMismatched.addAll(newMismatchedIndices);
      newMismatched[ayahNum] = ayahMismatched;

      final totalProcessed = (state.revealedWords[ayahNum]?.length ?? 0) +
          ayahMismatched.length;
      final ayahComplete = totalProcessed >= expectedLen;

      await _emitProgress(
        emit,
        SpeechResultReceived(state.spokenText, isFinal: false),
        ayahNum,
        newRevealed,
        newMismatched,
        totalProcessed,
        expectedLen,
        ayahComplete,
      );
    }
  }

  /// Shared helper to emit match progress and handle ayah completion/transition
  Future<void> _emitProgress(
    Emitter<HafalanState> emit,
    SpeechResultReceived event,
    int ayahNum,
    Map<int, Set<int>> newRevealed,
    Map<int, Set<int>> newMismatched,
    int processedCount,
    int expectedLen,
    bool ayahComplete,
  ) async {
    if (ayahComplete) {
      _silenceTimer?.cancel(); // CRITICAL: prevent timer from corrupting next ayah
      debugPrint('[HAFALAN] ═══ AYAH $ayahNum COMPLETE! Transitioning... ═══');
      final newCompleted = Set<int>.from(state.completedAyahs)..add(ayahNum);
      // Accuracy = matched / total (mismatched words reduce accuracy)
      final matched = newRevealed[ayahNum]?.length ?? 0;
      final accuracy = matched / expectedLen;
      final newAccuracies = List<double>.from(state.ayahAccuracies)
        ..add(accuracy);

      final nextIndex = state.currentAyahIndex + 1;
      final isAllCompleted = nextIndex >= _ayahs.length;

      emit(
        state.copyWith(
          spokenText: event.text,
          revealedWords: newRevealed,
          mismatchedWords: newMismatched,
          completedAyahs: newCompleted,
          currentMatchedWordCount: processedCount,
          ayahAccuracies: newAccuracies,
          currentAyahIndex: isAllCompleted ? state.currentAyahIndex : nextIndex,
          status: isAllCompleted
              ? HafalanStatus.completed
              : HafalanStatus.listening,
          clearMismatch: true,
        ),
      );

      if (!isAllCompleted) {
        _prepareCurrentAyahWords();
        emit(
          state.copyWith(
            spokenText: '',
            currentMatchedWordCount: 0,
            currentTotalWordCount: _currentExpectedWords.length,
          ),
        );
        // Cancel and restart STT for a clean buffer on the next ayah
        _isTransitioning = true;
        await _speech.cancel();
        await Future.delayed(const Duration(milliseconds: 200));
        if (state.isListening && !isClosed) {
          await _startSpeechEngine();
        }
        _isTransitioning = false;
      } else {
        _speech.stop();
        emit(state.copyWith(isListening: false));
      }
    } else {
      emit(
        state.copyWith(
          spokenText: event.text,
          revealedWords: newRevealed,
          mismatchedWords: newMismatched,
          currentMatchedWordCount: processedCount,
          clearMismatch: true,
        ),
      );
    }
  }

  void _onSkipAyah(SkipAyah event, Emitter<HafalanState> emit) {
    final ayahNum = currentAyahNumber;
    if (ayahNum == null) return;

    final totalWords = _currentExpectedWords.length;
    final alreadyRevealed = state.revealedWords[ayahNum] ?? <int>{};

    // Keep already-revealed words as green, mark the rest as mismatch (red)
    final newRevealed = Map<int, Set<int>>.from(state.revealedWords);
    newRevealed[ayahNum] = Set<int>.from(alreadyRevealed);

    final newMismatched = Map<int, Set<int>>.from(state.mismatchedWords);
    final ayahMismatched = Set<int>.from(newMismatched[ayahNum] ?? <int>{});
    for (int i = 0; i < totalWords; i++) {
      if (!alreadyRevealed.contains(i)) {
        ayahMismatched.add(i);
      }
    }
    newMismatched[ayahNum] = ayahMismatched;

    final newCompleted = Set<int>.from(state.completedAyahs)..add(ayahNum);
    final accuracy = alreadyRevealed.length / totalWords;
    final newAccuracies = List<double>.from(state.ayahAccuracies)
      ..add(accuracy);

    final nextIndex = state.currentAyahIndex + 1;
    final isCompleted = nextIndex >= _ayahs.length;

    emit(
      state.copyWith(
        revealedWords: newRevealed,
        mismatchedWords: newMismatched,
        completedAyahs: newCompleted,
        currentAyahIndex: isCompleted ? state.currentAyahIndex : nextIndex,
        status: isCompleted ? HafalanStatus.completed : HafalanStatus.ready,
        ayahAccuracies: newAccuracies,
        spokenText: '',
        currentMatchedWordCount: 0,
      ),
    );

    if (!isCompleted) {
      _prepareCurrentAyahWords();
      emit(state.copyWith(currentTotalWordCount: _currentExpectedWords.length));
    }
  }

  void _onTogglePeek(TogglePeek event, Emitter<HafalanState> emit) {
    emit(state.copyWith(isPeeking: event.isPeeking));
  }

  void _onResetHafalan(ResetHafalan event, Emitter<HafalanState> emit) {
    _silenceTimer?.cancel();
    _speech.cancel(); // Use cancel instead of stop to prevent trailing stale results
    _resetInternalState();
    _prepareCurrentAyahWords();
    emit(
      const HafalanState().copyWith(
        speechAvailable: state.speechAvailable,
        status: HafalanStatus.ready,
        currentTotalWordCount: _currentExpectedWords.length,
      ),
    );
  }

  /// Reset all internal state variables to their initial values.
  /// Called on fresh start and on manual reset.
  void _resetInternalState() {
    _normCache.clear();
    _lastPartialWords = const [];
    _lastProcessedAt = DateTime.fromMillisecondsSinceEpoch(0);
  }

  void _onSetCurrentAyah(SetCurrentAyah event, Emitter<HafalanState> emit) {
    final index = _ayahs.indexWhere((a) => a.numberInSurah == event.ayahNumber);
    if (index != -1) {
      emit(
        state.copyWith(
          currentAyahIndex: index,
          spokenText: '',
          currentMatchedWordCount: 0,
        ),
      );
      _prepareCurrentAyahWords();
      emit(state.copyWith(currentTotalWordCount: _currentExpectedWords.length));
    }
  }

  @override
  Future<void> close() {
    _speech.stop();
    _speech.cancel();
    return super.close();
  }
}

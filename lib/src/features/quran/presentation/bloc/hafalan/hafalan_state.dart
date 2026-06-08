import 'package:equatable/equatable.dart';

enum HafalanStatus {
  initial, // Not started
  ready, // Speech engine ready, waiting for user to tap mic
  listening, // Actively listening — words reveal in real-time
  paused, // User paused — can resume from current position
  completed, // All ayahs on page completed
  error, // Speech engine error
}

class HafalanState extends Equatable {
  final HafalanStatus status;
  final int currentAyahIndex;

  /// Per-word reveal tracking: ayahNumber → set of word indices that are revealed
  final Map<int, Set<int>> revealedWords;

  /// Per-word mismatch tracking: ayahNumber → set of word indices that were mismatched (red)
  final Map<int, Set<int>> mismatchedWords;

  /// Tracks fully completed ayahs (all words revealed)
  final Set<int> completedAyahs;

  final bool isListening;
  final bool isPeeking;
  final String spokenText;

  /// How many words of the current ayah have been matched so far
  final int currentMatchedWordCount;

  /// Total words in current ayah (for progress display)
  final int currentTotalWordCount;

  final String? errorMessage;
  final bool speechAvailable;

  /// Last word that didn't match (for warning display)
  final String? lastMismatchWord;

  /// Number of consecutive mismatches (resets on match)
  final int mismatchCount;

  // Accumulated accuracy for scoring (matched words / total words per ayah)
  final List<double> ayahAccuracies;

  const HafalanState({
    this.status = HafalanStatus.initial,
    this.currentAyahIndex = 0,
    this.revealedWords = const {},
    this.mismatchedWords = const {},
    this.completedAyahs = const {},
    this.isListening = false,
    this.isPeeking = false,
    this.spokenText = '',
    this.currentMatchedWordCount = 0,
    this.currentTotalWordCount = 0,
    this.errorMessage,
    this.speechAvailable = false,
    this.lastMismatchWord,
    this.mismatchCount = 0,
    this.ayahAccuracies = const [],
  });

  /// Overall accuracy across all completed ayahs
  double get overallAccuracy {
    if (ayahAccuracies.isEmpty) return 0.0;
    return ayahAccuracies.reduce((a, b) => a + b) / ayahAccuracies.length;
  }

  /// Total revealed words across all ayahs
  int get totalRevealedWords {
    int count = 0;
    for (final words in revealedWords.values) {
      count += words.length;
    }
    return count;
  }

  HafalanState copyWith({
    HafalanStatus? status,
    int? currentAyahIndex,
    Map<int, Set<int>>? revealedWords,
    Map<int, Set<int>>? mismatchedWords,
    Set<int>? completedAyahs,
    bool? isListening,
    bool? isPeeking,
    String? spokenText,
    int? currentMatchedWordCount,
    int? currentTotalWordCount,
    String? errorMessage,
    bool? speechAvailable,
    String? lastMismatchWord,
    int? mismatchCount,
    List<double>? ayahAccuracies,
    bool clearError = false,
    bool clearMismatch = false,
  }) {
    return HafalanState(
      status: status ?? this.status,
      currentAyahIndex: currentAyahIndex ?? this.currentAyahIndex,
      revealedWords: revealedWords ?? this.revealedWords,
      mismatchedWords: mismatchedWords ?? this.mismatchedWords,
      completedAyahs: completedAyahs ?? this.completedAyahs,
      isListening: isListening ?? this.isListening,
      isPeeking: isPeeking ?? this.isPeeking,
      spokenText: spokenText ?? this.spokenText,
      currentMatchedWordCount:
          currentMatchedWordCount ?? this.currentMatchedWordCount,
      currentTotalWordCount:
          currentTotalWordCount ?? this.currentTotalWordCount,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      speechAvailable: speechAvailable ?? this.speechAvailable,
      lastMismatchWord: clearMismatch
          ? null
          : (lastMismatchWord ?? this.lastMismatchWord),
      mismatchCount: mismatchCount ?? this.mismatchCount,
      ayahAccuracies: ayahAccuracies ?? this.ayahAccuracies,
    );
  }

  @override
  List<Object?> get props => [
    status,
    currentAyahIndex,
    revealedWords,
    mismatchedWords,
    completedAyahs,
    isListening,
    isPeeking,
    spokenText,
    currentMatchedWordCount,
    currentTotalWordCount,
    errorMessage,
    speechAvailable,
    lastMismatchWord,
    mismatchCount,
    ayahAccuracies,
  ];
}

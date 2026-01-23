import 'package:equatable/equatable.dart';
import '../../domain/entities/reciter.dart';

enum AudioStatus { initial, loading, ready, playing, paused, error }

class AudioState extends Equatable {
  final AudioStatus status;
  final List<Reciter> reciters;
  final Reciter? selectedReciter;
  final int? currentSurahId;
  final String? currentSurahName;
  final Duration position;
  final Duration duration;
  final String? errorMessage;
  final bool isMiniPlayerVisible;

  const AudioState({
    this.status = AudioStatus.initial,
    this.reciters = const [],
    this.selectedReciter,
    this.currentSurahId,
    this.currentSurahName,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.errorMessage,
    this.isMiniPlayerVisible = false,
  });

  AudioState copyWith({
    AudioStatus? status,
    List<Reciter>? reciters,
    Reciter? selectedReciter,
    int? currentSurahId,
    String? currentSurahName,
    Duration? position,
    Duration? duration,
    String? errorMessage,
    bool? isMiniPlayerVisible,
  }) {
    return AudioState(
      status: status ?? this.status,
      reciters: reciters ?? this.reciters,
      selectedReciter: selectedReciter ?? this.selectedReciter,
      currentSurahId: currentSurahId ?? this.currentSurahId,
      currentSurahName: currentSurahName ?? this.currentSurahName,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      errorMessage: errorMessage ?? this.errorMessage,
      isMiniPlayerVisible: isMiniPlayerVisible ?? this.isMiniPlayerVisible,
    );
  }

  @override
  List<Object?> get props => [
    status,
    reciters,
    selectedReciter,
    currentSurahId,
    currentSurahName,
    position,
    duration,
    errorMessage,
    isMiniPlayerVisible,
  ];
}

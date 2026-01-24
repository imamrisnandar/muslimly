import 'package:equatable/equatable.dart';
import '../../domain/entities/reciter.dart';

abstract class AudioEvent extends Equatable {
  const AudioEvent();

  @override
  List<Object?> get props => [];
}

class InitAudio extends AudioEvent {}

class FetchReciters extends AudioEvent {}

class SelectReciter extends AudioEvent {
  final Reciter reciter;
  const SelectReciter(this.reciter);
  @override
  List<Object?> get props => [reciter];
}

class PlaySurah extends AudioEvent {
  final int surahId;
  final String surahName;
  final int? startAyah;
  const PlaySurah({
    required this.surahId,
    required this.surahName,
    this.startAyah,
  });
  @override
  List<Object?> get props => [surahId, surahName, startAyah];
}

class PauseAudio extends AudioEvent {}

class ResumeAudio extends AudioEvent {}

class CloseAudio extends AudioEvent {} // Stop & Hide

// For internal stream updates
class UpdatePosition extends AudioEvent {
  final Duration position;
  const UpdatePosition(this.position);
  @override
  List<Object?> get props => [position];
}

class UpdateDuration extends AudioEvent {
  final Duration duration;
  const UpdateDuration(this.duration);
  @override
  List<Object?> get props => [duration];
}

class AudioComplete extends AudioEvent {}

class UpdateCurrentAyah extends AudioEvent {
  final int? ayahNumber;
  const UpdateCurrentAyah(this.ayahNumber);
  @override
  List<Object?> get props => [ayahNumber];
}

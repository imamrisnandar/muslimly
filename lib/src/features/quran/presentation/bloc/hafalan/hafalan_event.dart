import 'package:equatable/equatable.dart';

abstract class HafalanEvent extends Equatable {
  const HafalanEvent();

  @override
  List<Object?> get props => [];
}

/// Initialize speech recognition engine
class InitSpeech extends HafalanEvent {}

/// Start listening for the current ayah
class StartListening extends HafalanEvent {}

/// Stop listening manually
class StopListening extends HafalanEvent {}

/// Speech recognition result received
class SpeechResultReceived extends HafalanEvent {
  final String text;
  final bool isFinal;

  const SpeechResultReceived(this.text, {this.isFinal = false});

  @override
  List<Object?> get props => [text, isFinal];
}

/// Skip current ayah (reveal without reading)
class SkipAyah extends HafalanEvent {}

/// Toggle peek mode (show all text temporarily)
class TogglePeek extends HafalanEvent {
  final bool isPeeking;
  const TogglePeek(this.isPeeking);

  @override
  List<Object?> get props => [isPeeking];
}

/// Reset hafalan progress for current page
class ResetHafalan extends HafalanEvent {}

/// Move to specific ayah (e.g., after page change)
class SetCurrentAyah extends HafalanEvent {
  final int ayahNumber;
  const SetCurrentAyah(this.ayahNumber);

  @override
  List<Object?> get props => [ayahNumber];
}

/// Force evaluation of a mismatch due to prolonged speech engine silence
class ForceEvaluateMismatch extends HafalanEvent {}

import 'package:equatable/equatable.dart';

abstract class TranslationEvent extends Equatable {
  const TranslationEvent();

  @override
  List<Object?> get props => [];
}

class LoadAyahDetail extends TranslationEvent {
  final int surahId;
  final int ayahId;

  const LoadAyahDetail({required this.surahId, required this.ayahId});

  @override
  List<Object?> get props => [surahId, ayahId];
}

class ChangeTafsirVersion extends TranslationEvent {
  final int surahId;
  final int ayahId;
  final String tafsirId;

  const ChangeTafsirVersion({
    required this.surahId,
    required this.ayahId,
    required this.tafsirId,
  });

  @override
  List<Object?> get props => [surahId, ayahId, tafsirId];
}

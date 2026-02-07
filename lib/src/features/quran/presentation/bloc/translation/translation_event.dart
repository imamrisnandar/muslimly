import 'package:equatable/equatable.dart';

abstract class TranslationEvent extends Equatable {
  const TranslationEvent();

  @override
  List<Object?> get props => [];
}

class LoadAyahDetail extends TranslationEvent {
  final int surahId;
  final int ayahId;
  final String languageCode;

  const LoadAyahDetail({
    required this.surahId,
    required this.ayahId,
    this.languageCode = 'id',
  });

  @override
  List<Object> get props => [surahId, ayahId, languageCode];
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

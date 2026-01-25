import 'package:equatable/equatable.dart';
import '../../../domain/entities/word.dart';

abstract class TranslationState extends Equatable {
  const TranslationState();

  @override
  List<Object?> get props => [];
}

class TranslationInitial extends TranslationState {}

class TranslationLoading extends TranslationState {}

class TranslationLoaded extends TranslationState {
  final String translationIndo;
  final String translationEng;
  final String tafsirJalalayn;
  final String tafsirIbnKathir;
  final List<Word> words;

  const TranslationLoaded({
    required this.translationIndo,
    required this.translationEng,
    required this.tafsirJalalayn,
    required this.tafsirIbnKathir,
    required this.words,
  });

  @override
  List<Object?> get props => [
    translationIndo,
    translationEng,
    tafsirJalalayn,
    tafsirIbnKathir,
    words,
  ];
}

class TranslationError extends TranslationState {
  final String message;

  const TranslationError(this.message);

  @override
  List<Object?> get props => [message];
}

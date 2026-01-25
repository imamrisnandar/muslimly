import 'package:equatable/equatable.dart';

abstract class QuranEvent extends Equatable {
  const QuranEvent();

  @override
  List<Object?> get props => [];
}

class QuranFetchSurahs extends QuranEvent {}

class QuranFetchAyahs extends QuranEvent {
  final int surahId;
  final String languageCode;

  const QuranFetchAyahs(this.surahId, {this.languageCode = 'id'});

  @override
  List<Object> get props => [surahId, languageCode];
}

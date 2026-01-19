import 'package:equatable/equatable.dart';

abstract class QuranEvent extends Equatable {
  const QuranEvent();

  @override
  List<Object?> get props => [];
}

class QuranFetchSurahs extends QuranEvent {}

class QuranFetchAyahs extends QuranEvent {
  final int surahId;
  const QuranFetchAyahs(this.surahId);

  @override
  List<Object?> get props => [surahId];
}

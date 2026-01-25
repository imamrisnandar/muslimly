import 'package:equatable/equatable.dart';
import '../../domain/entities/ayah.dart';
import '../../domain/entities/surah.dart';

abstract class QuranState extends Equatable {
  const QuranState();

  @override
  List<Object?> get props => [];
}

class QuranInitial extends QuranState {}

class QuranLoading extends QuranState {}

class QuranSurahsLoaded extends QuranState {
  final List<Surah> surahs;
  const QuranSurahsLoaded(this.surahs);

  @override
  List<Object?> get props => [surahs];
}

class QuranAyahsLoaded extends QuranState {
  final List<Ayah> ayahs;
  final int surahId;
  final Map<int, String> translationMap;

  const QuranAyahsLoaded(
    this.ayahs,
    this.surahId, {
    this.translationMap = const {},
  });

  @override
  List<Object?> get props => [ayahs, surahId, translationMap];
}

class QuranError extends QuranState {
  final String message;
  const QuranError(this.message);

  @override
  List<Object?> get props => [message];
}

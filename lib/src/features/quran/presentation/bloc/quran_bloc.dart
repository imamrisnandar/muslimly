import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/get_ayahs.dart';
import '../../domain/usecases/get_surahs.dart';
import 'quran_event.dart';
import 'quran_state.dart';

@injectable
class QuranBloc extends Bloc<QuranEvent, QuranState> {
  final GetSurahs _getSurahs;
  final GetAyahs _getAyahs;

  QuranBloc(this._getSurahs, this._getAyahs) : super(QuranInitial()) {
    on<QuranFetchSurahs>((event, emit) async {
      emit(QuranLoading());
      final result = await _getSurahs();
      result.fold(
        (failure) => emit(QuranError(failure)),
        (surahs) => emit(QuranSurahsLoaded(surahs)),
      );
    });

    on<QuranFetchAyahs>((event, emit) async {
      emit(QuranLoading());
      final result = await _getAyahs(event.surahId);
      result.fold(
        (failure) => emit(QuranError(failure)),
        (ayahs) => emit(QuranAyahsLoaded(ayahs, event.surahId)),
      );
    });
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/di/di_container.dart';
import '../../domain/repositories/translation_repository.dart';
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

      // Fetch Ayahs first to get the count
      final ayahsResult = await _getAyahs(event.surahId);

      if (ayahsResult is Left) {
        emit(QuranError((ayahsResult as Left).value));
        return;
      }

      // Get ayahs list
      final ayahs = (ayahsResult as Right).value;
      final expectedCount = ayahs.length;

      // Fetch Translations with expected count for validation
      final translationResult = await getIt<TranslationRepository>()
          .getSurahTranslations(
            event.surahId,
            languageCode: event.languageCode,
            expectedAyahCount: expectedCount,
          );

      Map<int, String> transMap = {};
      if (translationResult is Right) {
        transMap = (translationResult as Right<String, Map<int, String>>).value;
      }

      emit(QuranAyahsLoaded(ayahs, event.surahId, translationMap: transMap));
    });
  }
}

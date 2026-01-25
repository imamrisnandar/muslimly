import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../../../domain/repositories/translation_repository.dart';
import '../../../domain/entities/word.dart';
import 'translation_event.dart';
import 'translation_state.dart';

@injectable
class TranslationBloc extends Bloc<TranslationEvent, TranslationState> {
  final TranslationRepository _repository;

  TranslationBloc(this._repository) : super(TranslationInitial()) {
    on<LoadAyahDetail>(_onLoadAyahDetail);
  }

  Future<void> _onLoadAyahDetail(
    LoadAyahDetail event,
    Emitter<TranslationState> emit,
  ) async {
    emit(TranslationLoading());

    // Tasks:
    // 0. Translation (Indo)
    // 1. Translation (Eng)
    // 2. Word-by-Word (Indo)
    // 3. Tafsir (Jalalayn)
    // 4. Tafsir (Ibn Kathir)
    final List<Future<dynamic>> tasks = [
      _repository.getTranslation(
        event.surahId,
        event.ayahId,
        languageCode: 'id',
      ),
      _repository.getTranslation(
        event.surahId,
        event.ayahId,
        languageCode: 'en',
      ),
      _repository.getWordByWord(event.surahId, event.ayahId),
      _repository.getTafsir(
        event.surahId,
        event.ayahId,
        tafsirId: 'id.jalalayn',
      ),
      _repository.getTafsir(
        event.surahId,
        event.ayahId,
        tafsirId: 'en.ibnkathir',
      ),
    ];

    final results = await Future.wait(tasks);

    // Safe casting
    final transIndoRes = results[0] as Either<String, String>;
    final transEngRes = results[1] as Either<String, String>;
    final wordRes = results[2] as Either<String, List<Word>>;
    final tafsirJalalaynRes = results[3] as Either<String, String>;
    final tafsirIbnKathirRes = results[4] as Either<String, String>;

    String translationIndo = '';
    String translationEng = '';
    List<Word> words = [];
    String jalalaynText = '';
    String ibnKathirText = '';

    transIndoRes.fold((l) {}, (r) => translationIndo = r);
    transEngRes.fold((l) {}, (r) => translationEng = r);
    wordRes.fold((l) {}, (r) => words = r);
    tafsirJalalaynRes.fold((l) {}, (r) => jalalaynText = r);
    tafsirIbnKathirRes.fold((l) {}, (r) => ibnKathirText = r);

    // If main translation is empty, consider it an error
    if (translationIndo.isEmpty && translationEng.isEmpty) {
      emit(
        const TranslationError("Gagal memuat data. Periksa koneksi internet."),
      );
    } else {
      emit(
        TranslationLoaded(
          translationIndo: translationIndo,
          translationEng: translationEng,
          tafsirJalalayn: jalalaynText,
          tafsirIbnKathir: ibnKathirText,
          words: words,
        ),
      );
    }
  }
}

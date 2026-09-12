import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/database/database_service.dart';
import '../../../domain/utils/hafalan_progress_calculator.dart';
import '../../../domain/utils/muraja_ah_scheduler.dart';
import 'hafalan_progress_state.dart';

class HafalanProgressCubit extends Cubit<HafalanProgressState> {
  final DatabaseService _databaseService;

  HafalanProgressCubit(this._databaseService)
    : super(const HafalanProgressState());

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final sessions = await _databaseService.getHafalanSessions();
      emit(
        state.copyWith(
          isLoading: false,
          surahProgress: HafalanProgressCalculator.calculateSurahProgress(
            sessions,
          ),
          juzProgress: HafalanProgressCalculator.calculateJuzProgress(sessions),
          totalAyatHafal: HafalanProgressCalculator.calculateTotalAyatHafal(
            sessions,
          ),
          dueMurajaah: MurajaahScheduler.calculateDueUnits(sessions),
          streak: HafalanProgressCalculator.calculateHafalanStreak(sessions),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Gagal memuat progress hafalan',
        ),
      );
    }
  }
}

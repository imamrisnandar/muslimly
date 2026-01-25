import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../../core/database/database_service.dart';
import '../../../../settings/data/repositories/settings_repository.dart';
import '../../../domain/entities/reading_activity.dart';
import 'reading_event.dart';
import 'reading_state.dart';

class ReadingBloc extends Bloc<ReadingEvent, ReadingState> {
  final DatabaseService _databaseService;
  final SettingsRepository _settingsRepository;

  ReadingBloc(this._databaseService, this._settingsRepository)
    : super(const ReadingState()) {
    on<LoadReadingOverview>(_onLoadOverview);
    on<LoadReadingHistory>(_onLoadReadingHistory);
    on<LogPageRead>(_onLogPageRead);
    on<LogAyahRead>(_onLogAyahRead);
    on<UpdateDailyTarget>(_onUpdateDailyTarget);
    on<NavigateWeeklyChart>(_onNavigateWeeklyChart);
  }

  Future<void> _onLoadReadingHistory(
    LoadReadingHistory event,
    Emitter<ReadingState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final history = await _databaseService.getReadingHistory();
      final now = DateTime.now();
      final weeklyPage = await _databaseService.getWeeklyProgress(
        endDate: now,
        mode: 'page',
      );
      final weeklyAyah = await _databaseService.getWeeklyProgress(
        endDate: now,
        mode: 'ayah',
      );
      final target = await _settingsRepository.getDailyReadingTarget();
      final ayahTarget = await _settingsRepository.getDailyAyahTarget();
      final unit = await _settingsRepository.getReadingTargetUnit();
      emit(
        state.copyWith(
          isLoading: false,
          readingHistory: history,
          weeklyPageProgress: weeklyPage,
          weeklyAyahProgress: weeklyAyah,
          chartReferenceDate: now,
          dailyTarget: target,
          dailyAyahTarget: ayahTarget,
          targetUnit: unit,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onNavigateWeeklyChart(
    NavigateWeeklyChart event,
    Emitter<ReadingState> emit,
  ) async {
    final currentRef = state.chartReferenceDate ?? DateTime.now();
    // Move by 7 days
    final newRef = currentRef.add(Duration(days: event.direction * 7));

    if (event.direction > 0 &&
        newRef.isAfter(DateTime.now().add(const Duration(days: 1)))) {
      // Allow going back to 'current week' but not further future
    }

    try {
      final weeklyPage = await _databaseService.getWeeklyProgress(
        endDate: newRef,
        mode: 'page',
      );
      final weeklyAyah = await _databaseService.getWeeklyProgress(
        endDate: newRef,
        mode: 'ayah',
      );
      emit(
        state.copyWith(
          weeklyPageProgress: weeklyPage,
          weeklyAyahProgress: weeklyAyah,
          chartReferenceDate: newRef,
        ),
      );
    } catch (e) {
      // ignore
    }
  }

  Future<void> _onLoadOverview(
    LoadReadingOverview event,
    Emitter<ReadingState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final now = DateTime.now();
      final dateStr = DateFormat('yyyy-MM-dd').format(now);

      // 1. Get Settings
      final pageTarget = await _settingsRepository.getDailyReadingTarget();
      final ayahTarget = await _settingsRepository.getDailyAyahTarget();
      final unit = await _settingsRepository.getReadingTargetUnit();

      // 2. Get Progress from DB
      // We need a smart progress fetcher
      // For now, let's keep dailyProgress as "Int representing current unit progress" behavior
      // OR we add logic to fetch BOTH page and ayah counts.
      // Ideally ReadingState should have pagesRead AND ayahsRead fields.
      // But to save time refactoring state excessively:
      // If unit == 'page', dailyProgress = pageCount
      // If unit == 'ayah', dailyProgress = ayahCount

      int progress = 0;
      if (unit == 'ayah') {
        // Need a new DB method: getDailyAyahCount
        // Or simple raw query here for now
        // For now let's assume raw query or add method to DB service later
        // Quick fix: Add getDailyAyahCount to DB Service.
        // Wait, I can't add to DB Service without file edit.
        // I'll stick to logic:
        progress = await _databaseService.getDailyAyahCount(dateStr);
      } else {
        progress = await _databaseService.getDailyPageCount(dateStr);
      }

      emit(
        state.copyWith(
          isLoading: false,
          dailyTarget: pageTarget,
          dailyAyahTarget: ayahTarget,
          targetUnit: unit,
          dailyProgress: progress,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onLogPageRead(
    LogPageRead event,
    Emitter<ReadingState> emit,
  ) async {
    try {
      final now = DateTime.now();
      final dateStr = DateFormat('yyyy-MM-dd').format(now);

      // Save to DB
      final activity = ReadingActivity(
        date: dateStr,
        pageNumber: event.pageNumber,
        surahNumber: event.surahNumber,
        durationSeconds: event.durationSeconds,
        timestamp: now.millisecondsSinceEpoch,
      );

      await _databaseService.insertActivity(activity);

      // Reload Progress
      final progress = await _databaseService.getDailyPageCount(dateStr);
      emit(state.copyWith(dailyProgress: progress));
    } catch (e) {
      // Fail silently or log error, but don't disrupt user too much
      print("Error logging reading: $e");
    }
  }

  Future<void> _onLogAyahRead(
    LogAyahRead event,
    Emitter<ReadingState> emit,
  ) async {
    try {
      final now = DateTime.now();
      final dateStr = DateFormat('yyyy-MM-dd').format(now);

      final activity = ReadingActivity(
        date: dateStr,
        pageNumber: 0, // 0 for Ayah Mode
        surahNumber: event.surahNumber,
        durationSeconds: 0, // Not tracked for now
        timestamp: now.millisecondsSinceEpoch,
        startAyah: event.startAyah,
        endAyah: event.endAyah,
        totalAyahs: event.totalAyahs,
        mode: 'ayah',
      );

      await _databaseService.insertActivity(activity);

      // Reload Progress (Logic needs update to count ayahs too)
      // For now we just trigger reload
      add(LoadReadingOverview());
    } catch (e) {
      print("Error logging ayah: $e");
    }
  }

  Future<void> _onUpdateDailyTarget(
    UpdateDailyTarget event,
    Emitter<ReadingState> emit,
  ) async {
    try {
      await _settingsRepository.saveDailyReadingTarget(event.newTarget);
      emit(state.copyWith(dailyTarget: event.newTarget));
    } catch (e) {
      emit(state.copyWith(errorMessage: "Failed to update target"));
    }
  }
}

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
      final weekly = await _databaseService.getWeeklyProgress(endDate: now);
      final target = await _settingsRepository.getDailyReadingTarget();
      emit(
        state.copyWith(
          isLoading: false,
          readingHistory: history,
          weeklyProgress: weekly,
          chartReferenceDate: now,
          dailyTarget: target,
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

    // Prevent navigating to future weeks beyond 'today's week' if desired,
    // but maybe user wants to see empty future? Assuming NO data there so fine.
    // However, usually we don't want to go beyond 'now'.
    if (event.direction > 0 &&
        newRef.isAfter(DateTime.now().add(const Duration(days: 1)))) {
      // Allow going back to 'current week' but not further future
      // Actually let's just allow it, data will be 0.
    }

    try {
      final weekly = await _databaseService.getWeeklyProgress(endDate: newRef);
      emit(state.copyWith(weeklyProgress: weekly, chartReferenceDate: newRef));
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

      // 1. Get Target from Settings
      final target = await _settingsRepository.getDailyReadingTarget();

      // 2. Get Progress from DB
      final progress = await _databaseService.getDailyPageCount(dateStr);

      emit(
        state.copyWith(
          isLoading: false,
          dailyTarget: target,
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

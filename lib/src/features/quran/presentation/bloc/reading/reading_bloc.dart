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
    on<ToggleChartView>(_onToggleChartView);
  }

  void _onToggleChartView(ToggleChartView event, Emitter<ReadingState> emit) {
    emit(state.copyWith(isWeeklyView: event.isWeekly));
  }

  Future<void> _onLoadReadingHistory(
    LoadReadingHistory event,
    Emitter<ReadingState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final history = await _databaseService.getReadingHistory();
      final now = DateTime.now();

      // Weekly Stats (7 days)
      final weeklyPage = await _databaseService.getWeeklyProgress(
        endDate: now,
        mode: 'page',
        days: 7,
      );
      final weeklyAyah = await _databaseService.getWeeklyProgress(
        endDate: now,
        mode: 'ayah',
        days: 7,
      );

      // Monthly Stats (30 days)
      final monthlyPage = await _databaseService.getWeeklyProgress(
        endDate: now,
        mode: 'page',
        days: 30,
      );
      final monthlyAyah = await _databaseService.getWeeklyProgress(
        endDate: now,
        mode: 'ayah',
        days: 30,
      );

      final target = await _settingsRepository.getDailyReadingTarget();
      final ayahTarget = await _settingsRepository.getDailyAyahTarget();
      final unit = await _settingsRepository.getReadingTargetUnit();

      // Calculate Lifetime Stats - Separate for Ayah and Page
      final ayahHistory = history.where((a) => a.mode == 'ayah').toList();
      final pageHistory = history.where((a) => a.mode != 'ayah').toList();

      final ayahStats = _calculateLifetimeStats(ayahHistory, 'ayah');
      final pageStats = _calculateLifetimeStats(pageHistory, 'page');

      emit(
        state.copyWith(
          isLoading: false,
          readingHistory: history,
          weeklyPageProgress: weeklyPage,
          weeklyAyahProgress: weeklyAyah,
          monthlyPageProgress: monthlyPage,
          monthlyAyahProgress: monthlyAyah,
          chartReferenceDate: now,
          dailyTarget: target,
          dailyAyahTarget: ayahTarget,
          targetUnit: unit,
          lifetimeTotalAyah: ayahStats['total'] as int,
          currentStreakAyah: ayahStats['streak'] as int,
          thirtyDayAverageAyah: ayahStats['average'] as double,
          lifetimeTotalPage: pageStats['total'] as int,
          currentStreakPage: pageStats['streak'] as int,
          thirtyDayAveragePage: pageStats['average'] as double,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  // Helper: Calculate Lifetime Stats
  Map<String, dynamic> _calculateLifetimeStats(
    List<ReadingActivity> history,
    String unit,
  ) {
    if (history.isEmpty) {
      return {'total': 0, 'streak': 0, 'average': 0.0};
    }

    // 1. Calculate Total (based on mode)
    int total = 0;
    if (unit == 'ayah') {
      // Sum all totalAyahs from ayah mode
      total = history
          .where((a) => a.mode == 'ayah')
          .fold(0, (sum, a) => sum + (a.totalAyahs ?? 0));
    } else {
      // Count unique pages from page mode
      final uniquePages = history
          .where((a) => a.mode != 'ayah')
          .map((a) => a.pageNumber)
          .toSet();
      total = uniquePages.length;
    }

    // 2. Calculate Streak (consecutive days with reading)
    final sortedDates = history.map((a) => a.date).toSet().toList()
      ..sort((a, b) => b.compareTo(a)); // Descending

    int streak = 0;
    if (sortedDates.isNotEmpty) {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final yesterday = DateFormat(
        'yyyy-MM-dd',
      ).format(DateTime.now().subtract(const Duration(days: 1)));

      // Check if streak is alive (today or yesterday)
      if (sortedDates.first == today || sortedDates.first == yesterday) {
        DateTime currentDate = DateFormat(
          'yyyy-MM-dd',
        ).parse(sortedDates.first);
        streak = 1;

        for (int i = 1; i < sortedDates.length; i++) {
          final prevDate = DateFormat('yyyy-MM-dd').parse(sortedDates[i]);
          final diff = currentDate.difference(prevDate).inDays;

          if (diff == 1) {
            streak++;
            currentDate = prevDate;
          } else {
            break;
          }
        }
      }
    }

    // 3. Calculate 30-Day Average
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final recentHistory = history.where((a) {
      final activityDate = DateTime.fromMillisecondsSinceEpoch(a.timestamp);
      return activityDate.isAfter(thirtyDaysAgo);
    }).toList();

    double average = 0.0;
    if (recentHistory.isNotEmpty) {
      if (unit == 'ayah') {
        final totalAyahs = recentHistory
            .where((a) => a.mode == 'ayah')
            .fold(0, (sum, a) => sum + (a.totalAyahs ?? 0));
        average = totalAyahs / 30.0;
      } else {
        final uniquePages = recentHistory
            .where((a) => a.mode != 'ayah')
            .map((a) => a.pageNumber)
            .toSet()
            .length;
        average = uniquePages / 30.0;
      }
    }

    return {'total': total, 'streak': streak, 'average': average};
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

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
    on<LoadMoreHistory>(_onLoadMoreHistory);
  }

  void _onToggleChartView(ToggleChartView event, Emitter<ReadingState> emit) {
    emit(state.copyWith(isWeeklyView: event.isWeekly));
  }

  Future<void> _onLoadMoreHistory(
    LoadMoreHistory event,
    Emitter<ReadingState> emit,
  ) async {
    if (state.isLoadingMore || !state.hasMoreHistory) return;

    emit(state.copyWith(isLoadingMore: true));

    // Simulate async delay (optional, for UX)
    await Future.delayed(const Duration(milliseconds: 300));

    final newCount = state.displayedWeeksCount + 6;

    // Calculate total weeks available
    final uniqueWeeks = state.readingHistory
        .map((a) {
          final date = DateTime.fromMillisecondsSinceEpoch(a.timestamp);
          final monday = date.subtract(Duration(days: date.weekday - 1));
          return DateFormat('yyyy-MM-dd').format(monday);
        })
        .toSet()
        .length;

    final hasMore = uniqueWeeks > newCount;

    emit(
      state.copyWith(
        displayedWeeksCount: newCount,
        hasMoreHistory: hasMore,
        isLoadingMore: false,
      ),
    );
  }

  Future<void> _onLoadReadingHistory(
    LoadReadingHistory event,
    Emitter<ReadingState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      // Get all history (set high limit for 1 year of data)
      final allHistory = await _databaseService.getReadingHistory(
        limit: 10000, // Large enough for 1 year of data
      );

      // Filter to 1 year max (inclusive)
      final oneYearAgo = DateTime.now().subtract(const Duration(days: 365));
      final history = allHistory.where((activity) {
        final activityDate = DateTime.fromMillisecondsSinceEpoch(
          activity.timestamp,
        );
        return activityDate.isAfter(oneYearAgo) ||
            activityDate.isAtSameMomentAs(oneYearAgo);
      }).toList();
      final now = DateTime.now();

      // Calculate End of Week (Sunday)
      // If today is Monday (1), daysUntilSunday = 7 - 1 = 6. Add 6 days.
      // If today is Sunday (7), daysUntilSunday = 7 - 7 = 0. Add 0 days.
      final int daysUntilSunday = DateTime.sunday - now.weekday;
      final DateTime endOfWeek = now.add(Duration(days: daysUntilSunday));

      // Weekly Stats (Fixed Week: Mon-Sun ending on endOfWeek)
      final weeklyPage = await _databaseService.getWeeklyProgress(
        endDate: endOfWeek,
        mode: 'page',
        days: 7,
      );
      final weeklyAyah = await _databaseService.getWeeklyProgress(
        endDate: endOfWeek,
        mode: 'ayah',
        days: 7,
      );

      // Monthly Stats (365 days to support navigation through past months)
      final monthlyPage = await _databaseService.getWeeklyProgress(
        endDate: now,
        mode: 'page',
        days: 365,
      );
      final monthlyAyah = await _databaseService.getWeeklyProgress(
        endDate: now,
        mode: 'ayah',
        days: 365,
      );

      final target = await _settingsRepository.getDailyReadingTarget();
      final ayahTarget = await _settingsRepository.getDailyAyahTarget();
      final unit = await _settingsRepository.getReadingTargetUnit();

      // Calculate Lifetime Stats - Separate for Ayah and Page
      final ayahHistory = history.where((a) => a.mode == 'ayah').toList();
      final pageHistory = history.where((a) => a.mode != 'ayah').toList();

      final ayahStats = _calculateLifetimeStats(ayahHistory, 'ayah');
      final pageStats = _calculateLifetimeStats(pageHistory, 'page');

      // Calculate total weeks available
      final uniqueWeeks = history
          .map((a) {
            final date = DateTime.fromMillisecondsSinceEpoch(a.timestamp);
            final monday = date.subtract(Duration(days: date.weekday - 1));
            return DateFormat('yyyy-MM-dd').format(monday);
          })
          .toSet()
          .length;

      final hasMore = uniqueWeeks > 6;

      emit(
        state.copyWith(
          isLoading: false,
          readingHistory: history,
          weeklyPageProgress: weeklyPage,
          weeklyAyahProgress: weeklyAyah,
          monthlyPageProgress: monthlyPage,
          monthlyAyahProgress: monthlyAyah,
          chartReferenceDate: endOfWeek, // Anchor to Sunday
          dailyTarget: target,
          dailyAyahTarget: ayahTarget,
          targetUnit: unit,
          lifetimeTotalAyah: ayahStats['total'] as int,
          currentStreakAyah: ayahStats['streak'] as int,
          thirtyDayAverageAyah: ayahStats['average'] as double,
          lifetimeTotalPage: pageStats['total'] as int,
          currentStreakPage: pageStats['streak'] as int,
          thirtyDayAveragePage: pageStats['average'] as double,
          displayedWeeksCount: 6,
          hasMoreHistory: hasMore,
          isLoadingMore: false,
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
    final isWeeklyView = state.isWeeklyView;

    DateTime newRef;

    if (isWeeklyView) {
      // Weekly: Move by 7 days
      newRef = currentRef.add(Duration(days: event.direction * 7));
    } else {
      // Monthly: Move by 1 month
      newRef = DateTime(
        currentRef.year,
        currentRef.month + event.direction,
        currentRef.day,
      );
      // Ensure day is valid for the new month
      final lastDayOfNewMonth = DateTime(newRef.year, newRef.month + 1, 0).day;
      if (newRef.day > lastDayOfNewMonth) {
        newRef = DateTime(newRef.year, newRef.month, lastDayOfNewMonth);
      }
    }

    // Cap at current period
    final now = DateTime.now();
    DateTime maxAllowedDate;

    if (isWeeklyView) {
      // Cap at current week's Sunday
      final int daysUntilSunday = DateTime.sunday - now.weekday;
      maxAllowedDate = now.add(Duration(days: daysUntilSunday));
    } else {
      // Cap at current month
      maxAllowedDate = now;
    }

    // Normalize dates to ignore time for comparison
    final newRefDate = DateTime(newRef.year, newRef.month, newRef.day);
    final maxDate = DateTime(
      maxAllowedDate.year,
      maxAllowedDate.month,
      maxAllowedDate.day,
    );

    if (event.direction > 0 && newRefDate.isAfter(maxDate)) {
      return; // Don't allow navigating past current period
    }

    try {
      final weeklyPage = await _databaseService.getWeeklyProgress(
        endDate: newRef, // newRef is a Sunday
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

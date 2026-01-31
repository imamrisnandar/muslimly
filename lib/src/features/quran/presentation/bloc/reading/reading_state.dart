import 'package:equatable/equatable.dart';
import '../../../domain/entities/reading_activity.dart';

class ReadingState extends Equatable {
  final bool isLoading;
  final int dailyProgress; // Pages read today (unique)
  final int dailyTarget; // Target (e.g., 4)
  final int dailyAyahTarget; // e.g. 50
  final String targetUnit; // 'page' or 'ayah'
  final List<ReadingActivity> readingHistory;
  final Map<String, int> weeklyPageProgress;
  final Map<String, int> weeklyAyahProgress;
  final Map<String, int> monthlyPageProgress;
  final Map<String, int> monthlyAyahProgress;
  final bool isWeeklyView;
  final DateTime? chartReferenceDate; // The end date of the visible chart week
  final String? errorMessage;

  // Lifetime Stats - Ayah Mode
  final int lifetimeTotalAyah;
  final int currentStreakAyah;
  final double thirtyDayAverageAyah;

  // Lifetime Stats - Page Mode
  final int lifetimeTotalPage;
  final int currentStreakPage;
  final double thirtyDayAveragePage;

  const ReadingState({
    this.isLoading = false,
    this.dailyProgress = 0,
    this.dailyTarget = 4,
    this.dailyAyahTarget = 50,
    this.targetUnit = 'page',
    this.readingHistory = const [],
    this.weeklyPageProgress = const {},
    this.weeklyAyahProgress = const {},
    this.monthlyPageProgress = const {},
    this.monthlyAyahProgress = const {},
    this.isWeeklyView = true,
    this.chartReferenceDate,
    this.errorMessage,
    this.lifetimeTotalAyah = 0,
    this.currentStreakAyah = 0,
    this.thirtyDayAverageAyah = 0.0,
    this.lifetimeTotalPage = 0,
    this.currentStreakPage = 0,
    this.thirtyDayAveragePage = 0.0,
  });

  ReadingState copyWith({
    bool? isLoading,
    int? dailyProgress,
    int? dailyTarget,
    int? dailyAyahTarget,
    String? targetUnit,
    List<ReadingActivity>? readingHistory,
    Map<String, int>? weeklyPageProgress,
    Map<String, int>? weeklyAyahProgress,
    Map<String, int>? monthlyPageProgress,
    Map<String, int>? monthlyAyahProgress,
    bool? isWeeklyView,
    DateTime? chartReferenceDate,
    String? errorMessage,
    int? lifetimeTotalAyah,
    int? currentStreakAyah,
    double? thirtyDayAverageAyah,
    int? lifetimeTotalPage,
    int? currentStreakPage,
    double? thirtyDayAveragePage,
  }) {
    return ReadingState(
      isLoading: isLoading ?? this.isLoading,
      dailyProgress: dailyProgress ?? this.dailyProgress,
      dailyTarget: dailyTarget ?? this.dailyTarget,
      dailyAyahTarget: dailyAyahTarget ?? this.dailyAyahTarget,
      targetUnit: targetUnit ?? this.targetUnit,
      readingHistory: readingHistory ?? this.readingHistory,
      weeklyPageProgress: weeklyPageProgress ?? this.weeklyPageProgress,
      weeklyAyahProgress: weeklyAyahProgress ?? this.weeklyAyahProgress,
      monthlyPageProgress: monthlyPageProgress ?? this.monthlyPageProgress,
      monthlyAyahProgress: monthlyAyahProgress ?? this.monthlyAyahProgress,
      isWeeklyView: isWeeklyView ?? this.isWeeklyView,
      chartReferenceDate: chartReferenceDate ?? this.chartReferenceDate,
      errorMessage: errorMessage,
      lifetimeTotalAyah: lifetimeTotalAyah ?? this.lifetimeTotalAyah,
      currentStreakAyah: currentStreakAyah ?? this.currentStreakAyah,
      thirtyDayAverageAyah: thirtyDayAverageAyah ?? this.thirtyDayAverageAyah,
      lifetimeTotalPage: lifetimeTotalPage ?? this.lifetimeTotalPage,
      currentStreakPage: currentStreakPage ?? this.currentStreakPage,
      thirtyDayAveragePage: thirtyDayAveragePage ?? this.thirtyDayAveragePage,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    dailyProgress,
    dailyTarget,
    dailyAyahTarget,
    targetUnit,
    readingHistory,
    weeklyPageProgress,
    weeklyAyahProgress,
    monthlyPageProgress,
    monthlyAyahProgress,
    isWeeklyView,
    chartReferenceDate,
    errorMessage,
    lifetimeTotalAyah,
    currentStreakAyah,
    thirtyDayAverageAyah,
    lifetimeTotalPage,
    currentStreakPage,
    thirtyDayAveragePage,
  ];
}

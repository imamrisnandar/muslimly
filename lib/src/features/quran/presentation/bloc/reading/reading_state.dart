import 'package:equatable/equatable.dart';
import '../../../domain/entities/reading_activity.dart';

class ReadingState extends Equatable {
  final bool isLoading;
  final int dailyProgress; // Pages read today (unique)
  final int dailyTarget; // Target (e.g., 4)
  final List<ReadingActivity> readingHistory;
  final Map<String, int> weeklyProgress;
  final DateTime? chartReferenceDate; // The end date of the visible chart week
  final String? errorMessage;

  const ReadingState({
    this.isLoading = false,
    this.dailyProgress = 0,
    this.dailyTarget = 4,
    this.readingHistory = const [],
    this.weeklyProgress = const {},
    this.chartReferenceDate,
    this.errorMessage,
  });

  ReadingState copyWith({
    bool? isLoading,
    int? dailyProgress,
    int? dailyTarget,
    List<ReadingActivity>? readingHistory,
    Map<String, int>? weeklyProgress,
    DateTime? chartReferenceDate,
    String? errorMessage,
  }) {
    return ReadingState(
      isLoading: isLoading ?? this.isLoading,
      dailyProgress: dailyProgress ?? this.dailyProgress,
      dailyTarget: dailyTarget ?? this.dailyTarget,
      readingHistory: readingHistory ?? this.readingHistory,
      weeklyProgress: weeklyProgress ?? this.weeklyProgress,
      chartReferenceDate: chartReferenceDate ?? this.chartReferenceDate,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    dailyProgress,
    dailyTarget,
    readingHistory,
    weeklyProgress,
    chartReferenceDate,
    errorMessage,
  ];
}

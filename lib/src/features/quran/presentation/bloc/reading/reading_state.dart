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
  final DateTime? chartReferenceDate; // The end date of the visible chart week
  final String? errorMessage;

  const ReadingState({
    this.isLoading = false,
    this.dailyProgress = 0,
    this.dailyTarget = 4,
    this.dailyAyahTarget = 50,
    this.targetUnit = 'page',
    this.readingHistory = const [],
    this.weeklyPageProgress = const {},
    this.weeklyAyahProgress = const {},
    this.chartReferenceDate,
    this.errorMessage,
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
    DateTime? chartReferenceDate,
    String? errorMessage,
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
      chartReferenceDate: chartReferenceDate ?? this.chartReferenceDate,
      errorMessage: errorMessage,
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
    chartReferenceDate,
    errorMessage,
  ];
}

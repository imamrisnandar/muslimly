import 'package:equatable/equatable.dart';

import '../../../domain/utils/hafalan_progress_calculator.dart';
import '../../../domain/utils/muraja_ah_scheduler.dart';

class HafalanProgressState extends Equatable {
  final bool isLoading;
  final List<SurahProgress> surahProgress;
  final List<JuzProgress> juzProgress;
  final int totalAyatHafal;
  final List<MurajaahUnit> dueMurajaah;
  final int streak;
  final String? errorMessage;

  const HafalanProgressState({
    this.isLoading = false,
    this.surahProgress = const [],
    this.juzProgress = const [],
    this.totalAyatHafal = 0,
    this.dueMurajaah = const [],
    this.streak = 0,
    this.errorMessage,
  });

  HafalanProgressState copyWith({
    bool? isLoading,
    List<SurahProgress>? surahProgress,
    List<JuzProgress>? juzProgress,
    int? totalAyatHafal,
    List<MurajaahUnit>? dueMurajaah,
    int? streak,
    String? errorMessage,
    bool clearError = false,
  }) {
    return HafalanProgressState(
      isLoading: isLoading ?? this.isLoading,
      surahProgress: surahProgress ?? this.surahProgress,
      juzProgress: juzProgress ?? this.juzProgress,
      totalAyatHafal: totalAyatHafal ?? this.totalAyatHafal,
      dueMurajaah: dueMurajaah ?? this.dueMurajaah,
      streak: streak ?? this.streak,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    surahProgress,
    juzProgress,
    totalAyatHafal,
    dueMurajaah,
    streak,
    errorMessage,
  ];
}

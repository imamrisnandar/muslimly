import 'package:equatable/equatable.dart';

abstract class ReadingEvent extends Equatable {
  const ReadingEvent();

  @override
  List<Object?> get props => [];
}

class LoadReadingOverview extends ReadingEvent {}

class LoadReadingHistory extends ReadingEvent {}

class LogPageRead extends ReadingEvent {
  final int pageNumber;
  final int durationSeconds;
  final int? surahNumber;

  const LogPageRead({
    required this.pageNumber,
    required this.durationSeconds,
    this.surahNumber,
  });

  @override
  List<Object?> get props => [pageNumber, durationSeconds, surahNumber];
}

class UpdateDailyTarget extends ReadingEvent {
  final int newTarget;

  const UpdateDailyTarget(this.newTarget);

  @override
  List<Object?> get props => [newTarget];
}

class NavigateWeeklyChart extends ReadingEvent {
  final int direction; // -1 for previous, 1 for next

  const NavigateWeeklyChart(this.direction);

  @override
  List<Object?> get props => [direction];
}

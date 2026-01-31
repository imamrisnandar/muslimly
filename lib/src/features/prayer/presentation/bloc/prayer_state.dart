import 'package:equatable/equatable.dart';
import '../../domain/entities/city.dart';
import '../../domain/entities/prayer_time.dart';

enum PrayerStatus { initial, loading, success, failure }

class PrayerState extends Equatable {
  final PrayerStatus status;
  final PrayerTime? prayerTime;
  final City currentCity;
  final String? errorMessage;

  final bool isSearching;
  final List<City> searchResults;
  final Map<String, String> notificationSettings;
  final DateTime? testAdzanTargetTime;

  const PrayerState({
    this.status = PrayerStatus.initial,
    this.prayerTime,
    this.currentCity = const City(
      id: 'jakarta',
      name: 'Jakarta',
      latitude: -6.2088,
      longitude: 106.8456,
    ),
    this.errorMessage,
    this.isSearching = false,
    this.searchResults = const [],
    this.notificationSettings = const {},
    this.testAdzanTargetTime,
  });

  PrayerState copyWith({
    PrayerStatus? status,
    PrayerTime? prayerTime,
    City? currentCity,
    String? errorMessage,
    bool? isSearching,
    List<City>? searchResults,
    Map<String, String>? notificationSettings,
    DateTime? testAdzanTargetTime,
  }) {
    return PrayerState(
      status: status ?? this.status,
      prayerTime: prayerTime ?? this.prayerTime,
      currentCity: currentCity ?? this.currentCity,
      errorMessage: errorMessage ?? this.errorMessage,
      isSearching: isSearching ?? this.isSearching,
      searchResults: searchResults ?? this.searchResults,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      testAdzanTargetTime: testAdzanTargetTime ?? this.testAdzanTargetTime,
    );
  }

  @override
  List<Object?> get props => [
    status,
    prayerTime,
    currentCity,
    errorMessage,
    isSearching,
    searchResults,
    notificationSettings,
    testAdzanTargetTime,
  ];
}

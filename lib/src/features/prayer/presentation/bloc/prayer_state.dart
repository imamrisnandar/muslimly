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

  const PrayerState({
    this.status = PrayerStatus.initial,
    this.prayerTime,
    this.currentCity = const City(id: '1301', name: 'JAKARTA'),
    this.errorMessage,
    this.isSearching = false,
    this.searchResults = const [],
    this.notificationSettings = const {},
  });

  PrayerState copyWith({
    PrayerStatus? status,
    PrayerTime? prayerTime,
    City? currentCity,
    String? errorMessage,
    bool? isSearching,
    List<City>? searchResults,
    Map<String, String>? notificationSettings,
  }) {
    return PrayerState(
      status: status ?? this.status,
      prayerTime: prayerTime ?? this.prayerTime,
      currentCity: currentCity ?? this.currentCity,
      errorMessage: errorMessage ?? this.errorMessage,
      isSearching: isSearching ?? this.isSearching,
      searchResults: searchResults ?? this.searchResults,
      notificationSettings: notificationSettings ?? this.notificationSettings,
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
  ];
}

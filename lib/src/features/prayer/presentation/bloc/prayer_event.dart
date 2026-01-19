import 'package:equatable/equatable.dart';
import '../../domain/entities/city.dart';

abstract class PrayerEvent extends Equatable {
  const PrayerEvent();

  @override
  List<Object> get props => [];
}

class FetchPrayerTime extends PrayerEvent {
  final String cityId;
  final DateTime date;

  const FetchPrayerTime({required this.cityId, required this.date});

  @override
  List<Object> get props => [cityId, date];
}

class SearchCityEvent extends PrayerEvent {
  final String keyword;

  const SearchCityEvent(this.keyword);

  @override
  List<Object> get props => [keyword];
}

class SelectCity extends PrayerEvent {
  final City city;

  const SelectCity(this.city);

  @override
  List<Object> get props => [city];
}

class FetchPrayerTimeByLocation extends PrayerEvent {}

class LoadNotificationSettings extends PrayerEvent {}

class UpdateNotificationSetting extends PrayerEvent {
  final String prayerName;
  final String soundType; // 'adhan', 'beep', 'silent'

  const UpdateNotificationSetting({
    required this.prayerName,
    required this.soundType,
  });

  @override
  List<Object> get props => [prayerName, soundType];
}

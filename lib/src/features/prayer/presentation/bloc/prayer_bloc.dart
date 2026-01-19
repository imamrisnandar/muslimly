import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/location_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../domain/entities/city.dart';
import '../../domain/entities/prayer_time.dart';
import '../../domain/usecases/get_prayer_time.dart';
import '../../domain/usecases/search_city.dart';
import '../../../settings/data/repositories/settings_repository.dart';
import 'prayer_event.dart';
import 'prayer_state.dart';

@injectable
class PrayerBloc extends Bloc<PrayerEvent, PrayerState> {
  final GetPrayerTime _getPrayerTime;
  final SearchCity _searchCity;
  final LocationService _locationService;
  final NotificationService _notificationService;
  final SettingsRepository _settingsRepository;

  PrayerBloc(
    this._getPrayerTime,
    this._searchCity,
    this._locationService,
    this._notificationService,
    this._settingsRepository,
  ) : super(const PrayerState()) {
    on<FetchPrayerTime>((event, emit) async {
      emit(state.copyWith(status: PrayerStatus.loading));

      // Request permissions once on first fetch (or handle better in a dedicated Init event)
      await _notificationService.requestPermissions();
      // Load Notification Settings
      final settings = await _settingsRepository
          .getPrayerNotificationSettings();
      emit(state.copyWith(notificationSettings: settings));

      final result = await _getPrayerTime(
        cityId: event.cityId,
        date: event.date,
      );

      result.fold(
        (failure) => emit(
          state.copyWith(status: PrayerStatus.failure, errorMessage: failure),
        ),
        (prayerTime) {
          emit(
            state.copyWith(
              status: PrayerStatus.success,
              prayerTime: prayerTime,
            ),
          );

          // Schedule Notifications
          _scheduleNotifications(prayerTime);
        },
      );
    });

    on<LoadNotificationSettings>((event, emit) async {
      final settings = await _settingsRepository
          .getPrayerNotificationSettings();
      emit(state.copyWith(notificationSettings: settings));
    });

    on<UpdateNotificationSetting>((event, emit) async {
      await _settingsRepository.savePrayerNotificationSetting(
        event.prayerName,
        event.soundType,
      );
      final settings = Map<String, String>.from(state.notificationSettings);
      settings[event.prayerName] = event.soundType;
      emit(state.copyWith(notificationSettings: settings));

      // Reschedule if we have prayer time
      if (state.prayerTime != null) {
        _scheduleNotifications(state.prayerTime!);
      }
    });

    on<SearchCityEvent>((event, emit) async {
      emit(state.copyWith(isSearching: true));
      final result = await _searchCity(event.keyword);
      result.fold(
        (failure) => emit(
          state.copyWith(
            isSearching: false,
            errorMessage: failure, // Or separate searchError
          ),
        ),
        (cities) =>
            emit(state.copyWith(isSearching: false, searchResults: cities)),
      );
    });

    on<SelectCity>((event, emit) {
      // Update city and reset search results/flag if needed
      emit(
        state.copyWith(
          currentCity: event.city,
          searchResults: [], // Clear results after selection?
          isSearching: false,
        ),
      );
      // Trigger fetch
      add(FetchPrayerTime(cityId: event.city.id, date: DateTime.now()));
    });

    on<FetchPrayerTimeByLocation>((event, emit) async {
      emit(state.copyWith(status: PrayerStatus.loading));

      final position = await _locationService.getCurrentPosition();
      if (position == null) {
        add(FetchPrayerTime(cityId: '1301', date: DateTime.now()));
        return;
      }

      final cityName = await _locationService.getCityFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (cityName == null) {
        add(FetchPrayerTime(cityId: '1301', date: DateTime.now()));
        return;
      }

      // Search for the city ID
      final searchResult = await _searchCity(cityName);
      searchResult.fold(
        (failure) => add(
          FetchPrayerTime(cityId: '1301', date: DateTime.now()),
        ), // Fallback
        (cities) {
          if (cities.isNotEmpty) {
            final city = cities.first; // Naive approach
            emit(state.copyWith(currentCity: city));
            add(FetchPrayerTime(cityId: city.id, date: DateTime.now()));
          } else {
            add(FetchPrayerTime(cityId: '1301', date: DateTime.now()));
          }
        },
      );
    });
  }

  void _scheduleNotifications(PrayerTime prayerTime) {
    // Helper to parse time string "HH:mm" to today's DateTime
    DateTime parseTime(String timeStr) {
      final now = DateTime.now();
      final parts = timeStr.split(':');
      return DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
    }

    final prayers = {
      'Imsak': prayerTime.imsak,
      'Subuh': prayerTime.subuh,
      'Terbit': prayerTime.terbit,
      'Dzuhur': prayerTime.dzuhur,
      'Ashar': prayerTime.ashar,
      'Maghrib': prayerTime.maghrib,
      'Isya': prayerTime.isya,
      // TEST ADZAN START: 1 Minute from now
      'Test Adzan': DateFormat(
        'HH:mm',
      ).format(DateTime.now().add(const Duration(minutes: 1))),
    };

    int id = 0;
    prayers.forEach((name, timeStr) async {
      final time = parseTime(timeStr);
      final isTest = name == 'Test Adzan';

      // Get setting for this prayer (default to 'adhan')
      final soundType = state.notificationSettings[name] ?? 'adhan';

      // 1. Exact Time
      await _notificationService.schedulePrayerNotification(
        id: id++,
        title: 'Waktu $name Telah Tiba',
        body: 'Mari laksanakan sholat $name sekarang.',
        scheduledTime: time,
        soundType: soundType,
        isRepeating: !isTest, // Test is one-off, others repeat
      );

      // 2. 15 Minutes Before (Skip for Test Adzan)
      // Pre-warning always uses default sound or silent, usually not Adhan
      // But user might want Adhan? Let's assume beep for pre-warning or same as main?
      // For now, let's use 'beep' for pre-warning to distinguish, or same setting?
      // Let's use 'beep' for pre-warning unless user chose silent.
      // 2. 15 Minutes Before (Skip for Test Adzan)
      if (!isTest) {
        String preSound = 'beep';
        if (soundType == 'silent') preSound = 'silent';

        await _notificationService.schedulePrayerNotification(
          id: id++,
          title: 'Menuju Waktu $name',
          body: '15 menit lagi waktu $name akan tiba.',
          scheduledTime: time.subtract(const Duration(minutes: 15)),
          soundType: preSound,
        );
      } else {
        // Increment ID to keep sequence aligned if needed, or just skip
        id++;
      }
    });
  }
}

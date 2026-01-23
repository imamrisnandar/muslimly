import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/utils/location_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../domain/entities/city.dart';
import '../../domain/entities/prayer_time.dart';
import '../../domain/usecases/get_prayer_time.dart';
import '../../domain/usecases/search_city.dart';
import '../../../settings/data/repositories/settings_repository.dart';
import '../../../quran/data/repositories/last_read_repository.dart';
import '../../../../l10n/generated/app_localizations.dart'; // Import generated l10n
import 'prayer_event.dart';
import 'prayer_state.dart';

@injectable
class PrayerBloc extends Bloc<PrayerEvent, PrayerState> {
  final GetPrayerTime _getPrayerTime;
  final SearchCity _searchCity;
  final LocationService _locationService;
  final NotificationService _notificationService;
  final SettingsRepository _settingsRepository;
  final LastReadRepository _lastReadRepository;

  PrayerBloc(
    this._getPrayerTime,
    this._searchCity,
    this._locationService,
    this._notificationService,
    this._settingsRepository,
    this._lastReadRepository,
  ) : super(const PrayerState()) {
    on<FetchPrayerTime>((event, emit) async {
      emit(state.copyWith(status: PrayerStatus.loading));

      // Request permissions once on first fetch
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
          // DEBUG: 1 minute for faster testing
          final testTime = DateTime.now().add(const Duration(minutes: 1));
          emit(
            state.copyWith(
              status: PrayerStatus.success,
              prayerTime: prayerTime,
              testAdzanTargetTime: testTime,
            ),
          );

          // Schedule Notifications
          _scheduleNotifications(prayerTime, testTime);
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
        final testTime =
            state.testAdzanTargetTime ??
            DateTime.now().add(const Duration(minutes: 1));
        _scheduleNotifications(state.prayerTime!, testTime);
      }
    });

    on<SearchCityEvent>((event, emit) async {
      emit(state.copyWith(isSearching: true));
      final result = await _searchCity(event.keyword);
      result.fold(
        (failure) =>
            emit(state.copyWith(isSearching: false, errorMessage: failure)),
        (cities) =>
            emit(state.copyWith(isSearching: false, searchResults: cities)),
      );
    });

    on<SelectCity>((event, emit) {
      emit(
        state.copyWith(
          currentCity: event.city,
          searchResults: [],
          isSearching: false,
        ),
      );
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

      final searchResult = await _searchCity(cityName);
      searchResult.fold(
        (failure) => add(
          FetchPrayerTime(cityId: '1301', date: DateTime.now()),
        ), // Fallback
        (cities) {
          if (cities.isNotEmpty) {
            final city = cities.first;
            emit(state.copyWith(currentCity: city));
            add(FetchPrayerTime(cityId: city.id, date: DateTime.now()));
          } else {
            add(FetchPrayerTime(cityId: '1301', date: DateTime.now()));
          }
        },
      );
    });
  }

  void _scheduleNotifications(
    PrayerTime prayerTime,
    DateTime testAdzanTime,
  ) async {
    // 1. Get Locale
    final langCode = await _settingsRepository.getLanguage();
    final locale = Locale(langCode ?? 'id'); // Default to ID if null
    final l10n = lookupAppLocalizations(locale);

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
      // TEST ADZAN DISABLED
      // 'Test Adzan': DateFormat('HH:mm').format(testAdzanTime),
    };

    int id = 0;
    for (final entry in prayers.entries) {
      final name = entry.key;
      final timeStr = entry.value;

      final isTest = name == 'Test Adzan';
      final time = isTest ? testAdzanTime : parseTime(timeStr);

      // Override sound type for Imsak and Terbit to always use 'beep'
      String soundType = state.notificationSettings[name] ?? 'adhan';
      if (name == 'Imsak' || name == 'Terbit') {
        soundType = 'beep';
      }

      String notificationTitle = l10n.notificationPrayerTitle(name);
      String notificationBody = l10n.notificationPrayerBody(name);

      // SMART REMINDER LOGIC for 'Test Adzan'
      if (isTest) {
        // 1. Fetch Real Data
        final userName = await _settingsRepository.getUserName();
        final lastRead = await _lastReadRepository.getLastRead();
        final targetPages = await _settingsRepository.getDailyReadingTarget();

        // Calculate Remaining
        int remainingPages = targetPages;
        if (lastRead != null) {
          remainingPages = (targetPages - 1).clamp(0, targetPages);
        }

        // Option A Selection (Using Localized Strings)
        if (userName != null && lastRead != null) {
          // PERSONALIZED (Name + Progress)
          notificationTitle = l10n.notificationSmartTitle(userName);
          notificationBody = l10n.notificationSmartBodyProgress(remainingPages);
        } else if (userName != null) {
          // PERSONALIZED (Name Only)
          notificationTitle = l10n.notificationSmartTitle(userName);
          notificationBody = l10n.notificationSmartBodyStart(remainingPages);
        } else {
          // FALLBACK
          notificationTitle = l10n.notificationFallbackTitle;
          notificationBody = l10n.notificationFallbackBody;
        }

        // Schedule with FORCED BEEP
        await _notificationService.schedulePrayerNotification(
          id: id++,
          title: notificationTitle,
          body: notificationBody,
          scheduledTime: time,
          soundType: 'beep', // Forced Beep
          isRepeating: !isTest,
        );
      } else {
        // STANDARD ADZAN for other times
        await _notificationService.schedulePrayerNotification(
          id: id++,
          title: notificationTitle,
          body: notificationBody,
          scheduledTime: time,
          soundType: soundType,
          isRepeating: !isTest,
        );
      }

      // 2. 15 Minutes Before (Skip for Test Adzan, Imsak, and Terbit)
      if (!isTest && name != 'Imsak' && name != 'Terbit') {
        String preSound = 'beep';
        if (soundType == 'silent') preSound = 'silent';

        await _notificationService.schedulePrayerNotification(
          id: id++,
          title: l10n.notificationPrePrayerTitle(name),
          body: l10n.notificationPrePrayerBody(name),
          scheduledTime: time.subtract(const Duration(minutes: 15)),
          soundType: preSound,
        );
      } else {
        id++;
      }
    }
  }
}

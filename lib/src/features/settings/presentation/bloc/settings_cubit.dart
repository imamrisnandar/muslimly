import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:injectable/injectable.dart';
import '../../data/repositories/settings_repository.dart';
import '../../../intro/data/repositories/name_repository.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../features/prayer/domain/services/fasting_service.dart';
import 'settings_state.dart';

@injectable
class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _settingsRepository;
  final NameRepository _nameRepository;
  final NotificationService _notificationService;
  final FastingService _fastingService;

  SettingsCubit(
    this._settingsRepository,
    this._nameRepository,
    this._notificationService,
    this._fastingService,
  ) : super(SettingsState.initial()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    final langCode = await _settingsRepository.getLanguage();
    final name = await _nameRepository.getName();
    final target = await _settingsRepository.getDailyReadingTarget();
    final ayahTarget = await _settingsRepository.getDailyAyahTarget();
    final unit = await _settingsRepository.getReadingTargetUnit();
    List<Map<String, dynamic>> adjustments = await _settingsRepository
        .getHijriAdjustments();

    final locale = langCode != null ? Locale(langCode) : const Locale('id');

    // Update Service with local data immediately
    _fastingService.setHijriAdjustments(adjustments);

    // Helper to update state with current adjustments
    void updateEmit(List<Map<String, dynamic>> currentAdjustments) {
      final now = DateTime.now();
      final hDate = HijriCalendar.fromDate(now);
      final currentAdj = currentAdjustments.firstWhere(
        (element) => element['hijri_month'] == hDate.hMonth,
        orElse: () => {'adjustment': 0},
      );
      final adjustmentValue = currentAdj['adjustment'] as int? ?? 0;

      emit(
        state.copyWith(
          locale: locale,
          userName: name,
          dailyTarget: target,
          dailyAyahTarget: ayahTarget,
          targetUnit: unit,
          hijriAdjustment: adjustmentValue,
          hijriAdjustments: currentAdjustments,
        ),
      );
    }

    // Emit initial state with local data immediately to avoid lag
    updateEmit(adjustments);

    // Initial Sync & Background Logic
    if (adjustments.isEmpty) {
      // First install: await remote to ensure Ramadan logic (+1) works immediately
      try {
        final remoteAdjustments = await _settingsRepository
            .fetchRemoteHijriAdjustments();
        if (remoteAdjustments.isNotEmpty) {
          await _settingsRepository.saveHijriAdjustments(remoteAdjustments);
          _fastingService.setHijriAdjustments(remoteAdjustments);
          updateEmit(remoteAdjustments);
        }
      } catch (e) {
        debugPrint("Failed to fetch remote adjustments on first install: $e");
      }
    } else {
      // Already has cache: fetch in background to stay updated
      _settingsRepository
          .fetchRemoteHijriAdjustments()
          .then((remoteAdjustments) async {
            if (remoteAdjustments.isNotEmpty) {
              await _settingsRepository.saveHijriAdjustments(remoteAdjustments);
              _fastingService.setHijriAdjustments(remoteAdjustments);
              if (!isClosed) {
                updateEmit(remoteAdjustments);
              }
            }
          })
          .catchError((e) {
            debugPrint("Background Hijri sync failed: $e");
          });
    }
  }

  Future<void> updateLanguage(Locale locale) async {
    await _settingsRepository.saveLanguage(locale.languageCode);
    emit(state.copyWith(locale: locale));
  }

  Future<void> updateName(String name) async {
    await _nameRepository.saveName(name);
    emit(state.copyWith(userName: name));
  }

  Future<void> updateDailyTarget(int pages) async {
    await _settingsRepository.saveDailyReadingTarget(pages);
    emit(state.copyWith(dailyTarget: pages));
  }

  Future<void> updateDailyAyahTarget(int ayahs) async {
    await _settingsRepository.saveDailyAyahTarget(ayahs);
    emit(state.copyWith(dailyAyahTarget: ayahs));
  }

  Future<void> updateTargetUnit(String unit) async {
    await _settingsRepository.saveReadingTargetUnit(unit);
    emit(state.copyWith(targetUnit: unit));
  }

  Future<void> updateHijriAdjustment(int month, int days) async {
    final List<Map<String, dynamic>> newAdjustments = List.from(
      state.hijriAdjustments,
    );
    final index = newAdjustments.indexWhere(
      (element) => element['hijri_month'] == month,
    );

    if (index != -1) {
      newAdjustments[index] = {'hijri_month': month, 'adjustment': days};
    } else {
      newAdjustments.add({'hijri_month': month, 'adjustment': days});
    }

    await _settingsRepository.saveHijriAdjustments(newAdjustments);
    _fastingService.setHijriAdjustments(newAdjustments);

    // Recalculate current month adjustment for UI state if needed
    // But since we are moving to list view, we might not need single `hijriAdjustment` state as much
    // For compatibility, let's update it if the modified month is current month
    final now = DateTime.now();
    final hDate = HijriCalendar.fromDate(now);
    if (month == hDate.hMonth) {
      emit(
        state.copyWith(hijriAdjustment: days, hijriAdjustments: newAdjustments),
      );
    } else {
      emit(state.copyWith(hijriAdjustments: newAdjustments));
    }
  }

  Future<void> testNotification() async {
    await _notificationService.requestPermissions();
    await _notificationService.showImmediateNotification(
      title: 'Test Notification',
      body: 'This is a test notification for prayer times.',
    );
  }
}

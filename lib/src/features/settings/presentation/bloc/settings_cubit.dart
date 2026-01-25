import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../data/repositories/settings_repository.dart';
import '../../../intro/data/repositories/name_repository.dart';
import '../../../../core/services/notification_service.dart';
import 'settings_state.dart';

@injectable
class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _settingsRepository;
  final NameRepository _nameRepository;
  final NotificationService _notificationService;

  SettingsCubit(
    this._settingsRepository,
    this._nameRepository,
    this._notificationService,
  ) : super(SettingsState.initial()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    final langCode = await _settingsRepository.getLanguage();
    final name = await _nameRepository.getName();
    final target = await _settingsRepository.getDailyReadingTarget();
    final ayahTarget = await _settingsRepository.getDailyAyahTarget();
    final unit = await _settingsRepository.getReadingTargetUnit();

    final locale = langCode != null ? Locale(langCode) : null;

    emit(
      state.copyWith(
        locale: locale,
        userName: name,
        dailyTarget: target,
        dailyAyahTarget: ayahTarget,
        targetUnit: unit,
      ),
    );
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

  Future<void> testNotification() async {
    await _notificationService.requestPermissions();
    await _notificationService.showImmediateNotification(
      title: 'Test Notification',
      body: 'This is a test notification for prayer times.',
    );
  }
}

import 'package:workmanager/workmanager.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui'; // for Locale
import '../../core/di/di_container.dart';
import '../../features/settings/data/repositories/settings_repository.dart';
import '../../core/database/database_service.dart';
import '../../l10n/generated/app_localizations.dart'; // Localization
import 'notification_service.dart';
// Actually we need to re-initialize DI in background.

@lazySingleton
class BackgroundService {
  void initialize() {
    Workmanager().initialize(callbackDispatcher, isInDebugMode: kDebugMode);
    _registerDailyTask();
  }

  void _registerDailyTask() {
    Workmanager().registerPeriodicTask(
      "muslimly_daily_refresh",
      "refreshPrayerTimesTask",
      frequency: const Duration(
        hours: 24,
      ), // Minimum 15 mins, but we want daily
      initialDelay: _calculateInitialDelay(),
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
    );
  }

  Duration _calculateInitialDelay() {
    final now = DateTime.now();
    // We want 3 AM tomorrow or today if it's before 3 AM
    DateTime target = DateTime(now.year, now.month, now.day, 3, 0);
    if (now.isAfter(target)) {
      target = target.add(const Duration(days: 1));
    }
    return target.difference(now);
  }

  // Debug Method
  void triggerImmediateSync() {
    Workmanager().registerOneOffTask(
      "test_sync_${DateTime.now().millisecondsSinceEpoch}",
      "refreshPrayerTimesTask",
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }
}

// TOP LEVEL FUNCTION
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print("DEBUG: Background Task Execution Started: $task");

    // 1. Initialize DI (Must be separate from main app isolate)
    // We need to configure dependencies slightly differently or ensure plugins work.
    // Assuming configureDependencies() works in background isolate.
    // Note: Some plugins might need re-initialization like LocalNotifications.

    // Ensure Widgets Binding
    // WidgetsFlutterBinding.ensureInitialized(); // executeTask does this internally usually?
    // But for plugins:
    // DartPluginRegistrant.ensureInitialized(); // Sometimes needed on iOS?

    try {
      configureDependencies(); // Re-init DI

      final settingsRepo = getIt<SettingsRepository>();
      final notificationService = getIt<NotificationService>();

      await notificationService.initialize();

      // 1. Refresh Logic
      // Real implementation would re-fetch city coordinates or sync data.

      // 2. Progress Notification Logic
      // So we need DatabaseService.

      final dbService = getIt<DatabaseService>();
      final now = DateTime.now();
      // LOGIC CHANGE: Check Yesterday's Progress
      // If running manual test (e.g. via button), usually we want to see stats?
      // But user specifically asked for "Yesterday's Progress".
      // So we must be consistent.

      final yesterday = now.subtract(const Duration(days: 1));
      final dateStr = yesterday.toIso8601String().substring(0, 10);

      // Use Settings to check unit
      final unit = await settingsRepo
          .getReadingTargetUnit(); // 'page' or 'ayah'

      int progress = 0;
      int target = 0;

      if (unit == 'ayah') {
        progress = await dbService.getDailyAyahCount(dateStr);
        target = await settingsRepo.getDailyAyahTarget();
      } else {
        progress = await dbService.getDailyPageCount(dateStr);
        target = await settingsRepo.getDailyReadingTarget();
      }

      // Language for Notification
      final langCode = await settingsRepo.getLanguage();
      final locale = Locale(langCode ?? 'id');
      final l10n = lookupAppLocalizations(locale);

      String title = l10n.backgroundRefreshTitle; // "Yesterday's Progress"
      String body = "";

      // Unit Labels
      final unitLabel = (unit == 'ayah')
          ? (l10n.lblAyah ?? "Ayat")
          : (l10n.lblPage ?? "Halaman");

      if (progress == 0) {
        body = l10n.backgroundProgressZero;
      } else if (progress >= target) {
        body = l10n.backgroundProgressFinished(target, unitLabel);
      } else {
        body = l10n.backgroundProgressEncourage(progress, unitLabel);
      }

      await notificationService.showImmediateNotification(
        title: title,
        body: body,
        soundType: 'beep', // Requested by User
      );

      print("DEBUG: Background Task Finished. Progress: $progress/$target");
    } catch (e) {
      print("DEBUG: Background Task Error: $e");
      return Future.value(false);
    }

    return Future.value(true);
  });
}

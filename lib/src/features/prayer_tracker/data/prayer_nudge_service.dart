import 'dart:convert';
import 'dart:ui';

import 'package:intl/intl.dart';

import '../../../core/services/notification_service.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/entities/excused_period.dart';
import '../domain/entities/prayer_log.dart';
import '../domain/entities/prayer_slot.dart';
import '../domain/utils/nudge_planner.dart';

/// Schedules/cancels the local-only nudge notifications. Never server-driven:
/// the server cannot know about excused periods (see roadmap §D).
class PrayerNudgeService {
  final NotificationService _notifications;
  PrayerNudgeService(this._notifications);

  static String _name(AppLocalizations l, TrackedPrayer p) {
    switch (p) {
      case TrackedPrayer.fajr:
        return l.prayerFajr;
      case TrackedPrayer.dhuhr:
        return l.prayerDhuhr;
      case TrackedPrayer.asr:
        return l.prayerAsr;
      case TrackedPrayer.maghrib:
        return l.prayerMaghrib;
      case TrackedPrayer.isha:
        return l.prayerIsha;
    }
  }

  /// Replaces all scheduled nudges with a fresh plan (or none if [enabled] is
  /// false). Call after every load and every check-in.
  Future<void> sync({
    required List<List<SlotView>> slotsByDay,
    required bool enabled,
    required Duration before,
    required String languageCode,
  }) async {
    await _notifications.cancelNotifications(
      List.generate(kPrayerNudgeIdCount, (i) => kPrayerNudgeIdBase + i),
    );
    if (!enabled) return;

    final l10n = lookupAppLocalizations(Locale(languageCode));
    final plan = NudgePlanner.plan(
      slotsByDay: slotsByDay,
      now: DateTime.now().toUtc(),
      before: before,
    );
    final fmt = DateFormat.Hm();
    for (final n in plan) {
      final name = _name(l10n, n.slot.prayer);
      await _notifications.scheduleNudgeNotification(
        id: kPrayerNudgeIdBase + n.index,
        title: name,
        body: l10n.trackerNudgeBody(name, fmt.format(n.slot.end.toLocal())),
        scheduledTime: n.fireAt.toLocal(),
        payload: jsonEncode({'route': '/prayer-tracker'}),
      );
    }
  }

  /// Replaces the end-of-pause reminder. Neutral wording on purpose.
  Future<void> syncExcuseEndReminder({
    required List<ExcusedPeriod> periods,
    required String languageCode,
  }) async {
    await _notifications.cancelNotifications([kExcuseEndNotificationId]);
    final at = NudgePlanner.excuseEndReminder(periods, DateTime.now());
    if (at == null) return;
    final l10n = lookupAppLocalizations(Locale(languageCode));
    await _notifications.scheduleNudgeNotification(
      id: kExcuseEndNotificationId,
      title: l10n.trackerExcuseEndNotifTitle,
      body: l10n.trackerExcuseEndNotifBody,
      scheduledTime: at,
      payload: jsonEncode({'route': '/prayer-tracker'}),
    );
  }
}

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:injectable/injectable.dart';

@lazySingleton
class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();
    // Detect and set local time zone
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    print('DEBUG: NotificationService init with timezone: $timeZoneName');
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        );

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    // 1. Adhan (Custom Sound) - v7 (Bumped to force update & fix sound)
    const AndroidNotificationDetails channelAdhan = AndroidNotificationDetails(
      'prayer_channel_v7',
      'Prayer Notifications (Adhan)',
      channelDescription: 'Notifications with Adhan sound',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('adhan'),
      playSound: true,
      audioAttributesUsage: AudioAttributesUsage.alarm,
    );

    // 2. Beep (Default System Sound)
    const AndroidNotificationDetails channelBeep = AndroidNotificationDetails(
      'prayer_channel_beep',
      'Prayer Notifications (Beep)',
      channelDescription: 'Notifications with default system sound',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    // 3. Silent (No Sound)
    const AndroidNotificationDetails channelSilent = AndroidNotificationDetails(
      'prayer_channel_silent',
      'Prayer Notifications (Silent)',
      channelDescription: 'Silent notifications',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      playSound: false,
      enableVibration: true,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
      },
    );

    final androidImplementation = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(
        AndroidNotificationChannel(
          channelAdhan.channelId,
          channelAdhan.channelName,
          description: channelAdhan.channelDescription,
          importance: channelAdhan.importance,
          sound: channelAdhan.sound,
          playSound: true,
          audioAttributesUsage: AudioAttributesUsage.alarm,
        ),
      );
      await androidImplementation.createNotificationChannel(
        AndroidNotificationChannel(
          channelBeep.channelId,
          channelBeep.channelName,
          description: channelBeep.channelDescription,
          importance: channelBeep.importance,
          playSound: true,
        ),
      );
      await androidImplementation.createNotificationChannel(
        AndroidNotificationChannel(
          channelSilent.channelId,
          channelSilent.channelName,
          description: channelSilent.channelDescription,
          importance: channelSilent.importance,
          playSound: false,
          enableVibration: true,
        ),
      );
    }
  }

  Future<void> requestPermissions() async {
    print('DEBUG: Requesting Notification & Alarm Permissions...');
    final androidImplementation = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation != null) {
      final bool? resultNotification = await androidImplementation
          .requestNotificationsPermission();
      final bool? resultAlarm = await androidImplementation
          .requestExactAlarmsPermission();
      print(
        'DEBUG: Permission Results -> Notification: $resultNotification, ExactAlarm: $resultAlarm',
      );
    }
  }

  Future<void> schedulePrayerNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String soundType = 'adhan', // 'adhan', 'beep', 'silent'
    bool isRepeating = true,
  }) async {
    // Strip milliseconds to ensure clean scheduling
    scheduledTime = DateTime(
      scheduledTime.year,
      scheduledTime.month,
      scheduledTime.day,
      scheduledTime.hour,
      scheduledTime.minute,
      scheduledTime.second,
    );

    // If time has passed today, schedule for tomorrow (Only if repeating or if we want to force next day)
    // For test (isRepeating=false), we strictly follow the time (or maybe we allow it to be today).
    if (isRepeating && scheduledTime.isBefore(DateTime.now())) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
      print('DEBUG: Time passed. Rescheduling for tomorrow: $scheduledTime');
    }

    print(
      'DEBUG: Scheduling notification ID:$id Title:$title Time:$scheduledTime (Local) Repeating:$isRepeating',
    );

    AndroidNotificationDetails androidDetails;

    switch (soundType) {
      case 'beep':
        androidDetails = const AndroidNotificationDetails(
          'prayer_channel_beep',
          'Prayer Notifications (Beep)',
          channelDescription: 'Notifications with default system sound',
          importance: Importance.max,
          priority: Priority.high,
        );
        break;
      case 'silent':
        androidDetails = const AndroidNotificationDetails(
          'prayer_channel_silent',
          'Prayer Notifications (Silent)',
          channelDescription: 'Silent notifications',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          playSound: false,
          enableVibration: true,
        );
        break;
      case 'adhan':
      default:
        androidDetails = const AndroidNotificationDetails(
          'prayer_channel_v7',
          'Prayer Notifications (Adhan)',
          channelDescription: 'Notifications with Adhan sound',
          importance: Importance.max,
          priority: Priority.high,
          sound: RawResourceAndroidNotificationSound('adhan'),
          playSound: true,
          audioAttributesUsage: AudioAttributesUsage.alarm,
        );
        break;
    }

    final tzDateTime = tz.TZDateTime.from(scheduledTime, tz.local);

    // Safety check: Don't schedule if already passed
    if (tzDateTime.isBefore(tz.TZDateTime.now(tz.local))) {
      return;
    }

    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzDateTime,
        NotificationDetails(
          android: androidDetails,
          iOS: const DarwinNotificationDetails(),
        ),
        // Use exactAllowWhileIdle as alarmClock might be restricted on some devices
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: isRepeating ? DateTimeComponents.time : null,
      );
    } catch (e) {
      // Handle error gracefully
    }
  }

  Future<void> showImmediateNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'prayer_channel_v7',
          'Prayer Notifications (Adhan)',
          channelDescription: 'Notifications with Adhan sound',
          importance: Importance.max,
          priority: Priority.high,
          sound: RawResourceAndroidNotificationSound('adhan'),
          playSound: true,
          audioAttributesUsage: AudioAttributesUsage.alarm,
        );
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: DarwinNotificationDetails(),
    );
    await _flutterLocalNotificationsPlugin.show(
      999,
      title,
      body,
      notificationDetails,
    );
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}

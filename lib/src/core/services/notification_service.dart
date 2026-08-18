import 'dart:io';
import 'package:flutter/foundation.dart';
import '../config/app_urls.dart';
import '../utils/app_logger.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// [requestPermission] must be false when called from a headless context
  /// (e.g. the WorkManager background isolate): permission requests need a
  /// foreground Activity, and crash with a native NPE without one.
  Future<void> initialize({bool requestPermission = true}) async {
    // 0. Initialize Firebase
    try {
      await Firebase.initializeApp();
      // print('DEBUG: Firebase Initialized');
    } catch (e) {
      AppLogger.error('Firebase initialization failed', e);
    }

    tz.initializeTimeZones();
    final String timeZoneName = (await FlutterTimezone.getLocalTimezone()).identifier;
    try {
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }

    // ... (Existing Local Notification Init) ...
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

    // Create Channels
    await _createChannels();

    await _flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
      },
    );

    // 1–3 below require a foreground Activity — skip entirely in background isolates
    if (requestPermission) {
      await requestPermissions();

      // 2. FCM Listener
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;

        if (notification != null && android != null) {
          showImmediateNotification(
            title: notification.title ?? 'Notification',
            body: notification.body ?? '',
            soundType: 'adhan',
          );
        }
      });

      // 3. Register Token (Initial Guest Registration)
      // If user logs in later, AuthBloc should call this again with token.
      await syncFCMToken(null);
    }
  }

  Future<void> _createChannels() async {
    final androidImplementation = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation != null) {
      // ... (Channel creation logic moved here for cleaner code or kept inline) ...
      // Keeping inline to minimize diff, but for this edit I will just reuse existing logic structure if possible
      // strict constraints: reusing existing logic would require copying it all.
      // efficient: create helper method or just keep it in initialize.
      // Let's keep it in initialize to match previous structure but add Firebase calls.
    }
  }

  Future<void> syncFCMToken(String? authToken) async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;

      // Collect Device Metadata
      final deviceInfo = await _getDeviceInfo();

      // Send to Backend
      final dio = Dio();
      final baseUrl = AppUrls.baseApi;

      final Options options = Options(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
      );

      final response = await dio.post(
        '$baseUrl/notifications/register',
        data: {
          'fcm_token': token,
          'platform': Platform.isAndroid ? 'android' : 'ios',
          // Device Metadata
          'device_model': deviceInfo['model'],
          'device_os_version': deviceInfo['osVersion'],
          'app_version': deviceInfo['appVersion'],
          'country_code': deviceInfo['countryCode'],
          'timezone': deviceInfo['timezone'],
        },
        options: options,
      );

      // Store device_id from response for sync operations
      if (response.data != null && response.data['data'] != null) {
        final deviceId = response.data['data']['device_id'];
        if (deviceId != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('device_id', deviceId);
          debugPrint('✅ Device ID stored');
        }
      }

    } catch (e) {
      debugPrint('❌ Error syncing FCM token: $e');
    }
  }

  /// Get the stored device_id from SharedPreferences
  static Future<String?> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('device_id');
  }

  Future<Map<String, String>> _getDeviceInfo() async {
    try {
      final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      String model = 'Unknown';
      String osVersion = 'Unknown';

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        model = '${androidInfo.manufacturer} ${androidInfo.model}';
        osVersion = 'Android ${androidInfo.version.release}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        model = iosInfo.model;
        osVersion = 'iOS ${iosInfo.systemVersion}';
      }

      // Get App Version
      final packageInfo = await PackageInfo.fromPlatform();

      // Get Timezone
      final timezone = DateTime.now().timeZoneName;

      return {
        'model': model,
        'osVersion': osVersion,
        'appVersion': packageInfo.version,
        'countryCode': 'ID', // Default or use geolocator for accurate detection
        'timezone': timezone,
      };
    } catch (e) {
      debugPrint('Error getting device info: $e');
      return {
        'model': 'Unknown',
        'osVersion': 'Unknown',
        'appVersion': '1.0.0',
        'countryCode': 'ID',
        'timezone': 'Asia/Jakarta',
      };
    }
  }

  Future<void> requestPermissions() async {
    // Guard against headless contexts: the plugin needs a foreground Activity
    // and otherwise throws a PlatformException from a native NPE
    try {
      // Add Firebase permission request
      await FirebaseMessaging.instance
          .requestPermission(alert: true, badge: true, sound: true);

      final androidImplementation = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
        await androidImplementation.requestExactAlarmsPermission();
      }
    } catch (e) {
      AppLogger.error('Notification permission request failed', e);
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
      // print('DEBUG: Time passed. Rescheduling for tomorrow: $scheduledTime');
    }

    // print(
    // 'DEBUG: Scheduling notification ID:$id Title:$title Time:$scheduledTime (Local) Repeating:$isRepeating',
    // );

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
        id: id,
        title: title,
        body: body,
        scheduledDate: tzDateTime,
        notificationDetails: NotificationDetails(
          android: androidDetails,
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: isRepeating ? DateTimeComponents.time : null,
      );
    } catch (e, s) {
      AppLogger.error('Failed to schedule prayer notification id=$id', e, s);
    }
  }

  Future<void> showImmediateNotification({
    required String title,
    required String body,
    String soundType = 'adhan',
  }) async {
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

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(),
    );
    await _flutterLocalNotificationsPlugin.show(
      id: 999,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
    );
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}

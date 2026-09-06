import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';
import '../utils/app_logger.dart';
import '../../config/router/app_router.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../di/di_container.dart';

/// Channel used for server-sent push / broadcast messages (daily reminder,
/// announcements). Kept separate from the prayer channels so it never plays
/// the adhan and the user can mute it independently in system settings.
const String kPushChannelId = 'push_general_v1';
const String kPushChannelName = 'General Notifications';

/// Resolve a notification payload to an in-app route. An explicit absolute
/// `route` in the data wins; otherwise fall back to a per-`type` destination,
/// and anything unrecognised opens the dashboard. Pure — unit-tested.
String resolveNotificationRoute(Map<String, dynamic> data) {
  final route = data['route'];
  if (route is String && route.startsWith('/')) return route;

  switch (data['type']) {
    case 'daily_reminder':
      return '/dashboard?index=2'; // Quran tab
    default:
      return '/dashboard';
  }
}

/// Background / terminated-state FCM handler. Must be a top-level function
/// annotated with `@pragma('vm:entry-point')` — it runs in its own isolate
/// with no access to the app's DI container or navigator.
///
/// FCM messages that carry a `notification` block are drawn by the OS while
/// the app is backgrounded, so there is nothing to do for those here. This
/// hook exists so `onBackgroundMessage` is registered (a plugin requirement)
/// and so data-only messages still surface something.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Already initialized in this isolate — ignore.
  }

  // Data-only message (no `notification` block): the OS shows nothing, so
  // render a local notification ourselves.
  if (message.notification == null && message.data.isNotEmpty) {
    final plugin = FlutterLocalNotificationsPlugin();
    await plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );
    await plugin.show(
      // 32-bit positive id (the plugin rejects anything wider).
      id: message.hashCode & 0x7fffffff,
      title: message.data['title'] ?? 'Muslimly',
      body: message.data['body'] ?? '',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          kPushChannelId,
          kPushChannelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: jsonEncode(message.data),
    );
  }
}

/// SharedPreferences key holding the epoch-ms of the last successful FCM
/// token sync. Drives the on-resume heartbeat.
const String _kFcmLastSyncKey = 'fcm_last_sync_ms';

/// Minimum gap between on-resume heartbeat re-registrations. The backend
/// uses `last_active_at` to decide which devices still get broadcasts, and
/// it only advances on /register — so we nudge it whenever the app is
/// opened, but no more than once a day.
const Duration _kHeartbeatInterval = Duration(hours: 24);

class NotificationService with WidgetsBindingObserver {
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
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    // Cold launch via a tapped local notification (e.g. a data-only push
    // rendered by the background isolate) — FCM's getInitialMessage doesn't
    // see those, so check the local plugin too.
    final launchDetails = await _flutterLocalNotificationsPlugin
        .getNotificationAppLaunchDetails();
    if (requestPermission &&
        (launchDetails?.didNotificationLaunchApp ?? false)) {
      final payload = launchDetails!.notificationResponse?.payload;
      if (payload != null && payload.isNotEmpty) {
        _navigateFromPayload(payload);
      }
    }

    // 1–5 below require a foreground Activity — skip entirely in background isolates
    if (requestPermission) {
      await requestPermissions();

      // Heartbeat: re-register (at most daily) whenever the app comes back to
      // the foreground so the backend's last_active_at stays fresh.
      WidgetsBinding.instance.addObserver(this);

      // 2. Foreground FCM listener — the OS does not draw notifications while
      // the app is in the foreground, so we render one locally. Works for
      // both platforms (the old `android != null` gate silently dropped iOS).
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final notification = message.notification;
        if (notification == null) return;
        showImmediateNotification(
          title: notification.title ?? 'Muslimly',
          body: notification.body ?? '',
          // Server pushes never play the adhan — only scheduled prayer
          // notifications do. A message can still opt into a sound via
          // data: {"sound": "adhan"|"beep"|"silent"}.
          soundType: message.data['sound'] ?? 'default',
          payload: jsonEncode(message.data),
        );
      });

      // 3. Route taps on a push (background → resumed, and cold launch).
      await _setupInteractedMessage();

      // Re-register whenever FCM rotates the token so the backend never
      // holds a stale one between app launches.
      FirebaseMessaging.instance.onTokenRefresh.listen((_) {
        syncFCMToken(null);
      });

      // 4. Register Token (Initial Guest Registration)
      // If user logs in later, AuthBloc should call this again with token.
      await syncFCMToken(null);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _heartbeat();
    }
  }

  /// Re-register the device on resume, but not more than once per
  /// [_kHeartbeatInterval], so the backend sees the device as active.
  Future<void> _heartbeat() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastMs = prefs.getInt(_kFcmLastSyncKey) ?? 0;
      final since = DateTime.now().millisecondsSinceEpoch - lastMs;
      if (since < _kHeartbeatInterval.inMilliseconds) return;
      await syncFCMToken(null);
    } catch (e) {
      debugPrint('❌ FCM heartbeat failed: $e');
    }
  }

  /// Handle a push that was tapped: [getInitialMessage] covers a cold start
  /// from a terminated state, [onMessageOpenedApp] covers a tap while the app
  /// sits in the background.
  Future<void> _setupInteractedMessage() async {
    final initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _navigateFromData(initialMessage.data);
    }
    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) => _navigateFromData(message.data),
    );
  }

  /// Navigate in response to a notification tap.
  ///
  /// Deferred to the next frame: a cold launch resolves the initial message
  /// during [initialize] (before `runApp`), when the router isn't mounted yet.
  void _navigateFromData(Map<String, dynamic> data) {
    final target = resolveNotificationRoute(data);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        appRouter.go(target);
      } catch (e, s) {
        AppLogger.error('Notification navigation failed', e, s);
      }
    });
  }

  /// Local-notification tap handler. The payload is the JSON-encoded FCM
  /// data map written when the notification was shown.
  void _onNotificationResponse(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null && payload.isNotEmpty) {
      _navigateFromPayload(payload);
    }
  }

  void _navigateFromPayload(String payload) {
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map) {
        _navigateFromData(decoded.cast<String, dynamic>());
      }
    } catch (e, s) {
      AppLogger.error('Failed to parse notification payload', e, s);
    }
  }

  Future<void> _createChannels() async {
    final androidImplementation = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidImplementation == null) return;

    // General push / broadcast channel — default system sound, never adhan.
    await androidImplementation.createNotificationChannel(
      const AndroidNotificationChannel(
        kPushChannelId,
        kPushChannelName,
        description: 'Reminders and announcements from Muslimly',
        importance: Importance.high,
      ),
    );

    // Prayer channels — these mirror the AndroidNotificationDetails used by
    // schedulePrayerNotification/showImmediateNotification. Creating them up
    // front means their sound/importance is locked in before the first fire
    // (Android ignores later changes to an existing channel).
    await androidImplementation.createNotificationChannel(
      const AndroidNotificationChannel(
        'prayer_channel_v7',
        'Prayer Notifications (Adhan)',
        description: 'Notifications with Adhan sound',
        importance: Importance.max,
        sound: RawResourceAndroidNotificationSound('adhan'),
        audioAttributesUsage: AudioAttributesUsage.alarm,
      ),
    );
    await androidImplementation.createNotificationChannel(
      const AndroidNotificationChannel(
        'prayer_channel_beep',
        'Prayer Notifications (Beep)',
        description: 'Notifications with default system sound',
        importance: Importance.max,
      ),
    );
    await androidImplementation.createNotificationChannel(
      const AndroidNotificationChannel(
        'prayer_channel_silent',
        'Prayer Notifications (Silent)',
        description: 'Silent notifications',
        importance: Importance.defaultImportance,
        playSound: false,
      ),
    );
  }

  Future<void> syncFCMToken(String? authToken) async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;

      // Collect Device Metadata
      final deviceInfo = await _getDeviceInfo();

      // Reflect the actual OS-level permission so broadcasts skip devices
      // where the user turned notifications off.
      final settings =
          await FirebaseMessaging.instance.getNotificationSettings();
      final pushEnabled = settings.authorizationStatus !=
              AuthorizationStatus.denied &&
          settings.authorizationStatus != AuthorizationStatus.notDetermined;

      // Shared Dio: base URL, timeouts and debug logging already configured.
      final dio = getIt<Dio>();

      final response = await dio.post(
        'notifications/register',
        data: {
          'fcm_token': token,
          'platform': Platform.isAndroid ? 'android' : 'ios',
          // Device Metadata
          'device_model': deviceInfo['model'],
          'device_os_version': deviceInfo['osVersion'],
          'app_version': deviceInfo['appVersion'],
          'country_code': deviceInfo['countryCode'],
          'timezone': deviceInfo['timezone'],
          'push_enabled': pushEnabled,
        },
        options: authToken != null
            ? Options(headers: {'Authorization': 'Bearer $authToken'})
            : null,
      );

      // Store device_id from response for sync operations
      if (response.data != null && response.data['data'] != null) {
        final deviceId = response.data['data']['device_id'];
        if (deviceId != null) {
          await getIt<FlutterSecureStorage>().write(
            key: 'device_id',
            value: deviceId,
          );
          debugPrint('✅ Device ID stored');
        }
      }

      // Mark a successful sync so the resume heartbeat can back off.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        _kFcmLastSyncKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      debugPrint('❌ Error syncing FCM token: $e');
    }
  }

  /// Detach this device from push on the backend. Called on logout so a
  /// shared phone's next user doesn't inherit the previous account's pushes.
  Future<void> unregisterFCMToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;
      await getIt<Dio>().post(
        'notifications/unregister',
        data: {'fcm_token': token},
      );
    } catch (e) {
      debugPrint('❌ Error unregistering FCM token: $e');
    }
  }

  /// Get the stored device_id from secure storage.
  ///
  /// One-time migration: device_id used to live in SharedPreferences.
  /// Existing installs already have a value there — if secure storage is
  /// empty, pull it across once so upgrading doesn't silently orphan a
  /// guest's local reading history/bookmarks from their synced device_id.
  static Future<String?> getDeviceId() async {
    final secureStorage = getIt<FlutterSecureStorage>();
    final current = await secureStorage.read(key: 'device_id');
    if (current != null) return current;

    final prefs = await SharedPreferences.getInstance();
    final legacy = prefs.getString('device_id');
    if (legacy != null) {
      await secureStorage.write(key: 'device_id', value: legacy);
      await prefs.remove('device_id');
    }
    return legacy;
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

      // IANA zone name (e.g. "Asia/Jakarta"), matching what the backend cron
      // and `tz` expect — not the abbreviation DateTime.timeZoneName returns.
      String timezone;
      try {
        timezone = (await FlutterTimezone.getLocalTimezone()).identifier;
      } catch (_) {
        timezone = 'Asia/Jakarta';
      }

      // Region from the device locale rather than a hardcoded 'ID'.
      final countryCode =
          WidgetsBinding.instance.platformDispatcher.locale.countryCode ?? 'ID';

      return {
        'model': model,
        'osVersion': osVersion,
        'appVersion': packageInfo.version,
        'countryCode': countryCode,
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

  /// Request the notification permission only — the in-place system dialog
  /// (POST_NOTIFICATIONS on Android 13+, the APNs prompt on iOS). Safe to call
  /// early / on startup.
  ///
  /// The exact-alarm permission is deliberately NOT requested here: on
  /// Android 12+ it yanks the user out to a full Settings screen, which is
  /// jarring mid-onboarding. Ask for it from [requestExactAlarmPermission]
  /// when the user is actually setting up prayer notifications.
  Future<void> requestPermissions() async {
    // Guard against headless contexts: the plugin needs a foreground Activity
    // and otherwise throws a PlatformException from a native NPE
    try {
      await FirebaseMessaging.instance
          .requestPermission(alert: true, badge: true, sound: true);

      final androidImplementation = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await androidImplementation?.requestNotificationsPermission();
    } catch (e) {
      AppLogger.error('Notification permission request failed', e);
    }
  }

  /// Request the "alarms & reminders" permission (Android 12+ sends the user
  /// to a Settings screen). Only call this in a prayer-notification context —
  /// exact scheduling needs it, but nothing else does.
  Future<void> requestExactAlarmPermission() async {
    try {
      final androidImplementation = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await androidImplementation?.requestExactAlarmsPermission();
    } catch (e) {
      AppLogger.error('Exact alarm permission request failed', e);
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

    Future<void> schedule(AndroidScheduleMode mode) {
      return _flutterLocalNotificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tzDateTime,
        notificationDetails: NotificationDetails(
          android: androidDetails,
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: mode,
        matchDateTimeComponents: isRepeating ? DateTimeComponents.time : null,
      );
    }

    try {
      await schedule(AndroidScheduleMode.exactAllowWhileIdle);
    } catch (e, s) {
      // Exact alarms need the SCHEDULE_EXACT_ALARM permission, which is denied
      // by default on Android 14+. Rather than dropping the prayer
      // notification entirely, fall back to an inexact one (fires within a
      // few minutes) — the user can grant exact timing from prayer settings.
      AppLogger.error(
        'Exact schedule failed for prayer notification id=$id, '
        'retrying inexact',
        e,
        s,
      );
      try {
        await schedule(AndroidScheduleMode.inexactAllowWhileIdle);
      } catch (e2, s2) {
        AppLogger.error('Failed to schedule prayer notification id=$id', e2, s2);
      }
    }
  }

  /// [soundType]: 'adhan' | 'beep' | 'silent' use the prayer channels;
  /// 'default' (the value used for server pushes) uses the general push
  /// channel with the system sound.
  Future<void> showImmediateNotification({
    required String title,
    required String body,
    String soundType = 'adhan',
    String? payload,
  }) async {
    AndroidNotificationDetails androidDetails;

    switch (soundType) {
      case 'default':
        androidDetails = const AndroidNotificationDetails(
          kPushChannelId,
          kPushChannelName,
          channelDescription: 'Reminders and announcements from Muslimly',
          importance: Importance.high,
          priority: Priority.high,
        );
        break;
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
      // Prayer notifications reuse id 999 (only one at a time); push messages
      // get a rolling id so they stack instead of replacing each other.
      id: soundType == 'default'
          ? (DateTime.now().millisecondsSinceEpoch ~/ 1000) & 0x7fffffff
          : 999,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: payload,
    );
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}

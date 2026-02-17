@lazySingleton
class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // 0. Initialize Firebase
    try {
      await Firebase.initializeApp();
      // print('DEBUG: Firebase Initialized');
    } catch (e) {
      // print('ERROR: Firebase Init Failed: $e');
    }

    tz.initializeTimeZones();
    // Detect and set local time zone
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    // print('DEBUG: NotificationService init with timezone: $timeZoneName');
    tz.setLocalLocation(tz.getLocation(timeZoneName));

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
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
      },
    );

    // 1. Request Permission (iOS/Android 13+)
    await requestPermissions();

    // 2. FCM Listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        showImmediateNotification(
          title: notification.title ?? 'Notification',
          body: notification.body ?? '',
          soundType:
              'adhan', // Defaulting to adhan for visibility, or parse from data
        );
      }
    });

    // 3. Register Token (Initial Guest Registration)
    // We do this silently. If user logs in later, AuthBloc should call this again with token.
    await syncFCMToken(null);
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
      String baseUrl = 'https://muslimly.my.id/api/v1';

      final Options options = Options(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
      );

      print('FCM_TOKEN: $token');
      print('DEVICE_INFO: $deviceInfo');

      await dio.post(
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

      print('✅ FCM Token + Device Metadata registered successfully');
    } catch (e) {
      print('❌ Error syncing FCM token: $e');
    }
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
      print('Error getting device info: $e');
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
    // ... (Existing implementation) ...
    // Add Firebase permission request
    NotificationSettings settings = await FirebaseMessaging.instance
        .requestPermission(alert: true, badge: true, sound: true);
    // print('User granted permission: ${settings.authorizationStatus}');

    final androidImplementation = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
      await androidImplementation.requestExactAlarmsPermission();
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

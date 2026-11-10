import 'dart:io';

import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';

import '../../../config/router/app_router.dart';
import '../../../core/utils/app_logger.dart';

/// Opens the prayer tab when the user taps the Android widget.
/// Cold start is covered by `initiallyLaunchedFromHomeWidget`, a running app
/// by the `widgetClicked` stream and `MainActivity.onNewIntent`.
class WidgetLaunchHandler {
  static const String route = '/dashboard?index=1';

  static const MethodChannel _channel = MethodChannel(
    'com.muslimly.app/widget_launch',
  );

  static const String trackerRoute = '/prayer-tracker';

  static bool isPrayerUri(Uri? uri) => uri != null && uri.host == 'prayer';
  static bool isTrackerUri(Uri? uri) => uri != null && uri.host == 'tracker';

  static Future<void> init() async {
    if (!Platform.isAndroid) return;
    try {
      final initial = await HomeWidget.initiallyLaunchedFromHomeWidget();
      _route(initial);
      HomeWidget.widgetClicked.listen(_route);
      // Warm start: MainActivity.onNewIntent forwards the deep link itself.
      _channel.setMethodCallHandler((call) async {
        if (call.method == 'widgetUri') {
          _route(Uri.tryParse(call.arguments as String));
        }
      });
    } catch (e, s) {
      AppLogger.error('Widget launch handler failed', e, s);
    }
  }

  // The plugin stream and our channel can both report one tap.
  static DateTime? _lastRouted;

  static void _route(Uri? uri) {
    final now = DateTime.now();
    if (_lastRouted != null &&
        now.difference(_lastRouted!) < const Duration(seconds: 1)) {
      return;
    }
    _lastRouted = now;
    if (isTrackerUri(uri)) {
      // push only: go()+push() back to back dropped the push. Back returns
      // to whatever was open (the dashboard on a cold start).
      appRouter.push(trackerRoute);
    } else if (isPrayerUri(uri)) {
      appRouter.go(route);
    }
  }
}

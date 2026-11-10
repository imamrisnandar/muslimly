import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
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
  static bool isSettingsUri(Uri? uri) =>
      uri != null && uri.host == 'widget-settings';

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

  static Uri? _pending;
  static AppLifecycleListener? _listener;

  // The plugin stream and our channel can both report one tap.
  static DateTime? _lastRouted;

  static void _route(Uri? uri) {
    // A warm-start intent reaches Dart while the app is still paused; a
    // navigation pushed then never shows. Wait until the app is resumed.
    final state = WidgetsBinding.instance.lifecycleState;
    if (state != null && state != AppLifecycleState.resumed) {
      _pending = uri;
      _listener ??= AppLifecycleListener(
        onResume: () {
          final u = _pending;
          _pending = null;
          if (u != null) {
            // One frame later so the resumed UI is on screen first.
            Future.delayed(const Duration(milliseconds: 250), () => _route(u));
          }
        },
      );
      return;
    }
    final now = DateTime.now();
    if (_lastRouted != null &&
        now.difference(_lastRouted!) < const Duration(seconds: 1)) {
      return;
    }
    _lastRouted = now;
    if (isSettingsUri(uri)) {
      _whenPastSplash(() => appRouter.push('/widget-settings'));
    } else if (isTrackerUri(uri)) {
      // push only: go()+push() back to back dropped the push. Back returns
      // to whatever was open (the dashboard on a cold start).
      _whenPastSplash(() => appRouter.push(trackerRoute));
    } else if (isPrayerUri(uri)) {
      _whenPastSplash(() => appRouter.go(route));
    }
  }

  /// The splash page ends with `go('/dashboard')`, which would wipe anything
  /// pushed while it is still showing (a cold start, or a warm start that
  /// resets the router). Wait until the router has left '/' (max ~10 s).
  static Future<void> _whenPastSplash(void Function() action) async {
    for (var i = 0; i < 40; i++) {
      final path = appRouter.routerDelegate.currentConfiguration.uri.path;
      if (path.isNotEmpty && path != '/') break;
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }
    // Let the destination's first frame settle before covering it.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    action();
  }
}

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Centralized logger. All errors are forwarded to Firebase Crashlytics
/// in release mode. Swap debug internals for `talker`/`logger` if needed.
class AppLogger {
  AppLogger._();

  static void debug(String message, [Object? error]) {
    if (kDebugMode) {
      debugPrint('[DEBUG] $message${error != null ? ' | $error' : ''}');
    }
  }

  static void info(String message) {
    if (kDebugMode) {
      debugPrint('[INFO]  $message');
    }
  }

  static void warning(String message, [Object? error]) {
    debugPrint('[WARN]  $message${error != null ? ' | $error' : ''}');
    if (!kDebugMode && error != null) {
      FirebaseCrashlytics.instance.log('WARN: $message | $error');
    }
  }

  static void error(
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    debugPrint('[ERROR] $message${error != null ? ' | $error' : ''}');
    if (kDebugMode && stackTrace != null) {
      debugPrint(stackTrace.toString());
    }
    if (!kDebugMode) {
      FirebaseCrashlytics.instance.recordError(
        error ?? message,
        stackTrace,
        reason: message,
        fatal: false,
      );
    }
  }

  /// Log a fatal error — app cannot continue.
  static void fatal(String message, Object error, StackTrace stackTrace) {
    debugPrint('[FATAL] $message | $error');
    FirebaseCrashlytics.instance.recordError(
      error,
      stackTrace,
      reason: message,
      fatal: true,
    );
  }
}

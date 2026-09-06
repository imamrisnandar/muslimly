import 'package:flutter_test/flutter_test.dart';
import 'package:muslimly/src/core/services/notification_service.dart';

void main() {
  group('resolveNotificationRoute', () {
    test('honours an explicit absolute route', () {
      expect(
        resolveNotificationRoute({'route': '/quran/bookmarks'}),
        '/quran/bookmarks',
      );
    });

    test('ignores a non-absolute route and falls back to type', () {
      expect(
        resolveNotificationRoute({'route': 'quran/bookmarks', 'type': 'daily_reminder'}),
        '/dashboard?index=2',
      );
    });

    test('maps daily_reminder to the Quran tab', () {
      expect(
        resolveNotificationRoute({'type': 'daily_reminder'}),
        '/dashboard?index=2',
      );
    });

    test('unknown type opens the dashboard', () {
      expect(resolveNotificationRoute({'type': 'something_new'}), '/dashboard');
      expect(resolveNotificationRoute({}), '/dashboard');
    });

    test('route wins over type', () {
      expect(
        resolveNotificationRoute({'route': '/settings', 'type': 'daily_reminder'}),
        '/settings',
      );
    });
  });
}

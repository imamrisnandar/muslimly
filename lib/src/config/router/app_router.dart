import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/quran/domain/entities/surah.dart';
import '../../features/quran/presentation/pages/surah_detail_page.dart';
import '../../features/quran/presentation/pages/mushaf_page.dart';
import '../../features/intro/presentation/pages/splash_page.dart';
import '../../features/intro/presentation/pages/name_input_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/quran/presentation/pages/bookmarks_page.dart';

import '../../features/quran/presentation/pages/reading_history_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashPage()),
    GoRoute(
      path: '/name-input',
      builder: (context, state) => const NameInputPage(),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) {
        final index =
            int.tryParse(state.uri.queryParameters['index'] ?? '0') ?? 0;
        return DashboardPage(initialIndex: index);
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: '/quran/bookmarks',
      builder: (context, state) => const BookmarksPage(),
    ),
    GoRoute(
      path: '/quran/history',
      builder: (context, state) => const ReadingHistoryPage(),
    ),
    GoRoute(
      path: '/quran/mushaf/:number',
      builder: (context, state) {
        // Handle both simple Surah object and expanded Map options
        final extra = state.extra;
        Surah surah;
        int? initialPage;

        if (extra is Surah) {
          surah = extra;
        } else if (extra is Map) {
          surah = extra['surah'] as Surah;
          initialPage = extra['initialPage'] as int?;
        } else {
          // Fallback or Error
          throw Exception("Invalid Extra for MushafPage");
        }

        final startAtEnd = state.uri.queryParameters['startAtEnd'] == 'true';

        return MushafPage(
          surah: surah,
          startAtEnd: startAtEnd,
          initialPage: initialPage,
        );
      },
    ),
    GoRoute(
      path: '/quran/:number',
      builder: (context, state) {
        final surah = state.extra as Surah;
        return SurahDetailPage(surah: surah);
      },
    ),
  ],
);

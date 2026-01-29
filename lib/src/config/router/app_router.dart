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
import '../../features/dashboard/presentation/pages/daily_inspiration_page.dart';
import '../../core/utils/quran_constants.dart';
import '../../features/quran/presentation/pages/search_results_page.dart';

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
        int? initialAyah;

        if (extra is Surah) {
          surah = extra;
        } else if (extra is Map) {
          surah = extra['surah'] as Surah;
          initialPage = extra['initialPage'] as int?;
          initialAyah = extra['initialAyah'] as int?;
        } else {
          // Fallback or Error
          throw Exception("Invalid Extra for MushafPage");
        }

        final startAtEnd = state.uri.queryParameters['startAtEnd'] == 'true';

        return MushafPage(
          surah: surah,
          startAtEnd: startAtEnd,
          initialPage: initialPage,
          initialAyah: initialAyah,
        );
      },
    ),
    GoRoute(
      path: '/quran/:number',
      builder: (context, state) {
        final extra = state.extra;
        Surah surah;
        int? initialAyah;

        if (extra is Surah) {
          surah = extra;
        } else if (extra is Map) {
          surah = extra['surah'] as Surah;
          initialAyah = extra['initialAyah'] as int?;
        } else {
          throw Exception("Invalid Extra for SurahDetailPage");
        }

        return SurahDetailPage(surah: surah, initialAyah: initialAyah);
      },
    ),
    GoRoute(
      path: '/mushaf',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        int? pageNumber = extra?['pageNumber'] as int?;
        final surahNumber = extra?['surahNumber'] as int?;
        final ayahNumber = extra?['ayahNumber'] as int?;

        // If pageNumber is missing but we have surahNumber, find the start page
        if (pageNumber == null && surahNumber != null) {
          pageNumber = QuranConstants.surahPageStart[surahNumber];
        }

        return MushafPage(initialPage: pageNumber, initialAyah: ayahNumber);
      },
    ),
    GoRoute(
      path: '/daily-inspiration',
      builder: (context, state) => const DailyInspirationPage(),
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) {
        final query = state.uri.queryParameters['q'] ?? '';
        return SearchResultsPage(initialQuery: query);
      },
    ),
  ],
);

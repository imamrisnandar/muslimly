import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'src/l10n/generated/app_localizations.dart'; // Localization
import 'src/features/settings/presentation/bloc/settings_cubit.dart';
import 'src/features/settings/presentation/bloc/settings_state.dart';
import 'src/features/auth/presentation/bloc/auth_bloc.dart';
import 'src/config/router/app_router.dart';
import 'src/core/di/di_container.dart';

import 'src/core/services/notification_service.dart';
import 'src/core/services/background_service.dart';

import 'src/features/quran/presentation/bloc/audio_bloc.dart';
import 'src/features/quran/presentation/bloc/audio_event.dart'; // Init audio if needed

import 'package:just_audio_background/just_audio_background.dart';
import 'package:google_fonts/google_fonts.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Fonts are bundled in assets/google_fonts — never fetch from the network,
  // so offline devices get the real fonts instead of a fatal-looking error
  GoogleFonts.config.allowRuntimeFetching = false;

  // Crashlytics — capture Flutter framework errors
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Crashlytics — capture async/platform errors outside Flutter's zone
  PlatformDispatcher.instance.onError = (error, stack) {
    // Font loading failures don't crash the app (text falls back to the
    // default font) — record them as non-fatal so they don't skew the
    // crash-free rate. Covers both google_fonts messages: network fetch
    // ("Failed to load font with url") and missing bundled asset
    // ("GoogleFonts.config.allowRuntimeFetching is false but font ...").
    final errorText = error.toString();
    final isFontLoadError = error is Exception &&
        (errorText.contains('Failed to load font') ||
            errorText.contains('GoogleFonts.config.allowRuntimeFetching'));
    FirebaseCrashlytics.instance.recordError(
      error,
      stack,
      fatal: !isFontLoadError,
    );
    return true;
  };

  // Disable Crashlytics collection in debug to avoid polluting reports
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);

  configureDependencies();

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.muslimly.app.channel.audio',
    androidNotificationChannelName: 'Audio Playback',
    androidNotificationOngoing: true,
    androidNotificationIcon: 'mipmap/ic_launcher',
  );
  await getIt<NotificationService>().initialize();
  getIt.registerLazySingleton<BackgroundService>(() => BackgroundService());
  getIt<BackgroundService>().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(392.72727272727275, 800.7272727272727),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => getIt<AuthBloc>()),
            BlocProvider(create: (_) => getIt<SettingsCubit>()),
            BlocProvider(create: (_) => getIt<AudioBloc>()..add(InitAudio())),
          ],
          child: BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, state) {
              return MaterialApp.router(
                title: 'Muslimly',
                debugShowCheckedModeBanner: false,
                locale: state.locale,
                localizationsDelegates:
                    AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                theme: ThemeData(
                  useMaterial3: true,
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: const Color(0xFF00E676),
                    primary: const Color(0xFF00E676),
                  ),
                ),
                routerConfig: appRouter,
              );
            },
          ),
        );
      },
    );
  }
}

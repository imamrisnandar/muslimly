import 'package:just_audio/just_audio.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/location_service.dart';

// Article Feature
import '../../features/article/data/datasources/article_local_data_source.dart';
import '../../features/article/data/datasources/article_remote_data_source.dart';
import '../../features/article/data/repositories/article_repository_impl.dart';
import '../../features/article/domain/repositories/article_repository.dart';
import '../../features/article/presentation/bloc/article_bloc.dart';

import '../../features/intro/data/repositories/name_repository.dart';
import '../../features/intro/domain/repositories/name_repository.dart' show NameRepository;
import '../../features/settings/data/repositories/settings_repository.dart'; // Settings Repo
import '../../features/settings/presentation/bloc/settings_cubit.dart'; // Settings Cubit
import '../services/notification_service.dart';
import '../services/showcase_preferences_service.dart';
import '../database/database_service.dart';

// Network
import 'network_module.dart';

// Auth
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/forgot_password_bloc.dart';

// Prayer
import '../../features/prayer/data/repositories/prayer_repository_impl.dart';

import '../../features/prayer/domain/repositories/prayer_repository.dart';
import '../../features/prayer/domain/usecases/get_prayer_time.dart';
import '../../features/prayer/domain/usecases/search_city.dart';
import '../../features/prayer/presentation/bloc/prayer_bloc.dart';

// Quran
import '../../features/quran/data/datasources/quran_local_data_source.dart';
import '../../features/quran/data/datasources/remote/sync_api_service.dart'; // Added SyncApiService
// import '../../features/quran/data/datasources/quran_remote_data_source.dart';
import '../../features/quran/data/repositories/quran_repository_impl.dart';
import '../../features/quran/data/repositories/last_read_repository.dart'; // Added
import '../../features/quran/domain/repositories/quran_repository.dart';
import '../../features/quran/domain/usecases/get_ayahs.dart';
import '../../features/quran/domain/usecases/get_page_for_ayah.dart';
import '../../features/quran/domain/usecases/get_surahs.dart';
import '../../features/quran/presentation/bloc/quran_bloc.dart';
import '../../features/quran/presentation/bloc/reading/reading_bloc.dart';
import '../../features/quran/presentation/bloc/bookmark/bookmark_bloc.dart';
import '../../features/quran/data/repositories/audio_repository.dart';
import '../../features/quran/presentation/bloc/audio_bloc.dart';
import '../../features/zikir/data/repositories/zikir_local_repository.dart' show ZikirLocalRepository;
import '../../features/zikir/domain/repositories/zikir_repository.dart' show ZikirRepository;
import '../../features/zikir/domain/usecases/get_zikir_content.dart';
import '../../features/quran/data/repositories/translation_repository_impl.dart';
import '../../features/tajweed/data/repositories/tajweed_repository.dart'; // Added
import '../../features/tajweed/domain/usecases/get_tajweed_content.dart';
import '../../features/fasting/data/repositories/fasting_repository.dart' show FastingRepositoryImpl;
import '../../features/fasting/domain/repositories/fasting_repository.dart' show FastingRepository;
import '../../features/fasting/domain/usecases/get_fasting_content.dart';
import '../../features/fasting/presentation/bloc/fasting_cubit.dart';
import '../../features/wudhu/data/repositories/wudhu_repository.dart' show WudhuRepositoryImpl;
import '../../features/wudhu/domain/repositories/wudhu_repository.dart' show WudhuRepository;
import '../../features/wudhu/domain/usecases/get_wudhu_content.dart';
import '../../features/wudhu/presentation/bloc/wudhu_cubit.dart';
import '../../features/prayer/domain/services/fasting_service.dart'; // Added
import '../../features/dashboard/domain/services/reminder_service.dart'; // Added
import '../../features/prayer/data/repositories/prayer_guide_repository.dart'; // Added
import '../../features/prayer/domain/usecases/get_prayer_guide_content.dart';
import '../../features/quran/domain/repositories/translation_repository.dart';
import '../../features/quran/presentation/bloc/translation/translation_bloc.dart';
import '../../features/quran/domain/usecases/search_ayahs.dart'; // Added
import '../../features/quran/presentation/bloc/search/search_bloc.dart'; // Added

final getIt = GetIt.instance;

void configureDependencies() {
  final networkModule = _$NetworkModule();

  // Register Dio
  getIt.registerLazySingleton<Dio>(() => networkModule.dio);

  // --- Core ---
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    ),
  );
  getIt.registerLazySingleton<ShowcasePreferencesService>(
    () => ShowcasePreferencesService(),
  );

  // --- Auth Feature ---
  getIt.registerFactory<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(getIt<Dio>()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      getIt<AuthRemoteDataSource>(),
      getIt<FlutterSecureStorage>(),
    ),
  );
  getIt.registerFactory<LoginUseCase>(
    () => LoginUseCase(getIt<AuthRepository>()),
  );
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      getIt<LoginUseCase>(),
      getIt<AuthRepository>(),
      getIt<NotificationService>(),
      getIt<DatabaseService>(),
      getIt<LastReadRepository>(),
      getIt<SyncApiService>(),
    ),
  );
  getIt.registerFactory<ForgotPasswordBloc>(
    () => ForgotPasswordBloc(getIt<AuthRepository>()),
  );

  // --- Prayer Feature ---

  getIt.registerLazySingleton<PrayerRepository>(
    () => PrayerRepositoryImpl(getIt<SettingsRepository>()),
  );
  getIt.registerFactory<GetPrayerTime>(
    () => GetPrayerTime(getIt<PrayerRepository>()),
  );
  getIt.registerFactory<SearchCity>(
    () => SearchCity(getIt<PrayerRepository>()),
  );
  // --- Utils ---
  getIt.registerLazySingleton<LocationService>(() => LocationService());
  getIt.registerLazySingleton<NameRepository>(
    () => NameRepositoryImpl(
      getIt<DatabaseService>(),
      getIt<AuthRepository>(),
      getIt<SyncApiService>(),
    ),
  );
  getIt.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(
      getIt<DatabaseService>(),
      getIt<Dio>(),
      getIt<AuthRepository>(),
      getIt<SyncApiService>(),
    ),
  );
  getIt.registerLazySingleton<NotificationService>(() => NotificationService());

  getIt.registerFactory<SettingsCubit>(
    () => SettingsCubit(
      getIt<SettingsRepository>(),
      getIt<NameRepository>(),
      getIt<NotificationService>(),
      getIt<FastingService>(),
    ),
  );

  getIt.registerFactory<PrayerBloc>(
    () => PrayerBloc(
      getIt<GetPrayerTime>(),
      getIt<SearchCity>(),
      getIt<LocationService>(),
      getIt<NotificationService>(),
      getIt<SettingsRepository>(),
      getIt<LastReadRepository>(),
      getIt<FastingService>(),
    ),
  );

  // --- Database ---
  getIt.registerLazySingleton<DatabaseService>(() => DatabaseService());

  // --- Quran Feature ---
  getIt.registerLazySingleton<QuranLocalDataSource>(
    () => QuranLocalDataSourceImpl(),
  );
  getIt.registerLazySingleton<SyncApiService>(
    () => SyncApiService(getIt<Dio>()),
  );
  getIt.registerLazySingleton<QuranRepository>(
    () => QuranRepositoryImpl(
      getIt<QuranLocalDataSource>(),
      getIt<DatabaseService>(),
      getIt<SyncApiService>(),
    ),
  );
  getIt.registerLazySingleton<LastReadRepository>(() => LastReadRepository());

  getIt.registerFactory<GetSurahs>(() => GetSurahs(getIt<QuranRepository>()));
  getIt.registerFactory<GetAyahs>(() => GetAyahs(getIt<QuranRepository>()));
  getIt.registerFactory<GetPageForAyah>(() => GetPageForAyah(getIt<QuranRepository>()));
  getIt.registerFactory<QuranBloc>(
    () => QuranBloc(getIt<GetSurahs>(), getIt<GetAyahs>()),
  );
  getIt.registerFactory<ReadingBloc>(
    () => ReadingBloc(
      getIt<DatabaseService>(),
      getIt<SettingsRepository>(),
      getIt<AuthRepository>(),
      getIt<QuranRepository>(),
      getIt<LastReadRepository>(),
    ),
  );
  getIt.registerFactory<BookmarkBloc>(
    () => BookmarkBloc(
      getIt<DatabaseService>(),
      getIt<LastReadRepository>(),
      getIt<SyncApiService>(),
      getIt<AuthRepository>(),
    ),
  );

  // --- Translation & Tafsir ---
  getIt.registerLazySingleton<TranslationRepository>(
    () => TranslationRepositoryImpl(getIt<DatabaseService>()),
  );
  getIt.registerFactory<TranslationBloc>(
    () => TranslationBloc(getIt<TranslationRepository>()),
  );

  // --- Search Feature ---
  getIt.registerFactory<SearchAyahs>(
    () => SearchAyahs(getIt<QuranRepository>()),
  );
  getIt.registerFactory<SearchBloc>(() => SearchBloc(getIt<SearchAyahs>()));

  // --- Murottal / Audio ---
  getIt.registerLazySingleton<AudioPlayer>(() => AudioPlayer());
  getIt.registerLazySingleton<AudioRepository>(
    () => AudioRepositoryImpl(getIt<DatabaseService>()),
  );
  getIt.registerLazySingleton<AudioBloc>(
    () => AudioBloc(
      getIt<AudioRepository>(),
      getIt<QuranRepository>(),
      getIt<AudioPlayer>(),
    ),
  );

  // --- Zikir Feature ---
  getIt.registerLazySingleton<ZikirRepository>(
    () => ZikirLocalRepository(),
  );
  getIt.registerFactory<GetZikirContent>(() => GetZikirContent(getIt<ZikirRepository>()));

  // --- Tajweed Feature ---
  getIt.registerLazySingleton<TajweedRepository>(() => TajweedRepositoryImpl());
  getIt.registerFactory<GetTajweedContent>(() => GetTajweedContent(getIt<TajweedRepository>()));

  // --- Fasting Feature ---
  getIt.registerLazySingleton<FastingRepository>(() => FastingRepositoryImpl());
  getIt.registerFactory<GetFastingContent>(() => GetFastingContent(getIt<FastingRepository>()));
  getIt.registerFactory<FastingCubit>(() => FastingCubit(getIt<GetFastingContent>()));

  getIt.registerLazySingleton<FastingService>(() => FastingService()); // Added

  // --- Reminder Service ---
  getIt.registerLazySingleton<ReminderService>(
    () => ReminderService(getIt<FastingService>()),
  );

  // --- Wudhu Feature ---
  getIt.registerLazySingleton<WudhuRepository>(() => WudhuRepositoryImpl());
  getIt.registerFactory<GetWudhuContent>(() => GetWudhuContent(getIt<WudhuRepository>()));
  getIt.registerFactory<WudhuCubit>(() => WudhuCubit(getIt<GetWudhuContent>()));

  // --- Prayer Feature ---
  getIt.registerLazySingleton<PrayerGuideRepository>(
    () => PrayerGuideRepository(),
  );
  getIt.registerFactory<GetPrayerGuideContent>(() => GetPrayerGuideContent(getIt<PrayerGuideRepository>()));

  // --- Article Feature ---
  getIt.registerLazySingleton<ArticleLocalDataSource>(
    () => ArticleLocalDataSourceImpl(getIt<DatabaseService>()),
  );
  getIt.registerLazySingleton<ArticleRemoteDataSource>(
    () => ArticleRemoteDataSourceImpl(getIt<Dio>()),
  );
  getIt.registerLazySingleton<ArticleRepository>(
    () => ArticleRepositoryImpl(
      localDataSource: getIt<ArticleLocalDataSource>(),
      remoteDataSource: getIt<ArticleRemoteDataSource>(),
    ),
  );
  getIt.registerFactory<ArticleBloc>(
    () => ArticleBloc(repository: getIt<ArticleRepository>()),
  );
}

class _$NetworkModule extends NetworkModule {}

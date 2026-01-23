import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '../utils/location_service.dart';
import '../../features/intro/data/repositories/name_repository.dart';
import '../../features/settings/data/repositories/settings_repository.dart'; // Settings Repo
import '../../features/settings/presentation/bloc/settings_cubit.dart'; // Settings Cubit
import '../services/notification_service.dart';
import '../database/database_service.dart';

// Network
import 'network_module.dart';

// Auth
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

// Prayer
import '../../features/prayer/data/datasources/prayer_remote_data_source.dart';
import '../../features/prayer/data/repositories/prayer_repository_impl.dart';
import '../../features/prayer/domain/repositories/prayer_repository.dart';
import '../../features/prayer/domain/usecases/get_prayer_time.dart';
import '../../features/prayer/domain/usecases/search_city.dart';
import '../../features/prayer/presentation/bloc/prayer_bloc.dart';

// Quran
import '../../features/quran/data/datasources/quran_local_data_source.dart';
// import '../../features/quran/data/datasources/quran_remote_data_source.dart';
import '../../features/quran/data/repositories/quran_repository_impl.dart';
import '../../features/quran/data/repositories/last_read_repository.dart'; // Added
import '../../features/quran/domain/repositories/quran_repository.dart';
import '../../features/quran/domain/usecases/get_ayahs.dart';
import '../../features/quran/domain/usecases/get_surahs.dart';
import '../../features/quran/presentation/bloc/quran_bloc.dart';
import '../../features/quran/presentation/bloc/reading/reading_bloc.dart';
import '../../features/quran/presentation/bloc/bookmark/bookmark_bloc.dart';
import '../../features/quran/data/repositories/audio_repository.dart';
import '../../features/quran/presentation/bloc/audio_bloc.dart';
import '../../features/zikir/data/repositories/zikir_local_repository.dart';

final getIt = GetIt.instance;

void configureDependencies() {
  final networkModule = _$NetworkModule();

  // Register Dio
  getIt.registerLazySingleton<Dio>(() => networkModule.dio);

  // --- Auth Feature ---
  getIt.registerFactory<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(getIt<Dio>()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<AuthRemoteDataSource>()),
  );
  getIt.registerFactory<LoginUseCase>(
    () => LoginUseCase(getIt<AuthRepository>()),
  );
  getIt.registerFactory<AuthBloc>(() => AuthBloc(getIt<LoginUseCase>()));

  // --- Prayer Feature ---
  getIt.registerLazySingleton<PrayerRemoteDataSource>(
    () => networkModule.getPrayerRemoteDataSource(getIt<Dio>()),
  );
  getIt.registerLazySingleton<PrayerRepository>(
    () => PrayerRepositoryImpl(getIt<PrayerRemoteDataSource>()),
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
    () => NameRepositoryImpl(getIt<DatabaseService>()),
  );
  getIt.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(getIt<DatabaseService>()),
  );
  getIt.registerLazySingleton<NotificationService>(() => NotificationService());

  getIt.registerFactory<SettingsCubit>(
    () => SettingsCubit(
      getIt<SettingsRepository>(),
      getIt<NameRepository>(),
      getIt<NotificationService>(),
    ),
  );

  getIt.registerFactory<PrayerBloc>(
    () => PrayerBloc(
      getIt<GetPrayerTime>(),
      getIt<SearchCity>(),
      getIt<LocationService>(),
      getIt<NotificationService>(),
      getIt<SettingsRepository>(),
      getIt<LastReadRepository>(), // Added
    ),
  );

  // --- Database ---
  getIt.registerLazySingleton<DatabaseService>(() => DatabaseService());

  // --- Quran Feature ---
  getIt.registerLazySingleton<QuranLocalDataSource>(
    () => QuranLocalDataSourceImpl(),
  );
  getIt.registerLazySingleton<QuranRepository>(
    () => QuranRepositoryImpl(getIt<QuranLocalDataSource>()),
  );
  getIt.registerLazySingleton<LastReadRepository>(() => LastReadRepository());

  getIt.registerFactory<GetSurahs>(() => GetSurahs(getIt<QuranRepository>()));
  getIt.registerFactory<GetAyahs>(() => GetAyahs(getIt<QuranRepository>()));
  getIt.registerFactory<QuranBloc>(
    () => QuranBloc(getIt<GetSurahs>(), getIt<GetAyahs>()),
  );
  getIt.registerFactory<ReadingBloc>(
    () => ReadingBloc(getIt<DatabaseService>(), getIt<SettingsRepository>()),
  );
  getIt.registerFactory<BookmarkBloc>(
    () => BookmarkBloc(getIt<DatabaseService>(), getIt<LastReadRepository>()),
  );

  // --- Murottal / Audio ---
  getIt.registerLazySingleton<AudioRepository>(
    () => AudioRepositoryImpl(getIt<Dio>(), getIt<DatabaseService>()),
  );
  getIt.registerFactory<AudioBloc>(() => AudioBloc(getIt<AudioRepository>()));

  // --- Zikir Feature ---
  getIt.registerLazySingleton<ZikirLocalRepository>(
    () => ZikirLocalRepository(),
  );
}

class _$NetworkModule extends NetworkModule {}

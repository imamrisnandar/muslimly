# Muslimly — Architecture Documentation

> Flutter app: Islamic companion (Quran, prayer times, fasting, dhikr)
> Last updated: 2026-06-04

---

## Daftar Isi

1. [Gambaran Umum](#1-gambaran-umum)
2. [Struktur Folder](#2-struktur-folder)
3. [Clean Architecture](#3-clean-architecture)
4. [State Management](#4-state-management)
5. [Dependency Injection](#5-dependency-injection)
6. [Navigasi](#6-navigasi)
7. [Network Layer](#7-network-layer)
8. [Database Lokal](#8-database-lokal)
9. [Lokalisasi](#9-lokalisasi)
10. [Core Infrastructure](#10-core-infrastructure)
11. [Feature Modules](#11-feature-modules)
12. [Data Flow](#12-data-flow)

---

## 1. Gambaran Umum

Muslimly dibangun dengan **Flutter** menggunakan pola **Clean Architecture** dengan struktur **feature-based**. Setiap fitur punya layer terpisah: `data`, `domain`, dan `presentation`.

### Stack Utama

| Kategori | Library |
|---|---|
| State Management | `flutter_bloc` (BLoC + Cubit) |
| Dependency Injection | `get_it` (manual, tidak code-gen) |
| Routing | `go_router` v17 |
| HTTP | `dio` v5 dengan SSL pinning |
| Database Lokal | `sqflite` |
| Error Handling | `fpdart` (`Either<L, R>`) |
| Kode Immutable | `freezed` |
| Audio | `just_audio` + `audio_service` |
| Firebase | `firebase_core`, `firebase_messaging`, `firebase_crashlytics` |
| Notifikasi | `flutter_local_notifications` |

---

## 2. Struktur Folder

```
lib/
├── main.dart                        ← Entry point, Firebase + DI init
└── src/
    ├── config/
    │   └── router/
    │       └── app_router.dart      ← GoRouter config, semua routes
    ├── core/                        ← Shared infrastructure
    │   ├── config/
    │   │   └── app_urls.dart        ← Semua URL/endpoint terpusat
    │   ├── database/
    │   │   └── database_service.dart ← SQLite singleton, 7 tabel
    │   ├── di/
    │   │   ├── di_container.dart    ← Semua registrasi GetIt
    │   │   └── network_module.dart  ← Dio + SSL pinning
    │   ├── error/
    │   │   ├── failures.dart        ← ServerFailure, CacheFailure
    │   │   └── exceptions.dart      ← ServerException, CacheException
    │   ├── presentation/
    │   │   └── widgets/
    │   │       ├── app_transparent_app_bar.dart
    │   │       └── premium_showcase.dart
    │   ├── services/
    │   │   ├── notification_service.dart  ← FCM + local notifications
    │   │   ├── background_service.dart    ← Workmanager tasks
    │   │   └── showcase_preferences_service.dart
    │   ├── theme/
    │   │   ├── app_colors.dart      ← Named colors + gradient helpers
    │   │   └── app_dimensions.dart  ← Spacing, radius, font size constants
    │   ├── utils/
    │   │   ├── app_logger.dart      ← Centralized logger → Crashlytics
    │   │   ├── custom_snackbar.dart
    │   │   ├── location_service.dart
    │   │   ├── quran_constants.dart
    │   │   ├── surah_names.dart
    │   │   └── tajweed_parser.dart
    │   └── widgets/
    │       └── islamic_loading_indicator.dart
    ├── features/                    ← 10 feature modules
    │   ├── article/
    │   ├── auth/
    │   ├── dashboard/
    │   ├── fasting/
    │   ├── intro/
    │   ├── prayer/
    │   ├── quran/
    │   ├── settings/
    │   ├── tajweed/
    │   ├── wudhu/
    │   └── zikir/
    └── l10n/
        ├── arb/
        │   ├── app_en.arb
        │   └── app_id.arb
        └── generated/
            └── app_localizations.dart
```

---

## 3. Clean Architecture

Setiap feature mengikuti struktur 3 layer:

```
features/[nama_feature]/
├── data/
│   ├── datasources/         ← Remote (API) dan Local (DB/assets)
│   ├── models/              ← JSON serializable, implements Entity
│   └── repositories/        ← Implementasi konkret repository
├── domain/
│   ├── entities/            ← Pure Dart class, tidak tahu Flutter/DB
│   ├── repositories/        ← Abstract interface (contract)
│   └── usecases/            ← Single-responsibility business logic
└── presentation/
    ├── bloc/                ← BLoC atau Cubit + State + Event
    ├── pages/               ← Halaman (route destination)
    └── widgets/             ← Widget reusable per-feature
```

### Prinsip

- **Dependency rule**: layer dalam tidak boleh tahu layer luar.
  ```
  presentation → domain ← data
  ```
- **Domain** hanya berisi Dart murni, tidak ada import Flutter/package eksternal.
- **Data layer** mengimplementasikan interface dari domain.
- **Presentation** hanya memanggil use case, tidak langsung ke repository.

### Status per Feature

| Feature | Data | Domain | Presentation | Catatan |
|---|---|---|---|---|
| quran | ✅ | ✅ | ✅ BLoC | Feature terbesar, 7 BLoC |
| auth | ✅ | ✅ | ✅ BLoC | flutter_secure_storage |
| prayer | ✅ | ✅ | ✅ BLoC | Adhan calculation |
| article | ✅ | ✅ | ✅ BLoC | Cache lokal |
| fasting | ✅ | ✅ | ✅ Cubit | Local JSON assets |
| wudhu | ✅ | ✅ | ✅ Cubit | Hardcoded content |
| zikir | ✅ | ✅ | ⚠️ setState | Belum ada Cubit |
| intro | ✅ | ✅ | ⚠️ setState | Belum ada Cubit |
| settings | ✅ | ❌ | ✅ Cubit | Domain layer belum ada |
| tajweed | ✅ | ❌ | — | Domain layer belum ada |
| dashboard | ✅ | ✅ service | — | Service-based, tanpa usecase |

---

## 4. State Management

### BLoC — Event-Driven

Digunakan untuk feature dengan state kompleks dan banyak interaksi.

```dart
// Pattern
class MyBloc extends Bloc<MyEvent, MyState> {
  MyBloc(this._useCase) : super(MyInitial()) {
    on<MyEvent>(_onMyEvent);
  }

  Future<void> _onMyEvent(MyEvent event, Emitter<MyState> emit) async {
    emit(MyLoading());
    final result = await _useCase(event.params);
    result.fold(
      (failure) => emit(MyError(failure)),
      (data)    => emit(MyLoaded(data)),
    );
  }
}
```

**BLoC yang Ada (10 total):**

| BLoC | Feature | Kegunaan |
|---|---|---|
| `QuranBloc` | quran | Load surah list, ayah list |
| `AudioBloc` | quran | Playback audio Quran (play/pause/seek/reciter) |
| `BookmarkBloc` | quran | CRUD bookmark ayah/halaman |
| `ReadingBloc` | quran | Tracking aktivitas membaca |
| `HafalanBloc` | quran | Speech recognition untuk hafalan |
| `SearchBloc` | quran | Cari ayah |
| `TranslationBloc` | quran | Load terjemahan + tafsir |
| `PrayerBloc` | prayer | Jadwal sholat, pencarian kota |
| `AuthBloc` | auth | Login, status autentikasi |
| `ArticleBloc` | article | Load + cache artikel |

### Cubit — Simplified

Digunakan untuk feature dengan state lebih sederhana.

```dart
// Pattern
class MyCubit extends Cubit<MyState> {
  MyCubit(this._useCase) : super(const MyState());

  Future<void> loadData(String param) async {
    emit(state.copyWith(status: MyStatus.loading));
    try {
      final data = await _useCase(param);
      emit(state.copyWith(items: data, status: MyStatus.loaded));
    } catch (e) {
      emit(state.copyWith(status: MyStatus.error, errorMessage: e.toString()));
    }
  }
}
```

**Cubit yang Ada (3 total):**

| Cubit | Feature | State |
|---|---|---|
| `SettingsCubit` | settings | locale, userName, notifikasi settings |
| `FastingCubit` | fasting | items, query, status (loading/loaded/error) |
| `WudhuCubit` | wudhu | items, query, status |

### Widget Usage

```dart
// Provide BLoC
BlocProvider(
  create: (_) => getIt<QuranBloc>()..add(QuranFetchSurahs()),
  child: QuranPage(),
)

// Consume state
BlocBuilder<QuranBloc, QuranState>(
  builder: (context, state) {
    if (state is QuranLoading) return LoadingWidget();
    if (state is QuranSurahsLoaded) return SurahList(state.surahs);
    return ErrorWidget();
  },
)

// Listen for side effects
BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is AuthAuthenticated) context.go('/dashboard');
  },
)
```

---

## 5. Dependency Injection

Menggunakan `get_it` sebagai service locator dengan registrasi **manual** di satu file terpusat.

### File

```
lib/src/core/di/di_container.dart
```

### Cara Registrasi

```dart
// Singleton — satu instance sepanjang app lifecycle
getIt.registerLazySingleton<AuthRepository>(
  () => AuthRepositoryImpl(
    getIt<AuthRemoteDataSource>(),
    getIt<FlutterSecureStorage>(),
  ),
);

// Factory — instance baru setiap dipanggil
getIt.registerFactory<AuthBloc>(
  () => AuthBloc(getIt<LoginUseCase>()),
);
```

### Cara Penggunaan

```dart
// Di widget/page (via DI)
final bloc = getIt<QuranBloc>();

// Di BlocProvider
BlocProvider(create: (_) => getIt<QuranBloc>()..add(QuranFetchSurahs()))

// Di service/repository (via constructor)
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(
    this._settingsRepository,
    this._nameRepository,
    this._notificationService,
    this._fastingService,
  ) : super(const SettingsState());
}
```

### Urutan Registrasi

```
1. Core (FlutterSecureStorage, ShowcasePreferencesService)
2. Network (Dio)
3. Database (DatabaseService)
4. Auth feature (DataSource → Repository → UseCase → BLoC)
5. Prayer feature
6. Quran feature
7. Settings feature
8. Article feature
9. Dashboard services
10. Zikir, Fasting, Wudhu, Tajweed
```

---

## 6. Navigasi

Menggunakan **GoRouter** v17 dengan named routes dan type-safe parameter passing.

### Konfigurasi

```
lib/src/config/router/app_router.dart
```

### Routes

```
/                     → SplashPage
/onboarding           → OnboardingPage
/name-input           → NameInputPage
/login                → LoginPage
/dashboard            → DashboardPage (tab index: 0-4)
/settings             → SettingsPage
/quran/:number        → SurahDetailPage (list mode)
/quran/mushaf/:number → MushafPage (page view mode)
/quran/hafalan/:number → HafalanPage
/mushaf               → MushafPage (query: pageNumber)
/quran/bookmarks      → BookmarksPage
/quran/history        → ReadingHistoryPage
/qibla                → QiblaCompassPage
/daily-inspiration    → DailyInspirationPage
/search               → SearchResultsPage (query: q)
/article-list         → ArticleListPage
/article-search       → ArticleSearchPage
/article-detail       → ArticleDetailPage
```

### Passing Data

```dart
// Simple navigation
context.go('/dashboard?index=2');
context.push('/quran/${surah.number}');

// Passing complex object via extra
context.push(
  '/quran/${surah.number}',
  extra: {
    'surah': surah,
    'initialAyah': ayahNumber,
  },
);

// Receiving di route
GoRoute(
  path: '/quran/:number',
  builder: (context, state) {
    final extra = state.extra as Map<String, dynamic>;
    final surah = extra['surah'] as Surah;
    return SurahDetailPage(surah: surah);
  },
)
```

---

## 7. Network Layer

### Konfigurasi Dio

```
lib/src/core/di/network_module.dart
```

```dart
Dio(BaseOptions(
  baseUrl: '${AppUrls.baseApi}/',   // https://muslimly.my.id/api/v1/
  connectTimeout: Duration(seconds: 30),
  receiveTimeout: Duration(seconds: 30),
  headers: {
    'Content-Type': 'application/json',
    'X-Device-ID': Platform.isAndroid ? 'android' : 'ios',
  },
))
```

### SSL Pinning

- **Mode**: Let's Encrypt E7 intermediate CA (expires 2027-03-12)
- **Debug**: Pinning dinonaktifkan → bisa debug dengan Charles/Proxyman
- **Release**: `SecurityContext` hanya trust E7 CA, reject semua bad cert

### Error Handling

```dart
// Repository pattern dengan Either
Future<Either<String, User>> login(email, password) async {
  try {
    final response = await _dataSource.login({...});
    return Right(response.toEntity());
  } on DioException catch (e) {
    return Left(e.message ?? 'Network error');
  } catch (e) {
    return Left(e.toString());
  }
}

// BLoC consuming Either
final result = await _loginUseCase(email, password);
result.fold(
  (failure) => emit(AuthFailure(failure)),
  (user)    => emit(AuthAuthenticated(user)),
);
```

### External APIs

| API | Base URL | Digunakan untuk |
|---|---|---|
| Backend muslimly | `https://muslimly.my.id/api/v1` | Auth, FCM token, sync |
| Quran.com | `https://api.quran.com/api/v4` | Ayah, terjemahan, tafsir, audio |
| AlQuran Cloud | `https://api.alquran.cloud/v1` | Terjemahan alternatif |
| Islamic Network CDN | `https://cdn.islamic.network/quran/audio` | Audio file per ayah/surah |
| QPC Fonts CDN | `https://cdn.jsdelivr.net/gh/nuqayah/qpc-fonts@master` | Font Uthmani Mushaf |

---

## 8. Database Lokal

Menggunakan **SQLite** via `sqflite`. Single `DatabaseService` singleton.

```
lib/src/core/database/database_service.dart
```

### Skema (versi 10)

| Tabel | Kolom Utama | Kegunaan |
|---|---|---|
| `app_settings` | `key` (PK), `value` | Key-value untuk preferences |
| `reading_activity` | `id`, `date`, `page_number`, `surah_number`, `duration_seconds`, `total_ayahs`, `mode`, `is_synced` | Tracking aktivitas baca Quran |
| `bookmarks` | `id`, `surah_number`, `page_number`, `ayah_number`, `mode` | Bookmark ayah/halaman |
| `translations` | `surah_number`, `ayah_number`, `language_code`, `text` | Cache terjemahan |
| `tafsirs` | `surah_number`, `ayah_number`, `tafsir_id`, `text` | Cache tafsir |
| `tajweeds` | `surah_number`, `ayah_number`, `text` | Cache aturan tajwid |
| `articles` | `id`, `title`, `content`, `category`, `author` | Cache artikel |

### Migrasi

Database menggunakan incremental migration via `_onUpgrade(db, oldVersion, newVersion)`. Dari v1 → v10 dengan penambahan kolom bertahap.

---

## 9. Lokalisasi

Menggunakan Flutter's built-in ARB-based localization.

### File

```
lib/src/l10n/arb/
├── app_en.arb     ← English
└── app_id.arb     ← Indonesian

lib/src/l10n/generated/
├── app_localizations.dart
├── app_localizations_en.dart
└── app_localizations_id.dart
```

### Cara Pakai

```dart
// Ambil instance
final l10n = AppLocalizations.of(context)!;

// Teks sederhana
Text(l10n.appTitle)

// Teks dengan parameter
Text(l10n.dashboardGreeting(userName))

// Ganti bahasa (via SettingsCubit)
context.read<SettingsCubit>().changeLanguage('id');
```

### Locale yang Didukung

- `en` — English (default)
- `id` — Indonesian

---

## 10. Core Infrastructure

### AppUrls (`core/config/app_urls.dart`)

Semua URL dikentralisasi. Tidak ada hardcoded URL di tempat lain.

```dart
AppUrls.baseApi           // https://muslimly.my.id/api/v1
AppUrls.quranComApi       // https://api.quran.com/api/v4
AppUrls.alQuranCloudApi   // https://api.alquran.cloud/v1
AppUrls.islamicNetworkAudio
AppUrls.qpcFontsCdn
AppUrls.quranComImages
AppUrls.surahAudioHigh(reciterId, surahNumber)  // static method
AppUrls.ayahAudioLow(reciterId, verseNum)       // static method
```

### AppColors (`core/theme/app_colors.dart`)

```dart
AppColors.accent            // #00E676 (primary green)
AppColors.bgGradientStart   // #0F2027
AppColors.bgGradientMid     // #203A43
AppColors.bgGradientEnd     // #2C5364
AppColors.cardDark          // #1C2A30
AppColors.gold              // #FFC107
AppColors.bgGradient        // LinearGradient (ready to use)
AppColors.bgGradientDecoration // BoxDecoration (ready to use)
```

### AppLogger (`core/utils/app_logger.dart`)

```dart
AppLogger.debug('message');               // Debug only
AppLogger.info('message');                // Debug only
AppLogger.warning('message', error);     // Debug + Crashlytics.log
AppLogger.error('message', error, stack); // Debug + Crashlytics.recordError
AppLogger.fatal('message', error, stack); // Always + Crashlytics (fatal=true)
```

### ShowcasePreferencesService (`core/services/showcase_preferences_service.dart`)

```dart
// Keys terpusat
ShowcaseKeys.dashboard   // 'hasShownDashboardShowcase'
ShowcaseKeys.quranList   // 'hasShownQuranListShowcase'
ShowcaseKeys.surahDetail // 'hasShownSurahDetailShowcase'
ShowcaseKeys.mushaf      // 'hasShownMushafShowcase'

// Usage
final service = getIt<ShowcasePreferencesService>();
final hasShown = await service.hasShown(ShowcaseKeys.dashboard);
await service.markShown(ShowcaseKeys.dashboard);
await service.clearAll(); // Reset semua showcase
```

---

## 11. Feature Modules

### Quran (Feature Terbesar)

```
quran/
├── data/
│   ├── datasources/
│   │   ├── local/
│   │   │   └── quran_library/   ← Embedded Quran text + reciters
│   │   ├── font_cache_service.dart
│   │   ├── quran_local_data_source.dart
│   │   └── remote/sync_api_service.dart
│   ├── models/                  ← Surah, Ayah, Reciter, Bookmark models
│   ├── repositories/
│   │   ├── quran_repository_impl.dart    ← API fetch tajweed/search
│   │   ├── audio_repository.dart         ← Reciter list + audio fetch
│   │   ├── translation_repository_impl.dart
│   │   ├── last_read_repository.dart     ← SharedPreferences
│   │   └── bookmarks (via DatabaseService)
├── domain/
│   ├── entities/       ← Surah, Ayah, ReadingActivity, QuranBookmark
│   ├── repositories/   ← QuranRepository, TranslationRepository interface
│   └── usecases/       ← GetSurahs, GetAyahs, SearchAyahs
└── presentation/
    ├── bloc/
    │   ├── quran_bloc.dart
    │   ├── audio_bloc.dart        ← Complex: 15+ events, audio stream subscription
    │   ├── bookmark/bookmark_bloc.dart
    │   ├── reading/reading_bloc.dart
    │   ├── hafalan/hafalan_bloc.dart  ← STT + word matching algorithm
    │   ├── search/search_bloc.dart
    │   └── translation/translation_bloc.dart
    └── pages/
        ├── quran_page.dart        ← Surah list
        ├── surah_detail_page.dart ← Ayah list (list mode)
        ├── mushaf_page.dart       ← Page view (halaman Quran)
        ├── hafalan_page.dart      ← Memorization mode
        ├── bookmarks_page.dart
        └── reading_history_page.dart
```

### Prayer

```
prayer/
├── data/
│   ├── repositories/
│   │   ├── prayer_repository_impl.dart  ← Adhan package calculations
│   │   └── prayer_guide_repository.dart ← Load JSON dari assets
│   └── models/ ← PrayerTime, City models
├── domain/
│   ├── usecases/ ← GetPrayerTime, SearchCity
│   ├── services/ ← FastingService (hijri date, fasting events)
│   └── entities/ ← prayer_time_extension.dart
└── presentation/
    ├── bloc/ ← PrayerBloc, PrayerEvent, PrayerState
    └── pages/
        ├── prayer_page.dart     ← Jadwal sholat + kalender ibadah
        ├── prayer_detail_page.dart
        ├── prayer_guide_page.dart
        └── qibla_compass_page.dart
```

### Auth

```
auth/
├── data/
│   ├── datasources/auth_remote_data_source.dart  ← Dio + Retrofit
│   ├── models/auth_model.dart                    ← JSON + JWT decode
│   └── repositories/auth_repository_impl.dart    ← flutter_secure_storage
├── domain/
│   ├── entities/auth_entity.dart    ← User (id, email, name, token)
│   ├── repositories/auth_repository.dart  ← getToken/saveToken/deleteToken
│   └── usecases/login_usecase.dart
└── presentation/
    ├── bloc/ ← AuthBloc, AuthEvent, AuthState
    └── pages/login_page.dart
```

---

## 12. Data Flow

### Alur Tipikal: Load Data dari API

```
User action (tap button)
    │
    ▼
Widget → context.read<QuranBloc>().add(QuranFetchSurahs())
    │
    ▼
QuranBloc._onFetchSurahs()
    │
    ▼
GetSurahs usecase (domain)
    │
    ▼
QuranRepository interface (domain)
    │
    ▼
QuranRepositoryImpl (data)
    │
    ├─→ QuranLocalDataSource  ← SQLite cache ada?
    │       ├─→ YES: return cached data
    │       └─→ NO: call remote API
    │
    └─→ HTTP: GET /api/v4/...
            │
            ▼
        Response → parse JSON → Entity
            │
            ▼
        return Right(surahs) atau Left("error message")
    │
    ▼
BLoC: result.fold(
    Left  → emit(QuranError(message))
    Right → emit(QuranSurahsLoaded(surahs))
)
    │
    ▼
BlocBuilder rebuilds → UI updates
```

### Alur: Showcase (Tutorial)

```
Page initState()
    │
    ▼
ShowcaseView.register()  ← registrasi ke ShowcaseService
    │
    ▼
WidgetsBinding.addPostFrameCallback(_checkShowcase)
    │
    ▼
ShowcasePreferencesService.hasShown(ShowcaseKeys.xxx)
    │
    ├─→ true: skip
    └─→ false:
            │
            ▼
        Future.delayed(1s)
            │
            ▼
        _showcaseView.startShowCase([key1, key2, ...])
            │
            ▼
        ShowcasePreferencesService.markShown(key)

Page dispose()
    │
    ▼
_showcaseView.unregister()
```

### Alur: Error Handling

```
Error terjadi di Repository/Service
    │
    ▼
catch (e, s)
    │
    ├─→ Debug mode:
    │       AppLogger.error(msg, e, s)
    │           └─→ debugPrint('[ERROR] ...')
    │
    └─→ Release mode:
            AppLogger.error(msg, e, s)
                └─→ FirebaseCrashlytics.instance.recordError(e, s)
                        └─→ Muncul di Firebase Console → Crashlytics
```

---

## Catatan Arsitektur

### Yang Sudah Konsisten
- Repository pattern dengan abstract interface di domain
- Either untuk error handling di layer API-facing
- BLoC untuk state management feature utama
- Dependency injection terpusat

### Yang Perlu Diseragamkan
- `settings` dan `tajweed` belum punya domain layer
- `zikir` dan beberapa halaman masih pakai `setState` langsung
- Sebagian error menggunakan `Either<String, T>` (String), sebagian `Either<Failure, T>` (object) — belum seragam

### Konvensi Penamaan

| Tipe | Konvensi | Contoh |
|---|---|---|
| BLoC | `[Feature]Bloc` | `QuranBloc` |
| Cubit | `[Feature]Cubit` | `FastingCubit` |
| State | `[Feature]State` | `FastingState` |
| Event | `[Feature]Event` | `QuranEvent` |
| UseCase | `[Action][Entity]` | `GetSurahs`, `SearchCity` |
| Repository interface | `[Feature]Repository` | `QuranRepository` |
| Repository impl | `[Feature]RepositoryImpl` | `QuranRepositoryImpl` |
| Model | `[Entity]Model` | `SurahModel` |
| Entity | `[Entity]` | `Surah` |
| Page | `[Feature]Page` | `QuranPage` |

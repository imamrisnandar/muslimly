import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart'; // Fixed import
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../settings/presentation/bloc/settings_cubit.dart';
import '../../../settings/presentation/bloc/settings_state.dart';
import 'prayer_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../quran/presentation/pages/quran_page.dart';
import '../../../quran/presentation/pages/help_guide_page.dart';
import '../../../../core/widgets/islamic_loading_indicator.dart';
import '../../../prayer/presentation/pages/qibla_compass_page.dart';
import '../../../zikir/presentation/pages/dzikir_page.dart';
import '../../../prayer/presentation/bloc/prayer_bloc.dart';
import '../../../prayer/presentation/bloc/prayer_event.dart';
import '../../../prayer/presentation/bloc/prayer_state.dart';
import '../../../quran/presentation/bloc/reading/reading_bloc.dart';
import '../../../quran/presentation/bloc/reading/reading_event.dart';
import '../../../quran/presentation/bloc/reading/reading_state.dart';
import '../../../quran/presentation/bloc/bookmark/bookmark_bloc.dart';
import '../../../quran/presentation/bloc/bookmark/bookmark_event.dart';
import '../../../quran/presentation/bloc/bookmark/bookmark_state.dart';

import '../widgets/prayer_countdown_widget.dart';
import '../../../quran/presentation/bloc/audio_bloc.dart';
import '../../../quran/presentation/bloc/audio_event.dart';
import '../../../quran/presentation/bloc/audio_state.dart';
import '../../../quran/presentation/widgets/draggable_audio_player.dart';
import '../../domain/services/reminder_service.dart';
import '../../../prayer/domain/services/fasting_service.dart';
import '../../domain/models/reminder_models.dart';
import '../../../zikir/data/repositories/zikir_local_repository.dart';
import '../../../zikir/presentation/pages/dzikir_reading_page.dart';

import '../../../prayer/domain/entities/prayer_time_extension.dart'; // Ext Impt
import '../../../../core/di/di_container.dart';
import '../../../../core/services/notification_service.dart';

import '../../../../core/presentation/widgets/premium_showcase.dart'; // Import
import 'package:showcaseview/showcaseview.dart';

import '../../../article/presentation/bloc/article_bloc.dart';
import '../../../article/presentation/widgets/article_carousel_widget.dart';

class DashboardPage extends StatefulWidget {
  final int initialIndex;
  const DashboardPage({super.key, this.initialIndex = 0});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late int _currentIndex;

  // Showcase Keys
  final GlobalKey _dailyGoalKey = GlobalKey();
  final GlobalKey _settingsTabKey = GlobalKey();
  final GlobalKey _prayerCardKey = GlobalKey();
  final GlobalKey _quickAccessKey = GlobalKey();
  final GlobalKey _dzikirTabKey = GlobalKey();
  final GlobalKey _quranTabKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    context.read<SettingsCubit>().loadSettings();
    _requestAllPermissions();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkShowcase());
  }

  Future<void> _checkShowcase() async {
    final prefs = await SharedPreferences.getInstance();
    final hasShown = prefs.getBool('hasShownDashboardShowcase') ?? false;

    if (!hasShown && mounted) {
      await Future.delayed(const Duration(milliseconds: 1000));
      if (mounted) {
        ShowCaseWidget.of(context).startShowCase([
          _dailyGoalKey,
          _settingsTabKey,
          _prayerCardKey,
          _quickAccessKey,
          _dzikirTabKey,
          _quranTabKey,
        ]);
        prefs.setBool('hasShownDashboardShowcase', true);
      }
    }
  }

  @override
  void didUpdateWidget(covariant DashboardPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialIndex != oldWidget.initialIndex) {
      setState(() {
        _currentIndex = widget.initialIndex;
      });
    }
  }

  Future<void> _requestAllPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    await getIt<NotificationService>().requestPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              getIt<PrayerBloc>()..add(FetchPrayerTimeByLocation()),
        ),
        BlocProvider(
          create: (context) => getIt<ReadingBloc>()..add(LoadReadingOverview()),
        ),
        BlocProvider(create: (context) => getIt<AudioBloc>()..add(InitAudio())),
        BlocProvider(
          create: (context) => getIt<BookmarkBloc>()..add(LoadBookmarks()),
        ),
        BlocProvider(create: (context) => getIt<ArticleBloc>()),
      ],
      child: Builder(
        builder: (context) {
          return ShowCaseWidget(
            builder: (context) {
              return Scaffold(
                extendBody: true,
                bottomNavigationBar: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: BottomNavigationBar(
                    currentIndex: _currentIndex,
                    onTap: (index) => context.go('/dashboard?index=$index'),
                    backgroundColor: const Color(0xFF1C2A30),
                    selectedItemColor: const Color(0xFF00E676),
                    unselectedItemColor: Colors.white54,
                    type: BottomNavigationBarType.fixed,
                    showUnselectedLabels: true,
                    selectedLabelStyle: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Outfit',
                    ),
                    unselectedLabelStyle: TextStyle(
                      fontSize: 10.sp,
                      fontFamily: 'Outfit',
                    ),
                    items: [
                      BottomNavigationBarItem(
                        icon: const Icon(Icons.home_filled),
                        label: AppLocalizations.of(context)!.bottomNavHome,
                      ),
                      BottomNavigationBarItem(
                        icon: const Icon(Icons.mosque),
                        label: AppLocalizations.of(context)!.bottomNavPrayer,
                      ),
                      BottomNavigationBarItem(
                        icon: PremiumShowcase(
                          globalKey: _quranTabKey,
                          title: AppLocalizations.of(
                            context,
                          )!.showcaseQuranTabTitle,
                          description: AppLocalizations.of(
                            context,
                          )!.showcaseQuranTab,
                          targetShapeBorder: const CircleBorder(),
                          child: const Icon(
                            Icons.menu_book_rounded,
                            color: Color(0xFFFFC107),
                          ),
                        ),
                        label: AppLocalizations.of(context)!.bottomNavQuran,
                      ),
                      BottomNavigationBarItem(
                        icon: PremiumShowcase(
                          globalKey: _dzikirTabKey,
                          title: AppLocalizations.of(
                            context,
                          )!.showcaseDzikirTitle,
                          description: AppLocalizations.of(
                            context,
                          )!.showcaseDzikir,
                          targetShapeBorder: const CircleBorder(),
                          child: const Icon(Icons.spa),
                        ),
                        label: AppLocalizations.of(context)!.bottomNavDzikir,
                      ),
                      BottomNavigationBarItem(
                        icon: PremiumShowcase(
                          globalKey: _settingsTabKey,
                          title: AppLocalizations.of(
                            context,
                          )!.showcaseSettingsTitle,
                          description: AppLocalizations.of(
                            context,
                          )!.showcaseSettingsGoal,
                          targetShapeBorder: const CircleBorder(),
                          child: const Icon(Icons.settings),
                        ),
                        label: AppLocalizations.of(context)!.bottomNavSettings,
                      ),
                    ],
                  ),
                ),
                body: Container(
                  decoration: const BoxDecoration(color: Color(0xFF0F2027)),
                  child: SafeArea(
                    child: Stack(
                      children: [
                        IndexedStack(
                          index: _currentIndex,
                          children: [
                            _buildHomeContent(context),
                            const PrayerPage(),
                            QuranPage(isVisible: _currentIndex == 2),
                            const DzikirPage(),
                            const SettingsPage(),
                          ],
                        ),
                        BlocListener<AudioBloc, AudioState>(
                          listener: (context, state) {},
                          child: DraggableAudioPlayer(
                            enableShowcase: _currentIndex == 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context) {
    return Column(
      children: [
        // STICKY HEADER
        BlocBuilder<PrayerBloc, PrayerState>(
          builder: (context, state) {
            return Padding(
              padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ClipOval(
                        child: Image.asset(
                          'assets/icon/app_icon.png',
                          height: 32.sp,
                          width: 32.sp,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        AppLocalizations.of(context)!.appTitle,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  // LOCATION DISPLAY
                  InkWell(
                    onTap: () => _showCitySearchDialog(context),
                    borderRadius: BorderRadius.circular(8.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on,
                            color: const Color(0xFF00E676),
                            size: 14.sp,
                          ),
                          SizedBox(width: 4.w),
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 100.w),
                            child: Text(
                              state.currentCity.name,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Icon(
                            Icons.edit_outlined,
                            color: const Color(0xFF00E676),
                            size: 12.sp,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        SizedBox(height: 8.h),

        // SCROLLABLE CONTENT
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              // Reload Data
              context.read<PrayerBloc>().add(FetchPrayerTimeByLocation());
              context.read<ReadingBloc>().add(LoadReadingOverview());
              context.read<BookmarkBloc>().add(
                LoadBookmarks(),
              ); // Add Bookmark Refresh
              context.read<SettingsCubit>().loadSettings();

              // Small delay for visual feedback
              await Future.delayed(const Duration(seconds: 1));
            },
            color: const Color(0xFF00E676),
            child: SingleChildScrollView(
              physics:
                  const AlwaysScrollableScrollPhysics(), // Force Scrollable
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // GREETING
                  BlocBuilder<SettingsCubit, SettingsState>(
                    builder: (context, state) {
                      final name = state.userName ?? 'Friend';
                      return Text(
                        AppLocalizations.of(context)!.dashboardGreeting(name),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 4.h),

                  // TEST ADZAN COUNTDOWN (Removed)
                  Builder(
                    builder: (context) {
                      final now = DateTime.now();
                      String gregorian = "";
                      try {
                        gregorian = DateFormat(
                          'd MMM yyyy',
                        ).format(now); // Short Format
                      } catch (e) {
                        gregorian = "${now.day}-${now.month}-${now.year}";
                      }

                      final hijri = getIt<FastingService>()
                          .getAdjustedHijriDate(now);
                      final hijriStr =
                          "${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear} H";
                      return Text(
                        '$gregorian • $hijriStr',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 14.sp,
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 12.h),

                  // PROGRESS SECTION (Moved Up)
                  BlocBuilder<ReadingBloc, ReadingState>(
                    builder: (context, state) {
                      final l10n = AppLocalizations.of(context)!;
                      // Determine target and progress based on unit
                      // Bloc already handles logic:
                      // dailyProgress is the count for the current unit
                      // dailyTarget is (pageTarget) but we need to select correct target field

                      final unit = state.targetUnit;
                      final progress = state.dailyProgress;
                      final target = (unit == 'ayah')
                          ? state.dailyAyahTarget
                          : state.dailyTarget;
                      final label = (unit == 'ayah')
                          ? "Ayahs"
                          : l10n.lblPages; // Todo: Add localized "Ayahs"

                      return PremiumShowcase(
                        globalKey: _dailyGoalKey,
                        title: AppLocalizations.of(
                          context,
                        )!.showcaseDailyGoalTitle, // Localized
                        description: AppLocalizations.of(
                          context,
                        )!.showcaseDailyGoal,
                        child: _buildDailyGoalCard(
                          context,
                          progress,
                          target,
                          label,
                          l10n,
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 12.h),

                  // HERO CARD (Prayer Time)
                  BlocBuilder<SettingsCubit, SettingsState>(
                    builder: (context, settingsState) {
                      return BlocBuilder<PrayerBloc, PrayerState>(
                        builder: (context, state) {
                          if (state.status == PrayerStatus.loading) {
                            return _buildLoadingHero();
                          }

                          if (state.prayerTime == null) {
                            return _buildErrorHero("Data not available");
                          }

                          // Use Extension
                          final nextPrayer = state.prayerTime!.getNextPrayer(
                            AppLocalizations.of(context)!,
                          );

                          // Get reminder data
                          final reminderService = getIt<ReminderService>();
                          final reminderData = reminderService.getReminderData(
                            state.prayerTime!,
                            DateTime.now(),
                          );
                          final l10n = AppLocalizations.of(context)!;

                          // final gradient = _getPrayerGradient(
                          //   nextPrayer['name'],
                          // ); // Unused now
                          final isLandscape =
                              MediaQuery.of(context).orientation ==
                              Orientation.landscape;

                          return PremiumShowcase(
                            globalKey: _prayerCardKey,
                            title: AppLocalizations.of(
                              context,
                            )!.showcasePrayerTitle, // Localized
                            description: AppLocalizations.of(
                              context,
                            )!.showcasePrayerCard,
                            child: GestureDetector(
                              onTap: () => context.go('/dashboard?index=1'),
                              child: Container(
                                height: isLandscape
                                    ? null
                                    : null, // Auto height for reminders
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24.r),
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(
                                        0xFF1DE9B6,
                                      ).withOpacity(0.2), // Teal Accent as Base
                                      const Color(0xFF1DE9B6).withOpacity(0.05),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    // Soft Teal Glow
                                    BoxShadow(
                                      color: const Color(
                                        0xFF1DE9B6,
                                      ).withOpacity(0.1),
                                      blurRadius: 20,
                                      spreadRadius: -5,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: const Color(
                                      0xFFFFC107,
                                    ).withOpacity(0.3), // Clearer Gold Border
                                    width: 1,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    // Background Pattern
                                    Positioned(
                                      right: -20,
                                      bottom: -20,
                                      child: Icon(
                                        Icons.mosque,
                                        size: isLandscape ? 80.sp : 120.sp,
                                        color: const Color(
                                          0xFFFFC107,
                                        ).withOpacity(0.1), // Gold Icon Tint
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(
                                        isLandscape ? 8.w : 20.w,
                                      ),
                                      child: isLandscape
                                          ? Row(
                                              children: [
                                                // Left: Label Only
                                                Expanded(
                                                  flex: 2,
                                                  child: Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal: 8.w,
                                                          vertical: 4.h,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.black12,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20.r,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      AppLocalizations.of(
                                                        context,
                                                      )!.cardNextPrayer,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10.sp,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                // Middle: Prayer Name & Time
                                                Expanded(
                                                  flex: 4,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .baseline,
                                                    textBaseline:
                                                        TextBaseline.alphabetic,
                                                    children: [
                                                      Flexible(
                                                        child: Text(
                                                          nextPrayer['name'],
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 20.sp,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: 8.w),
                                                      Text(
                                                        nextPrayer['time'],
                                                        style: TextStyle(
                                                          color: Colors.white70,
                                                          fontSize: 16.sp,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                // Right: Countdown
                                                Expanded(
                                                  flex: 3,
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            horizontal: 8.w,
                                                            vertical: 4.h,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.black26,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12.r,
                                                            ),
                                                        border: Border.all(
                                                          color: const Color(
                                                            0xFFFFC107,
                                                          ).withOpacity(0.3),
                                                          width: 1,
                                                        ),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: const Color(
                                                              0xFFFFC107,
                                                            ).withOpacity(0.15),
                                                            blurRadius: 10,
                                                            spreadRadius: -2,
                                                          ),
                                                        ],
                                                      ),
                                                      child: PrayerCountdownWidget(
                                                        targetTime:
                                                            nextPrayer['nextPrayerTime']
                                                                as DateTime,
                                                        baseColor: const Color(
                                                          0xFFFFC107, // Gold Countdown Progress
                                                        ),
                                                        onFinished: () {
                                                          context.read<PrayerBloc>().add(
                                                            FetchPrayerTime(
                                                              latitude: state
                                                                  .currentCity
                                                                  .latitude,
                                                              longitude: state
                                                                  .currentCity
                                                                  .longitude,
                                                              date:
                                                                  DateTime.now(),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // ROW 1: Label + Prayer Name
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            horizontal: 10.w,
                                                            vertical: 4.h,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.black12,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              20.r,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        AppLocalizations.of(
                                                          context,
                                                        )!.cardNextPrayer,
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12.sp,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      nextPrayer['name'],
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 28.sp,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        height: 1.0,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 12.h),
                                                // ROW 2: Time + Countdown
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      nextPrayer['time'],
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 24.sp,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            horizontal: 12.w,
                                                            vertical: 6.h,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.black26,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12.r,
                                                            ),
                                                        border: Border.all(
                                                          color: const Color(
                                                            0xFFFFC107,
                                                          ).withOpacity(0.3),
                                                          width: 1,
                                                        ),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: const Color(
                                                              0xFFFFC107,
                                                            ).withOpacity(0.15),
                                                            blurRadius: 10,
                                                            spreadRadius: -2,
                                                          ),
                                                        ],
                                                      ),
                                                      child: PrayerCountdownWidget(
                                                        targetTime:
                                                            nextPrayer['nextPrayerTime']
                                                                as DateTime,
                                                        baseColor: const Color(
                                                          0xFFFFC107, // Gold Countdown Progress
                                                        ),
                                                        onFinished: () {
                                                          context.read<PrayerBloc>().add(
                                                            FetchPrayerTime(
                                                              latitude: state
                                                                  .currentCity
                                                                  .latitude,
                                                              longitude: state
                                                                  .currentCity
                                                                  .longitude,
                                                              date:
                                                                  DateTime.now(),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                // REMINDERS SECTION
                                                if (reminderData.todayFasting !=
                                                        null ||
                                                    reminderData.nextFasting !=
                                                        null ||
                                                    reminderData
                                                        .hasAnyActiveDzikir) ...[
                                                  SizedBox(height: 12.h),
                                                  Container(
                                                    padding: EdgeInsets.all(
                                                      10.w,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.black
                                                          .withOpacity(0.2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12.r,
                                                          ),
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        // Fasting info
                                                        if (reminderData
                                                                    .todayFasting !=
                                                                null ||
                                                            reminderData
                                                                    .nextFasting !=
                                                                null)
                                                          _buildCompactFastingInfo(
                                                            reminderData,
                                                            l10n.localeName,
                                                          ),

                                                        if (reminderData
                                                            .hasAnyActiveDzikir) ...[
                                                          if (reminderData
                                                                      .todayFasting !=
                                                                  null ||
                                                              reminderData
                                                                      .nextFasting !=
                                                                  null)
                                                            Padding(
                                                              padding:
                                                                  EdgeInsets.symmetric(
                                                                    vertical:
                                                                        6.h,
                                                                  ),
                                                              child: Divider(
                                                                color: Colors
                                                                    .white
                                                                    .withOpacity(
                                                                      0.1,
                                                                    ),
                                                                height: 1,
                                                              ),
                                                            ),
                                                          _buildCompactDzikirInfo(
                                                            context,
                                                            reminderData,
                                                          ),
                                                        ],
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  SizedBox(height: 12.h),

                  // ARTICLE CAROUSEL (Hidden for release)
                  const ArticleCarouselWidget(),
                  SizedBox(height: 12.h),

                  // QUICK ACCESS GRID (2x2)
                  PremiumShowcase(
                    globalKey: _quickAccessKey,
                    title: AppLocalizations.of(
                      context,
                    )!.showcaseQuickAccessTitle, // Localized
                    description: AppLocalizations.of(
                      context,
                    )!.showcaseQuickAccess,
                    child: Column(
                      children: [
                        // Row 1
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: BlocBuilder<BookmarkBloc, BookmarkState>(
                                  builder: (context, bookmarkState) {
                                    return _buildQuickAccessGridItem(
                                      context,
                                      title: AppLocalizations.of(
                                        context,
                                      )!.cardContinueReading,
                                      icon: Icons.menu_book,
                                      color: const Color(
                                        0xFF00E676,
                                      ), // Menu Focus Green
                                      onTap: () {
                                        context.push('/quran/bookmarks');
                                      },
                                    );
                                  },
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: _buildQuickAccessGridItem(
                                  context,
                                  title: AppLocalizations.of(
                                    context,
                                  )!.cardReadingHistory,
                                  icon: Icons.history,
                                  color: const Color(
                                    0xFF00E676,
                                  ), // Menu Focus Green
                                  onTap: () => context.push('/quran/history'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 12.h),
                        // Row 2
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: _buildQuickAccessGridItem(
                                  context,
                                  title: AppLocalizations.of(
                                    context,
                                  )!.qiblaCompass,
                                  icon: Icons.explore_outlined,
                                  color: const Color(
                                    0xFF00E676,
                                  ), // Menu Focus Green
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const QiblaCompassPage(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: _buildQuickAccessGridItem(
                                  context,
                                  title: AppLocalizations.of(
                                    context,
                                  )!.lblInspiration, // Localized
                                  icon: Icons.lightbulb_outline,
                                  color: const Color(
                                    0xFF00E676,
                                  ), // Menu Focus Green
                                  onTap: () =>
                                      context.push('/daily-inspiration'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 80.h), // Bottom padding for Nav Bar
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingHero() {
    return Container(
      height: 220.h,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: const Center(child: IslamicLoadingIndicator(size: 64)),
    );
  }

  Widget _buildErrorHero(String msg) {
    return Container(
      height: 220.h,
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Center(
        child: Text(msg, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  void _showCitySearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return BlocProvider.value(
          value: context.read<PrayerBloc>(),
          child: const _CitySearchDialog(),
        );
      },
    );
  }

  // existing _buildQuickAccessGridItem is already defined below but was removed in thought process due to lack of space?
  // No, the previous tool confirmed checking until line 1254.
  // Wait, I replaced _buildErrorHero but I need to make sure I don't break the file structure.
  // Viewing showed `_buildErrorHero` around line 840.
  // I will append _showLastReadSelection AFTER _buildErrorHero.

  Widget _buildDailyGoalCard(
    BuildContext context,
    int progress,
    int target,
    String unitLabel,
    AppLocalizations l10n,
  ) {
    final percentage = (target > 0) ? (progress / target).clamp(0.0, 1.0) : 0.0;
    final isCompleted = percentage >= 1.0;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Container(
      height: isLandscape ? null : 170.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1DE9B6).withOpacity(0.2), // Teal Accent as Base
            const Color(0xFF1DE9B6).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          // Soft Teal Glow
          BoxShadow(
            color: const Color(0xFF1DE9B6).withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: -5,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFFFC107).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: GestureDetector(
        onTap: () => context.push('/quran/history'),
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            // Background Pattern
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                Icons.auto_stories,
                size: isLandscape ? 80.sp : 140.sp,
                color: const Color(
                  0xFFFFC107,
                ).withOpacity(0.1), // Gold Icon Tint
              ),
            ),

            Padding(
              padding: EdgeInsets.all(isLandscape ? 8.w : 24.w),
              child: isLandscape
                  ? Row(
                      children: [
                        // Icon
                        Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            Icons.flag_rounded,
                            color: const Color(
                              0xFF00E676,
                            ), // Green Icon for Goal
                            size: 16.sp,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        // Title
                        Text(
                          l10n.cardDailyGoal,
                          style: TextStyle(
                            color: const Color(
                              0xFFFFC107,
                            ), // Gold Title for Goal
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HelpGuidePage(),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(12.r),
                          child: Padding(
                            padding: EdgeInsets.all(2.w),
                            child: Icon(
                              Icons.info_outline_rounded,
                              color: Colors.white70,
                              size: 14.sp,
                            ),
                          ),
                        ),

                        const Spacer(),
                        // Progress Text
                        Text(
                          "$progress",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              " / $target",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12.sp,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            InkWell(
                              onTap: () => context.push('/settings'),
                              borderRadius: BorderRadius.circular(12.r),
                              child: Padding(
                                padding: EdgeInsets.all(4.w),
                                child: Icon(
                                  Icons.edit,
                                  color: Colors.white54,
                                  size: 14.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 12.w),
                        // Circular Progress
                        Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFFFFC107,
                                ).withOpacity(0.2), // Gold Glow
                                blurRadius: 10,
                                spreadRadius: -2,
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircularProgressIndicator(
                                value: 1.0,
                                strokeWidth: 4.w,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white.withOpacity(0.1),
                                ),
                              ),
                              CircularProgressIndicator(
                                value: percentage,
                                strokeWidth: 4.w,
                                strokeCap: StrokeCap.round,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFFFFC107), // Gold Progress
                                ),
                                backgroundColor: Colors.transparent,
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8.w),
                                    decoration: BoxDecoration(
                                      color: Colors.white24,
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: Icon(
                                      Icons.flag_rounded,
                                      color: const Color(
                                        0xFF00E676,
                                      ), // Green Icon for Goal
                                      size: 20.sp,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      l10n.cardDailyGoal,
                                      style: TextStyle(
                                        color: const Color(
                                          0xFFFFC107,
                                        ), // Gold Title for Goal
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const HelpGuidePage(),
                                        ),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(12.r),
                                    child: Padding(
                                      padding: EdgeInsets.all(4.w),
                                      child: Icon(
                                        Icons.info_outline_rounded,
                                        color: Colors.white70,
                                        size: 16.sp,
                                      ),
                                    ),
                                  ),
                                  if (isCompleted) ...[
                                    SizedBox(width: 4.w),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 4.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFFFFC107,
                                        ), // Gold Completed Badge
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                      ),
                                      child: Text(
                                        l10n.lblCompleted,
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                "$progress",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32.sp,
                                  fontWeight: FontWeight.bold,
                                  height: 1.0,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Row(
                                children: [
                                  Text(
                                    "/ $target $unitLabel",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  InkWell(
                                    onTap: () => context.push('/settings'),
                                    borderRadius: BorderRadius.circular(12.r),
                                    child: Padding(
                                      padding: EdgeInsets.all(4.w),
                                      child: Icon(
                                        Icons.edit,
                                        color: Colors.white54,
                                        size: 16.sp,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Circular Progress
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 80.w,
                                  height: 80.w,
                                  child: CircularProgressIndicator(
                                    value: 1.0,
                                    strokeWidth: 8.w,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white.withOpacity(0.1),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 80.w,
                                  height: 80.w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFFFFC107,
                                        ).withOpacity(0.2), // Gold Glow
                                        blurRadius: 15,
                                        spreadRadius: -2,
                                      ),
                                    ],
                                  ),
                                  child: CircularProgressIndicator(
                                    value: percentage,
                                    strokeWidth: 8.w,
                                    strokeCap: StrokeCap.round,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                          Color(0xFFFFC107), // Gold Progress
                                        ),
                                    backgroundColor: Colors.transparent,
                                  ),
                                ),
                                Text(
                                  "${(percentage * 100).toInt()}%",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            if (!isCompleted) ...[
                              SizedBox(height: 12.h),
                              GestureDetector(
                                onTap: () => context.push('/quran/bookmarks'),
                                child: Text(
                                  l10n.lblReadMore,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.white54,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessGridItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        splashColor: color.withOpacity(0.3),
        highlightColor: color.withOpacity(0.1),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1C2A30).withOpacity(0.95),
                const Color(0xFF243742).withOpacity(0.85),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: color.withOpacity(0.15),
                blurRadius: 25,
                spreadRadius: -5,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon Container with Soft styling
              Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // Soft Gradient Background
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
                  ),
                  // Thin, Subtle Border
                  border: Border.all(color: color.withOpacity(0.3), width: 1.5),
                  // Soft, Diffused Shadows
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.2),
                      blurRadius: 15,
                      spreadRadius: -2,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: color.withOpacity(0.9), // Slightly softer icon color
                    size: 28.sp,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                  height: 1.2,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // LinearGradient _getPrayerGradient(String prayerName) {
  //   switch (prayerName) {
  //     case 'Subuh':
  //       return const LinearGradient(
  //         colors: [Color(0xFF2C3E50), Color(0xFFE1B12C)],
  //         begin: Alignment.topLeft,
  //         end: Alignment.bottomRight,
  //       );
  //     case 'Terbit':
  //       return const LinearGradient(
  //         colors: [Color(0xFFE1B12C), Color(0xFFF1C40F)],
  //         begin: Alignment.topLeft,
  //         end: Alignment.bottomRight,
  //       );
  //     case 'Dzuhur':
  //       return const LinearGradient(
  //         colors: [Color(0xFF2980B9), Color(0xFF6DD5FA)],
  //         begin: Alignment.topLeft,
  //         end: Alignment.bottomRight,
  //       );
  //     case 'Ashar':
  //       return const LinearGradient(
  //         colors: [Color(0xFF6DD5FA), Color(0xFFFF7F50)],
  //         begin: Alignment.topLeft,
  //         end: Alignment.bottomRight,
  //       );
  //     case 'Maghrib':
  //       return const LinearGradient(
  //         colors: [Color(0xFFFF7F50), Color(0xFF8E44AD)],
  //         begin: Alignment.topLeft,
  //         end: Alignment.bottomRight,
  //       );
  //     case 'Isya':
  //       return const LinearGradient(
  //         colors: [Color(0xFF8E44AD), Color(0xFF2C3E50)],
  //         begin: Alignment.topLeft,
  //         end: Alignment.bottomRight,
  //       );
  //     case 'Imsak':
  //     default:
  //       return const LinearGradient(
  //         colors: [Color(0xFF11998e), Color(0xFF38ef7d)], // Default Green
  //         begin: Alignment.topLeft,
  //         end: Alignment.bottomRight,
  //       );
  //   }
  // }

  // Compact fasting info for prayer card
  Widget _buildCompactFastingInfo(
    ReminderCardData reminderData,
    String locale,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(
              Icons.nightlight_round,
              color: const Color(0xFFFFC107), // Gold Fasting Icon
              size: 12.sp,
            ),
            SizedBox(width: 4.w),
            Text(
              l10n.reminderFasting,
              style: TextStyle(
                color: const Color(0xFF00E676),
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        if (reminderData.todayFasting != null)
          _buildCompactFastingItem(
            context,
            reminderData.todayFasting!,
            'Hari ini',
            showCountdown: true,
          ),
        if (reminderData.todayFasting != null &&
            reminderData.nextFasting != null)
          SizedBox(height: 4.h),
        if (reminderData.nextFasting != null)
          _buildCompactFastingItem(
            context,
            reminderData.nextFasting!,
            'Berikutnya',
            showCountdown: false,
          ),
      ],
    );
  }

  Widget _buildCompactFastingItem(
    BuildContext context,
    FastingReminder fasting,
    String label, {
    required bool showCountdown,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Icon(
          showCountdown ? Icons.restaurant : Icons.event,
          color: fasting.color.withOpacity(0.8),
          size: 12.sp,
        ),
        SizedBox(width: 6.w),
        Expanded(
          child: RichText(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: [
                TextSpan(
                  text: showCountdown && fasting.timeUntilIftar != null
                      ? l10n.reminderIftarIn(
                          ReminderService.formatDuration(
                            fasting.timeUntilIftar!,
                          ),
                        )
                      : _getLocalizedEventName(context, fasting.event) ??
                            fasting.type,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextSpan(
                  text: ' • ${_formatFastingDate(fasting.date)}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Format fasting date with Gregorian and Hijri
  String _formatFastingDate(DateTime date) {
    final gregorian = DateFormat('d MMM').format(date);
    // Use FastingService to get ADJUSTED Hijri date
    final hijri = getIt<FastingService>().getAdjustedHijriDate(date);
    return '$gregorian • ${hijri.hDay} ${_getShortHijriMonth(hijri.hMonth)}';
  }

  // Get short Hijri month name
  String _getShortHijriMonth(int month) {
    const months = [
      'Muh',
      'Saf',
      'R.Awl',
      'R.Akh',
      'J.Ula',
      'J.Ukh',
      'Raj',
      'Syab',
      'Ram',
      'Syaw',
      'Zulqa',
      'Zulhi',
    ];
    return month >= 1 && month <= 12 ? months[month - 1] : '';
  }

  // Compact dzikir info for prayer card
  Widget _buildCompactDzikirInfo(
    BuildContext context,
    ReminderCardData reminderData,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(
              Icons.menu_book_rounded,
              color: const Color(0xFFFFC107),
              size: 12.sp,
            ),
            SizedBox(width: 4.w),
            Text(
              l10n.reminderDzikir,
              style: TextStyle(
                color: const Color(0xFFFFC107),
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        if (reminderData.morningDzikir.isActiveNow)
          _buildCompactDzikirItem(context, reminderData.morningDzikir),
        if (reminderData.morningDzikir.isActiveNow &&
            reminderData.eveningDzikir.isActiveNow)
          SizedBox(height: 4.h),
        if (reminderData.eveningDzikir.isActiveNow)
          _buildCompactDzikirItem(context, reminderData.eveningDzikir),
      ],
    );
  }

  Widget _buildCompactDzikirItem(BuildContext context, DzikirReminder dzikir) {
    final l10n = AppLocalizations.of(context)!;
    return InkWell(
      onTap: () async {
        // Navigate to specific dzikir page
        final locale = Localizations.localeOf(context);
        final items = dzikir.type == DzikirType.morning
            ? await getIt<ZikirLocalRepository>().getMorningZikir(locale)
            : await getIt<ZikirLocalRepository>().getEveningZikir(locale);

        final title = dzikir.type == DzikirType.morning
            ? l10n.dzikirMorningTitle
            : l10n.dzikirEveningTitle;

        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  DzikirReadingPage(title: title, items: items),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(8.r),
      child: Row(
        children: [
          Icon(
            Icons.notifications_active,
            color: const Color(0xFFFFC107).withOpacity(0.8),
            size: 12.sp,
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              l10n.reminderDzikirTime(dzikir.displayName),
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: const Color(0xFFFFC107).withOpacity(0.5),
            size: 10.sp,
          ),
        ],
      ),
    );
  }

  // Helper for localized fasting name
  String? _getLocalizedEventName(BuildContext context, FastingEvent event) {
    final l10n = AppLocalizations.of(context)!;
    switch (event) {
      case FastingEvent.eidFitr:
        return l10n.eidFitr;
      case FastingEvent.eidAdha:
        return l10n.eidAdha;
      case FastingEvent.tasyrik:
        return l10n.daysTasyrik;
      case FastingEvent.ramadan:
        return l10n.fastingRamadan;
      case FastingEvent.arafah:
        return l10n.fastingArafah;
      case FastingEvent.ashura:
        return l10n.fastingAshura;
      case FastingEvent.tasua:
        return l10n.fastingTasua;
      case FastingEvent.ayyamulBidh:
        return l10n.fastingAyyamulBidh;
      case FastingEvent.monday:
        return l10n.fastingMonday;
      case FastingEvent.thursday:
        return l10n.fastingThursday;
      case FastingEvent.none:
        return null;
    }
  }
}

// City Search Dialog Widget
class _CitySearchDialog extends StatefulWidget {
  const _CitySearchDialog();

  @override
  State<_CitySearchDialog> createState() => __CitySearchDialogState();
}

class __CitySearchDialogState extends State<_CitySearchDialog> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  List<String> _recentSearches = [];
  static const String _recentSearchesKey = 'recent_city_searches';
  static const int _maxRecentSearches = 5;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onSearchChanged);
    _loadRecentSearches();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.removeListener(_onSearchChanged);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final searches = prefs.getStringList(_recentSearchesKey) ?? [];
    if (mounted) {
      setState(() {
        _recentSearches = searches;
      });
    }
  }

  Future<void> _saveRecentSearch(String cityName) async {
    final prefs = await SharedPreferences.getInstance();
    _recentSearches.remove(cityName);
    _recentSearches.insert(0, cityName);
    if (_recentSearches.length > _maxRecentSearches) {
      _recentSearches = _recentSearches.sublist(0, _maxRecentSearches);
    }
    await prefs.setStringList(_recentSearchesKey, _recentSearches);
    if (mounted) {
      setState(() {});
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    final query = _controller.text.trim();
    if (query.isEmpty) return;
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.read<PrayerBloc>().add(SearchCityEvent(query));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      backgroundColor: const Color(0xFF1E2F36),
      title: Row(
        children: [
          Expanded(
            child: Text(
              l10n.searchCityTitle,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              context.read<PrayerBloc>().add(FetchPrayerTimeByLocation());
              Navigator.pop(context);
            },
            icon: const Icon(Icons.my_location),
            color: const Color(0xFF00E676),
            tooltip: l10n.useCurrentLocation,
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFF00E676).withOpacity(0.1),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: l10n.searchCityHint,
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white54),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF00E676)),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final query = _controller.text.trim();
                if (query.isNotEmpty) {
                  context.read<PrayerBloc>().add(SearchCityEvent(query));
                }
              },
              child: const Text("Search"),
            ),
            SizedBox(height: 16.h),
            Flexible(
              child: BlocBuilder<PrayerBloc, PrayerState>(
                builder: (context, state) {
                  if (state.isSearching) {
                    return SizedBox(
                      height: 100.h,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF00E676),
                        ),
                      ),
                    );
                  }
                  if (state.searchResults.isNotEmpty) {
                    return SizedBox(
                      height: 200.h,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: state.searchResults.length,
                        itemBuilder: (context, index) {
                          final city = state.searchResults[index];
                          return ListTile(
                            leading: const Icon(
                              Icons.location_on,
                              color: Color(0xFF00E676),
                            ),
                            title: Text(
                              city.name,
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              "${city.latitude.toStringAsFixed(4)}, ${city.longitude.toStringAsFixed(4)}",
                              style: const TextStyle(color: Colors.white54),
                            ),
                            onTap: () async {
                              await _saveRecentSearch(city.name);
                              if (mounted) {
                                context.read<PrayerBloc>().add(
                                  SelectCity(city),
                                );
                                Navigator.pop(context);
                              }
                            },
                          );
                        },
                      ),
                    );
                  } else if (!state.isSearching &&
                      _controller.text.isNotEmpty) {
                    return _buildEmptyState();
                  }
                  return _buildInitialStateWithRecent();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_off, size: 48.sp, color: Colors.white38),
          SizedBox(height: 12.h),
          Text(
            l10n.locationNotFound,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            l10n.trySearchingWith,
            style: TextStyle(fontSize: 13.sp, color: Colors.white54),
          ),
          SizedBox(height: 8.h),
          _buildSuggestionItem(l10n.searchSuggestionCity),
          _buildSuggestionItem(l10n.searchSuggestionDistrict),
          _buildSuggestionItem(l10n.searchSuggestionAddress),
        ],
      ),
    );
  }

  Widget _buildInitialStateWithRecent() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search, size: 40.sp, color: Colors.white24),
          SizedBox(height: 12.h),
          Text(
            l10n.searchForLocation,
            style: TextStyle(fontSize: 14.sp, color: Colors.white54),
          ),
          if (_recentSearches.isNotEmpty) ...[
            SizedBox(height: 16.h),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Recent Searches:",
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white38,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: _recentSearches
                  .map((city) => _buildRecentSearchChip(city))
                  .toList(),
            ),
          ],
          SizedBox(height: 12.h),
          Text(
            l10n.popularCities,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.white38,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _buildQuickSearchChip("Jakarta"),
              _buildQuickSearchChip("Bandung"),
              _buildQuickSearchChip("Surabaya"),
              _buildQuickSearchChip("Yogyakarta"),
              _buildQuickSearchChip("Medan"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearchChip(String cityName) {
    return InkWell(
      onTap: () {
        _controller.text = cityName;
        context.read<PrayerBloc>().add(SearchCityEvent(cityName));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: const Color(0xFF00E676).withOpacity(0.15),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFF00E676).withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, size: 14.sp, color: const Color(0xFF00E676)),
            SizedBox(width: 4.w),
            Text(
              cityName,
              style: TextStyle(fontSize: 12.sp, color: const Color(0xFF00E676)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionItem(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.arrow_right, size: 16.sp, color: const Color(0xFF00E676)),
          SizedBox(width: 4.w),
          Text(
            text,
            style: TextStyle(fontSize: 12.sp, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSearchChip(String cityName) {
    return InkWell(
      onTap: () {
        _controller.text = cityName;
        context.read<PrayerBloc>().add(SearchCityEvent(cityName));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Text(
          cityName,
          style: TextStyle(fontSize: 12.sp, color: Colors.white70),
        ),
      ),
    );
  }
}

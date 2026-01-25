import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart'; // Fixed import
import 'package:intl/intl.dart';
import '../../../quran/domain/entities/last_read.dart';
import 'package:hijri/hijri_calendar.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../settings/presentation/bloc/settings_cubit.dart';
import '../../../settings/presentation/bloc/settings_state.dart';
import 'prayer_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../quran/presentation/pages/quran_page.dart';
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
import '../../../quran/domain/entities/surah.dart';
import '../widgets/prayer_countdown_widget.dart';
import '../../../quran/presentation/bloc/audio_bloc.dart';
import '../../../quran/presentation/bloc/audio_event.dart';
import '../../../quran/presentation/bloc/audio_state.dart';
import '../../../quran/presentation/widgets/draggable_audio_player.dart';

import '../../../prayer/domain/entities/prayer_time_extension.dart'; // Ext Impt
import '../../../../core/di/di_container.dart';
import '../../../../core/services/notification_service.dart';

import 'package:showcaseview/showcaseview.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardPage extends StatefulWidget {
  final int initialIndex;
  const DashboardPage({super.key, this.initialIndex = 0});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late int _currentIndex;

  // Showcase Keys
  // Showcase Keys
  final GlobalKey _dailyGoalKey = GlobalKey();
  final GlobalKey _settingsTabKey = GlobalKey();
  final GlobalKey _prayerCardKey = GlobalKey();
  final GlobalKey _quickAccessKey = GlobalKey();
  final GlobalKey _dzikirTabKey = GlobalKey();
  final GlobalKey _quranTabKey = GlobalKey();

  // Audio Player Showcase Keys
  final GlobalKey _dragAudioKey = GlobalKey();
  final GlobalKey _qoriAudioKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    // Force reload settings (e.g. name update from Intro)
    context.read<SettingsCubit>().loadSettings();
    _requestAllPermissions();
    // Check for showcase
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkShowcase());
  }

  Future<void> _checkShowcase() async {
    final prefs = await SharedPreferences.getInstance();
    final hasShown = prefs.getBool('hasShownDashboardShowcase') ?? false;

    if (!hasShown && mounted) {
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

  // Check Audio Showcase
  Future<void> _checkAudioShowcase() async {
    final prefs = await SharedPreferences.getInstance();
    final hasShown = prefs.getBool('hasShownAudioPlayerShowcase') ?? false;

    if (!hasShown && mounted) {
      // Delay slightly to ensure widget is rendered
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        ShowCaseWidget.of(
          context,
        ).startShowCase([_dragAudioKey, _qoriAudioKey]);
        prefs.setBool('hasShownAudioPlayerShowcase', true);
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
    // 1. Location (Prioritized for Dashboard Data)
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // 2. Notifications (Secondary)
    await getIt<NotificationService>().requestPermissions();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Wrap with MultiBlocProvider
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
      ],
      child: Builder(
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
                backgroundColor: const Color(0xFF1C2A30), // Dark background
                selectedItemColor: const Color(0xFF00E676), // Accent Green
                unselectedItemColor: Colors.white54,
                type: BottomNavigationBarType.fixed,
                showUnselectedLabels: true,
                selectedLabelStyle: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: TextStyle(fontSize: 10.sp),
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
                    icon: Showcase(
                      key: _quranTabKey,
                      description: AppLocalizations.of(
                        context,
                      )!.showcaseQuranTab,
                      targetShapeBorder: const CircleBorder(),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        color: Color(
                          0xFFFFC107,
                        ), // Amber/Gold Highlight (Diff from Focus)
                      ),
                    ),
                    label: AppLocalizations.of(context)!.bottomNavQuran,
                  ),
                  BottomNavigationBarItem(
                    icon: Showcase(
                      key: _dzikirTabKey,
                      description: AppLocalizations.of(context)!.showcaseDzikir,
                      targetShapeBorder: const CircleBorder(),
                      child: const Icon(Icons.spa),
                    ), // Dzikir Icon
                    label: AppLocalizations.of(context)!.bottomNavDzikir,
                  ),
                  BottomNavigationBarItem(
                    icon: Showcase(
                      key: _settingsTabKey,
                      description: AppLocalizations.of(
                        context,
                      )!.showcaseSettingsGoal,
                      targetShapeBorder: const CircleBorder(),
                      child: const Icon(Icons.settings),
                    ), // Settings Icon
                    label: AppLocalizations.of(context)!.bottomNavSettings,
                  ),
                ],
              ),
            ),
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0F2027),
                    Color(0xFF203A43),
                    Color(0xFF2C5364),
                  ],
                ),
              ),
              child: SafeArea(
                child: Stack(
                  children: [
                    IndexedStack(
                      index: _currentIndex,
                      children: [
                        _buildHomeContent(context), // Uses inner context
                        const PrayerPage(),
                        const QuranPage(),
                        // Dzikir & Doa (Index 3)
                        const DzikirPage(),
                        // Settings (Index 4)
                        const SettingsPage(),
                      ],
                    ),
                    // Listen to Audio Bloc for Showcase Trigger
                    BlocListener<AudioBloc, AudioState>(
                      listener: (context, state) {
                        if (state.isMiniPlayerVisible) {
                          _checkAudioShowcase();
                        }
                      },
                      child: DraggableAudioPlayer(
                        dragShowcaseKey: _dragAudioKey,
                        qoriShowcaseKey: _qoriAudioKey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context) {
    return Column(
      children: [
        // STICKY HEADER
        Padding(
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
            ],
          ),
        ),
        SizedBox(height: 8.h),

        // SCROLLABLE CONTENT
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              // Reload Data
              context.read<PrayerBloc>().add(FetchPrayerTimeByLocation());
              context.read<ReadingBloc>().add(LoadReadingOverview());
              context
                  .read<SettingsCubit>()
                  .loadSettings(); // Reload settings like name/target

              // Small delay for visual feedback
              await Future.delayed(const Duration(seconds: 1));
            },
            color: const Color(0xFF00E676),
            child: SingleChildScrollView(
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

                      final hijri = HijriCalendar.fromDate(now);
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
                  SizedBox(height: 24.h),

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

                      return Showcase(
                        key: _dailyGoalKey,
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
                  SizedBox(height: 32.h),

                  // HERO CARD (Prayer Time)
                  BlocBuilder<PrayerBloc, PrayerState>(
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

                      final gradient = _getPrayerGradient(nextPrayer['name']);
                      final isLandscape =
                          MediaQuery.of(context).orientation ==
                          Orientation.landscape;

                      return Showcase(
                        key: _prayerCardKey,
                        description: AppLocalizations.of(
                          context,
                        )!.showcasePrayerCard,
                        child: GestureDetector(
                          onTap: () => context.go('/dashboard?index=1'),
                          child: Container(
                            height: isLandscape ? null : 150.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.r),
                              gradient: gradient,
                              boxShadow: [
                                BoxShadow(
                                  color: gradient.colors.last.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
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
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(
                                    isLandscape ? 8.w : 20.w,
                                  ),
                                  child: isLandscape
                                      ? Row(
                                          children: [
                                            // Left: Label & City
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.symmetric(
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
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10.sp,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 4.h),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.location_on,
                                                      color: Colors.white70,
                                                      size: 12.sp,
                                                    ),
                                                    SizedBox(width: 4.w),
                                                    Text(
                                                      state.currentCity.name,
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12.sp,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            const Spacer(),
                                            // Middle: Prayer Name & Time
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.baseline,
                                              textBaseline:
                                                  TextBaseline.alphabetic,
                                              children: [
                                                Text(
                                                  nextPrayer['name'],
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20.sp,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(width: 8.w),
                                                Text(
                                                  nextPrayer['time'],
                                                  style: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 16.sp,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const Spacer(),
                                            // Right: Countdown
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 8.w,
                                                vertical: 4.h,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.black26,
                                                borderRadius:
                                                    BorderRadius.circular(12.r),
                                              ),
                                              child: PrayerCountdownWidget(
                                                targetTime:
                                                    nextPrayer['nextPrayerTime']
                                                        as DateTime,
                                                baseColor: const Color(
                                                  0xFF00E676,
                                                ),
                                                onFinished: () {
                                                  context
                                                      .read<PrayerBloc>()
                                                      .add(
                                                        FetchPrayerTime(
                                                          cityId: state
                                                              .currentCity
                                                              .id,
                                                          date: DateTime.now(),
                                                        ),
                                                      );
                                                },
                                              ),
                                            ),
                                          ],
                                        )
                                      : Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // TOP ROW: Label & City
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.symmetric(
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
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.location_on,
                                                      color: Colors.white70,
                                                      size: 14.sp,
                                                    ),
                                                    SizedBox(width: 4.w),
                                                    Text(
                                                      state.currentCity.name,
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14.sp,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            // MIDDLE ROW: Prayer Name & Time
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  nextPrayer['name'],
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 28.sp,
                                                    fontWeight: FontWeight.bold,
                                                    height: 1.0,
                                                  ),
                                                ),
                                                SizedBox(width: 12.w),
                                                Text(
                                                  nextPrayer['time'],
                                                  style: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 20.sp,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            // BOTTOM ROW: Countdown & Hijri Date
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 12.w,
                                                    vertical: 6.h,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black26,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12.r,
                                                        ),
                                                  ),
                                                  child: PrayerCountdownWidget(
                                                    targetTime:
                                                        nextPrayer['nextPrayerTime']
                                                            as DateTime,
                                                    baseColor: const Color(
                                                      0xFF00E676,
                                                    ),
                                                    onFinished: () {
                                                      // Refresh Prayer Times when countdown finishes
                                                      context
                                                          .read<PrayerBloc>()
                                                          .add(
                                                            FetchPrayerTime(
                                                              cityId: state
                                                                  .currentCity
                                                                  .id,
                                                              date:
                                                                  DateTime.now(),
                                                            ),
                                                          );
                                                    },
                                                  ),
                                                ),
                                                Text(
                                                  state.prayerTime!
                                                      .getHijriDate(),
                                                  style: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 12.sp,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 32.h),

                  // QUICK ACCESS
                  Text(
                    AppLocalizations.of(context)!.cardQuickAccess,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  // QUICK ACCESS GRID
                  Showcase(
                    key: _quickAccessKey,
                    description: AppLocalizations.of(
                      context,
                    )!.showcaseQuickAccess,
                    child: IntrinsicHeight(
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
                                  color: const Color(0xFF1B5E20),
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
                              color: const Color(0xFF0288D1),
                              onTap: () => context.push('/quran/history'),
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
                              color: const Color(0xFFE65100),
                              onTap: () => context.push('/daily-inspiration'),
                            ),
                          ),
                        ],
                      ),
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
      child: const Center(child: CircularProgressIndicator()),
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
      height: isLandscape ? null : 160.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: const LinearGradient(
          colors: [Color(0xFF6A11CB), Color(0xFF2575FC)], // Deep Purple to Blue
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2575FC).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Pattern
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.auto_stories,
              size: isLandscape ? 80.sp : 140.sp,
              color: Colors.white.withOpacity(0.08),
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
                          color: Colors.white,
                          size: 16.sp,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      // Title
                      Text(
                        l10n.cardDailyGoal,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
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
                      SizedBox(
                        width: 40.w,
                        height: 40.w,
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
                                Color(0xFF00E676),
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
                                    color: Colors.white,
                                    size: 20.sp,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    l10n.cardDailyGoal,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
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
                                      color: const Color(0xFF00E676),
                                      borderRadius: BorderRadius.circular(8.r),
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
                            SizedBox(height: 16.h),
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
                              SizedBox(
                                width: 80.w,
                                height: 80.w,
                                child: CircularProgressIndicator(
                                  value: percentage,
                                  strokeWidth: 8.w,
                                  strokeCap: StrokeCap.round,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        Color(0xFF00E676),
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
    );
  }

  Widget _buildQuickAccessGridItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // height removed to avoid overflow, handled by IntrinsicHeight in parent
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: const Color(0xFF1C2A30),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color.withOpacity(0.9), size: 24.sp),
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  LinearGradient _getPrayerGradient(String prayerName) {
    switch (prayerName) {
      case 'Subuh':
        return const LinearGradient(
          colors: [Color(0xFF2C3E50), Color(0xFFE1B12C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'Terbit':
        return const LinearGradient(
          colors: [Color(0xFFE1B12C), Color(0xFFF1C40F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'Dzuhur':
        return const LinearGradient(
          colors: [Color(0xFF2980B9), Color(0xFF6DD5FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'Ashar':
        return const LinearGradient(
          colors: [Color(0xFF6DD5FA), Color(0xFFFF7F50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'Maghrib':
        return const LinearGradient(
          colors: [Color(0xFFFF7F50), Color(0xFF8E44AD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'Isya':
        return const LinearGradient(
          colors: [Color(0xFF8E44AD), Color(0xFF2C3E50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'Imsak':
      default:
        return const LinearGradient(
          colors: [Color(0xFF11998e), Color(0xFF38ef7d)], // Default Green
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }
}

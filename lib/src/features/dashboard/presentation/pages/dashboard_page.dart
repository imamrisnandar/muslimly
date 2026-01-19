import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart'; // Fixed import
import 'package:intl/intl.dart';
import 'package:hijri/hijri_calendar.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../settings/presentation/bloc/settings_cubit.dart';
import '../../../settings/presentation/bloc/settings_state.dart';
import 'prayer_page.dart';
import '../../../quran/presentation/pages/quran_page.dart';
import '../../../prayer/presentation/bloc/prayer_bloc.dart';
import '../../../prayer/presentation/bloc/prayer_event.dart';
import '../../../prayer/presentation/bloc/prayer_state.dart';
import '../../../quran/presentation/bloc/reading/reading_bloc.dart';
import '../../../quran/presentation/bloc/reading/reading_event.dart';
import '../../../quran/presentation/bloc/reading/reading_state.dart';

import '../../../prayer/domain/entities/prayer_time_extension.dart'; // Ext Impt
import '../../../../core/di/di_container.dart';
import '../../../../core/services/notification_service.dart';

class DashboardPage extends StatefulWidget {
  final int initialIndex;
  const DashboardPage({super.key, this.initialIndex = 0});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _requestAllPermissions();
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
                onTap: (index) => setState(() => _currentIndex = index),
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
                    icon: const Icon(Icons.book),
                    label: AppLocalizations.of(context)!.bottomNavQuran,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.music_note),
                    label: AppLocalizations.of(context)!.bottomNavMurottal,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.article),
                    label: AppLocalizations.of(context)!.bottomNavArticles,
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
                child: IndexedStack(
                  index: _currentIndex,
                  children: [
                    _buildHomeContent(context), // Uses inner context
                    const PrayerPage(),
                    const QuranPage(),
                    const Center(
                      child: Text(
                        'Murottal Page',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const Center(
                      child: Text(
                        'Articles Page',
                        style: TextStyle(color: Colors.white),
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
              IconButton(
                onPressed: () => context.push('/settings').then((value) {
                  // Update UserName (Cubit already listens to Repo changes if implemented that way,
                  // but SettingsCubit in Dashboard is same instance? Yes, likely global or provided up high.
                  // Wait, SettingsCubit in Dashboard is provided via getIt factory?
                  // SettingsCubit is Factory in DI... meaning new instance every time BlocProvider creates it.
                  // If Dashboard creates SettingsCubit, and Settings creates ANOTHER SettingsCubit...
                  // Changes in Settings won't be seen by Dashboard unless we reload.
                  // ReadingBloc also needs reload.
                  context.read<ReadingBloc>().add(LoadReadingOverview());
                  // We might also need to reload SettingsCubit to see new Name immediatley if not shared.
                  // But userName is less critical.
                  context
                      .read<SettingsCubit>()
                      .loadSettings(); // We need to expose a public reload method or just re-create?
                  // Actually SettingsCubit constructor loads settings.
                  // We can't re-construct easily without triggering re-build.
                  // We should add a public 'reload' method to SettingsCubit if we want instant name update. For now reading target is priority.
                }),
                icon: Icon(
                  Icons.settings_outlined,
                  color: Colors.white,
                  size: 24.sp,
                ),
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

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _currentIndex = 1; // Switch to Prayer Tab
                          });
                        },
                        child: Container(
                          height: 220.h,
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
                              // Background Pattern/Icon overlay
                              Positioned(
                                right: -20,
                                bottom: -20,
                                child: Icon(
                                  Icons.mosque,
                                  size: 150.sp,
                                  color: Colors.white.withOpacity(0.2),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(20.w),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              AppLocalizations.of(
                                                context,
                                              )!.cardNextPrayer,
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 14.sp,
                                              ),
                                            ),
                                            Text(
                                              nextPrayer['name'],
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 28.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              state.currentCity.name,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              nextPrayer['time'],
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 24.sp,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              state.prayerTime!
                                                  .getHijriDate(), // Display Hijri Date
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
                                    SizedBox(height: 16.h),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12.w,
                                        vertical: 6.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black26,
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            color: const Color(0xFF00E676),
                                            size: 16.sp,
                                          ),
                                          SizedBox(width: 8.w),
                                          Text(
                                            nextPrayer['timeLeft'],
                                            style: TextStyle(
                                              color: const Color(0xFF00E676),
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 32.h),

                  // PROGRESS SECTION
                  BlocBuilder<ReadingBloc, ReadingState>(
                    builder: (context, state) {
                      final progress = state.dailyProgress;
                      final target = state.dailyTarget;
                      final percentage = (target > 0)
                          ? (progress / target).clamp(0.0, 1.0)
                          : 0.0;

                      final isCompleted = progress >= target && target > 0;
                      final l10n = AppLocalizations.of(context)!;

                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        l10n.cardDailyGoal,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(width: 6.w),
                                      Tooltip(
                                        message: l10n.targetHelp,
                                        triggerMode: TooltipTriggerMode.tap,
                                        showDuration: const Duration(
                                          seconds: 3,
                                        ),
                                        padding: EdgeInsets.all(12.w),
                                        margin: EdgeInsets.symmetric(
                                          horizontal: 24.w,
                                        ),
                                        textStyle: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14.sp,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(
                                            0.9,
                                          ), // Strong contrast
                                          borderRadius: BorderRadius.circular(
                                            8.r,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.info_outline,
                                          color: Colors.white70,
                                          size: 18.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (isCompleted)
                                    Text(
                                      l10n.targetReachedMessage,
                                      style: TextStyle(
                                        color: const Color(0xFF00E676),
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                ],
                              ),
                              Text(
                                l10n.targetProgress(progress, target),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10.r),
                            child: LinearProgressIndicator(
                              value: percentage,
                              minHeight: 8.h,
                              backgroundColor: Colors.white.withOpacity(0.1),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isCompleted
                                    ? const Color(0xFF00E676) // Green if done
                                    : const Color(
                                        0xFF2196F3,
                                      ), // Blue if progress
                              ),
                            ),
                          ),
                        ],
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
                  _buildQuickAccessCard(
                    title: AppLocalizations.of(context)!.cardContinueReading,
                    subtitle: AppLocalizations.of(
                      context,
                    )!.cardContinueReadingSubtitle,
                    color: const Color(0xFF1B5E20),
                    icon: Icons.menu_book,
                    onTap: () => context.push('/quran/bookmarks'),
                  ),
                  SizedBox(height: 16.h),
                  _buildQuickAccessCard(
                    title: AppLocalizations.of(context)!.cardReadingHistory,
                    subtitle: AppLocalizations.of(
                      context,
                    )!.cardReadingHistorySubtitle,
                    color: const Color(0xFF0288D1),
                    icon: Icons.history,
                    onTap: () => context.push('/quran/history'),
                  ),
                  SizedBox(height: 16.h),
                  _buildQuickAccessCard(
                    title: AppLocalizations.of(context)!.cardDailyInspiration,
                    subtitle: AppLocalizations.of(
                      context,
                    )!.cardDailyInspirationSubtitle,
                    color: const Color(0xFFE65100),
                    icon: Icons.lightbulb_outline,
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

  Widget _buildQuickAccessCard({
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: const Color(0xFF1C2A30), // Dark card bg
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.white54, fontSize: 14.sp),
                  ),
                ],
              ),
            ),
            Container(
              height: 60.h,
              width: 100.w,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: Colors.white, size: 30.sp),
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

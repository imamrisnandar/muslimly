import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart'; // Fixed import
import 'package:intl/intl.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../settings/presentation/bloc/settings_cubit.dart';
import '../../../settings/presentation/bloc/settings_state.dart';
import 'prayer_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../quran/presentation/pages/quran_page.dart';
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
import '../widgets/fasting_reminder_section.dart';
import '../widgets/dzikir_reminder_section.dart';
import '../../../quran/presentation/widgets/draggable_audio_player.dart';
import '../../domain/services/reminder_service.dart';
import '../../../prayer/domain/services/fasting_service.dart';
import '../../domain/models/reminder_models.dart';
import '../../../zikir/domain/usecases/get_zikir_content.dart';
import '../../../zikir/presentation/pages/dzikir_reading_page.dart';

import '../../../prayer/domain/entities/prayer_time_extension.dart'; // Ext Impt
import '../../../../core/di/di_container.dart';
import '../../../../core/services/notification_service.dart';

import '../../../article/presentation/bloc/article_bloc.dart';
import '../../../article/presentation/widgets/article_carousel_widget.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/city_search_dialog.dart';
import '../widgets/dashboard_daily_goal_card_widget.dart';

class DashboardPage extends StatefulWidget {
  final int initialIndex;
  const DashboardPage({super.key, this.initialIndex = 0});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late int _currentIndex;
  // Tabs are only ever built once the user actually opens them, instead of
  // all 5 (each with its own BLoC/init side effects) firing at once on
  // startup. Once built, a tab stays in the IndexedStack so its state (scroll
  // position, in-progress audio, etc.) survives switching away and back.
  late final Set<int> _builtIndices;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _builtIndices = {widget.initialIndex};
    context.read<SettingsCubit>().loadSettings();
    _requestAllPermissions();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant DashboardPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialIndex != oldWidget.initialIndex) {
      setState(() {
        _currentIndex = widget.initialIndex;
        _builtIndices.add(widget.initialIndex);
      });
    }
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
      _builtIndices.add(index);
    });
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
    return Scaffold(
                extendBody: true,
                bottomNavigationBar: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: BottomNavigationBar(
                    currentIndex: _currentIndex,
                    onTap: _onTabSelected,
                    backgroundColor: AppColors.cardDark,
                    selectedItemColor: AppColors.accent,
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
                        icon: const Icon(
                          Icons.menu_book_rounded,
                          color: AppColors.gold,
                        ),
                        label: AppLocalizations.of(context)!.bottomNavQuran,
                      ),
                      BottomNavigationBarItem(
                        icon: const Icon(Icons.spa),
                        label: AppLocalizations.of(context)!.bottomNavDzikir,
                      ),
                      BottomNavigationBarItem(
                        icon: const Icon(Icons.settings),
                        label: AppLocalizations.of(context)!.bottomNavSettings,
                      ),
                    ],
                  ),
                ),
                body: Container(
                  decoration: const BoxDecoration(color: AppColors.bgGradientStart),
                  child: SafeArea(
                    child: Stack(
                      children: [
                        IndexedStack(
                          index: _currentIndex,
                          children: [
                            _builtIndices.contains(0)
                                ? _buildHomeContent(context)
                                : const SizedBox.shrink(),
                            _builtIndices.contains(1)
                                ? const PrayerPage()
                                : const SizedBox.shrink(),
                            _builtIndices.contains(2)
                                ? const QuranPage()
                                : const SizedBox.shrink(),
                            _builtIndices.contains(3)
                                ? const DzikirPage()
                                : const SizedBox.shrink(),
                            _builtIndices.contains(4)
                                ? const SettingsPage()
                                : const SizedBox.shrink(),
                          ],
                        ),
                        DraggableAudioPlayer(
                          enableShowcase: _currentIndex == 2,
                        ),
                      ],
                    ),
                  ),
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
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on,
                            color: AppColors.accent,
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
                            color: AppColors.accent,
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
              // Get current language code
              final lang = Localizations.localeOf(context).languageCode;

              // Reload Data
              context.read<PrayerBloc>().add(FetchPrayerTimeByLocation());
              context.read<ReadingBloc>().add(LoadReadingOverview());
              context.read<ReadingBloc>().add(SyncReadingData());
              context.read<BookmarkBloc>().add(
                LoadBookmarks(),
              ); // Add Bookmark Refresh
              context.read<SettingsCubit>().loadSettings();

              // Refresh Article Carousel
              context.read<ArticleBloc>().add(LoadArticles(lang: lang, limit: 5));

              // Small delay for visual feedback
              await Future.delayed(const Duration(seconds: 1));
            },
            color: AppColors.accent,
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
                      final name = (state.userName.isEmpty) ? 'Friend' : state.userName;
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

                      return DashboardDailyGoalCardWidget(
                            progress: progress,
                            target: target,
                            unitLabel: label,
                            l10n: l10n,
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

                          return GestureDetector(
                              onTap: () => _onTabSelected(1),
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
                                      ).withValues(alpha: 0.2), // Teal Accent as Base
                                      AppColors.accentDark.withValues(alpha: 0.05),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    // Soft Teal Glow
                                    BoxShadow(
                                      color: const Color(
                                        0xFF1DE9B6,
                                      ).withValues(alpha: 0.1),
                                      blurRadius: 20,
                                      spreadRadius: -5,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: const Color(
                                      0xFFFFC107,
                                    ).withValues(alpha: 0.3), // Clearer Gold Border
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
                                        ).withValues(alpha: 0.1), // Gold Icon Tint
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
                                                          ).withValues(alpha: 0.3),
                                                          width: 1,
                                                        ),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: const Color(
                                                              0xFFFFC107,
                                                            ).withValues(alpha: 0.15),
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
                                                          ).withValues(alpha: 0.3),
                                                          width: 1,
                                                        ),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: const Color(
                                                              0xFFFFC107,
                                                            ).withValues(alpha: 0.15),
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
                                                          .withValues(alpha: 0.2),
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
                                                        FastingReminderSection(
                                                          todayFasting: reminderData.todayFasting,
                                                          nextFasting: reminderData.nextFasting,
                                                          locale: l10n.localeName,
                                                        ),
                                                        if (reminderData.hasAnyActiveDzikir) ...[
                                                          if (reminderData.todayFasting != null || reminderData.nextFasting != null)
                                                            Padding(
                                                              padding: EdgeInsets.symmetric(vertical: 6.h),
                                                              child: Divider(
                                                                color: Colors.white.withValues(alpha: 0.1),
                                                                height: 1,
                                                              ),
                                                            ),
                                                          DzikirReminderSection(
                                                            morningDzikir: reminderData.morningDzikir,
                                                            eveningDzikir: reminderData.eveningDzikir,
                                                            onDzikirTap: (dzikir) async {
                                                              final locale = Localizations.localeOf(context);
                                                              final items = dzikir.type == DzikirType.morning
                                                                  ? await getIt<GetZikirContent>()(ZikirCategory.morning, locale)
                                                                  : await getIt<GetZikirContent>()(ZikirCategory.evening, locale);
                                                              final title = dzikir.type == DzikirType.morning
                                                                  ? l10n.dzikirMorningTitle
                                                                  : l10n.dzikirEveningTitle;
                                                              if (context.mounted) {
                                                                Navigator.push(context, MaterialPageRoute(
                                                                  builder: (_) => DzikirReadingPage(title: title, items: items),
                                                                ));
                                                              }
                                                            },
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
                  Column(
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
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: const Center(child: IslamicLoadingIndicator(size: 64)),
    );
  }

  Widget _buildErrorHero(String msg) {
    return Container(
      height: 220.h,
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
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
          child: const CitySearchDialog(),
        );
      },
    );
  }

  // existing _buildQuickAccessGridItem is already defined below but was removed in thought process due to lack of space?
  // No, the previous tool confirmed checking until line 1254.
  // Wait, I replaced _buildErrorHero but I need to make sure I don't break the file structure.
  // Viewing showed `_buildErrorHero` around line 840.
  // I will append _showLastReadSelection AFTER _buildErrorHero.

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
        splashColor: color.withValues(alpha: 0.3),
        highlightColor: color.withValues(alpha: 0.1),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.cardDark.withValues(alpha: 0.95),
                const Color(0xFF243742).withValues(alpha: 0.85),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: color.withValues(alpha: 0.15),
                blurRadius: 25,
                spreadRadius: -5,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
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
                    colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0.05)],
                  ),
                  // Thin, Subtle Border
                  border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
                  // Soft, Diffused Shadows
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.2),
                      blurRadius: 15,
                      spreadRadius: -2,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: color.withValues(alpha: 0.9), // Slightly softer icon color
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
                      color: Colors.black.withValues(alpha: 0.3),
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
}

// City Search Dialog Widget

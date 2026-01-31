import 'package:flutter/material.dart';
import 'help_guide_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:muslimly/src/core/utils/surah_names.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../core/di/di_container.dart';
import '../bloc/reading/reading_bloc.dart';
import '../bloc/reading/reading_event.dart';
import '../bloc/reading/reading_state.dart';
import '../../domain/entities/reading_activity.dart';

class ReadingHistoryPage extends StatefulWidget {
  const ReadingHistoryPage({super.key});

  @override
  State<ReadingHistoryPage> createState() => _ReadingHistoryPageState();
}

class _ReadingHistoryPageState extends State<ReadingHistoryPage> {
  // We use a key to force rebuild of TabController when initialIndex changes if needed,
  // but typically we just need to set it once or listen to changes.
  // Actually, BlocBuilder inside Scaffold body allows us to read state,
  // but DefaultTabController wraps Scaffold.
  // We need to access Bloc BEFORE DefaultTabController.

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ReadingBloc>()..add(LoadReadingHistory()),
      child: BlocBuilder<ReadingBloc, ReadingState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Material(
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF00E676)),
              ),
            );
          }

          // Determine initial index based on targetUnit
          // 'ayah' -> Tab 0, 'page' -> Tab 1
          final initialIndex = state.targetUnit == 'ayah' ? 0 : 1;

          return DefaultTabController(
            key: ValueKey(
              'history_tab_$initialIndex',
            ), // Force rebuild if index changes
            length: 2,
            initialIndex: initialIndex,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0F2027),
                    Color(0xFF203A43),
                    Color(0xFF2C5364),
                  ],
                ),
              ),
              child: Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  centerTitle: true,
                  leading: const BackButton(color: Colors.white),
                  title: Text(
                    AppLocalizations.of(context)!.historyTitle ??
                        "Reading History",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Outfit',
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.info_outline, color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HelpGuidePage(),
                          ),
                        );
                      },
                    ),
                  ],
                  bottom: PreferredSize(
                    preferredSize: Size.fromHeight(60.h),
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(50.r),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: TabBar(
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(40.r),
                          color: const Color(0xFF00E676),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00E676).withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        labelColor: const Color(0xFF052025),
                        unselectedLabelColor: Colors.white70,
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15.sp,
                          fontFamily: 'Outfit',
                          letterSpacing: 0.5,
                        ),
                        unselectedLabelStyle: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15.sp,
                          fontFamily: 'Outfit',
                          letterSpacing: 0.5,
                        ),
                        splashBorderRadius: BorderRadius.circular(40.r),
                        tabs: [
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.format_list_bulleted_rounded,
                                  size: 18,
                                ),
                                SizedBox(width: 6.w),
                                Flexible(
                                  child: Text(
                                    AppLocalizations.of(context)!.lblListType ??
                                        "Ayah",
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.menu_book_rounded, size: 18),
                                SizedBox(width: 6.w),
                                Flexible(
                                  child: Text(
                                    AppLocalizations.of(
                                          context,
                                        )!.lblMushafType ??
                                        "Mushaf",
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                body: Builder(
                  builder: (context) {
                    // Filter History
                    final ayahHistory = state.readingHistory
                        .where((a) => a.mode == 'ayah')
                        .toList();
                    final pageHistory = state.readingHistory
                        .where((a) => a.mode == 'page')
                        .toList();

                    // Sort descending by timestamp
                    ayahHistory.sort(
                      (a, b) => b.timestamp.compareTo(a.timestamp),
                    );
                    pageHistory.sort(
                      (a, b) => b.timestamp.compareTo(a.timestamp),
                    );

                    return TabBarView(
                      children: [
                        _buildHistoryList(
                          context,
                          ayahHistory,
                          true,
                          state.weeklyAyahProgress,
                          state.monthlyAyahProgress,
                          state.chartReferenceDate,
                          state.dailyAyahTarget, // Pass Ayah Target
                          state.lifetimeTotalAyah,
                          state.currentStreakAyah,
                          state.thirtyDayAverageAyah,
                          state.isWeeklyView,
                        ),
                        _buildHistoryList(
                          context,
                          pageHistory,
                          false,
                          state.weeklyPageProgress,
                          state.monthlyPageProgress,
                          state.chartReferenceDate,
                          state.dailyTarget, // Pass Page Target
                          state.lifetimeTotalPage,
                          state.currentStreakPage,
                          state.thirtyDayAveragePage,
                          state.isWeeklyView,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryList(
    BuildContext context,
    List<ReadingActivity> history,
    bool isListMode, // Ayah Mode
    Map<String, int> weeklyProgress,
    Map<String, int> monthlyProgress,
    DateTime? chartRefDate,
    int target, // Daily Target for chart
    int lifetimeTotal,
    int currentStreak,
    double thirtyDayAverage,
    bool isWeeklyView,
  ) {
    // 1. Group History by Week
    final groupedHistory = _groupHistoryByWeek(history, context);

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      children: [
        // --- Lifetime Stats Cards ---
        _buildLifetimeStatsCards(
          context,
          lifetimeTotal,
          currentStreak,
          thirtyDayAverage,
          isListMode,
        ),
        SizedBox(height: 16.h),

        // --- Reading Insight ---
        _buildInsightCard(
          context,
          weeklyProgress,
          target,
          currentStreak,
          lifetimeTotal,
          isListMode, // Pass mode to determine unit
        ),

        // --- View Toggle ---
        _buildViewToggle(context, isWeeklyView),
        SizedBox(height: 12.h),

        // --- Weekly/Monthly Graph ---
        _buildWeeklySummary(
          context,
          isWeeklyView ? weeklyProgress : monthlyProgress,
          chartRefDate,
          target,
          isWeeklyView,
        ),

        // --- History List Title ---
        Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Text(
            AppLocalizations.of(context)!.historyTitle ?? "Reading History",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              fontFamily: 'Outfit',
            ),
          ),
        ),

        // --- Empty State ---
        if (history.isEmpty) ...[
          SizedBox(height: 40.h),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.history_toggle_off,
                  size: 64.sp,
                  color: Colors.white12,
                ),
                SizedBox(height: 16.h),
                Text(
                  AppLocalizations.of(context)!.emptyBookmarkTitle ??
                      "No History Yet",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          // --- Grouped List View ---
          ...groupedHistory.entries.map((entry) {
            // Calculate Weekly Total
            int weeklyTotal = 0;
            int totalDuration = 0; // Sum duration

            if (isListMode) {
              weeklyTotal = entry.value.fold(
                0,
                (sum, item) => sum + (item.totalAyahs ?? 0),
              );
            } else {
              // Count unique pages
              weeklyTotal = entry.value.map((e) => e.pageNumber).toSet().length;
            }
            totalDuration = entry.value.fold(
              0,
              (sum, item) => sum + item.durationSeconds,
            );

            final l10n = AppLocalizations.of(context)!;
            final unit = isListMode
                ? (l10n.lblAyahs ?? 'Ayahs')
                : (l10n.lblPages ?? 'Pages');
            final durationStr = _formatDuration(
              totalDuration,
            ); // Format duration

            return Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
                expansionTileTheme: ExpansionTileThemeData(
                  iconColor: const Color(0xFF00E676),
                  collapsedIconColor: Colors.white54,
                  textColor: Colors.white,
                  collapsedTextColor: Colors.white,
                ),
              ),
              child: ExpansionTile(
                initiallyExpanded: true, // Auto open new items
                tilePadding: EdgeInsets.zero,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${l10n.lblWeek ?? 'Week'}: ${entry.key}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          "$weeklyTotal $unit", // Show Total
                          style: TextStyle(
                            color: const Color(0xFF00E676),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Outfit',
                          ),
                        ),
                        if (totalDuration > 0) ...[
                          SizedBox(width: 8.w),
                          Icon(
                            Icons.access_time,
                            size: 12.sp,
                            color: Colors.white54,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            durationStr,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12.sp,
                              fontFamily: 'Outfit',
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                children: entry.value.map((activity) {
                  return _buildHistoryItem(context, activity, isListMode);
                }).toList(),
              ),
            );
          }),
        ],
      ],
    );
  }

  // Helper to group history
  Map<String, List<ReadingActivity>> _groupHistoryByWeek(
    List<ReadingActivity> history,
    BuildContext context,
  ) {
    final Map<String, List<ReadingActivity>> groups = {};
    final String locale = Localizations.localeOf(context).languageCode;

    for (var activity in history) {
      // Parse date: 2023-01-01
      final date = DateTime.fromMillisecondsSinceEpoch(activity.timestamp);
      // Determine week range (Mon - Sun)
      // Find Monday
      final monday = date.subtract(Duration(days: date.weekday - 1));
      final sunday = monday.add(const Duration(days: 6));

      final rangeKey =
          "${DateFormat('d MMM', locale).format(monday)} - ${DateFormat('d MMM', locale).format(sunday)}";

      if (groups.containsKey(rangeKey)) {
        groups[rangeKey]!.add(activity);
      } else {
        groups[rangeKey] = [activity];
      }
    }
    return groups;
  }

  Widget _buildHistoryItem(
    BuildContext context,
    ReadingActivity activity,
    bool isListMode,
  ) {
    final String locale = Localizations.localeOf(context).languageCode;
    final surahName =
        (activity.surahNumber != null &&
            activity.surahNumber! >= 1 &&
            activity.surahNumber! <= 114)
        ? SurahNames.indonesianNames[activity.surahNumber! - 1]
        : "Surah ${activity.surahNumber}";

    return Container(
      margin: EdgeInsets.only(bottom: 8.h, left: 16.w, right: 16.w),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(
            isListMode ? Icons.format_list_bulleted : Icons.menu_book,
            color: const Color(0xFF00E676),
            size: 16.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  surahName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Outfit',
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  isListMode
                      ? "${activity.totalAyahs} Ayahs (Ayah ${activity.startAyah}-${activity.endAyah})"
                      : "Page ${activity.pageNumber}",
                  style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                ),
              ],
            ),
          ),
          Row(
            children: [
              if (activity.durationSeconds > 0) ...[
                Icon(Icons.access_time, size: 10.sp, color: Colors.white30),
                SizedBox(width: 2.w),
                Text(
                  _formatDuration(activity.durationSeconds),
                  style: TextStyle(color: Colors.white30, fontSize: 11.sp),
                ),
                SizedBox(width: 8.w),
                Text(
                  "•",
                  style: TextStyle(color: Colors.white30, fontSize: 11.sp),
                ),
                SizedBox(width: 8.w),
              ],
              Text(
                DateFormat("EEE, HH:mm", locale).format(
                  DateTime.fromMillisecondsSinceEpoch(activity.timestamp),
                ),
                style: TextStyle(color: Colors.white30, fontSize: 11.sp),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) return "${seconds}s";
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    if (remainingSeconds == 0) return "${minutes}m";
    return "${minutes}m ${remainingSeconds}s";
  }

  Widget _buildViewToggle(BuildContext context, bool isWeeklyView) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          _buildToggleButton(context, 'Weekly', isWeeklyView, true),
          SizedBox(width: 8.w),
          _buildToggleButton(context, 'Monthly', !isWeeklyView, false),
        ],
      ),
    );
  }

  Widget _buildToggleButton(
    BuildContext context,
    String label,
    bool isActive,
    bool isWeekly,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          context.read<ReadingBloc>().add(ToggleChartView(isWeekly: isWeekly));
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF00E676)
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: isActive
                  ? const Color(0xFF00E676)
                  : Colors.white.withOpacity(0.1),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? Colors.black : Colors.white70,
              fontSize: 12.sp,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklySummary(
    BuildContext context,
    Map<String, int> progress,
    DateTime? chartRefDate,
    int target, // Daily Target
    bool isWeeklyView, // NEW Param
  ) {
    // Determine number of days to show
    final daysToShow = isWeeklyView ? 7 : 30;

    final refDate = chartRefDate ?? DateTime.now();
    final bool isCurrentWeek = refDate.isAfter(
      DateTime.now().subtract(const Duration(days: 1)),
    );

    final List<String> labels = [];
    final List<int> values = [];
    int maxVal = target > 0 ? target : 1;

    final String locale = Localizations.localeOf(context).languageCode;

    for (int i = daysToShow - 1; i >= 0; i--) {
      final d = refDate.subtract(Duration(days: i));
      final key = DateFormat('yyyy-MM-dd').format(d);
      final val = progress[key] ?? 0;

      if (isWeeklyView) {
        labels.add(
          DateFormat('E', locale).format(d)[0],
        ); // M, T, W (Single letter)
      } else {
        // Show label for first, last, and every 5th day
        if (i == 0 || i == daysToShow - 1 || i % 5 == 0) {
          labels.add(DateFormat('d').format(d));
        } else {
          labels.add('');
        }
      }

      values.add(val);
      if (val > maxVal) maxVal = val;
    }

    // Add buffer to maxVal for visuals
    if (maxVal == target) maxVal = (target * 1.5).ceil();

    // Date Range Label
    final startDate = refDate.subtract(Duration(days: daysToShow - 1));
    final dateRange =
        "${DateFormat('d MMM', locale).format(startDate)} - ${DateFormat('d MMM', locale).format(refDate)}";

    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00E676).withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isWeeklyView
                          ? (AppLocalizations.of(context)!.chartWeeklyTitle ??
                                "Weekly Progress")
                          : "Monthly Progress", // Hardcoded fallback or need key
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      dateRange,
                      style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                    onPressed: () {
                      context.read<ReadingBloc>().add(
                        const NavigateWeeklyChart(-1),
                      );
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  SizedBox(width: 8.w),
                  IconButton(
                    icon: Icon(
                      Icons.chevron_right,
                      color: isCurrentWeek ? Colors.white24 : Colors.white,
                      size: 24.sp,
                    ),
                    onPressed: isCurrentWeek
                        ? null
                        : () {
                            context.read<ReadingBloc>().add(
                              const NavigateWeeklyChart(1),
                            );
                          },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(daysToShow, (index) {
              final val = values[index];
              final label = labels[index];

              // Calculate Heights
              final double maxH = 120.h;
              double valHeight = maxVal > 0 ? (val / maxVal) * maxH : 0;
              double targetHeight = maxVal > 0 ? (target / maxVal) * maxH : 0;

              // Cap heights
              if (valHeight > maxH) valHeight = maxH;
              if (targetHeight > maxH) targetHeight = maxH;
              if (valHeight < 0) valHeight = 0;

              final bool isAchieved = val >= target && target > 0;
              final bool isToday =
                  isWeeklyView && (index == daysToShow - 1) && isCurrentWeek;

              // Bar width adjustment
              final barWidth = isWeeklyView ? 24.w : 6.w;
              final fontSize = isWeeklyView ? 11.sp : 9.sp;

              return Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      // Target Line (Background)
                      if (isWeeklyView) // Only show target marker in weekly view if simpler
                        Container(
                          height: targetHeight,
                          width: barWidth,
                          alignment: Alignment.topCenter,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: Colors.white.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                          ),
                        ),

                      // Value Bar
                      Container(
                        width: barWidth,
                        height: valHeight > 0 ? valHeight : 2.h, // Min height
                        decoration: BoxDecoration(
                          color: isAchieved
                              ? const Color(0xFF00E676)
                              : (val > 0
                                    ? const Color(0xFFFFB74D)
                                    : Colors.white10),
                          borderRadius: BorderRadius.circular(4.r),
                          gradient: isAchieved
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFF00E676),
                                    Color(0xFF69F0AE),
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                )
                              : null,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    label,
                    style: TextStyle(
                      color: isToday ? const Color(0xFF00E676) : Colors.white54,
                      fontSize: fontSize,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              );
            }),
          ),
          SizedBox(height: 16.h),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(
                color: const Color(0xFF00E676),
                label:
                    AppLocalizations.of(context)!.chartLegendTargetReached ??
                    "Reached",
              ),
              SizedBox(width: 16.w),
              _buildLegendItem(
                color: const Color(0xFFFFB74D),
                label:
                    AppLocalizations.of(context)!.chartLegendInProgress ??
                    "In Progress",
              ),
              SizedBox(width: 16.w),
              _buildLegendItem(
                color: Colors.white.withOpacity(0.2),
                label: "Target ($target)",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 4.w),
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 10.sp,
            fontFamily: 'Outfit',
          ),
        ),
      ],
    );
  }

  Widget _buildLifetimeStatsCards(
    BuildContext context,
    int total,
    int streak,
    double average,
    bool isListMode,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final unitLabel = isListMode ? l10n.lblAyahs : l10n.lblPages;

    return Row(
      children: [
        // Card 1: Total
        Expanded(
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF00E676).withOpacity(0.15),
                  Colors.white.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isListMode ? Icons.format_list_bulleted : Icons.menu_book,
                      color: const Color(0xFF00E676),
                      size: 20.sp,
                    ),
                    SizedBox(width: 6.w),
                    Flexible(
                      child: Text(
                        l10n.lblLifetimeTotal,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11.sp,
                          fontFamily: 'Outfit',
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  total.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Outfit',
                  ),
                ),
                Text(
                  unitLabel,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 11.sp,
                    fontFamily: 'Outfit',
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 12.w),

        // Card 2: Streak
        Expanded(
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFFB74D).withOpacity(0.15),
                  Colors.white.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('🔥', style: TextStyle(fontSize: 20.sp)),
                    SizedBox(width: 6.w),
                    Flexible(
                      child: Text(
                        l10n.lblReadingStreak,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11.sp,
                          fontFamily: 'Outfit',
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  streak.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Outfit',
                  ),
                ),
                Text(
                  l10n.lblDays,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 11.sp,
                    fontFamily: 'Outfit',
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 12.w),

        // Card 3: Average
        Expanded(
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF64B5F6).withOpacity(0.15),
                  Colors.white.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      color: const Color(0xFF64B5F6),
                      size: 20.sp,
                    ),
                    SizedBox(width: 6.w),
                    Flexible(
                      child: Text(
                        l10n.lblDailyAverage,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11.sp,
                          fontFamily: 'Outfit',
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  average.toStringAsFixed(1),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Outfit',
                  ),
                ),
                Text(
                  unitLabel,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 11.sp,
                    fontFamily: 'Outfit',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Helper: Generate Reading Insight
  Map<String, dynamic>? _generateInsight(
    BuildContext context,
    Map<String, int> weeklyProgress,
    int target,
    int currentStreak,
    int lifetimeTotal,
  ) {
    final now = DateTime.now();

    // Calculate weekly stats
    int weeklyTotal = 0;
    int weeklyTarget = target * 7;
    int daysWithProgress = 0;
    int maxDailyValue = 0;

    for (int i = 6; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      final key = DateFormat('yyyy-MM-dd').format(d);
      final val = weeklyProgress[key] ?? 0;
      weeklyTotal += val;
      if (val > 0) daysWithProgress++;
      if (val > maxDailyValue) maxDailyValue = val;
    }

    final todayKey = DateFormat('yyyy-MM-dd').format(now);
    final todayProgress = weeklyProgress[todayKey] ?? 0;
    final percentage = weeklyTarget > 0
        ? (weeklyTotal / weeklyTarget * 100)
        : 0;

    // Priority 1: Streak warnings (if streak exists and today = 0)
    if (currentStreak >= 3 && todayProgress == 0) {
      return {
        'type': 'warning',
        'icon': '⚠️',
        'message': 'insightStreakWarning',
        'color': const Color(0xFFFFB74D),
        'params': {'streak': currentStreak.toString()},
      };
    }

    // Priority 2: Ahead of target
    if (percentage >= 120) {
      return {
        'type': 'success',
        'icon': '🎉',
        'message': 'insightAheadTarget',
        'color': const Color(0xFF00E676),
        'params': {'percent': (percentage - 100).toStringAsFixed(0)},
      };
    }

    // Priority 3: Behind target with actionable tip
    if (percentage < 80 && daysWithProgress < 7) {
      final remaining = weeklyTarget - weeklyTotal;

      // Calculate actual days left in current week (from today forward)
      final dayOfWeek = now.weekday; // 1=Mon, 7=Sun
      final daysLeft = 8 - dayOfWeek; // Days left including today

      final needed = daysLeft > 0 ? (remaining / daysLeft).ceil() : remaining;
      return {
        'type': 'warning',
        'icon': '💪',
        'message': 'insightBehindTarget',
        'color': const Color(0xFFFFB74D),
        'params': {
          'remaining': remaining.toString(),
          'needed': needed.toString(),
        },
      };
    }

    // Priority 4: Streak milestone
    if (currentStreak == 5 ||
        currentStreak == 7 ||
        currentStreak == 14 ||
        currentStreak == 30) {
      return {
        'type': 'milestone',
        'icon': '🔥',
        'message': 'insightStreakMilestone',
        'color': const Color(0xFFFF6E40),
        'params': {'streak': currentStreak.toString()},
      };
    }

    // Priority 5: Perfect week
    if (daysWithProgress == 7 && weeklyTotal >= weeklyTarget) {
      return {
        'type': 'success',
        'icon': '👏',
        'message': 'insightPerfectWeek',
        'color': const Color(0xFF00E676),
        'params': {},
      };
    }

    // Priority 6: New daily record
    if (maxDailyValue >= target * 2 && maxDailyValue > 0) {
      return {
        'type': 'milestone',
        'icon': '⭐',
        'message': 'insightDailyRecord',
        'color': const Color(0xFFFFD700),
        'params': {'max': maxDailyValue.toString()},
      };
    }

    // Priority 7: Lifetime milestone
    if (lifetimeTotal == 100 || lifetimeTotal == 500 || lifetimeTotal == 1000) {
      return {
        'type': 'milestone',
        'icon': '🌟',
        'message': 'insightLifetimeMilestone',
        'color': const Color(0xFF00E676),
        'params': {'total': lifetimeTotal.toString()},
      };
    }

    return null; // No insight for now
  }

  Widget _buildInsightCard(
    BuildContext context,
    Map<String, int> weeklyProgress,
    int target,
    int currentStreak,
    int lifetimeTotal,
    bool isListMode, // Add mode parameter
  ) {
    final insight = _generateInsight(
      context,
      weeklyProgress,
      target,
      currentStreak,
      lifetimeTotal,
    );

    if (insight == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final unitLabel = isListMode
        ? l10n.lblAyahs
        : l10n.lblPages; // Get unit label
    String message = '';

    // Get localized message with params
    switch (insight['message']) {
      case 'insightStreakWarning':
        message = l10n.insightStreakWarning(
          insight['params']['streak'],
          unitLabel, // Add unit
        );
        break;
      case 'insightAheadTarget':
        message = l10n.insightAheadTarget(insight['params']['percent']);
        break;
      case 'insightBehindTarget':
        message = l10n.insightBehindTarget(
          insight['params']['needed'], // Swap: needed first
          insight['params']['remaining'], // then remaining
          unitLabel, // Add unit
        );
        break;
      case 'insightStreakMilestone':
        message = l10n.insightStreakMilestone(insight['params']['streak']);
        break;
      case 'insightPerfectWeek':
        message = l10n.insightPerfectWeek;
        break;
      case 'insightDailyRecord':
        message = l10n.insightDailyRecord(
          insight['params']['max'],
          unitLabel, // Add unit
        );
        break;
      case 'insightLifetimeMilestone':
        message = l10n.insightLifetimeMilestone(
          insight['params']['total'],
          unitLabel, // Add unit
        );
        break;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            (insight['color'] as Color).withOpacity(0.2),
            Colors.white.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: (insight['color'] as Color).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Text(insight['icon'] as String, style: TextStyle(fontSize: 24.sp)),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Outfit',
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  l10n.insightTargetInfo(
                    target.toString(),
                    unitLabel,
                    (target * 7).toString(),
                  ),
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 10.sp,
                    fontFamily: 'Outfit',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

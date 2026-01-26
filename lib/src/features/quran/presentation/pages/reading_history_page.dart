import 'package:flutter/material.dart';
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
                          state.chartReferenceDate,
                          state.dailyAyahTarget, // Pass Ayah Target
                        ),
                        _buildHistoryList(
                          context,
                          pageHistory,
                          false,
                          state.weeklyPageProgress,
                          state.chartReferenceDate,
                          state.dailyTarget, // Pass Page Target
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
    DateTime? chartRefDate,
    int target, // Daily Target for chart
  ) {
    // 1. Group History by Week
    final groupedHistory = _groupHistoryByWeek(history, context);

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      children: [
        // --- Weekly Graph ---
        _buildWeeklySummary(context, weeklyProgress, chartRefDate, target),

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
                title: Text(
                  "${AppLocalizations.of(context)!.lblWeek ?? 'Week'}: ${entry.key}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Outfit',
                  ),
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
          Text(
            DateFormat(
              "EEE, HH:mm",
              locale,
            ).format(DateTime.fromMillisecondsSinceEpoch(activity.timestamp)),
            style: TextStyle(color: Colors.white30, fontSize: 11.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklySummary(
    BuildContext context,
    Map<String, int> weeklyProgress,
    DateTime? chartRefDate,
    int target, // Daily Target
  ) {
    // Determine Last 7 Days based on chartRefDate
    final refDate = chartRefDate ?? DateTime.now();
    final bool isCurrentWeek = refDate.isAfter(
      DateTime.now().subtract(const Duration(days: 1)),
    );
    final List<String> last7Days = [];
    final List<int> values = [];
    int maxVal = target > 0 ? target : 1; // Base max on target

    final String locale = Localizations.localeOf(context).languageCode;

    for (int i = 6; i >= 0; i--) {
      final d = refDate.subtract(Duration(days: i));
      final key = DateFormat(
        'yyyy-MM-dd',
      ).format(d); // Key format doesn't depend on locale
      final val = weeklyProgress[key] ?? 0;
      last7Days.add(DateFormat('E', locale).format(d)); // Mon, Tue... LOCALIZED
      values.add(val);
      if (val > maxVal) maxVal = val;
    }

    // Add buffer to maxVal for visuals
    if (maxVal == target) maxVal = (target * 1.5).ceil();

    // Date Range Label
    final startDate = refDate.subtract(const Duration(days: 6));
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
                      AppLocalizations.of(context)!.chartWeeklyTitle ??
                          "Weekly Progress",
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
            children: List.generate(7, (index) {
              final val = values[index];
              final day = last7Days[index];

              // Calculate Heights
              final double maxH = 120.h;
              double valHeight = (val / maxVal) * maxH;
              double targetHeight = (target / maxVal) * maxH;

              // Cap heights
              if (valHeight > maxH) valHeight = maxH;
              if (targetHeight > maxH) targetHeight = maxH;

              return Column(
                children: [
                  // Value/Target Text
                  Text(
                    target > 0 ? "$val/$target" : "$val",
                    style: TextStyle(
                      color: val >= target
                          ? const Color(0xFF00E676) // Green text if reached
                          : Colors.white70,
                      fontSize: 9.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  // Stack for Bar
                  SizedBox(
                    height: maxH,
                    width: 12.w, // Slightly wider for overlay
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        // Target Bar (Background)
                        Container(
                          width: 12.w,
                          height: targetHeight,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(4.r),
                              topRight: Radius.circular(4.r),
                            ),
                          ),
                        ),
                        // Realization Bar (Foreground)
                        Container(
                          width: 12.w,
                          height: valHeight,
                          decoration: BoxDecoration(
                            color: val >= target
                                ? const Color(
                                    0xFF00E676,
                                  ) // Green if target reached
                                : const Color(0xFFFFB74D), // Orange if below
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    day,
                    style: TextStyle(color: Colors.white54, fontSize: 10.sp),
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
}

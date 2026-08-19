import 'package:flutter/material.dart';
import 'help_guide_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../core/di/di_container.dart';
import '../../../../core/presentation/widgets/app_transparent_app_bar.dart';
import '../bloc/reading/reading_bloc.dart';
import '../bloc/reading/reading_event.dart';
import '../bloc/reading/reading_state.dart';
import '../../domain/entities/reading_activity.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode
import '../../../../core/database/generate_dummy_data.dart';
import '../../../../core/widgets/islamic_loading_indicator.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/reading_history_item_widget.dart';
import '../widgets/reading_history_chart_widget.dart';
import '../widgets/reading_history_stats_widget.dart';

class ReadingHistoryPage extends StatefulWidget {
  const ReadingHistoryPage({super.key});

  @override
  State<ReadingHistoryPage> createState() => _ReadingHistoryPageState();
}

class _ReadingHistoryPageState extends State<ReadingHistoryPage> {
  final ScrollController _scrollController = ScrollController();
  ReadingBloc? _readingBloc;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_readingBloc == null) return;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      // Trigger load more when scrolled to 80%
      _readingBloc!.add(LoadMoreHistory());
    }
  }

  Future<void> _generateDummyData() async {
    await generateDummyData();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        _readingBloc = getIt<ReadingBloc>()..add(LoadReadingHistory());
        return _readingBloc!;
      },
      child: BlocBuilder<ReadingBloc, ReadingState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Material(
              child: Center(child: IslamicLoadingIndicator(size: 64)),
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
                    AppColors.bgGradientStart,
                    AppColors.bgGradientMid,
                    AppColors.bgGradientEnd,
                  ],
                ),
              ),
              child: Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppTransparentAppBar(
                  centerTitle: true,
                  titleFontSize: 20.sp,
                  title: AppLocalizations.of(context)!.historyTitle,
                  actions: [
                    // Debug: Generate Dummy Data
                    // Debug: Generate Dummy Data
                    if (kDebugMode)
                      IconButton(
                        icon: const Icon(Icons.science, color: Colors.amber),
                        tooltip: 'Generate 6 months dummy data',
                        onPressed: () async {
                          // Import the generator
                          final scaffoldMessenger = ScaffoldMessenger.of(
                            context,
                          );
                          try {
                            // Show loading
                            scaffoldMessenger.showSnackBar(
                              const SnackBar(
                                content: Text('Generating dummy data...'),
                                duration: Duration(seconds: 2),
                              ),
                            );

                            // Generate data
                            await _generateDummyData();

                            // Reload history
                            if (context.mounted) {
                              context.read<ReadingBloc>().add(
                                LoadReadingHistory(),
                              );
                            }

                            scaffoldMessenger.showSnackBar(
                              const SnackBar(
                                content: Text('✅ Dummy data generated!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content: Text('Error: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                      ),
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
                        color: Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(50.r),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: TabBar(
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(40.r),
                          color: AppColors.accent,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withValues(alpha: 0.3),
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
                                    AppLocalizations.of(context)!.lblListType,
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
                                    AppLocalizations.of(context)!.lblMushafType,
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
    // 1. Group History by Week or Month based on toggle
    final groupedHistory = isWeeklyView
        ? _groupHistoryByWeek(history, context)
        : _groupHistoryByMonth(history, context);

    // 2. Get pagination state from BlocBuilder context
    final state = context.read<ReadingBloc>().state;
    final displayedWeeksCount = state.displayedWeeksCount;
    final isLoadingMore = state.isLoadingMore;
    final hasMoreHistory = state.hasMoreHistory;

    // 3. Limit displayed periods (weeks or months)
    final limitedHistory = groupedHistory.entries
        .take(displayedWeeksCount)
        .toList();

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ReadingHistoryStatsWidget(
                  total: lifetimeTotal,
                  streak: currentStreak,
                  average: thirtyDayAverage,
                  isListMode: isListMode,
                  weeklyProgress: weeklyProgress,
                  target: target,
                  currentStreak: currentStreak,
                  lifetimeTotal: lifetimeTotal,
                ),
                SizedBox(height: 16.h),
                _buildViewToggle(context, isWeeklyView),
                SizedBox(height: 12.h),
                ReadingHistoryChartWidget(
                  progress: isWeeklyView ? weeklyProgress : monthlyProgress,
                  chartRefDate: chartRefDate,
                  target: target,
                  isWeeklyView: isWeeklyView,
                  readingBloc: _readingBloc!,
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: Text(
                    AppLocalizations.of(context)!.historyTitle,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Outfit',
                    ),
                  ),
                ),
                if (history.isEmpty) ...[
                  SizedBox(height: 20.h),
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.history_toggle_off,
                            size: 28.sp,
                            color: Colors.white24,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          AppLocalizations.of(context)!.emptyHistorySubtitle,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          AppLocalizations.of(context)!.emptyBookmarkSubtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12.sp,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        ElevatedButton(
                          onPressed: () => context.go('/dashboard?index=2'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.w,
                              vertical: 10.h,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.r),
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.btnGoToQuran,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (history.isNotEmpty) ...[
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            sliver: SliverList.builder(
              itemCount: limitedHistory.length,
              itemBuilder: (context, index) {
                final entry = limitedHistory[index];
                final shouldExpand = index < 2;
                final l10n = AppLocalizations.of(context)!;

                int weeklyTotal = 0;
                int totalDuration = 0;
                if (isListMode) {
                  weeklyTotal = entry.value.fold(
                    0,
                    (sum, item) => sum + (item.totalAyahs ?? 0),
                  );
                } else {
                  weeklyTotal = entry.value
                      .map((e) => e.pageNumber)
                      .toSet()
                      .length;
                }
                totalDuration = entry.value.fold(
                  0,
                  (sum, item) => sum + item.durationSeconds,
                );

                final unit = isListMode ? l10n.lblAyahs : l10n.lblPages;
                final durationStr = formatReadingDuration(totalDuration);

                return Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent,
                    expansionTileTheme: ExpansionTileThemeData(
                      iconColor: AppColors.accent,
                      collapsedIconColor: Colors.white54,
                      textColor: Colors.white,
                      collapsedTextColor: Colors.white,
                    ),
                  ),
                  child: ExpansionTile(
                    initiallyExpanded: shouldExpand,
                    tilePadding: EdgeInsets.zero,
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isWeeklyView
                              ? "${l10n.lblWeek}: ${entry.key}"
                              : entry.key,
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
                              "$weeklyTotal $unit",
                              style: TextStyle(
                                color: AppColors.accent,
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
                    children: entry.value
                        .map(
                          (activity) => ReadingHistoryItemWidget(
                            activity: activity,
                            isListMode: isListMode,
                          ),
                        )
                        .toList(),
                  ),
                );
              },
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (isLoadingMore)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: const Center(
                      child: IslamicLoadingIndicator(size: 32),
                    ),
                  ),
                if (!hasMoreHistory && limitedHistory.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context)!.msgEndOfHistory,
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12.sp,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
              ]),
            ),
          ),
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

  Map<String, List<ReadingActivity>> _groupHistoryByMonth(
    List<ReadingActivity> history,
    BuildContext context,
  ) {
    final Map<String, List<ReadingActivity>> groups = {};
    final String locale = Localizations.localeOf(context).languageCode;

    for (var activity in history) {
      final date = DateTime.fromMillisecondsSinceEpoch(activity.timestamp);

      // Group by month (e.g., "January 2026", "February 2026")
      final monthKey = DateFormat('MMMM yyyy', locale).format(date);

      if (groups.containsKey(monthKey)) {
        groups[monthKey]!.add(activity);
      } else {
        groups[monthKey] = [activity];
      }
    }
    return groups;
  }

  // Extracted to dedicated widget files:
  // • _buildHistoryItem, _formatDuration → reading_history_item_widget.dart
  // • _buildWeeklySummary, _buildLegendItem → reading_history_chart_widget.dart
  // • _buildLifetimeStatsCards, _buildInsightCard, _generateInsight → reading_history_stats_widget.dart

  Widget _buildViewToggle(BuildContext context, bool isWeeklyView) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          _buildToggleButton(context, l10n.lblWeekly, isWeeklyView, true),
          SizedBox(width: 8.w),
          _buildToggleButton(context, l10n.lblMonthly, !isWeeklyView, false),
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
        onTap: () => _readingBloc?.add(ToggleChartView(isWeekly: isWeekly)),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.accent
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: isActive
                  ? AppColors.accent
                  : Colors.white.withValues(alpha: 0.1),
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
}

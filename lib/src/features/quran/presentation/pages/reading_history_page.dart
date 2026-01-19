import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/di_container.dart';
import '../../../../core/utils/surah_names.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../bloc/reading/reading_bloc.dart';
import '../bloc/reading/reading_event.dart';
import '../bloc/reading/reading_state.dart';

class ReadingHistoryPage extends StatelessWidget {
  const ReadingHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ReadingBloc>()..add(LoadReadingHistory()),
      child: Scaffold(
        backgroundColor: const Color(0xFF0F2027),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: const BackButton(color: Colors.white),
          title: Text(
            AppLocalizations.of(context)!.historyTitle,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: BlocBuilder<ReadingBloc, ReadingState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.errorMessage != null) {
              return Center(
                child: Text(
                  state.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }
            if (state.readingHistory.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history_toggle_off,
                      size: 64.sp,
                      color: Colors.white24,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      AppLocalizations.of(context)!.chartLegendNoActivity,
                      style: TextStyle(color: Colors.white54, fontSize: 16.sp),
                    ),
                    SizedBox(height: 24.h),
                    ElevatedButton(
                      onPressed: () {
                        // Switch tab to Quran (Index 2)
                        context.go('/dashboard?index=2');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00E676),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 12.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 4,
                        shadowColor: const Color(0xFF00E676).withOpacity(0.4),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.btnGoToQuran,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            // Group by Date
            final groupedHistory = <String, List<dynamic>>{};
            for (var activity in state.readingHistory) {
              if (!groupedHistory.containsKey(activity.date)) {
                groupedHistory[activity.date] = [];
              }
              groupedHistory[activity.date]!.add(activity);
            }

            return ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: groupedHistory.length + 1, // +1 for Chart
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildWeeklyChart(context, state);
                }

                final realIndex = index - 1;
                final dateKey = groupedHistory.keys.elementAt(realIndex);
                final activities = groupedHistory[dateKey]!;

                // Format Date Header
                final date = DateTime.parse(dateKey);
                final dateHeader = DateFormat('EEEE, d MMMM yyyy').format(date);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: Text(
                        dateHeader,
                        style: TextStyle(
                          color: const Color(0xFF00E676),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ...activities.map((activity) {
                      final startTime = DateTime.fromMillisecondsSinceEpoch(
                        activity.timestamp,
                      );
                      final timeStr = DateFormat('HH:mm').format(startTime);
                      final durationStr = _formatDuration(
                        activity.durationSeconds,
                      );

                      // Surah Name Logic
                      String surahDisplay = "Unknown Surah";
                      if (activity.surahNumber != null &&
                          activity.surahNumber! >= 1 &&
                          activity.surahNumber! <= 114) {
                        surahDisplay = SurahNames
                            .indonesianNames[activity.surahNumber! - 1];
                      }

                      return Container(
                        margin: EdgeInsets.only(bottom: 12.h),
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10.w),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.menu_book,
                                color: Colors.white,
                                size: 20.sp,
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    surahDisplay,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    "Page ${activity.pageNumber} • $timeStr",
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00E676).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Text(
                                durationStr,
                                style: TextStyle(
                                  color: const Color(0xFF00E676),
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildWeeklyChart(BuildContext context, ReadingState state) {
    if (state.weeklyProgress.isEmpty && state.readingHistory.isEmpty) {
      // If truly empty (brand new app), still show chart framework maybe?
      // But preserving existing logic for now.
    }

    final refDate = state.chartReferenceDate ?? DateTime.now();
    final startDate = refDate.subtract(const Duration(days: 6));

    // Check if we can go forward (is refDate < today?)
    final now = DateTime.now();
    final canGoNext =
        refDate.year < now.year ||
        (refDate.year == now.year && refDate.month < now.month) ||
        (refDate.year == now.year &&
            refDate.month == now.month &&
            refDate.day < now.day);

    final List<Map<String, dynamic>> chartData = [];
    int maxPages = 4; // Default min max

    // Generate last 7 days from refDate
    for (int i = 6; i >= 0; i--) {
      final d = refDate.subtract(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(d);
      final dayName = DateFormat('E').format(d); // Mon, Tue
      final count = state.weeklyProgress[dateStr] ?? 0;

      if (count > maxPages) maxPages = count;

      chartData.add({'day': dayName, 'count': count, 'date': dateStr});
    }

    final dateRangeStr =
        "${DateFormat('d MMM').format(startDate)} - ${DateFormat('d MMM yyyy').format(refDate)}";

    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2A30),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.white),
                onPressed: () {
                  context.read<ReadingBloc>().add(
                    const NavigateWeeklyChart(-1),
                  );
                },
              ),
              Column(
                children: [
                  Text(
                    AppLocalizations.of(context)!.chartWeeklyTitle,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    dateRangeStr,
                    style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  Icons.chevron_right,
                  color: canGoNext ? Colors.white : Colors.white24,
                ),
                onPressed: canGoNext
                    ? () {
                        context.read<ReadingBloc>().add(
                          const NavigateWeeklyChart(1),
                        );
                      }
                    : null,
              ),
            ],
          ),

          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: chartData.map((data) {
              final count = data['count'] as int;
              final day = data['day'] as String;
              final isToday =
                  data['date'] == DateFormat('yyyy-MM-dd').format(now);

              // Height calc
              final double heightRatio = maxPages > 0 ? (count / maxPages) : 0;
              final double barHeight = 100.h * heightRatio;

              final isTargetReached = count >= state.dailyTarget;

              return Column(
                children: [
                  Text(
                    "$count/${state.dailyTarget}",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Container(
                    width: 12.w,
                    height: barHeight > 0 ? barHeight : 4.h, // Min height
                    decoration: BoxDecoration(
                      color: isTargetReached
                          ? const Color(0xFF00E676)
                          : (count > 0
                                ? const Color(0xFF2196F3)
                                : Colors.white10),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    day,
                    style: TextStyle(
                      color: isToday ? const Color(0xFF00E676) : Colors.white54,
                      fontSize: 12.sp,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
          SizedBox(height: 16.h),
          Text(
            AppLocalizations.of(context)!.targetLabel(state.dailyTarget),
            style: TextStyle(color: Colors.white54, fontSize: 12.sp),
          ),
          SizedBox(height: 16.h),
          // LEGEND
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildLegendItem(
                color: const Color(0xFF00E676),
                label: AppLocalizations.of(context)!.chartLegendTargetReached,
              ),
              SizedBox(width: 16.w),
              _buildLegendItem(
                color: const Color(0xFF2196F3),
                label: AppLocalizations.of(context)!.chartLegendInProgress,
              ),
              SizedBox(width: 16.w),
              _buildLegendItem(
                color: Colors.white12,
                label: AppLocalizations.of(context)!.chartLegendNoActivity,
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
        SizedBox(width: 6.w),
        Text(
          label,
          style: TextStyle(color: Colors.white70, fontSize: 10.sp),
        ),
      ],
    );
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) {
      return "${seconds}s";
    }
    final minutes = (seconds / 60).floor();
    return "${minutes}m";
  }
}

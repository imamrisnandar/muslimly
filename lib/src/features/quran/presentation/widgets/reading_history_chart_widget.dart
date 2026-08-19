import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:muslimly/src/core/theme/app_colors.dart';
import '../bloc/reading/reading_bloc.dart';
import '../bloc/reading/reading_event.dart';

class ReadingHistoryChartWidget extends StatelessWidget {
  final Map<String, int> progress;
  final DateTime? chartRefDate;
  final int target;
  final bool isWeeklyView;
  final ReadingBloc readingBloc;

  const ReadingHistoryChartWidget({
    super.key,
    required this.progress,
    required this.chartRefDate,
    required this.target,
    required this.isWeeklyView,
    required this.readingBloc,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final refDate = chartRefDate ?? now;

    int daysToShow;
    DateTime startDate;
    DateTime endDate;

    if (isWeeklyView) {
      daysToShow = 7;
      endDate = refDate;
      startDate = refDate.subtract(Duration(days: daysToShow - 1));
    } else {
      startDate = DateTime(refDate.year, refDate.month, 1);
      endDate = DateTime(refDate.year, refDate.month + 1, 0);
      daysToShow = endDate.day;
    }

    final bool isCurrentPeriod = refDate.isAfter(
      DateTime.now().subtract(const Duration(days: 1)),
    );

    final List<String> labels = [];
    final List<int> values = [];
    final List<String> dateKeys = [];
    int maxVal = target > 0 ? target : 1;

    final String locale = Localizations.localeOf(context).languageCode;

    for (int i = 0; i < daysToShow; i++) {
      final d = startDate.add(Duration(days: i));
      final key = DateFormat('yyyy-MM-dd').format(d);
      final val = progress[key] ?? 0;

      dateKeys.add(key);

      if (isWeeklyView) {
        labels.add(DateFormat('E', locale).format(d)[0]);
      } else {
        if (d.day == 1 || d.day == 10 || d.day == 20 || d.day == endDate.day) {
          labels.add(DateFormat('d').format(d));
        } else {
          labels.add('');
        }
      }

      values.add(val);
      if (val > maxVal) maxVal = val;
    }

    if (maxVal == target) maxVal = (target * 1.5).ceil();

    final dateRange = isWeeklyView
        ? "${DateFormat('d MMM', locale).format(startDate)} - ${DateFormat('d MMM', locale).format(endDate)}"
        : DateFormat('MMMM yyyy', locale).format(refDate);

    final todayStr = DateFormat('yyyy-MM-dd').format(now);

    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accent.withValues(alpha: 0.15),
            Colors.white.withValues(alpha: 0.05),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
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
                      isWeeklyView ? "Weekly Progress" : "Monthly Progress",
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
                      readingBloc.add(const NavigateWeeklyChart(-1));
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  SizedBox(width: 8.w),
                  IconButton(
                    icon: Icon(
                      Icons.chevron_right,
                      color: isCurrentPeriod ? Colors.white24 : Colors.white,
                      size: 24.sp,
                    ),
                    onPressed: isCurrentPeriod
                        ? null
                        : () {
                            readingBloc.add(const NavigateWeeklyChart(1));
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
              final dateKey = dateKeys[index];

              final double maxH = 120.h;
              double valHeight = maxVal > 0 ? (val / maxVal) * maxH : 0;
              double targetHeight = maxVal > 0 ? (target / maxVal) * maxH : 0;

              if (valHeight > maxH) valHeight = maxH;
              if (targetHeight > maxH) targetHeight = maxH;
              if (valHeight < 0) valHeight = 0;

              final bool isAchieved = val >= target && target > 0;
              final bool isToday = dateKey == todayStr;

              final barWidth = isWeeklyView ? 24.w : 6.w;
              final fontSize = isWeeklyView ? 11.sp : 9.sp;

              return Column(
                children: [
                  if (val > 0) ...[
                    Text(
                      val.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    SizedBox(height: 4.h),
                  ],
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      if (isWeeklyView)
                        Container(
                          height: targetHeight,
                          width: barWidth,
                          alignment: Alignment.topCenter,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: Colors.white.withValues(alpha: 0.1),
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                      Container(
                        width: barWidth,
                        height: valHeight > 0 ? valHeight : 2.h,
                        decoration: BoxDecoration(
                          color: isAchieved
                              ? AppColors.accent
                              : (val > 0 ? AppColors.goldPale : Colors.white10),
                          borderRadius: BorderRadius.circular(4.r),
                          gradient: isAchieved
                              ? const LinearGradient(
                                  colors: [
                                    AppColors.accent,
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
                      color: isToday ? AppColors.accent : Colors.white54,
                      fontSize: fontSize,
                      fontWeight:
                          isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              );
            }),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(
                color: AppColors.accent,
                label: "Reached",
              ),
              SizedBox(width: 16.w),
              _buildLegendItem(
                color: AppColors.goldPale,
                label: "In Progress",
              ),
              SizedBox(width: 16.w),
              _buildLegendItem(
                color: Colors.white.withValues(alpha: 0.2),
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

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:muslimly/src/core/utils/surah_names.dart';
import 'package:muslimly/src/core/theme/app_colors.dart';
import '../../domain/entities/reading_activity.dart';

String formatReadingDuration(int seconds) {
  if (seconds < 60) return "${seconds}s";
  final minutes = (seconds / 60).floor();
  final remainingSeconds = seconds % 60;
  if (remainingSeconds == 0) return "${minutes}m";
  return "${minutes}m ${remainingSeconds}s";
}

class ReadingHistoryItemWidget extends StatelessWidget {
  final ReadingActivity activity;
  final bool isListMode;

  const ReadingHistoryItemWidget({
    super.key,
    required this.activity,
    required this.isListMode,
  });

  @override
  Widget build(BuildContext context) {
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
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(
            isListMode ? Icons.format_list_bulleted : Icons.menu_book,
            color: AppColors.accent,
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
                  formatReadingDuration(activity.durationSeconds),
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
                DateFormat("d MMM, HH:mm", locale).format(
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
}

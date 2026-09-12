import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../quran/presentation/widgets/hafalan_history_stats_widget.dart';

/// Structural duplicate of DashboardDailyGoalCardWidget (same visual
/// language: circular progress + count, "Completed" pill) but for hafalan's
/// streak instead of the daily reading target — see
/// HAFALAN_TRACKER_PLAN.md §E. Both tap targets go to
/// /quran/hafalan/progress (section B's page) instead of the reading card's
/// /quran/history and /quran/bookmarks. No "streak target" setting to edit
/// here (unlike the reading card's daily-target editor) — the target is
/// always the next streak milestone.
int _nextStreakMilestone(int streak) {
  for (final m in hafalanStreakMilestones) {
    if (streak < m) return m;
  }
  return streak == 0 ? hafalanStreakMilestones.first : streak;
}

class DashboardHafalanProgressCardWidget extends StatelessWidget {
  final int streak;

  const DashboardHafalanProgressCardWidget({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final target = _nextStreakMilestone(streak);
    final percentage = (target > 0) ? (streak / target).clamp(0.0, 1.0) : 0.0;
    final isCompleted = percentage >= 1.0;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Container(
      height: isLandscape ? null : 170.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF6E40).withValues(alpha: 0.18),
            const Color(0xFFFF6E40).withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6E40).withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: -5,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: GestureDetector(
        onTap: () => context.push('/quran/hafalan/progress'),
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                Icons.local_fire_department_rounded,
                size: isLandscape ? 80.sp : 140.sp,
                color: const Color(0xFFFF6E40).withValues(alpha: 0.12),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(isLandscape ? 8.w : 24.w),
              child: isLandscape
                  ? Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            Icons.local_fire_department_rounded,
                            color: const Color(0xFFFF6E40),
                            size: 16.sp,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          l10n.hafalanStreakCardTitle,
                          style: TextStyle(
                            color: const Color(0xFFFFC107),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "$streak",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          " ${l10n.hafalanStreakUnitLandscape(target)}",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFFFFC107,
                                ).withValues(alpha: 0.2),
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
                                  Colors.white.withValues(alpha: 0.1),
                                ),
                              ),
                              CircularProgressIndicator(
                                value: percentage,
                                strokeWidth: 4.w,
                                strokeCap: StrokeCap.round,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.gold,
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
                                      Icons.local_fire_department_rounded,
                                      color: const Color(0xFFFF6E40),
                                      size: 20.sp,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      'Streak Hafalan',
                                      style: TextStyle(
                                        color: const Color(0xFFFFC107),
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
                                        color: const Color(0xFFFFC107),
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                      ),
                                      child: Text(
                                        l10n.hafalanStreakCompletedBadge,
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
                                "$streak",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32.sp,
                                  fontWeight: FontWeight.bold,
                                  height: 1.0,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                l10n.hafalanStreakUnitPortrait(target),
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
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
                                      Colors.white.withValues(alpha: 0.1),
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
                                        ).withValues(alpha: 0.2),
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
                                          AppColors.gold,
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
                            SizedBox(height: 12.h),
                            Text(
                              l10n.hafalanLihatProgress,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white54,
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
    );
  }
}

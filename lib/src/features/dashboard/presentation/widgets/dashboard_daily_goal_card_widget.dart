import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../quran/presentation/pages/help_guide_page.dart';

class DashboardDailyGoalCardWidget extends StatelessWidget {
  final int progress;
  final int target;
  final String unitLabel;
  final AppLocalizations l10n;

  const DashboardDailyGoalCardWidget({
    super.key,
    required this.progress,
    required this.target,
    required this.unitLabel,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (target > 0) ? (progress / target).clamp(0.0, 1.0) : 0.0;
    final isCompleted = percentage >= 1.0;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Container(
      height: isLandscape ? null : 170.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: LinearGradient(
          colors: [
            AppColors.accentDark.withValues(alpha: 0.2), // Teal Accent as Base
            AppColors.accentDark.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          // Soft Teal Glow
          BoxShadow(
            color: AppColors.accentDark.withValues(alpha: 0.1),
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
        onTap: () => context.push('/quran/history'),
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            // Background Pattern
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                Icons.auto_stories,
                size: isLandscape ? 80.sp : 140.sp,
                color: const Color(
                  0xFFFFC107,
                ).withValues(alpha: 0.1), // Gold Icon Tint
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
                            color: const Color(
                              0xFF00E676,
                            ), // Green Icon for Goal
                            size: 16.sp,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        // Title
                        Text(
                          l10n.cardDailyGoal,
                          style: TextStyle(
                            color: const Color(
                              0xFFFFC107,
                            ), // Gold Title for Goal
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HelpGuidePage(),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(12.r),
                          child: Padding(
                            padding: EdgeInsets.all(2.w),
                            child: Icon(
                              Icons.info_outline_rounded,
                              color: Colors.white70,
                              size: 14.sp,
                            ),
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
                        Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFFFFC107,
                                ).withValues(alpha: 0.2), // Gold Glow
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
                                  AppColors.gold, // Gold Progress
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
                                      color: const Color(
                                        0xFF00E676,
                                      ), // Green Icon for Goal
                                      size: 20.sp,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      l10n.cardDailyGoal,
                                      style: TextStyle(
                                        color: const Color(
                                          0xFFFFC107,
                                        ), // Gold Title for Goal
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const HelpGuidePage(),
                                        ),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(12.r),
                                    child: Padding(
                                      padding: EdgeInsets.all(4.w),
                                      child: Icon(
                                        Icons.info_outline_rounded,
                                        color: Colors.white70,
                                        size: 16.sp,
                                      ),
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
                                        color: const Color(
                                          0xFFFFC107,
                                        ), // Gold Completed Badge
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
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
                              SizedBox(height: 12.h),
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
                                        ).withValues(alpha: 0.2), // Gold Glow
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
                                          AppColors.gold, // Gold Progress
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
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/models/reminder_models.dart';
import '../../domain/services/reminder_service.dart';
import '../../../../core/theme/app_colors.dart';

class DzikirReminderSection extends StatelessWidget {
  final DzikirReminder morningDzikir;
  final DzikirReminder eveningDzikir;
  final VoidCallback? onTap;
  final void Function(DzikirReminder)? onDzikirTap;

  const DzikirReminderSection({
    super.key,
    required this.morningDzikir,
    required this.eveningDzikir,
    this.onTap,
    this.onDzikirTap,
  });

  @override
  Widget build(BuildContext context) {
    // Only show if any dzikir is active
    final hasActiveDzikir =
        morningDzikir.isActiveNow || eveningDzikir.isActiveNow;

    if (!hasActiveDzikir) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.menu_book_rounded,
              color: AppColors.gold,
              size: 14.sp,
            ),
            SizedBox(width: 6.w),
            Text(
              'DZIKIR',
              style: TextStyle(
                color: AppColors.gold,
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        if (morningDzikir.isActiveNow) _buildDzikirItem(morningDzikir),
        if (morningDzikir.isActiveNow && eveningDzikir.isActiveNow)
          SizedBox(height: 6.h),
        if (eveningDzikir.isActiveNow) _buildDzikirItem(eveningDzikir),
      ],
    );
  }

  Widget _buildDzikirItem(DzikirReminder dzikir) {
    return InkWell(
      onTap: onDzikirTap != null ? () => onDzikirTap!(dzikir) : onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.gold.withValues(alpha: 0.2),
              AppColors.gold.withValues(alpha: 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: AppColors.gold.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Animated icon
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.gold.withValues(alpha: 0.4),
                    AppColors.gold.withValues(alpha: 0.2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Icon(
                dzikir.icon,
                color: AppColors.gold,
                size: 14.sp,
              ),
            ),
            SizedBox(width: 8.w),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Waktunya Dzikir ${dzikir.displayName}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    ReminderService.formatTime(dzikir.scheduledTime),
                    style: TextStyle(
                      color: AppColors.gold.withValues(alpha: 0.8),
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
            ),
            // Arrow icon
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.gold.withValues(alpha: 0.6),
              size: 12.sp,
            ),
          ],
        ),
      ),
    );
  }
}

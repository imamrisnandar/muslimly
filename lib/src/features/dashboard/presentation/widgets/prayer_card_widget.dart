import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

class PrayerCardWidget extends StatelessWidget {
  final String name;
  final String arabicName;
  final String time;
  final bool isCurrent;
  final bool isNext;
  final VoidCallback onTap;
  final IconData icon;
  final String? notificationStatus;
  final VoidCallback? onNotificationTap;

  const PrayerCardWidget({
    super.key,
    required this.name,
    required this.arabicName,
    required this.time,
    this.isCurrent = false,
    this.isNext = false,
    required this.onTap,
    required this.icon,
    this.notificationStatus,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isNext) {
      return _buildHighlightedCard(context);
    }
    return _buildStandardRow(context);
  }

  Widget _buildHighlightedCard(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.h), // Reduced from 6.h
      decoration: BoxDecoration(
        color: AppColors.cardDark.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20.r),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 10.w,
              vertical: 8.h,
            ), // Reduced vertical from 10.h
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.accent,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 8.w),
                // Prayer Name (single line, no Arabic)
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                // Notification Icon
                if (notificationStatus != null) ...[
                  SizedBox(width: 6.w),
                  InkWell(
                    onTap: onNotificationTap,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: EdgeInsets.all(4.w),
                      child: Icon(
                        _getNotificationIcon(notificationStatus!),
                        color: Colors.white70,
                        size: 18.sp,
                      ),
                    ),
                  ),
                ],
                SizedBox(width: 6.w),
                // Time (fully visible)
                Text(
                  time,
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStandardRow(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 8.h,
          horizontal: 8.w,
        ), // Reduced vertical from 16.h
        child: Row(
          children: [
            Icon(
              icon,
              color: isCurrent ? Colors.white : Colors.white38,
              size: 20.sp,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  color: isCurrent ? Colors.white : Colors.white70,
                  fontSize: 16.sp,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
            if (notificationStatus != null)
              IconButton(
                onPressed: onNotificationTap,
                icon: Icon(
                  _getNotificationIcon(notificationStatus!),
                  color: isCurrent ? Colors.white : Colors.white54,
                  size: 20.sp,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                visualDensity: VisualDensity.compact,
              ),
            SizedBox(width: 8.w),
            Text(
              time,
              style: TextStyle(
                color: isCurrent ? Colors.white : Colors.white70,
                fontSize: 16.sp,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String status) {
    switch (status) {
      case 'adhan':
        return Icons.notifications_active;
      case 'beep':
        return Icons.notifications_none;
      case 'silent':
        return Icons.notifications_off_outlined;
      case 'off':
        return Icons.notifications_off;
      default:
        return Icons.notifications_none;
    }
  }
}

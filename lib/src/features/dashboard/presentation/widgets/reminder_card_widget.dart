import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/models/reminder_models.dart';
import 'dzikir_reminder_section.dart';
import 'fasting_reminder_section.dart';

class ReminderCardWidget extends StatelessWidget {
  final ReminderCardData data;
  final VoidCallback? onDzikirTap;

  const ReminderCardWidget({super.key, required this.data, this.onDzikirTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = l10n.localeName;

    // Hide card completely if no fasting and no active dzikir
    final hasFasting = data.todayFasting != null || data.nextFasting != null;
    final hasActiveDzikir = data.hasAnyActiveDzikir;

    if (!hasFasting && !hasActiveDzikir) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A44), Color(0xFF152A33)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header - only if has content
          Row(
            children: [
              Icon(
                Icons.notifications_active_outlined,
                color: const Color(0xFF00E676),
                size: 16.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Pengingat',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (hasActiveDzikir) ...[
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC107).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4.r),
                    border: Border.all(
                      color: const Color(0xFFFFC107).withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 4.w,
                        height: 4.h,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFC107),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Aktif',
                        style: TextStyle(
                          color: const Color(0xFFFFC107),
                          fontSize: 9.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 10.h),

          // Fasting Section
          if (hasFasting) ...[
            FastingReminderSection(
              todayFasting: data.todayFasting,
              nextFasting: data.nextFasting,
              locale: locale,
            ),
            if (hasActiveDzikir) SizedBox(height: 10.h),
          ],

          // Dzikir Section (only if active)
          if (hasActiveDzikir)
            DzikirReminderSection(
              morningDzikir: data.morningDzikir,
              eveningDzikir: data.eveningDzikir,
              onTap: onDzikirTap,
            ),
        ],
      ),
    );
  }
}

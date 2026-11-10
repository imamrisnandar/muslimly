import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/prayer_slot.dart';
import '../bloc/prayer_tracker_cubit.dart';
import '../bloc/prayer_tracker_state.dart';

/// Compact dashboard card: how many of today's five prayers are recorded as
/// prayed, plus the streak. Taps through to the tracker page.
class DashboardPrayerTrackerCard extends StatelessWidget {
  const DashboardPrayerTrackerCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<PrayerTrackerCubit, PrayerTrackerState>(
      builder: (context, state) {
        if (state.status != PrayerTrackerStatus.ready) {
          return const SizedBox.shrink();
        }
        final done = state.todaySlots
            .where((v) => v.status == SlotStatus.performed)
            .length;
        final streak = state.stats?.streakDays ?? 0;
        return Padding(
          padding: EdgeInsets.only(top: 12.h),
          child: GestureDetector(
            onTap: () async {
              await context.push('/prayer-tracker');
              if (context.mounted) {
                context.read<PrayerTrackerCubit>().refresh();
              }
            },
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.mosque_rounded,
                    color: AppColors.gold,
                    size: 28.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.trackerTitle,
                          style: TextStyle(
                            color: AppColors.gold,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          streak > 0
                              ? l10n.trackerStreak(streak)
                              : l10n.trackerStreakNone,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '$done/5',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

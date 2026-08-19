import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:muslimly/src/core/theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// Generates a reading insight card data map based on current stats.
/// Returns null if no relevant insight exists.
Map<String, dynamic>? generateReadingInsight({
  required Map<String, int> weeklyProgress,
  required int target,
  required int currentStreak,
  required int lifetimeTotal,
}) {
  final now = DateTime.now();
  final int daysUntilSunday = DateTime.sunday - now.weekday;
  final DateTime endOfWeek = now.add(Duration(days: daysUntilSunday));

  int weeklyTotal = 0;
  int weeklyTarget = target * 7;
  int daysWithProgress = 0;
  int maxDailyValue = 0;

  for (int i = 6; i >= 0; i--) {
    final d = endOfWeek.subtract(Duration(days: i));
    final key = DateFormat('yyyy-MM-dd').format(d);
    final val = weeklyProgress[key] ?? 0;
    weeklyTotal += val;
    if (val > 0) daysWithProgress++;
    if (val > maxDailyValue) maxDailyValue = val;
  }

  final todayKey = DateFormat('yyyy-MM-dd').format(now);
  final todayProgress = weeklyProgress[todayKey] ?? 0;
  final percentage =
      weeklyTarget > 0 ? (weeklyTotal / weeklyTarget * 100) : 0;

  if (currentStreak >= 3 && todayProgress == 0) {
    return {
      'type': 'warning',
      'icon': '⚠️',
      'message': 'insightStreakWarning',
      'color': AppColors.goldPale,
      'params': {'streak': currentStreak.toString()},
    };
  }

  if (percentage >= 120) {
    return {
      'type': 'success',
      'icon': '🎉',
      'message': 'insightAheadTarget',
      'color': AppColors.accent,
      'params': {'percent': (percentage - 100).toStringAsFixed(0)},
    };
  }

  if (percentage < 80 && daysWithProgress < 7) {
    final remaining = weeklyTarget - weeklyTotal;
    final dayOfWeek = now.weekday;
    final daysLeft = 8 - dayOfWeek;
    final needed = daysLeft > 0 ? (remaining / daysLeft).ceil() : remaining;
    return {
      'type': 'warning',
      'icon': '💪',
      'message': 'insightBehindTarget',
      'color': AppColors.goldPale,
      'params': {
        'remaining': remaining.toString(),
        'needed': needed.toString(),
      },
    };
  }

  if (currentStreak == 5 ||
      currentStreak == 7 ||
      currentStreak == 14 ||
      currentStreak == 30) {
    return {
      'type': 'milestone',
      'icon': '🔥',
      'message': 'insightStreakMilestone',
      'color': const Color(0xFFFF6E40),
      'params': {'streak': currentStreak.toString()},
    };
  }

  if (daysWithProgress == 7 && weeklyTotal >= weeklyTarget) {
    return {
      'type': 'success',
      'icon': '👏',
      'message': 'insightPerfectWeek',
      'color': AppColors.accent,
      'params': {},
    };
  }

  if (maxDailyValue >= target * 2 && maxDailyValue > 0) {
    return {
      'type': 'milestone',
      'icon': '⭐',
      'message': 'insightDailyRecord',
      'color': const Color(0xFFFFD700),
      'params': {'max': maxDailyValue.toString()},
    };
  }

  if (lifetimeTotal == 100 ||
      lifetimeTotal == 500 ||
      lifetimeTotal == 1000) {
    return {
      'type': 'milestone',
      'icon': '🌟',
      'message': 'insightLifetimeMilestone',
      'color': AppColors.accent,
      'params': {'total': lifetimeTotal.toString()},
    };
  }

  return null;
}

class ReadingHistoryStatsWidget extends StatelessWidget {
  final int total;
  final int streak;
  final double average;
  final bool isListMode;
  final Map<String, int> weeklyProgress;
  final int target;
  final int currentStreak;
  final int lifetimeTotal;

  const ReadingHistoryStatsWidget({
    super.key,
    required this.total,
    required this.streak,
    required this.average,
    required this.isListMode,
    required this.weeklyProgress,
    required this.target,
    required this.currentStreak,
    required this.lifetimeTotal,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final unitLabel = isListMode ? l10n.lblAyahs : l10n.lblPages;

    return Column(
      children: [
        // ── Lifetime stats row ──
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: isListMode
                    ? Icons.format_list_bulleted
                    : Icons.menu_book,
                iconColor: AppColors.accent,
                label: l10n.lblLifetimeTotal,
                value: total.toString(),
                unit: unitLabel,
                gradientColor: AppColors.accent,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _StatCard(
                emoji: '🔥',
                label: l10n.lblReadingStreak,
                value: streak.toString(),
                unit: l10n.lblDays,
                gradientColor: AppColors.goldPale,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _StatCard(
                icon: Icons.trending_up,
                iconColor: const Color(0xFF64B5F6),
                label: l10n.lblDailyAverage,
                value: average.toStringAsFixed(1),
                unit: unitLabel,
                gradientColor: const Color(0xFF64B5F6),
              ),
            ),
          ],
        ),
        // ── Insight card ──
        _buildInsightCard(context, l10n, unitLabel),
      ],
    );
  }

  Widget _buildInsightCard(
    BuildContext context,
    AppLocalizations l10n,
    String unitLabel,
  ) {
    final insight = generateReadingInsight(
      weeklyProgress: weeklyProgress,
      target: target,
      currentStreak: currentStreak,
      lifetimeTotal: lifetimeTotal,
    );

    if (insight == null) return const SizedBox.shrink();

    String message = '';
    switch (insight['message']) {
      case 'insightStreakWarning':
        message = l10n.insightStreakWarning(
          insight['params']['streak'],
          unitLabel,
        );
        break;
      case 'insightAheadTarget':
        message = l10n.insightAheadTarget(insight['params']['percent']);
        break;
      case 'insightBehindTarget':
        message = l10n.insightBehindTarget(
          insight['params']['needed'],
          insight['params']['remaining'],
          unitLabel,
        );
        break;
      case 'insightStreakMilestone':
        message =
            l10n.insightStreakMilestone(insight['params']['streak']);
        break;
      case 'insightPerfectWeek':
        message = l10n.insightPerfectWeek;
        break;
      case 'insightDailyRecord':
        message = l10n.insightDailyRecord(
          insight['params']['max'],
          unitLabel,
        );
        break;
      case 'insightLifetimeMilestone':
        message = l10n.insightLifetimeMilestone(
          insight['params']['total'],
          unitLabel,
        );
        break;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            (insight['color'] as Color).withValues(alpha: 0.2),
            Colors.white.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: (insight['color'] as Color).withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Text(
            insight['icon'] as String,
            style: TextStyle(fontSize: 24.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Outfit',
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  l10n.insightTargetInfo(
                    target.toString(),
                    unitLabel,
                    (target * 7).toString(),
                  ),
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 10.sp,
                    fontFamily: 'Outfit',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Private helper widget — stat card
// ────────────────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData? icon;
  final Color? iconColor;
  final String? emoji;
  final String label;
  final String value;
  final String unit;
  final Color gradientColor;

  const _StatCard({
    this.icon,
    this.iconColor,
    this.emoji,
    required this.label,
    required this.value,
    required this.unit,
    required this.gradientColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            gradientColor.withValues(alpha: 0.15),
            Colors.white.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (emoji != null)
                Text(emoji!, style: TextStyle(fontSize: 20.sp))
              else if (icon != null)
                Icon(icon!, color: iconColor, size: 20.sp),
              SizedBox(width: 6.w),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11.sp,
                    fontFamily: 'Outfit',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              fontFamily: 'Outfit',
            ),
          ),
          Text(
            unit,
            style: TextStyle(
              color: Colors.white54,
              fontSize: 11.sp,
              fontFamily: 'Outfit',
            ),
          ),
        ],
      ),
    );
  }
}

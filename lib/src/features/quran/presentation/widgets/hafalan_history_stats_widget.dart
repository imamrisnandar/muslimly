import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/di/di_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../settings/domain/repositories/settings_repository.dart';

/// Streak-day thresholds that trigger a milestone insight — the same
/// numbers generateReadingInsight uses for its streak milestones (5/7/14/30,
/// see reading_history_stats_widget.dart), extended with 60/100 for
/// hafalan's longer-horizon habit.
const List<int> hafalanStreakMilestones = [5, 7, 14, 30, 60, 100];

/// Total-ayat-memorized thresholds.
const List<int> hafalanAyatMilestones = [10, 50, 100, 250, 500, 1000];

/// Generates a hafalan insight banner's data, or null if none applies.
///
/// Unlike generateReadingInsight's exact-equality thresholds (`currentStreak
/// == 5/7/14/30` — a real bug, see HAFALAN_TRACKER_PLAN.md §E: a user who
/// skips the exact day a threshold is hit, e.g. two sessions logged on the
/// same day jumping past 7 straight to 8, never sees the banner), this
/// picks the highest threshold that's been reached AND not yet shown
/// ([lastShownStreakMilestone]/[lastShownAyatMilestone] track that
/// separately per HAFALAN_TRACKER_PLAN.md §E — purely local UI dedup, see
/// SettingsRepository.getLastShownHafalanStreakMilestone).
///
/// Framing intentionally avoids "point"/score language (Riset #2 point 3 —
/// gamifying ibadah risks feeling like the app is "counting pahala"):
/// consistency ("N hari berturut-turut") and memorization progress ("N ayat
/// sudah hafal"), never a score.
///
/// `'message'` is deliberately NOT a pre-formatted string: this is a pure
/// function with no BuildContext, so it can't call AppLocalizations itself.
/// It returns `'type'` ('streak'/'ayat') + `'milestone'` (the threshold
/// int) instead, and the rendering widget (HafalanInsightSection.build,
/// which does have context) resolves the actual localized message from
/// those two fields.
Map<String, dynamic>? generateHafalanInsight({
  required int streak,
  required int totalAyatHafal,
  required int lastShownStreakMilestone,
  required int lastShownAyatMilestone,
}) {
  final streakMilestone = _highestNewMilestone(
    hafalanStreakMilestones,
    streak,
    lastShownStreakMilestone,
  );
  if (streakMilestone != null) {
    return {
      'type': 'streak',
      'icon': '🔥',
      'milestone': streakMilestone,
      'color': const Color(0xFFFF6E40),
    };
  }

  final ayatMilestone = _highestNewMilestone(
    hafalanAyatMilestones,
    totalAyatHafal,
    lastShownAyatMilestone,
  );
  if (ayatMilestone != null) {
    return {
      'type': 'ayat',
      'icon': '📖',
      'milestone': ayatMilestone,
      'color': AppColors.accent,
    };
  }

  return null;
}

int? _highestNewMilestone(List<int> thresholds, int value, int lastShown) {
  int? best;
  for (final m in thresholds) {
    if (value >= m && m > lastShown && (best == null || m > best)) {
      best = m;
    }
  }
  return best;
}

/// Fetches the "already shown" milestone watermarks, computes the current
/// insight, renders it if any, and marks it shown so it never repeats.
/// A no-op (renders nothing) once [streak]/[totalAyatHafal] don't clear any
/// new threshold.
class HafalanInsightSection extends StatefulWidget {
  final int streak;
  final int totalAyatHafal;

  const HafalanInsightSection({
    super.key,
    required this.streak,
    required this.totalAyatHafal,
  });

  @override
  State<HafalanInsightSection> createState() => _HafalanInsightSectionState();
}

class _HafalanInsightSectionState extends State<HafalanInsightSection> {
  Map<String, dynamic>? _insight;

  @override
  void initState() {
    super.initState();
    _computeInsight();
  }

  @override
  void didUpdateWidget(HafalanInsightSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.streak != widget.streak ||
        oldWidget.totalAyatHafal != widget.totalAyatHafal) {
      _computeInsight();
    }
  }

  Future<void> _computeInsight() async {
    final settings = getIt<SettingsRepository>();
    final lastStreak = await settings.getLastShownHafalanStreakMilestone();
    final lastAyat = await settings.getLastShownHafalanAyatMilestone();

    final insight = generateHafalanInsight(
      streak: widget.streak,
      totalAyatHafal: widget.totalAyatHafal,
      lastShownStreakMilestone: lastStreak,
      lastShownAyatMilestone: lastAyat,
    );

    if (!mounted) return;
    setState(() => _insight = insight);

    if (insight == null) return;
    // Mark shown immediately — best-effort, a failed write just means the
    // same banner might show once more next load, not a functional break.
    try {
      if (insight['type'] == 'streak') {
        await settings.saveLastShownHafalanStreakMilestone(
          insight['milestone'] as int,
        );
      } else {
        await settings.saveLastShownHafalanAyatMilestone(
          insight['milestone'] as int,
        );
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final insight = _insight;
    if (insight == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final milestone = insight['milestone'] as int;
    final message = insight['type'] == 'streak'
        ? l10n.hafalanInsightStreakMessage(milestone)
        : l10n.hafalanInsightAyatMessage(milestone);
    final color = insight['color'] as Color;
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          border: Border.all(color: color.withValues(alpha: 0.35)),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            Text(insight['icon'] as String, style: TextStyle(fontSize: 22.sp)),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

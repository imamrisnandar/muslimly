import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/utils/hafalan_progress_calculator.dart';
import 'hafalan_audio_controls_widget.dart';

class HafalanSurahProgressTileWidget extends StatelessWidget {
  final String surahName;
  final int ayahCount;
  final SurahProgress progress;

  const HafalanSurahProgressTileWidget({
    super.key,
    required this.surahName,
    required this.ayahCount,
    required this.progress,
  });

  ({Color bg, Color border, Color text, String label}) _badgeStyle(
    AppLocalizations l10n,
  ) {
    switch (progress.status) {
      case SurahHafalanStatus.sudah:
        return (
          bg: AppColors.accent.withValues(alpha: 0.16),
          border: AppColors.accent.withValues(alpha: 0.4),
          text: AppColors.accent,
          label: l10n.hafalanStatusSudahHafal,
        );
      case SurahHafalanStatus.sedang:
        return (
          bg: AppColors.gold.withValues(alpha: 0.16),
          border: AppColors.gold.withValues(alpha: 0.4),
          text: AppColors.goldLight,
          label: l10n.hafalanStatusSedangDihafal,
        );
      case SurahHafalanStatus.belum:
        return (
          bg: Colors.white.withValues(alpha: 0.08),
          border: Colors.white.withValues(alpha: 0.18),
          text: Colors.white.withValues(alpha: 0.7),
          label: l10n.hafalanStatusBelum,
        );
    }
  }

  String _subtitle(AppLocalizations l10n) {
    final ts = progress.lastSessionTimestamp;
    if (ts == null) return l10n.hafalanSubtitleAyatOnly(ayahCount);
    return l10n.hafalanSubtitleAyatWithDate(ayahCount, _relativeDate(l10n, ts));
  }

  String _relativeDate(AppLocalizations l10n, int timestampMs) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestampMs);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sessionDay = DateTime(date.year, date.month, date.day);
    final diffDays = today.difference(sessionDay).inDays;

    if (diffDays == 0) return l10n.hafalanDateToday;
    if (diffDays == 1) return l10n.hafalanDateYesterday;
    if (diffDays < 7) return l10n.hafalanDateDaysAgo(diffDays);
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final badge = _badgeStyle(l10n);
    final audioPath = progress.latestAudioFilePath;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      surahName,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      _subtitle(l10n),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.white.withValues(alpha: 0.54),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: badge.bg,
                  border: Border.all(color: badge.border),
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Text(
                  badge.label,
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w600,
                    color: badge.text,
                  ),
                ),
              ),
            ],
          ),
          if (audioPath != null && progress.latestAudioSessionId != null) ...[
            SizedBox(height: 4.h),
            HafalanAudioControls(
              sessionId: progress.latestAudioSessionId!,
              audioFilePath: audioPath,
              isSaved: progress.latestAudioIsSaved,
            ),
          ],
        ],
      ),
    );
  }
}

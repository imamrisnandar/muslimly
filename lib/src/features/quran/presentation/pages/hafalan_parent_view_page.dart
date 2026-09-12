import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/di_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/quran_constants.dart';
import '../../../../core/utils/surah_names.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/utils/hafalan_progress_calculator.dart';
import '../bloc/hafalan_progress/hafalan_progress_cubit.dart';
import '../bloc/hafalan_progress/hafalan_progress_state.dart';
import '../widgets/hafalan_surah_progress_tile_widget.dart';

/// Read-only "Tampilan Orang Tua" — a parent/guardian glancing at a child's
/// hafalan progress. Reuses section B's per-surah list + last-session date
/// and C's streak, nothing new to compute (HAFALAN_TRACKER_PLAN.md §E).
///
/// Deliberately NOT a new auth/profile system: the app already treats
/// "whoever is holding this device" as one identity (user_id/device_id),
/// so this is just another page, not access control.
///
/// Framing: per-session accuracy is never shown here — only sudah/sedang
/// status and dates, so a parent reading this never sees anything that
/// reads as a "nilai rapor" (report-card score) rather than progress
/// (Riset #2 point 4).
class HafalanParentViewPage extends StatelessWidget {
  const HafalanParentViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HafalanProgressCubit>()..load(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.bgGradient),
          child: SafeArea(
            child: Column(
              children: [
                _AppBar(),
                Expanded(
                  child:
                      BlocBuilder<HafalanProgressCubit, HafalanProgressState>(
                        builder: (context, state) {
                          if (state.isLoading && state.surahProgress.isEmpty) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.gold,
                              ),
                            );
                          }
                          return _ParentViewContent(state: state);
                        },
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 4.h, 20.w, 6.h),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          Text(
            AppLocalizations.of(context)!.hafalanParentViewTitle,
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _ParentViewContent extends StatelessWidget {
  final HafalanProgressState state;

  const _ParentViewContent({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final attempted = state.surahProgress
        .where((p) => p.status != SurahHafalanStatus.belum)
        .toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 0),
            child: Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.local_fire_department_rounded,
                    iconColor: const Color(0xFFFF6E40),
                    value: '${state.streak}',
                    label: l10n.hafalanStreakDaysLabel,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _StatCard(
                    icon: Icons.menu_book_rounded,
                    iconColor: AppColors.accent,
                    value: '${state.totalAyatHafal}',
                    label: l10n.hafalanAyatSudahHafalLabel,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 8.h),
            child: Text(
              attempted.isEmpty
                  ? l10n.hafalanNoSurahAttempted
                  : l10n.hafalanSectionAttemptedSurahs,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
          sliver: SliverList.separated(
            itemCount: attempted.length,
            separatorBuilder: (_, __) => SizedBox(height: 8.h),
            itemBuilder: (context, index) {
              final progress = attempted[index];
              final surahNumber = progress.surahNumber;
              return HafalanSurahProgressTileWidget(
                surahName: SurahNames.englishNames[surahNumber - 1],
                ayahCount: QuranConstants.surahAyahCounts[surahNumber] ?? 0,
                progress: progress,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.25)),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 22.sp),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

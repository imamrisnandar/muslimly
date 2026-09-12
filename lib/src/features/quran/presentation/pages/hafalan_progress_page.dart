import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/di_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/quran_constants.dart';
import '../../../../core/utils/surah_names.dart';
import '../../domain/utils/hafalan_progress_calculator.dart';
import '../../domain/utils/muraja_ah_scheduler.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../bloc/hafalan_progress/hafalan_progress_cubit.dart';
import '../bloc/hafalan_progress/hafalan_progress_state.dart';
import '../widgets/hafalan_history_stats_widget.dart';
import '../widgets/hafalan_surah_progress_tile_widget.dart';

class HafalanProgressPage extends StatelessWidget {
  const HafalanProgressPage({super.key});

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
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Text(
                    AppLocalizations.of(context)!.hafalanProgressSubtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ),
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
                          if (state.errorMessage != null) {
                            return Center(
                              child: Text(
                                state.errorMessage!,
                                style: const TextStyle(color: Colors.white70),
                              ),
                            );
                          }
                          return _ProgressContent(state: state);
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
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.hafalanProgressPageTitle,
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.family_restroom_rounded, color: Colors.white),
            tooltip: AppLocalizations.of(context)!.hafalanParentViewTitle,
            onPressed: () => context.push('/quran/hafalan/parent-view'),
          ),
        ],
      ),
    );
  }
}

class _ProgressContent extends StatelessWidget {
  final HafalanProgressState state;

  const _ProgressContent({required this.state});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
            child: Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.25),
                ),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  Text(
                    '${state.totalAyatHafal}',
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    AppLocalizations.of(context)!.hafalanAyatSudahHafalLabel,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: HafalanInsightSection(
            streak: state.streak,
            totalAyatHafal: state.totalAyatHafal,
          ),
        ),
        if (state.dueMurajaah.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 8.h),
              child: Text(
                AppLocalizations.of(context)!.hafalanSectionPerluDiulang,
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
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            sliver: SliverList.separated(
              itemCount: state.dueMurajaah.length,
              separatorBuilder: (_, __) => SizedBox(height: 8.h),
              itemBuilder: (context, index) {
                final unit = state.dueMurajaah[index];
                return _MurajaahDueTile(unit: unit);
              },
            ),
          ),
        ],
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 8.h),
            child: Text(
              AppLocalizations.of(context)!.hafalanSectionPerJuz,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 64.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              itemCount: state.juzProgress.length,
              separatorBuilder: (_, __) => SizedBox(width: 10.w),
              itemBuilder: (context, index) {
                final juz = state.juzProgress[index];
                return _JuzChip(juz: juz);
              },
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 8.h),
            child: Text(
              AppLocalizations.of(context)!.hafalanSectionPerSurah,
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
            itemCount: state.surahProgress.length,
            separatorBuilder: (_, __) => SizedBox(height: 8.h),
            itemBuilder: (context, index) {
              final progress = state.surahProgress[index];
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

class _JuzChip extends StatelessWidget {
  final JuzProgress juz;

  const _JuzChip({required this.juz});

  @override
  Widget build(BuildContext context) {
    final percent = (juz.percentage * 100).round();
    return Container(
      width: 78.w,
      padding: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(
              context,
            )!.hafalanJuzLabel(juz.juzNumber),
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 6.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99.r),
              child: LinearProgressIndicator(
                value: juz.percentage,
                minHeight: 5.h,
                backgroundColor: Colors.white.withValues(alpha: 0.12),
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
              ),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '$percent%',
            style: TextStyle(
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _MurajaahDueTile extends StatelessWidget {
  final MurajaahUnit unit;

  const _MurajaahDueTile({required this.unit});

  @override
  Widget build(BuildContext context) {
    final surahName = SurahNames.englishNames[unit.surahNumber - 1];
    return InkWell(
      borderRadius: BorderRadius.circular(14.r),
      onTap: () => context.push(
        '/quran/hafalan/${unit.surahNumber}',
        extra: {'initialPage': unit.pageNumber},
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.gold.withValues(alpha: 0.08),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.25)),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.hafalanMurajaahTileTitle(
                      surahName,
                      unit.pageNumber,
                    ),
                    style: TextStyle(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    AppLocalizations.of(context)!.hafalanMurajaahTileSubtitle,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.goldLight,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}

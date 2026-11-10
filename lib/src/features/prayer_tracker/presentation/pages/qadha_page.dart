import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/di_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/prayer_log.dart';
import '../bloc/qadha_cubit.dart';
import 'prayer_tracker_page.dart' show prayerLabel;

/// Tampilkan wizard estimasi qadha? Disembunyikan hingga tinjauan ustadz.
const bool _showQadhaWizard = false;

class QadhaPage extends StatelessWidget {
  const QadhaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<QadhaCubit>()..load(),
      child: const _QadhaView(),
    );
  }
}

class _QadhaView extends StatelessWidget {
  const _QadhaView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                  Text(
                    l10n.qadhaTitle,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: BlocBuilder<QadhaCubit, QadhaState>(
                  builder: (context, s) {
                    if (!s.loaded) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.gold),
                      );
                    }
                    return _Body(state: s);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final QadhaState state;
  const _Body({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<QadhaCubit>();
    final white = TextStyle(color: Colors.white, fontSize: 14.sp);
    final muted = TextStyle(color: Colors.white60, fontSize: 12.sp);

    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
      children: [
        Text(
          state.total == 0
              ? l10n.trackerQadhaNone
              : l10n.trackerQadhaTotal(state.total),
          style: TextStyle(
            color: AppColors.gold,
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12.h),
        for (final p in TrackedPrayer.values)
          Container(
            margin: EdgeInsets.only(bottom: 8.h),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                Expanded(child: Text(prayerLabel(l10n, p), style: white)),
                Text(
                  '${state.balance[p] ?? 0}',
                  style: white.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  tooltip: l10n.qadhaUndo,
                  icon: const Icon(Icons.undo, color: Colors.white54),
                  onPressed: (state.done[p] ?? 0) > 0
                      ? () => cubit.undo(p)
                      : null,
                ),
                FilledButton(
                  onPressed: (state.balance[p] ?? 0) > 0
                      ? () => cubit.makeUp(p)
                      : null,
                  child: Text(l10n.qadhaMakeUp),
                ),
              ],
            ),
          ),
        SizedBox(height: 12.h),
        Text(
          l10n.qadhaPaceTitle,
          style: white.copyWith(fontWeight: FontWeight.w600),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.remove_circle_outline,
                color: Colors.white,
              ),
              onPressed: state.pace > 0
                  ? () => cubit.setPace(state.pace - 1)
                  : null,
            ),
            Text(
              state.pace == 0
                  ? l10n.qadhaPaceNone
                  : l10n.qadhaPacePerDay(state.pace),
              style: white,
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.white),
              onPressed: () => cubit.setPace(state.pace + 1),
            ),
          ],
        ),
        if (state.finishDate != null)
          Text(
            l10n.qadhaFinishEstimate(
              DateFormat.yMMMMd(
                Localizations.localeOf(context).toString(),
              ).format(state.finishDate!),
            ),
            style: muted,
          ),
        // Wizard disembunyikan sampai ditinjau ustadz (rumus estimasi, sakit).
        if (_showQadhaWizard) ...[
          SizedBox(height: 16.h),
          OutlinedButton.icon(
            icon: const Icon(Icons.calculate_outlined),
            label: Text(l10n.qadhaWizardButton),
            onPressed: () async {
              await context.push('/qadha/wizard');
              if (context.mounted) cubit.load();
            },
          ),
        ],
        SizedBox(height: 12.h),
        Text(l10n.qadhaReminderNote, style: muted),
        Text(l10n.qadhaFiqhNote, style: muted),
        Text(l10n.trackerLocalNote, style: muted),
      ],
    );
  }
}

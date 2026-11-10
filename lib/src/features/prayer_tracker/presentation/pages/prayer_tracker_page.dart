import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/di_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/excused_period.dart';
import '../../domain/entities/prayer_log.dart';
import '../../domain/entities/prayer_slot.dart';
import '../bloc/prayer_tracker_cubit.dart';
import '../bloc/prayer_tracker_state.dart';

String prayerLabel(AppLocalizations l, TrackedPrayer p) {
  switch (p) {
    case TrackedPrayer.fajr:
      return l.prayerFajr;
    case TrackedPrayer.dhuhr:
      return l.prayerDhuhr;
    case TrackedPrayer.asr:
      return l.prayerAsr;
    case TrackedPrayer.maghrib:
      return l.prayerMaghrib;
    case TrackedPrayer.isha:
      return l.prayerIsha;
  }
}

class PrayerTrackerPage extends StatelessWidget {
  const PrayerTrackerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PrayerTrackerCubit>()..loadLastKnown(),
      child: const _PrayerTrackerView(),
    );
  }
}

class _PrayerTrackerView extends StatefulWidget {
  const _PrayerTrackerView();

  @override
  State<_PrayerTrackerView> createState() => _PrayerTrackerViewState();
}

class _PrayerTrackerViewState extends State<_PrayerTrackerView>
    with WidgetsBindingObserver {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Windows open/close with the clock, so re-resolve statuses periodically.
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) context.read<PrayerTrackerCubit>().refresh();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<PrayerTrackerCubit>().refresh();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

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
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => context.canPop()
                          ? context.pop()
                          : context.go('/dashboard'),
                    ),
                    Text(
                      l10n.trackerTitle,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: BlocBuilder<PrayerTrackerCubit, PrayerTrackerState>(
                  builder: (context, state) {
                    switch (state.status) {
                      case PrayerTrackerStatus.initial:
                      case PrayerTrackerStatus.loading:
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.gold,
                          ),
                        );
                      case PrayerTrackerStatus.error:
                        return Center(
                          child: Text(
                            l10n.trackerLoadError,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        );
                      case PrayerTrackerStatus.ready:
                        return _Content(state: state);
                    }
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

class _Content extends StatelessWidget {
  final PrayerTrackerState state;
  const _Content({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<PrayerTrackerCubit>();
    final earlier = state.earlierDays;
    final streak = state.stats?.streakDays ?? 0;

    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
      children: [
        Text(
          streak > 0 ? l10n.trackerStreak(streak) : l10n.trackerStreakNone,
          style: TextStyle(color: AppColors.gold, fontSize: 14.sp),
        ),
        if (state.approximate) ...[
          SizedBox(height: 8.h),
          Text(
            l10n.trackerApproxLocation,
            style: TextStyle(color: Colors.white70, fontSize: 12.sp),
          ),
        ],
        if (earlier.isNotEmpty) ...[
          SizedBox(height: 16.h),
          _SectionTitle(l10n.trackerEarlier),
          SizedBox(height: 2.h),
          Text(
            l10n.trackerEarlierHint,
            style: TextStyle(color: Colors.white60, fontSize: 12.sp),
          ),
          SizedBox(height: 10.h),
          for (var i = 0; i < earlier.length; i++)
            _EarlierDayCard(
              key: ValueKey(earlier[i].date),
              day: earlier[i],
              initiallyOpen: i == 0,
            ),
        ],
        SizedBox(height: 16.h),
        _SectionTitle(l10n.trackerToday),
        SizedBox(height: 8.h),
        for (final v in state.todaySlots) _SlotTile(view: v),
        SizedBox(height: 16.h),
        _ExcuseSection(state: state),
        SizedBox(height: 16.h),
        _SectionTitle(l10n.trackerQadhaTitle),
        SizedBox(height: 4.h),
        InkWell(
          onTap: () async {
            await context.push('/qadha');
            if (context.mounted) cubit.refresh();
          },
          child: Row(
            children: [
              Expanded(
                child: Text(
                  state.totalQadha == 0
                      ? l10n.trackerQadhaNone
                      : l10n.trackerQadhaTotal(state.totalQadha),
                  style: TextStyle(color: Colors.white, fontSize: 14.sp),
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white54),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          activeThumbColor: AppColors.gold,
          title: Text(
            l10n.trackerNudgeSetting,
            style: const TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            l10n.trackerNudgeSettingHint,
            style: const TextStyle(color: Colors.white60),
          ),
          value: state.nudgeEnabled,
          onChanged: cubit.setNudgeEnabled,
        ),
        SizedBox(height: 8.h),
        Text(
          l10n.trackerLocalNote,
          style: TextStyle(color: Colors.white54, fontSize: 11.sp),
        ),
        Text(
          l10n.trackerFiqhNote,
          style: TextStyle(color: Colors.white54, fontSize: 11.sp),
        ),
      ],
    );
  }
}

/// One earlier day with unrecorded prayers, collapsed to a single row. The
/// most recent day starts open; older ones stay closed so the page stays short.
class _EarlierDayCard extends StatefulWidget {
  final DaySlots day;
  final bool initiallyOpen;
  const _EarlierDayCard({
    super.key,
    required this.day,
    required this.initiallyOpen,
  });

  @override
  State<_EarlierDayCard> createState() => _EarlierDayCardState();
}

class _EarlierDayCardState extends State<_EarlierDayCard> {
  late bool _open = widget.initiallyOpen;

  String _title(BuildContext context, AppLocalizations l10n) {
    final d = DateTime.tryParse(widget.day.date);
    final date = _friendlyDate(context, widget.day.date);
    if (d == null) return date;
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final isYesterday =
        d.year == yesterday.year &&
        d.month == yesterday.month &&
        d.day == yesterday.day;
    return isYesterday ? '${l10n.trackerYesterday} · $date' : date;
  }

  Future<void> _confirmAll(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<PrayerTrackerCubit>();
    final slots = [for (final v in widget.day.slots) v.slot];
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        icon: const Icon(Icons.task_alt_rounded, color: AppColors.accent),
        title: Text(
          l10n.trackerMarkAllTitle(slots.length),
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          l10n.trackerMarkAllBody(_friendlyDate(ctx, widget.day.date)),
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.trackerMarkAllConfirm),
          ),
        ],
      ),
    );
    if (ok == true) {
      HapticFeedback.mediumImpact();
      await cubit.checkInMany(slots);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final count = widget.day.slots.length;
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: _open
              ? AppColors.gold.withValues(alpha: 0.35)
              : Colors.white12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(18.r),
            onTap: () => setState(() => _open = !_open),
            child: Padding(
              padding: EdgeInsets.fromLTRB(14.w, 12.h, 10.w, 12.h),
              child: Row(
                children: [
                  Icon(
                    Icons.history_rounded,
                    color: AppColors.gold,
                    size: 20.sp,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      _title(context, l10n),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      l10n.trackerEarlierCount(count),
                      style: TextStyle(
                        color: AppColors.gold,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _open ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: !_open
                ? const SizedBox(width: double.infinity)
                : Padding(
                    padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 12.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.trackerTapToRecord,
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 11.sp,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            for (
                              var i = 0;
                              i < widget.day.slots.length;
                              i++
                            ) ...[
                              if (i > 0) SizedBox(width: 6.w),
                              Expanded(
                                child: _PrayerChip(
                                  view: widget.day.slots[i],
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    _showRecordSheet(
                                      context,
                                      widget.day.slots[i],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton.tonalIcon(
                            onPressed: () => _confirmAll(context),
                            icon: const Icon(Icons.done_all_rounded, size: 18),
                            label: Text(l10n.trackerMarkAllPrayed),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _PrayerChip extends StatelessWidget {
  final SlotView view;
  final VoidCallback onTap;
  const _PrayerChip({required this.view, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Material(
      color: Colors.white.withValues(alpha: 0.06),
      shape: StadiumBorder(side: BorderSide(color: Colors.white12)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 8.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                prayerLabel(l10n, view.slot.prayer),
                maxLines: 1,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                formatSlotTime(view.slot.start),
                style: TextStyle(color: Colors.white54, fontSize: 11.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet to answer for one unrecorded prayer.
Future<void> _showRecordSheet(BuildContext context, SlotView view) {
  final l10n = AppLocalizations.of(context)!;
  final cubit = context.read<PrayerTrackerCubit>();
  final slot = view.slot;
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.cardDark,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 16.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              prayerLabel(l10n, slot.prayer),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              '${_friendlyDate(ctx, slot.date)} · '
              '${formatSlotTime(slot.start)} – ${formatSlotTime(slot.end)}',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white60, fontSize: 12.sp),
            ),
            SizedBox(height: 18.h),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                cubit.checkIn(slot);
              },
              icon: const Icon(Icons.check_rounded),
              label: Text(l10n.trackerActionPrayed),
            ),
            SizedBox(height: 8.h),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                cubit.checkIn(slot, inJamaah: true);
              },
              icon: const Icon(Icons.groups_rounded),
              label: Text(l10n.trackerActionJamaah),
            ),
            SizedBox(height: 4.h),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                cubit.markMissed(slot);
              },
              child: Text(l10n.trackerActionMissed),
            ),
          ],
        ),
      ),
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      color: Colors.white,
      fontSize: 16.sp,
      fontWeight: FontWeight.w600,
    ),
  );
}

class _SlotTile extends StatelessWidget {
  final SlotView view;
  const _SlotTile({required this.view});

  String _status(AppLocalizations l) {
    switch (view.status) {
      case SlotStatus.upcoming:
        return l.trackerStatusUpcoming;
      case SlotStatus.open:
        return l.trackerStatusOpen;
      case SlotStatus.unrecorded:
        return l.trackerStatusUnrecorded;
      case SlotStatus.missed:
        return l.trackerStatusMissed;
      case SlotStatus.excused:
        return l.trackerExcuseStatus;
      case SlotStatus.performed:
        return view.inJamaah
            ? l.trackerStatusPerformedJamaah
            : l.trackerStatusPerformed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<PrayerTrackerCubit>();
    final slot = view.slot;
    final canAct =
        view.status == SlotStatus.open || view.status == SlotStatus.unrecorded;
    final done = view.status == SlotStatus.performed;

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: done
              ? AppColors.accent.withValues(alpha: 0.5)
              : Colors.white12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  prayerLabel(l10n, slot.prayer),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${formatSlotTime(slot.start)} – ${formatSlotTime(slot.end)}',
                style: TextStyle(color: Colors.white60, fontSize: 12.sp),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            _status(l10n),
            style: TextStyle(
              color: done ? AppColors.accent : Colors.white70,
              fontSize: 12.sp,
            ),
          ),
          if (canAct) ...[
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              children: [
                FilledButton(
                  onPressed: () => cubit.checkIn(slot),
                  child: Text(l10n.trackerActionPrayed),
                ),
                OutlinedButton(
                  onPressed: () => cubit.checkIn(slot, inJamaah: true),
                  child: Text(l10n.trackerActionJamaah),
                ),
                if (view.status == SlotStatus.unrecorded)
                  TextButton(
                    onPressed: () => cubit.markMissed(slot),
                    child: Text(l10n.trackerActionMissed),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

String _kindLabel(AppLocalizations l, ExcuseKind k) {
  switch (k) {
    case ExcuseKind.haid:
      return l.trackerExcuseKindHaid;
    case ExcuseKind.nifas:
      return l.trackerExcuseKindNifas;
    case ExcuseKind.sakit:
      return l.trackerExcuseKindSakit;
  }
}

/// Pause (excused period) controls. All data here is local-only.
class _ExcuseSection extends StatelessWidget {
  final PrayerTrackerState state;
  const _ExcuseSection({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<PrayerTrackerCubit>();
    final active = state.activePeriod;
    final past = state.periods.where((p) => !p.isActive).toList().reversed;
    final muted = TextStyle(color: Colors.white60, fontSize: 12.sp);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(l10n.trackerExcuseTitle),
        SizedBox(height: 4.h),
        if (active != null) ...[
          Text(
            '${_kindLabel(l10n, active.kind)} · '
            '${l10n.trackerExcuseActive(active.startDate)}',
            style: TextStyle(color: Colors.white, fontSize: 14.sp),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            children: [
              FilledButton(
                onPressed: () => cubit.endExcuse(active.id!),
                child: Text(l10n.trackerExcuseEnd),
              ),
              TextButton(
                onPressed: () => cubit.deleteExcuse(active.id!),
                child: Text(l10n.trackerExcuseDelete),
              ),
            ],
          ),
        ] else
          OutlinedButton(
            onPressed: () => _showStartSheet(context, cubit),
            child: Text(l10n.trackerExcuseStart),
          ),
        if (past.isNotEmpty) ...[
          SizedBox(height: 8.h),
          Text(l10n.trackerExcuseHistory, style: muted),
          for (final p in past)
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${_kindLabel(l10n, p.kind)} · ${p.startDate} – ${p.endDate}',
                    style: TextStyle(color: Colors.white70, fontSize: 13.sp),
                  ),
                ),
                IconButton(
                  tooltip: l10n.trackerExcuseDelete,
                  icon: const Icon(Icons.delete_outline, color: Colors.white54),
                  onPressed: () => cubit.deleteExcuse(p.id!),
                ),
              ],
            ),
        ],
        SizedBox(height: 4.h),
        Text(l10n.trackerExcuseLocalOnly, style: muted),
      ],
    );
  }

  Future<void> _showStartSheet(
    BuildContext context,
    PrayerTrackerCubit cubit,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    var kind = ExcuseKind.haid;
    DateTime? expected;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(
            16.w,
            16.h,
            16.w,
            16.h + MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RadioGroup<ExcuseKind>(
                groupValue: kind,
                onChanged: (v) => setSheet(() => kind = v!),
                child: Column(
                  children: [
                    for (final k in ExcuseKind.values)
                      RadioListTile<ExcuseKind>(
                        value: k,
                        title: Text(_kindLabel(l10n, k)),
                      ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () async {
                  final now = DateTime.now();
                  final d = await showDatePicker(
                    context: ctx,
                    initialDate: now.add(const Duration(days: 7)),
                    firstDate: now,
                    lastDate: now.add(const Duration(days: 365)),
                  );
                  if (d != null) setSheet(() => expected = d);
                },
                child: Text(
                  '${l10n.trackerExcuseExpectedEnd}: '
                  '${expected == null ? l10n.trackerExcuseNoExpected : DateFormat('yyyy-MM-dd').format(expected!)}',
                ),
              ),
              FilledButton(
                onPressed: () {
                  cubit.startExcuse(kind, expectedEnd: expected);
                  Navigator.of(ctx).pop();
                },
                child: Text(l10n.trackerExcuseSave),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// `2026-11-08` -> "Min, 8 Nov" in the app language; falls back to the raw
/// key if it cannot be parsed.
String _friendlyDate(BuildContext context, String ymd) {
  final d = DateTime.tryParse(ymd);
  if (d == null) return ymd;
  return DateFormat.MMMEd(Localizations.localeOf(context).toString()).format(d);
}

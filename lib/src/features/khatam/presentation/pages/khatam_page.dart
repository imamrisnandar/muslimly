import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/database/database_service.dart';
import '../../../../core/di/di_container.dart';
import '../../../../core/presentation/widgets/gradient_page.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/khatam_plan.dart';

const _kPlanKey = 'khatam_plan';

class KhatamPage extends StatefulWidget {
  const KhatamPage({super.key});

  @override
  State<KhatamPage> createState() => _KhatamPageState();
}

class _KhatamPageState extends State<KhatamPage> {
  final DatabaseService _db = getIt<DatabaseService>();
  KhatamPlan? _plan;
  KhatamProgress? _progress;
  bool _loaded = false;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final plan = KhatamPlan.decode(await _db.getSetting(_kPlanKey));
    KhatamProgress? progress;
    if (plan != null) {
      final counts = await _db.countPagesSince(
        DateFormat('yyyy-MM-dd').format(plan.start),
      );
      progress = KhatamCalculator.compute(
        plan: plan,
        pagesRead: plan.khatamCount == 1 ? counts.uniquePages : counts.pageDays,
        today: DateTime.now(),
      );
    }
    if (!mounted) return;
    setState(() {
      _plan = plan;
      _progress = progress;
      _loaded = true;
      _editing = false;
    });
  }

  Future<void> _save(KhatamPlan plan) async {
    await _db.saveSetting(_kPlanKey, plan.encode());
    await _load();
  }

  Future<void> _delete() async {
    await _db.saveSetting(_kPlanKey, '');
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GradientPage(
      title: l10n.khatamTitle,
      actions: [
        if (_plan != null && !_editing)
          IconButton(
            tooltip: l10n.khatamEdit,
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            onPressed: () => setState(() => _editing = true),
          ),
      ],
      child: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : (_plan == null || _editing)
          ? _KhatamForm(initial: _plan, onSave: _save, onDelete: _delete)
          : _KhatamProgressView(plan: _plan!, progress: _progress!),
    );
  }
}

class _KhatamProgressView extends StatelessWidget {
  final KhatamPlan plan;
  final KhatamProgress progress;
  const _KhatamProgressView({required this.plan, required this.progress});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final fmt = DateFormat.yMMMMd(locale);
    final p = progress;
    final muted = TextStyle(color: Colors.white60, fontSize: 13.sp);
    String status;
    if (p.finished) {
      status = l10n.khatamDone;
    } else if (p.notStarted) {
      status = l10n.khatamNotStarted(fmt.format(plan.start));
    } else if (p.overdue) {
      status = l10n.khatamOverdue;
    } else if (p.behindBy > 0) {
      status = l10n.khatamBehind(p.behindBy);
    } else {
      status = l10n.khatamOnTrack;
    }
    return ListView(
      padding: EdgeInsets.all(16.r),
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.khatamPagesRead(p.pagesRead, p.totalPages),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.h),
              LinearProgressIndicator(
                value: p.fraction,
                minHeight: 8.h,
                color: AppColors.accent,
                backgroundColor: Colors.white12,
                borderRadius: BorderRadius.circular(8.r),
              ),
              SizedBox(height: 10.h),
              Text(
                status,
                style: TextStyle(color: AppColors.gold, fontSize: 14.sp),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        if (!p.finished)
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.khatamDailyTarget(p.dailyTarget),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(l10n.khatamPerPrayer(p.pagesPerPrayer), style: muted),
                SizedBox(height: 4.h),
                Text(l10n.khatamDaysLeft(p.remainingReadingDays), style: muted),
              ],
            ),
          ),
        SizedBox(height: 12.h),
        Text(
          l10n.khatamPlanRange(
            fmt.format(plan.start),
            fmt.format(plan.target),
            plan.khatamCount,
          ),
          style: muted,
        ),
        SizedBox(height: 8.h),
        Text(l10n.khatamUniqueNote, style: muted),
      ],
    );
  }
}

class _KhatamForm extends StatefulWidget {
  final KhatamPlan? initial;
  final Future<void> Function(KhatamPlan) onSave;
  final Future<void> Function() onDelete;
  const _KhatamForm({
    required this.initial,
    required this.onSave,
    required this.onDelete,
  });

  @override
  State<_KhatamForm> createState() => _KhatamFormState();
}

class _KhatamFormState extends State<_KhatamForm> {
  late DateTime _start;
  late DateTime _target;
  late int _count;
  late Set<int> _off;
  int _ramadanAdjust = 0;

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    final today = dateOnly(DateTime.now());
    _start = i?.start ?? today;
    _target = i?.target ?? DateTime(today.year, today.month, today.day + 30);
    _count = i?.khatamCount ?? 1;
    _off = {...?i?.offWeekdays};
  }

  void _applyRamadan() {
    final r = KhatamCalculator.nextRamadan(
      DateTime.now(),
      adjustDays: _ramadanAdjust,
    );
    final today = dateOnly(DateTime.now());
    setState(() {
      _start = r.start.isBefore(today) ? today : r.start;
      _target = r.end;
    });
  }

  Future<void> _pick(bool isStart) async {
    final initial = isStart ? _start : _target;
    final d = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (d == null) return;
    setState(() {
      if (isStart) {
        _start = dateOnly(d);
      } else {
        _target = dateOnly(d);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final fmt = DateFormat.yMMMMd(locale);
    final valid = !_target.isBefore(_start) && _off.length < 7;
    final weekdayNames = DateFormat.E(locale);
    // 2024-01-01 was a Monday.
    String wd(int w) => weekdayNames.format(DateTime(2024, 1, w));
    return ListView(
      padding: EdgeInsets.all(16.r),
      children: [
        Text(
          l10n.khatamSetupHint,
          style: TextStyle(color: Colors.white70, fontSize: 14.sp),
        ),
        SizedBox(height: 12.h),
        OutlinedButton.icon(
          icon: const Icon(Icons.nights_stay_outlined),
          label: Text(l10n.khatamPresetRamadan),
          onPressed: _applyRamadan,
        ),
        Row(
          children: [
            Text(
              l10n.khatamRamadanAdjust(_ramadanAdjust),
              style: TextStyle(color: Colors.white60, fontSize: 12.sp),
            ),
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              color: Colors.white70,
              onPressed: () {
                setState(() => _ramadanAdjust--);
                _applyRamadan();
              },
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              color: Colors.white70,
              onPressed: () {
                setState(() => _ramadanAdjust++);
                _applyRamadan();
              },
            ),
          ],
        ),
        ListTile(
          title: Text(
            l10n.khatamStartDate,
            style: const TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            fmt.format(_start),
            style: const TextStyle(color: Colors.white60),
          ),
          onTap: () => _pick(true),
        ),
        ListTile(
          title: Text(
            l10n.khatamTargetDate,
            style: const TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            fmt.format(_target),
            style: const TextStyle(color: Colors.white60),
          ),
          onTap: () => _pick(false),
        ),
        Row(
          children: [
            Text(
              l10n.khatamCount(_count),
              style: const TextStyle(color: Colors.white),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              color: Colors.white70,
              onPressed: _count > 1 ? () => setState(() => _count--) : null,
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              color: Colors.white70,
              onPressed: _count < 10 ? () => setState(() => _count++) : null,
            ),
          ],
        ),
        Text(
          l10n.khatamOffDays,
          style: TextStyle(color: Colors.white70, fontSize: 13.sp),
        ),
        Wrap(
          spacing: 6.w,
          children: [
            for (var w = 1; w <= 7; w++)
              FilterChip(
                label: Text(wd(w)),
                selected: _off.contains(w),
                onSelected: (v) => setState(() {
                  v ? _off.add(w) : _off.remove(w);
                }),
              ),
          ],
        ),
        SizedBox(height: 20.h),
        FilledButton(
          style: FilledButton.styleFrom(foregroundColor: Colors.black87),
          onPressed: valid
              ? () => widget.onSave(
                  KhatamPlan(
                    start: _start,
                    target: _target,
                    khatamCount: _count,
                    offWeekdays: _off,
                  ),
                )
              : null,
          child: Text(l10n.toolsSave),
        ),
        if (widget.initial != null)
          TextButton(
            onPressed: widget.onDelete,
            child: Text(l10n.khatamDelete),
          ),
      ],
    );
  }
}

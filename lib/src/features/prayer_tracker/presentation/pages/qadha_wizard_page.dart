import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/di_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/prayer_log.dart';
import '../../domain/utils/qadha_estimator.dart';
import '../bloc/qadha_cubit.dart';
import 'prayer_tracker_page.dart' show prayerLabel;

class QadhaWizardPage extends StatelessWidget {
  const QadhaWizardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<QadhaCubit>()..load(),
      child: const _Wizard(),
    );
  }
}

class _Wizard extends StatefulWidget {
  const _Wizard();
  @override
  State<_Wizard> createState() => _WizardState();
}

class _WizardState extends State<_Wizard> {
  int _step = 0;
  DateTime? _from;
  DateTime? _to;
  QadhaPattern _pattern = QadhaPattern.never;
  final Map<TrackedPrayer, int> _perWeek = {
    for (final p in TrackedPrayer.values) p: 0,
  };
  double _excused = 0;
  final Map<TrackedPrayer, TextEditingController> _review = {
    for (final p in TrackedPrayer.values) p: TextEditingController(),
  };

  @override
  void dispose() {
    for (final c in _review.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pick(bool from) async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: (from ? _from : _to) ?? now,
      firstDate: DateTime(now.year - 80),
      lastDate: now,
    );
    if (d != null) setState(() => from ? _from = d : _to = d);
  }

  void _fillReview() {
    final r = QadhaEstimator.estimate(
      QadhaEstimateInput(
        from: _from!,
        to: _to!,
        pattern: _pattern,
        prayedPerWeek: _perWeek,
        excusedDaysPerMonth: _excused,
      ),
    );
    for (final p in TrackedPrayer.values) {
      _review[p]!.text = '${r[p]}';
    }
  }

  bool get _canContinue => _step != 0 || (_from != null && _to != null);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final df = DateFormat.yMMMd(Localizations.localeOf(context).toString());
    final white = TextStyle(color: Colors.white, fontSize: 14.sp);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.qadhaWizardTitle),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      backgroundColor: AppColors.bgGradientStart,
      body: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(
            context,
          ).colorScheme.copyWith(primary: AppColors.gold),
        ),
        child: Stepper(
          currentStep: _step,
          type: StepperType.vertical,
          onStepTapped: null,
          controlsBuilder: (context, details) {
            final last = _step == 3;
            return Padding(
              padding: EdgeInsets.only(top: 12.h),
              child: Row(
                children: [
                  FilledButton(
                    onPressed: _canContinue
                        ? () async {
                            if (last) {
                              final target = {
                                for (final p in TrackedPrayer.values)
                                  p: (int.tryParse(_review[p]!.text) ?? 0)
                                      .clamp(0, 1000000),
                              };
                              await context.read<QadhaCubit>().saveBaseline(
                                target,
                              );
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.qadhaSaved)),
                              );
                              context.pop();
                              return;
                            }
                            setState(() {
                              _step++;
                              if (_step == 3) _fillReview();
                            });
                          }
                        : null,
                    child: Text(last ? l10n.qadhaSave : l10n.qadhaNext),
                  ),
                  SizedBox(width: 8.w),
                  if (_step > 0)
                    TextButton(
                      onPressed: () => setState(() => _step--),
                      child: Text(l10n.qadhaBack),
                    ),
                ],
              ),
            );
          },
          steps: [
            Step(
              isActive: _step >= 0,
              title: Text(l10n.qadhaStepRange, style: white),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.qadhaFrom, style: white),
                  TextButton(
                    onPressed: () => _pick(true),
                    child: Text(
                      _from == null ? l10n.qadhaPickDate : df.format(_from!),
                    ),
                  ),
                  Text(l10n.qadhaTo, style: white),
                  TextButton(
                    onPressed: () => _pick(false),
                    child: Text(
                      _to == null ? l10n.qadhaPickDate : df.format(_to!),
                    ),
                  ),
                ],
              ),
            ),
            Step(
              isActive: _step >= 1,
              title: Text(l10n.qadhaStepPattern, style: white),
              content: Column(
                children: [
                  RadioGroup<QadhaPattern>(
                    groupValue: _pattern,
                    onChanged: (v) => setState(() => _pattern = v!),
                    child: Column(
                      children: [
                        RadioListTile<QadhaPattern>(
                          value: QadhaPattern.never,
                          title: Text(l10n.qadhaPatternNever, style: white),
                        ),
                        RadioListTile<QadhaPattern>(
                          value: QadhaPattern.sometimes,
                          title: Text(l10n.qadhaPatternSometimes, style: white),
                        ),
                      ],
                    ),
                  ),
                  if (_pattern == QadhaPattern.sometimes)
                    for (final p in TrackedPrayer.values) ...[
                      Text(
                        l10n.qadhaPerWeek(prayerLabel(l10n, p), _perWeek[p]!),
                        style: white,
                      ),
                      Slider(
                        min: 0,
                        max: 7,
                        divisions: 7,
                        value: _perWeek[p]!.toDouble(),
                        onChanged: (v) =>
                            setState(() => _perWeek[p] = v.round()),
                      ),
                    ],
                ],
              ),
            ),
            Step(
              isActive: _step >= 2,
              title: Text(l10n.qadhaStepExcuse, style: white),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.qadhaExcuseHint, style: white),
                  Slider(
                    min: 0,
                    max: 15,
                    divisions: 15,
                    label: _excused.round().toString(),
                    value: _excused,
                    onChanged: (v) => setState(() => _excused = v),
                  ),
                ],
              ),
            ),
            Step(
              isActive: _step >= 3,
              title: Text(l10n.qadhaStepReview, style: white),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.qadhaReviewHint, style: white),
                  for (final p in TrackedPrayer.values)
                    TextField(
                      controller: _review[p],
                      keyboardType: TextInputType.number,
                      style: white,
                      decoration: InputDecoration(
                        labelText: prayerLabel(l10n, p),
                        labelStyle: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  SizedBox(height: 8.h),
                  Text(
                    l10n.qadhaFiqhNote,
                    style: TextStyle(color: Colors.white60, fontSize: 12.sp),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

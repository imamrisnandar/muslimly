import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/generated/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../bloc/settings_cubit.dart';
import '../bloc/settings_state.dart';
import '../../../prayer/presentation/bloc/prayer_bloc.dart';
import '../../../prayer/presentation/bloc/prayer_event.dart';
import '../../../../core/theme/app_colors.dart';

void showTargetBottomSheet(BuildContext context, SettingsState initialState) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.cardDarker,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (context) {
      return BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          final l10n = AppLocalizations.of(context)!;
          final isAyahMode = state.targetUnit == 'ayah';
          final currentTarget = isAyahMode
              ? state.dailyAyahTarget
              : state.dailyTarget;

          return SizedBox(
            height: 600.h,
            child: Column(
              children: [
                Center(
                  child: Container(
                    margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.targetSelectTitle,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20.h),

                        // MODE SELECTOR
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          padding: EdgeInsets.all(4.w),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildModeButton(
                                  context,
                                  l10n.lblPages,
                                  'page',
                                  !isAyahMode,
                                ),
                              ),
                              Expanded(
                                child: _buildModeButton(
                                  context,
                                  l10n.lblAyah,
                                  'ayah',
                                  isAyahMode,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16.h),

                        // EXPLANATION
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF0D47A1,
                            ).withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: Colors.blueAccent.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.blueAccent,
                                size: 20.sp,
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  isAyahMode
                                      ? l10n.targetAyahExplanation
                                      : l10n.targetPageExplanation,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 13.sp,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24.h),

                        Text(
                          l10n.targetChooseTarget,
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0,
                          ),
                        ),
                        SizedBox(height: 12.h),

                        if (isAyahMode) ...[
                          _buildTargetOption(
                            context,
                            10,
                            "10 ${l10n.lblAyah}",
                            currentTarget,
                            true,
                          ),
                          _buildTargetOption(
                            context,
                            20,
                            "20 ${l10n.lblAyah}",
                            currentTarget,
                            true,
                          ),
                          _buildTargetOption(
                            context,
                            50,
                            "50 ${l10n.lblAyah}",
                            currentTarget,
                            true,
                          ),
                          _buildTargetOption(
                            context,
                            100,
                            "100 ${l10n.lblAyah}",
                            currentTarget,
                            true,
                          ),
                        ] else ...[
                          _buildTargetOption(
                            context,
                            2,
                            l10n.targetBeginner,
                            currentTarget,
                            false,
                          ),
                          _buildTargetOption(
                            context,
                            4,
                            l10n.targetRoutine,
                            currentTarget,
                            false,
                          ),
                          _buildTargetOption(
                            context,
                            10,
                            l10n.targetHalfJuz,
                            currentTarget,
                            false,
                          ),
                          _buildTargetOption(
                            context,
                            20,
                            l10n.targetOneJuz,
                            currentTarget,
                            false,
                          ),
                        ],

                        SizedBox(height: 8.h),
                        Container(
                          margin: EdgeInsets.only(top: 8.h),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white24),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: ListTile(
                            leading: const Icon(
                              Icons.edit,
                              color: Colors.white70,
                            ),
                            title: Text(
                              l10n.targetCustom,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: const Icon(
                              Icons.chevron_right,
                              color: Colors.white54,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              _showCustomTargetDialog(
                                context,
                                currentTarget,
                                isAyahMode,
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 32.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

String _getAdjustmentText(int adjustment, AppLocalizations l10n) {
  if (adjustment == 0) return "0 ${l10n.days}";
  final sign = adjustment > 0 ? "+" : "";
  return "$sign$adjustment ${l10n.days}";
}

void showCalculationMethodBottomSheet(
  BuildContext context,
  SettingsState state,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.cardDarker,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (sheetContext) {
      final l10n = AppLocalizations.of(sheetContext)!;
      final options = <String, String>{
        'singapore': l10n.prayerCalculationMethodSingapore,
        'kemenag_ri': l10n.prayerCalculationMethodKemenagRI,
      };

      return Padding(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.prayerCalculationMethod,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            ...options.entries.map((entry) {
              final selected = state.calculationMethod == entry.key;
              return RadioListTile<String>(
                value: entry.key,
                groupValue: state.calculationMethod,
                activeColor: AppColors.accent,
                title: Text(
                  entry.value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                onChanged: (value) {
                  if (value == null) return;
                  context.read<SettingsCubit>().updateCalculationMethod(value);
                  // PrayerBloc is only provided under the /dashboard route
                  // (shared with the Jadwal tab); Settings can also be
                  // reached via the standalone /settings route, where it
                  // isn't available, so this refetch is best-effort.
                  try {
                    final prayerBloc = context.read<PrayerBloc>();
                    prayerBloc.add(
                      FetchPrayerTime(
                        latitude: prayerBloc.state.currentCity.latitude,
                        longitude: prayerBloc.state.currentCity.longitude,
                        date: DateTime.now(),
                      ),
                    );
                  } catch (_) {}
                  Navigator.pop(sheetContext);
                },
              );
            }),
          ],
        ),
      );
    },
  );
}

void showHijriAdjustmentBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.cardDarker,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (context) {
      final l10n = AppLocalizations.of(context)!;
      // Helper to get month name
      String getMonthName(int i) {
        return _getHijriMonthName(context, i);
      }

      return Container(
        height: 600.h,
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
        child: Column(
          children: [
            Text(
              l10n.hijriAdjustment,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              l10n.hijriAdjustmentSubtitle,
              style: TextStyle(color: Colors.white54, fontSize: 14.sp),
            ),
            SizedBox(height: 24.h),
            Expanded(
              child: BlocBuilder<SettingsCubit, SettingsState>(
                builder: (context, state) {
                  return ListView.separated(
                    itemCount: 12,
                    separatorBuilder: (c, i) =>
                        Divider(color: Colors.white.withValues(alpha: 0.05)),
                    itemBuilder: (context, index) {
                      final monthIndex = index + 1;
                      final monthName = getMonthName(monthIndex);

                      final adjMap = state.hijriAdjustments.firstWhere(
                        (e) => e['hijri_month'] == monthIndex,
                        orElse: () => {'adjustment': 0},
                      );
                      final currentVal = adjMap['adjustment'] as int? ?? 0;

                      return ListTile(
                        title: Text(
                          monthName,
                          style: const TextStyle(color: Colors.white),
                        ),
                        trailing: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: currentVal != 0
                                ? AppColors.accent.withValues(alpha: 0.2)
                                : Colors.white10,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: currentVal != 0
                                  ? AppColors.accent
                                  : Colors.transparent,
                            ),
                          ),
                          child: Text(
                            _getAdjustmentText(currentVal, l10n),
                            style: TextStyle(
                              color: currentVal != 0
                                  ? AppColors.accent
                                  : Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        onTap: () => _showAdjustmentSelector(
                          context,
                          monthIndex,
                          currentVal,
                          monthName,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

String _getHijriMonthName(BuildContext context, int month) {
  final locale = Localizations.localeOf(context).languageCode;
  if (locale == 'id') {
    const months = [
      "Muharram",
      "Safar",
      "Rabiul Awal",
      "Rabiul Akhir",
      "Jumadil Awal",
      "Jumadil Akhir",
      "Rajab",
      "Sya'ban",
      "Ramadhan",
      "Syawal",
      "Dzulqa'idah",
      "Dzulhijjah",
    ];
    if (month >= 1 && month <= 12) return months[month - 1];
  } else {
    const months = [
      "Muharram",
      "Safar",
      "Rabi' al-awwal",
      "Rabi' al-thani",
      "Jumada al-awwal",
      "Jumada al-thani",
      "Rajab",
      "Sha'ban",
      "Ramadan",
      "Shawwal",
      "Dhu al-Qi'dah",
      "Dhu al-Hijjah",
    ];
    if (month >= 1 && month <= 12) return months[month - 1];
  }
  return "Month $month";
}

void _showAdjustmentSelector(
  BuildContext context,
  int monthIndex,
  int currentAdjustment,
  String monthName,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.cardDarker,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (context) {
      final l10n = AppLocalizations.of(context)!;
      return Padding(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.settingsMonthAdjustment(monthName),
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (int i = -2; i <= 2; i++)
                  _buildAdjustmentOption(
                    context,
                    monthIndex,
                    i,
                    currentAdjustment,
                  ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildAdjustmentOption(
  BuildContext context,
  int monthIndex,
  int value,
  int groupValue,
) {
  final isSelected = value == groupValue;
  return GestureDetector(
    onTap: () {
      context.read<SettingsCubit>().updateHijriAdjustment(monthIndex, value);
      Navigator.pop(context);
    },
    child: Container(
      width: 50.w,
      height: 50.w,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.accent : Colors.white10,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        value > 0 ? "+$value" : "$value",
        style: TextStyle(
          color: isSelected ? Colors.black : Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16.sp,
        ),
      ),
    ),
  );
}

Widget _buildModeButton(
  BuildContext context,
  String label,
  String value,
  bool isSelected,
) {
  return GestureDetector(
    onTap: () {
      context.read<SettingsCubit>().updateTargetUnit(value);
    },
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.accent : Colors.transparent,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.black87 : Colors.white54,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          fontSize: 14.sp,
        ),
      ),
    ),
  );
}

void _showCustomTargetDialog(
  BuildContext context,
  int currentTarget,
  bool isAyahMode,
) {
  final l10n = AppLocalizations.of(context)!;
  final TextEditingController controller = TextEditingController(
    text: currentTarget.toString(),
  );
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: AppColors.cardDarker,
        title: Text(
          l10n.targetCustomTitle,
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: l10n.targetCustomHint,
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white54),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.accent),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null && value > 0) {
                if (isAyahMode) {
                  context.read<SettingsCubit>().updateDailyAyahTarget(value);
                } else {
                  context.read<SettingsCubit>().updateDailyTarget(value);
                }
                Navigator.pop(context);
              }
            },
            child: Text(
              l10n.settingsSave,
              style: const TextStyle(color: AppColors.accent),
            ),
          ),
        ],
      );
    },
  ).then((_) => controller.dispose());
}

Widget _buildTargetOption(
  BuildContext context,
  int value,
  String label,
  int currentValue,
  bool isAyahMode,
) {
  final isSelected = value == currentValue;
  return Container(
    margin: EdgeInsets.only(bottom: 8.h),
    decoration: BoxDecoration(
      color: isSelected
          ? AppColors.accent.withValues(alpha: 0.1)
          : Colors.white.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(12.r),
      border: isSelected
          ? Border.all(color: AppColors.accent)
          : Border.all(color: Colors.transparent),
    ),
    child: ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      leading: Icon(
        isSelected ? Icons.check_circle : Icons.circle_outlined,
        color: isSelected ? AppColors.accent : Colors.white54,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        if (isAyahMode) {
          context.read<SettingsCubit>().updateDailyAyahTarget(value);
        } else {
          context.read<SettingsCubit>().updateDailyTarget(value);
        }
      },
    ),
  );
}

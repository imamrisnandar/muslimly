import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/models/reminder_models.dart';
import '../../domain/services/reminder_service.dart';
import '../../../prayer/domain/services/fasting_service.dart';
import '../../../../l10n/generated/app_localizations.dart';

class FastingReminderSection extends StatelessWidget {
  final FastingReminder? todayFasting;
  final FastingReminder? nextFasting;
  final String locale;

  const FastingReminderSection({
    super.key,
    this.todayFasting,
    this.nextFasting,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    // If no fasting data, don't show section
    if (todayFasting == null && nextFasting == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.nightlight_round,
              color: const Color(0xFF00E676),
              size: 14.sp,
            ),
            SizedBox(width: 6.w),
            Text(
              AppLocalizations.of(context)!.lblFastingHeader,
              style: TextStyle(
                color: const Color(0xFF00E676),
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        if (todayFasting != null) ...[
          _buildFastingItem(
            context,
            label: 'Hari ini',
            fasting: todayFasting!,
            showCountdown: true,
          ),
          if (nextFasting != null) SizedBox(height: 6.h),
        ],
        if (nextFasting != null)
          _buildFastingItem(
            context,
            label: 'Berikutnya',
            fasting: nextFasting!,
            showCountdown: false,
          ),
      ],
    );
  }

  Widget _buildFastingItem(
    BuildContext context, {
    required String label,
    required FastingReminder fasting,
    required bool showCountdown,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            fasting.color.withOpacity(0.15),
            fasting.color.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: fasting.color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: fasting.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Icon(
              showCountdown ? Icons.restaurant : Icons.event,
              color: fasting.color,
              size: 14.sp,
            ),
          ),
          SizedBox(width: 8.w),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: TextStyle(color: Colors.white60, fontSize: 10.sp),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '•',
                      style: TextStyle(color: Colors.white30, fontSize: 10.sp),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      _getLocalizedEventName(context, fasting.event) ??
                          fasting.type,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (showCountdown && fasting.timeUntilIftar != null) ...[
                  SizedBox(height: 2.h),
                  Text(
                    'Berbuka ${ReminderService.formatDuration(fasting.timeUntilIftar!)} lagi',
                    style: TextStyle(
                      color: fasting.color,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ] else if (!showCountdown) ...[
                  SizedBox(height: 2.h),
                  Text(
                    ReminderService.formatDate(fasting.date, locale),
                    style: TextStyle(color: Colors.white70, fontSize: 10.sp),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? _getLocalizedEventName(BuildContext context, FastingEvent event) {
    final l10n = AppLocalizations.of(context)!;
    switch (event) {
      case FastingEvent.eidFitr:
        return l10n.eidFitr;
      case FastingEvent.eidAdha:
        return l10n.eidAdha;
      case FastingEvent.tasyrik:
        return l10n.daysTasyrik;
      case FastingEvent.ramadan:
        return l10n.fastingRamadan;
      case FastingEvent.arafah:
        return l10n.fastingArafah;
      case FastingEvent.ashura:
        return l10n.fastingAshura;
      case FastingEvent.tasua:
        return l10n.fastingTasua;
      case FastingEvent.ayyamulBidh:
        return l10n.fastingAyyamulBidh;
      case FastingEvent.monday:
        return l10n.fastingMonday;
      case FastingEvent.thursday:
        return l10n.fastingThursday;
      case FastingEvent.none:
        return null;
    }
  }
}

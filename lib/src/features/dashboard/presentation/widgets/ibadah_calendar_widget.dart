import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:hijri/hijri_calendar.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../prayer/domain/services/fasting_service.dart';

class IbadahCalendarWidget extends StatefulWidget {
  final FastingService fastingService;

  const IbadahCalendarWidget({super.key, required this.fastingService});

  @override
  State<IbadahCalendarWidget> createState() => _IbadahCalendarWidgetState();
}

class _IbadahCalendarWidgetState extends State<IbadahCalendarWidget> {
  late DateTime _focusedDate;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _focusedDate = DateTime.now();
    _selectedDate = DateTime.now();
  }

  void _onMonthChanged(int increment) {
    setState(() {
      _focusedDate = DateTime(
        _focusedDate.year,
        _focusedDate.month + increment,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        SizedBox(height: 16.h),
        _buildDaysOfWeek(),
        SizedBox(height: 16.h),
        _buildCalendarGrid(),
        SizedBox(height: 24.h),
        _buildSelectedDateDetail(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => _onMonthChanged(-1),
          icon: Icon(Icons.chevron_left, color: Colors.white, size: 24.sp),
        ),
        Column(
          children: [
            Text(
              DateFormat(
                'MMMM yyyy',
                AppLocalizations.of(context)!.localeName,
              ).format(_focusedDate),
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _getHijriMonthYear(_focusedDate),
              style: TextStyle(color: Colors.white70, fontSize: 14.sp),
            ),
          ],
        ),
        IconButton(
          onPressed: () => _onMonthChanged(1),
          icon: Icon(Icons.chevron_right, color: Colors.white, size: 24.sp),
        ),
      ],
    );
  }

  String _getHijriMonthYear(DateTime date) {
    final hijri = HijriCalendar.fromDate(date);
    return "${hijri.longMonthName} ${hijri.hYear} H";
  }

  Widget _buildDaysOfWeek() {
    // Localized days
    final l10n = AppLocalizations.of(context)!;
    final days = [
      l10n.calendarDayMon,
      l10n.calendarDayTue,
      l10n.calendarDayWed,
      l10n.calendarDayThu,
      l10n.calendarDayFri,
      l10n.calendarDaySat,
      l10n.calendarDaySun,
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: days
          .map(
            (day) => SizedBox(
              width: 40.w,
              child: Center(
                child: Text(
                  day,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildCalendarGrid() {
    // Determine days in month
    final daysInMonth = DateTime(
      _focusedDate.year,
      _focusedDate.month + 1,
      0,
    ).day;
    final firstDayOfMonth = DateTime(_focusedDate.year, _focusedDate.month, 1);

    // Weekday: Mon=1 ... Sun=7. We want Mon at index 0.
    final startingOffset = firstDayOfMonth.weekday - 1;

    // Total cells = Offset + Days
    final totalCells = startingOffset + daysInMonth;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8.h, // Space between rows
        crossAxisSpacing: 8.w, // Space between columns
        childAspectRatio:
            MediaQuery.of(context).orientation == Orientation.landscape
            ? 1.5
            : 1.0, // Square cells often look neater with spacing
      ),
      itemCount: totalCells,
      itemBuilder: (context, index) {
        if (index < startingOffset) {
          return const SizedBox();
        }

        final day = index - startingOffset + 1;
        final date = DateTime(_focusedDate.year, _focusedDate.month, day);

        return _buildDayCell(date);
      },
    );
  }

  Widget _buildDayCell(DateTime date) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final double daySize = isLandscape ? 12.sp : 14.sp;
    final double hijriSize = isLandscape ? 8.sp : 10.sp;
    final double dotSize = isLandscape ? 4.h : 6.h;

    final isSelected =
        date.year == _selectedDate.year &&
        date.month == _selectedDate.month &&
        date.day == _selectedDate.day;

    final isToday =
        date.year == DateTime.now().year &&
        date.month == DateTime.now().month &&
        date.day == DateTime.now().day;

    final fastingType = widget.fastingService.getFastingType(date);

    // Hijri Day Calculation
    final hijriDate = HijriCalendar.fromDate(date);

    return InkWell(
      onTap: () {
        setState(() {
          _selectedDate = date;
        });
      },
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF00E676).withOpacity(0.2)
              : const Color(0xFF141F23), // Darker bg for cells
          borderRadius: BorderRadius.circular(8.r),
          border: isToday
              ? Border.all(color: const Color(0xFF00E676), width: 1.5)
              : Border.all(color: Colors.white10, width: 0.5),
        ),
        child: Stack(
          children: [
            // Gregorian Date (Top Right)
            Positioned(
              top: 4.h,
              right: 6.w,
              child: Text(
                "${date.day}",
                style: TextStyle(
                  color: isSelected ? const Color(0xFF00E676) : Colors.white,
                  fontSize: daySize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Hijri Date (Bottom Right)
            Positioned(
              bottom: 4.h,
              right: 6.w,
              child: Text(
                "${hijriDate.hDay}",
                style: TextStyle(color: Colors.white38, fontSize: hijriSize),
              ),
            ),
            // Fasting Dot (Bottom Left)
            if (fastingType != FastingType.none)
              Positioned(
                bottom: 6.h,
                left: 6.w,
                child: _buildFastingDot(fastingType, size: dotSize),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFastingDot(FastingType type, {double? size}) {
    Color? color;
    if (type == FastingType.wajib) color = const Color(0xFFFFC107); // Gold
    if (type == FastingType.sunnah) color = const Color(0xFF00E676); // Green
    if (type == FastingType.haram) color = Colors.redAccent; // Red

    if (color == null) {
      return SizedBox(height: 6.h, width: 6.h);
    }

    return Container(
      width: 6.h,
      height: 6.h,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildSelectedDateDetail() {
    final l10n = AppLocalizations.of(context)!;
    final hijri = HijriCalendar.fromDate(_selectedDate);
    final eventName = _getLocalizedEventName(
      l10n,
      widget.fastingService.getFastingEvent(_selectedDate),
    );
    final fastingType = widget.fastingService.getFastingType(_selectedDate);

    Color borderColor = const Color(0xFF1B5E20).withOpacity(0.1);

    if (fastingType == FastingType.wajib) {
      borderColor = const Color(0xFFFFC107);
    } else if (fastingType == FastingType.sunnah) {
      borderColor = const Color(0xFF00E676);
    } else if (fastingType == FastingType.haram) {
      borderColor = Colors.redAccent.withOpacity(0.5);
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2A30),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Line 1: Date & Hijri
                Text(
                  "${DateFormat('d MMM yyyy', AppLocalizations.of(context)!.localeName).format(_selectedDate)} • ${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear} H",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                // Line 2: Event (if any)
                if (eventName != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    eventName,
                    style: TextStyle(
                      color: borderColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? _getLocalizedEventName(AppLocalizations l10n, FastingEvent event) {
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
        return null; // Return null if nospecial event
    }
  }
}

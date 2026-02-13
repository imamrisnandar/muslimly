import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../l10n/generated/app_localizations.dart';
import 'prayer_countdown_widget.dart';
import '../../../prayer/domain/services/fasting_service.dart';
import '../../domain/models/reminder_models.dart';

class PrayerHeaderWidget extends StatelessWidget {
  final Map<String, dynamic>? nextPrayer;
  final String locationName;
  final String? hijriDate;
  final DateTime? nextPrayerTime;
  final VoidCallback onLocationTap;
  final VoidCallback onQiblaTap;
  final VoidCallback? onTimerFinished;
  final FastingEvent? currentFasting;
  final Map<String, dynamic>? nextFasting;
  final ReminderCardData? reminderData;

  const PrayerHeaderWidget({
    super.key,
    required this.nextPrayer,
    required this.locationName,
    this.hijriDate,
    this.nextPrayerTime,
    required this.onLocationTap,
    required this.onQiblaTap,
    this.onTimerFinished,
    this.currentFasting,
    this.nextFasting,
    this.reminderData,
  });

  LinearGradient _getGradient(String? prayerName) {
    // Default to 'Imsak' or generic if null
    final name = prayerName ?? 'Imsak';

    switch (name) {
      case 'Subuh':
      case 'Fajr':
        return const LinearGradient(
          colors: [
            Color(0xFF1A237E),
            Color(0xFFFDD835),
          ], // Deep Blue -> Morning Sun
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'Terbit':
      case 'Sunrise':
        return const LinearGradient(
          colors: [
            Color(0xFFFDD835),
            Color(0xFFFF9800),
          ], // Bright Yellow -> Orange
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case 'Dzuhur':
      case 'Dhuhr':
        return const LinearGradient(
          colors: [Color(0xFF42A5F5), Color(0xFF81D4FA)], // Bright Sky Blue
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case 'Ashar':
      case 'Asr':
        return const LinearGradient(
          colors: [
            Color(0xFF81D4FA),
            Color(0xFFFFCC80),
          ], // Soft Blue -> Afternoon Gold
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'Maghrib':
        return const LinearGradient(
          colors: [
            Color(0xFF311B92),
            Color(0xFFFF7043),
          ], // Purple -> Sunset Orange
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case 'Isya':
      case 'Isha':
        return const LinearGradient(
          colors: [Color(0xFF0D47A1), Color(0xFF1E88E5)], // Deep Night Blue
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case 'Imsak':
      default:
        return const LinearGradient(
          colors: [Color(0xFF004D40), Color(0xFF009688)], // Islamic Green
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(gradient: _getGradient(nextPrayer?['name'])),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Abstract Pattern Overlay
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: CustomPaint(painter: _IslamicPatternPainter()),
            ),
          ),

          // 2. Content
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;

              // Use Aspect Ratio to determine Layout:
              // Sidebar (Portrait Shape): Taller or Square-ish -> Single Column
              // Header (Landscape Shape): Wider -> Double Column

              // Threshold: 1.4 (If width is less than 1.4x height, treat as Sidebar/Portrait Shape)
              // Threshold: 1.1
              final isSidebarOrPortraitShape = width < (height * 1.1);

              if (isSidebarOrPortraitShape) {
                // LANDSCAPE APP MODE (Sidebar - Taller Shape)
                // User request: "2 kolom ketika landscape"
                // We use _buildPortraitLayout (which is the Horizontal/2-Column design)
                return SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                    child: _buildPortraitLayout(context, l10n),
                  ),
                );
              } else {
                // PORTRAIT APP MODE (Header - Wider Shape)
                // User request: "1 kolom ketika portrait"
                // We use _buildLandscapeLayout (which is the Vertical/1-Column design)
                return SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                    child: _buildLandscapeLayout(
                      context,
                      l10n,
                    ), // 1-Column Layout
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPortraitLayout(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- MAIN 2-COLUMN LAYOUT ---
        Expanded(
          child: SingleChildScrollView(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === LEFT COLUMN (Primary Info) ===
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Location
                      GestureDetector(
                        onTap: onLocationTap,
                        child: Container(
                          margin: EdgeInsets.only(bottom: 40.h),
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.15),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                color: Colors.white70,
                                size: 14.sp,
                              ),
                              SizedBox(width: 4.w),
                              Flexible(
                                child: Text(
                                  locationName,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Icon(
                                Icons.edit_outlined,
                                color: Colors.white70,
                                size: 12.sp,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // 2. "Insya Allah, Menuju..."
                      Text(
                        l10n.prayerHeading,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14.sp,
                          fontStyle: FontStyle.italic,
                          fontFamily: 'Amiri',
                        ),
                      ),
                      SizedBox(height: 8.h),

                      // 3. Prayer Name & Time
                      Text(
                        nextPrayer?['name'] ?? '-',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32.sp, // Reduced from 42.sp
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          height: 1.0,
                          fontFamily: 'Amiri',
                        ),
                      ),
                      SizedBox(height: 2.h), // Reduced from 4.h
                      Text(
                        nextPrayer?['time'] ?? '--:--',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 26.sp, // Reduced from 32.sp
                          fontWeight: FontWeight.w300,
                          letterSpacing: -0.5,
                          height: 1.0,
                        ),
                      ),

                      SizedBox(height: 24.h),

                      // 4. Countdown
                      if (nextPrayerTime != null)
                        Container(
                          padding: EdgeInsets.only(
                            left: 12.w,
                            top: 4.h,
                            bottom: 4.h,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.countdownLabel.toUpperCase(),
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 10.sp,
                                  letterSpacing: 1.2,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              PrayerCountdownWidget(
                                targetTime: nextPrayerTime!,
                                baseColor: Colors.white,
                                textStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'RobotoMono',
                                ),
                                onFinished: onTimerFinished,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                // === RIGHT COLUMN (Secondary Info & Interactive) ===
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // 1. Qibla (Top Right)
                      Container(
                        margin: EdgeInsets.only(bottom: 40.h),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.15),
                          ),
                        ),
                        child: IconButton(
                          onPressed: onQiblaTap,
                          icon: Icon(
                            Icons.explore_outlined,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                          tooltip: l10n.qiblaDirection,
                          padding: EdgeInsets.all(8.r),
                          constraints: const BoxConstraints(),
                        ),
                      ),

                      // 2. Hijri Date
                      if (hijriDate != null)
                        Padding(
                          padding: EdgeInsets.only(bottom: 8.h),
                          child: Text(
                            hijriDate!,
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13.sp,
                              fontFamily: 'Amiri',
                              overflow: TextOverflow.ellipsis,
                            ),
                            maxLines: 2,
                          ),
                        ),

                      // 3. Reminder Info
                      if (_buildReminderInfo(context, l10n) != null)
                        _buildReminderInfo(context, l10n)!,
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 10.h), // Reduced bottom buffer
      ],
    );
  }

  Widget _buildLandscapeLayout(BuildContext context, AppLocalizations l10n) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Location & Qibla Row (Top)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Location
              Flexible(
                child: GestureDetector(
                  onTap: onLocationTap,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: Colors.white.withOpacity(0.15)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: Colors.white70,
                          size: 14.sp,
                        ),
                        SizedBox(width: 6.w),
                        Flexible(
                          child: Text(
                            locationName,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.edit_outlined,
                          color: Colors.white70,
                          size: 11.sp,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              // Qibla
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.15)),
                ),
                child: IconButton(
                  onPressed: onQiblaTap,
                  icon: Icon(
                    Icons.explore_outlined,
                    color: Colors.white,
                    size: 18.sp,
                  ),
                  tooltip: l10n.qiblaDirection,
                  padding: EdgeInsets.all(8.r),
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // 2. Greeting
          Text(
            l10n.prayerHeading,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12.sp,
              fontStyle: FontStyle.italic,
              fontFamily: 'Amiri',
            ),
          ),
          SizedBox(height: 4.h),

          // 3. Prayer Name & Time
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nextPrayer?['name'] ?? '-',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                  fontFamily: 'Amiri',
                  height: 1.0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 2.h),
              Text(
                nextPrayer?['time'] ?? '--:--',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w300,
                  letterSpacing: -0.3,
                  height: 1.0,
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // 4. Countdown
          if (nextPrayerTime != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.countdownLabel.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 10.sp,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PrayerCountdownWidget(
                    targetTime: nextPrayerTime!,
                    baseColor: Colors.white,
                    textStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'RobotoMono',
                    ),
                    onFinished: onTimerFinished,
                  ),
                ],
              ),
            ),

          SizedBox(height: 12.h),

          // 5. Hijri Date
          if (hijriDate != null)
            Text(
              hijriDate!,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12.sp,
                fontFamily: 'Amiri',
              ),
            ),

          // 6. Reminder Info
          if (_buildReminderInfo(context, l10n) != null)
            _buildReminderInfo(context, l10n)!,
        ],
      ),
    );
  }

  // Build Reminder Info (Fasting + Dzikir)
  Widget? _buildReminderInfo(BuildContext context, AppLocalizations l10n) {
    if (reminderData == null) return null;

    final hasFasting =
        reminderData!.hasTodayFasting || reminderData!.hasNextFasting;
    final hasDzikir = reminderData!.hasAnyActiveDzikir;

    if (!hasFasting && !hasDzikir) return null;

    return Container(
      margin: EdgeInsets.only(top: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fasting Info
          if (hasFasting) ...[
            _buildFastingInfo(context, l10n),
            if (hasDzikir) SizedBox(height: 8.h),
          ],
          // Dzikir Info
          if (hasDzikir) _buildDzikirInfo(context, l10n),
        ],
      ),
    );
  }

  Widget _buildFastingInfo(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Today's Fasting
        if (reminderData!.todayFasting != null)
          _buildFastingItem(
            context,
            l10n,
            reminderData!.todayFasting!,
            isToday: true,
          ),
        // Next Fasting
        if (reminderData!.todayFasting != null &&
            reminderData!.nextFasting != null)
          SizedBox(height: 6.h),
        if (reminderData!.nextFasting != null)
          _buildFastingItem(
            context,
            l10n,
            reminderData!.nextFasting!,
            isToday: false,
          ),
      ],
    );
  }

  Widget _buildFastingItem(
    BuildContext context,
    AppLocalizations l10n,
    FastingReminder fasting, {
    required bool isToday,
  }) {
    return Row(
      children: [
        // Icon - smaller
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: fasting.color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Icon(Icons.restaurant, color: fasting.color, size: 10.sp),
        ),
        SizedBox(width: 4.w),
        // Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isToday ? l10n.todayFasting : l10n.nextFasting,
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      fasting.event.getLocalizedName(l10n),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  // Date badge - hide in very narrow layouts
                  // Commented out to save space
                  // SizedBox(width: 4.w),
                  // Container(...),
                ],
              ),
            ],
          ),
        ),
        // Countdown - hide to save space in narrow layouts
        // if (isToday && fasting.timeUntilIftar != null) ...[...],
      ],
    );
  }

  Widget _buildDzikirInfo(BuildContext context, AppLocalizations l10n) {
    final activeDzikirs = <DzikirReminder>[];
    if (reminderData!.morningDzikir.isActiveNow) {
      activeDzikirs.add(reminderData!.morningDzikir);
    }
    if (reminderData!.eveningDzikir.isActiveNow) {
      activeDzikirs.add(reminderData!.eveningDzikir);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: activeDzikirs.map((dzikir) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: activeDzikirs.last == dzikir ? 0 : 6.h,
          ),
          child: Row(
            children: [
              // Icon - smaller
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E676).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Icon(
                  dzikir.icon,
                  color: const Color(0xFF00E676),
                  size: 10.sp,
                ),
              ),
              SizedBox(width: 4.w),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.reminderDzikir,
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    Text(
                      'Dzikir ${dzikir.displayName}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              // Active indicator - hide to save space
              // SizedBox(width: 4.w),
              // Container(...),
            ],
          ),
        );
      }).toList(),
    );
  }
}

extension on FastingEvent {
  String getLocalizedName(AppLocalizations l10n) {
    // Ideally: return l10n.fastingName(this.name);
    // Using hardcoded strings for now as requested/fallback
    switch (this) {
      case FastingEvent.monday:
        return "Senin";
      case FastingEvent.thursday:
        return "Kamis";
      case FastingEvent.ayyamulBidh:
        return "Ayyamul Bidh";
      case FastingEvent.ashura:
        return "Ashura";
      case FastingEvent.tasua:
        return "Tasua";
      case FastingEvent.arafah:
        return "Arafah";
      case FastingEvent.ramadan:
        return "Ramadhan";
      case FastingEvent.eidFitr:
        return "Idul Fitri (Haram)";
      case FastingEvent.eidAdha:
        return "Idul Adha (Haram)";
      case FastingEvent.tasyrik:
        return "Hari Tasyrik (Haram)";
      case FastingEvent.none:
        return "";
    }
  }
}

class _IslamicPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final path = Path();
    // Simple geometric pattern generation (Hexagons)
    final double hexRadius = 30.0;
    final double hexHeight = hexRadius * 1.732; // sqrt(3)
    final double hexWidth = hexRadius * 2;

    for (double y = 0; y < size.height + hexHeight; y += hexHeight * 0.75) {
      for (double x = 0; x < size.width + hexWidth; x += hexWidth) {
        _drawHexagon(
          path,
          x + ((y / (hexHeight * 0.75)).floor() % 2 == 0 ? 0 : hexWidth / 2),
          y,
          hexRadius,
        );
      }
    }
    canvas.drawPath(path, paint);
  }

  void _drawHexagon(Path path, double x, double y, double radius) {
    path.moveTo(x + radius * 0.5, y);
    path.lineTo(x + radius * 1.5, y);
    path.lineTo(x + radius * 2.0, y + radius * 0.866);
    path.lineTo(x + radius * 1.5, y + radius * 1.732);
    path.lineTo(x + radius * 0.5, y + radius * 1.732);
    path.lineTo(x, y + radius * 0.866);
    path.close();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

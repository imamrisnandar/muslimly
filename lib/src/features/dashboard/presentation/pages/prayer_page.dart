import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../prayer/presentation/bloc/prayer_bloc.dart';
import '../../../prayer/presentation/bloc/prayer_event.dart';
import '../../../prayer/presentation/bloc/prayer_state.dart';
import '../../../prayer/domain/services/fasting_service.dart';
import '../../../prayer/domain/entities/prayer_time_extension.dart';
import '../widgets/ibadah_calendar_widget.dart';
import '../widgets/prayer_countdown_widget.dart';
import '../../../../l10n/generated/app_localizations.dart';

class PrayerPage extends StatefulWidget {
  const PrayerPage({super.key});

  @override
  State<PrayerPage> createState() => _PrayerPageState();
}

class _PrayerPageState extends State<PrayerPage>
    with SingleTickerProviderStateMixin {
  late FastingService _fastingService;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _fastingService = FastingService();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.read<PrayerBloc>();
      if (bloc.state.status == PrayerStatus.initial ||
          bloc.state.prayerTime == null) {
        bloc.add(
          FetchPrayerTime(
            latitude: bloc.state.currentCity.latitude,
            longitude: bloc.state.currentCity.longitude,
            date: DateTime.now(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: BlocBuilder<PrayerBloc, PrayerState>(
          builder: (context, state) {
            return NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                final orientation = MediaQuery.of(context).orientation;
                return [
                  // 1. Prayer Header (Scrolls away)
                  SliverToBoxAdapter(child: _buildHeader(context, state)),

                  // 2. Tab Bar (Sticks to top)
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverAppBarDelegate(
                      TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(40.r),
                          color: const Color(0xFF00E676),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00E676).withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        labelColor: const Color(0xFF052025),
                        unselectedLabelColor: Colors.white70,
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: orientation == Orientation.landscape
                              ? 12.sp
                              : 14.sp,
                          fontFamily: 'Outfit',
                          letterSpacing: 0.5,
                        ),
                        unselectedLabelStyle: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: orientation == Orientation.landscape
                              ? 12.sp
                              : 14.sp,
                          fontFamily: 'Outfit',
                          letterSpacing: 0.5,
                        ),
                        splashBorderRadius: BorderRadius.circular(40.r),
                        tabs: [
                          Tab(text: AppLocalizations.of(context)!.lblSchedule),
                          Tab(text: AppLocalizations.of(context)!.lblCalendar),
                        ],
                      ),
                      isLandscape: orientation == Orientation.landscape,
                    ),
                  ),
                ];
              },
              body: TabBarView(
                controller: _tabController,
                children: [
                  _buildPrayerTab(context, state),
                  _buildCalendarTab(context),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPrayerTab(BuildContext context, PrayerState state) {
    return RefreshIndicator(
      color: const Color(0xFF00E676),
      onRefresh: () async {
        context.read<PrayerBloc>().add(
          FetchPrayerTime(
            latitude: state.currentCity.latitude,
            longitude: state.currentCity.longitude,
            date: DateTime.now(),
          ),
        );
      },
      // Using CustomScrollView to work nicely with NestedScrollView
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 100.h),
            sliver: SliverToBoxAdapter(
              child: _buildPrayerContent(context, state),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarTab(BuildContext context) {
    return RefreshIndicator(
      color: const Color(0xFF00E676),
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 100.h),
            sliver: SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C2A30),
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: IbadahCalendarWidget(fastingService: _fastingService),
              ),
            ),
          ),
        ],
      ),
    );
  }

  LinearGradient _getPrayerGradient(String prayerName) {
    switch (prayerName) {
      case 'Subuh':
      case 'Fajr':
        return const LinearGradient(
          colors: [Color(0xFF2C3E50), Color(0xFFE1B12C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'Terbit':
      case 'Sunrise':
        return const LinearGradient(
          colors: [Color(0xFFE1B12C), Color(0xFFF1C40F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'Dzuhur':
      case 'Dhuhr':
        return const LinearGradient(
          colors: [Color(0xFF2980B9), Color(0xFF6DD5FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'Ashar':
      case 'Asr':
        return const LinearGradient(
          colors: [Color(0xFF6DD5FA), Color(0xFFFF7F50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'Maghrib':
        return const LinearGradient(
          colors: [Color(0xFFFF7F50), Color(0xFF8E44AD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'Isya':
      case 'Isha':
        return const LinearGradient(
          colors: [Color(0xFF8E44AD), Color(0xFF2C3E50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'Imsak':
      default:
        return const LinearGradient(
          colors: [Color(0xFF11998e), Color(0xFF38ef7d)], // Default Green
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  Widget _buildHeader(BuildContext context, PrayerState state) {
    Map<String, dynamic>? nextPrayer;
    final l10n = AppLocalizations.of(context)!;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    if (state.prayerTime != null) {
      nextPrayer = state.prayerTime!.getNextPrayer(l10n);
    }

    // Scaling factors
    // Scaling factors - Further Reduced
    final double titleSize = isLandscape ? 10.sp : 10.sp;
    final double iconSize = isLandscape ? 60.sp : 150.sp; // Much smaller icon
    final double timeSize = isLandscape ? 18.sp : 28.sp; // Smaller time
    final double smallTimeSize = isLandscape ? 14.sp : 20.sp;
    final double padding = isLandscape ? 8.w : 24.w; // Minimal padding

    // Fasting Info Logic
    final today = DateTime.now();
    final fastingType = _fastingService.getFastingType(today);
    final fastingEvent = _fastingService.getFastingEvent(today);
    String? fastingName;

    if (fastingType == FastingType.wajib || fastingType == FastingType.sunnah) {
      switch (fastingEvent) {
        case FastingEvent.monday:
          fastingName = l10n.fastingMonday;
          break;
        case FastingEvent.thursday:
          fastingName = l10n.fastingThursday;
          break;
        case FastingEvent.ayyamulBidh:
          fastingName = l10n.fastingAyyamulBidh;
          break;
        case FastingEvent.ramadan:
          fastingName = l10n.fastingRamadan;
          break;
        case FastingEvent.arafah:
          fastingName = l10n.fastingArafah;
          break;
        case FastingEvent.ashura:
          fastingName = l10n.fastingAshura;
          break;
        case FastingEvent.tasua:
          fastingName = l10n.fastingTasua;
          break;
        default:
          fastingName = null;
      }
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: padding,
        vertical: isLandscape ? 0 : 8.h,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          gradient: _getPrayerGradient(nextPrayer?['name'] ?? ''),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: isLandscape ? -20 : -30,
              top: isLandscape ? -20 : -30,
              child: Icon(
                Icons.mosque,
                size: iconSize,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(isLandscape ? 12.w : 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              l10n.cardNextPrayer,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: titleSize,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (fastingName != null) ...[
                            SizedBox(height: 8.h),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: fastingType == FastingType.wajib
                                    ? const Color(0xFFFFC107).withOpacity(0.9)
                                    : const Color(0xFF00E676).withOpacity(0.9),
                                borderRadius: BorderRadius.circular(20.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.event,
                                    color: Colors.white,
                                    size: titleSize,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    fastingName,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: titleSize,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.white70,
                              size: titleSize + 2,
                            ),
                            SizedBox(width: 4.w),
                            Flexible(
                              child: Text(
                                state.currentCity.name,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: titleSize + 2,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => _showCitySearchDialog(context),
                              icon: Icon(
                                Icons.edit_location_alt,
                                color: Colors.white70,
                                size: isLandscape ? 16.sp : 20.sp,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              style: IconButton.styleFrom(
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            IconButton(
                              onPressed: () => context.push('/qibla'),
                              icon: Icon(
                                Icons.explore,
                                color: const Color(0xFFFFC107),
                                size: isLandscape ? 16.sp : 20.sp,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              style: IconButton.styleFrom(
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        _getLocalizedName(l10n, nextPrayer?['name'] ?? '-'),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: timeSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        nextPrayer?['time'] ?? '--:--',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: smallTimeSize,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: PrayerCountdownWidget(
                        targetTime:
                            nextPrayer?['nextPrayerTime'] as DateTime? ??
                            DateTime.now(),
                        baseColor: const Color(0xFF00E676),
                        onFinished: () {
                          context.read<PrayerBloc>().add(
                            FetchPrayerTime(
                              latitude: state.currentCity.latitude,
                              longitude: state.currentCity.longitude,
                              date: DateTime.now(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerContent(BuildContext context, PrayerState state) {
    final l10n = AppLocalizations.of(context)!;

    if ((state.status == PrayerStatus.loading ||
            state.status == PrayerStatus.initial) &&
        state.prayerTime == null) {
      return Center(
        child: CircularProgressIndicator(color: Theme.of(context).primaryColor),
      );
    } else if (state.status == PrayerStatus.failure &&
        state.prayerTime == null) {
      return Center(
        child: Text(
          "Error: ${state.errorMessage}",
          style: const TextStyle(color: Colors.red),
        ),
      );
    } else if (state.prayerTime != null) {
      final t = state.prayerTime!;

      String getPrayerName(String key) {
        switch (key) {
          case 'Imsak':
            return l10n.prayerImsak;
          case 'Subuh':
            return l10n.prayerFajr;
          case 'Terbit':
            return l10n.prayerSunrise;
          case 'Dzuhur':
            return l10n.prayerDhuhr;
          case 'Ashar':
            return l10n.prayerAsr;
          case 'Maghrib':
            return l10n.prayerMaghrib;
          case 'Isya':
            return l10n.prayerIsha;
          default:
            return key;
        }
      }

      final nextPrayerMap = t.getNextPrayer(l10n);
      final nextPrayerName = nextPrayerMap['name'];

      final prayers = [
        {'key': 'Imsak', 'arabic': 'إمساك', 'time': t.imsak},
        {'key': 'Subuh', 'arabic': 'الفجر', 'time': t.subuh},
        {'key': 'Terbit', 'arabic': 'الشروق', 'time': t.terbit},
        {'key': 'Dzuhur', 'arabic': 'الظهر', 'time': t.dzuhur},
        {'key': 'Ashar', 'arabic': 'العصر', 'time': t.ashar},
        {'key': 'Maghrib', 'arabic': 'المغرب', 'time': t.maghrib},
        {'key': 'Isya', 'arabic': 'العشاء', 'time': t.isya},
      ];

      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: prayers.map((p) {
          final key = p['key']!;
          final isHighlighted = nextPrayerMap['name'] == key;
          final displayName = getPrayerName(key);

          return _buildPrayerCard(context, p, key, displayName, isHighlighted);
        }).toList(),
      );
    }
    return Center(
      child: Text(
        "Unknown State:\nStatus: ${state.status}\nData: ${state.prayerTime}",
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.red),
      ),
    );
  }

  Widget _buildPrayerCard(
    BuildContext context,
    Map<String, String> prayer,
    String key,
    String displayName,
    bool isHighlighted,
  ) {
    final currentSetting =
        context.read<PrayerBloc>().state.notificationSettings[key] ?? 'adhan';

    IconData getNotificationIcon() {
      // Imsak and Terbit are always beep
      if (key == 'Imsak' || key == 'Terbit') {
        return Icons.notifications_none;
      }

      switch (currentSetting) {
        case 'silent':
          return Icons.notifications_off;
        case 'beep':
          return Icons.notifications_none;
        case 'adhan':
        default:
          return Icons.notifications_active;
      }
    }

    // Prayer-specific icons
    IconData getPrayerIcon() {
      switch (key) {
        case 'Fajr':
        case 'Subuh':
          return Icons.wb_twilight; // Dawn
        case 'Terbit':
          return Icons.wb_sunny; // Sunrise
        case 'Dzuhur':
        case 'Dhuhr':
          return Icons.wb_sunny; // Noon sun
        case 'Ashar':
        case 'Asr':
          return Icons.wb_cloudy; // Afternoon
        case 'Maghrib':
          return Icons.wb_twilight; // Sunset
        case 'Isya':
        case 'Isha':
          return Icons.nightlight_round; // Night
        case 'Imsak':
        default:
          return Icons.access_time; // Default clock
      }
    }

    final gradient = _getPrayerGradient(key);

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: InkWell(
        onTap: (key == 'Imsak' || key == 'Terbit')
            ? null
            : () => _showNotificationSettings(
                context,
                displayName,
                key,
                currentSetting,
              ),
        borderRadius: BorderRadius.circular(14.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            gradient: isHighlighted
                ? gradient
                : LinearGradient(
                    colors: [
                      const Color(0xFF1C2A30),
                      const Color(0xFF1C2A30).withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: isHighlighted
                  ? Colors.white.withOpacity(0.4)
                  : const Color(0xFF00E676).withOpacity(0.15),
              width: isHighlighted ? 1.5 : 1,
            ),
            boxShadow: isHighlighted
                ? [
                    BoxShadow(
                      color: gradient.colors.last.withOpacity(0.5),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                      spreadRadius: 1,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            children: [
              // Left: Prayer Icon + Name
              Expanded(
                child: Row(
                  children: [
                    // Prayer Icon with glow effect
                    Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        gradient: isHighlighted
                            ? LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.3),
                                  Colors.white.withOpacity(0.15),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : LinearGradient(
                                colors: [
                                  const Color(0xFF00E676).withOpacity(0.25),
                                  const Color(0xFF00E676).withOpacity(0.1),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        borderRadius: BorderRadius.circular(8.r),
                        boxShadow: isHighlighted
                            ? [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: const Color(
                                    0xFF00E676,
                                  ).withOpacity(0.3),
                                  blurRadius: 6,
                                  spreadRadius: 0.5,
                                ),
                              ],
                      ),
                      child: Icon(
                        getPrayerIcon(),
                        color: isHighlighted
                            ? Colors.white
                            : const Color(0xFF00E676),
                        size: 18.sp,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    // Prayer Name & Arabic
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                              shadows: isHighlighted
                                  ? [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 4,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            prayer['arabic']!,
                            style: TextStyle(
                              color: isHighlighted
                                  ? Colors.white.withOpacity(0.85)
                                  : Colors.white.withOpacity(0.6),
                              fontSize: 11.sp,
                              fontFamily: 'Amiri',
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              // Right: Time + Notification Icon
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Time with gradient background
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      gradient: isHighlighted
                          ? LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.25),
                                Colors.white.withOpacity(0.15),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            )
                          : LinearGradient(
                              colors: [
                                Colors.black.withOpacity(0.3),
                                Colors.black.withOpacity(0.2),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                      borderRadius: BorderRadius.circular(6.r),
                      border: Border.all(
                        color: isHighlighted
                            ? Colors.white.withOpacity(0.2)
                            : Colors.white.withOpacity(0.05),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      prayer['time']!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        shadows: isHighlighted
                            ? [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 4,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  // Notification Icon with subtle background
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: isHighlighted
                          ? Colors.white.withOpacity(0.15)
                          : const Color(0xFF00E676).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      getNotificationIcon(),
                      color: isHighlighted
                          ? Colors.white.withOpacity(0.85)
                          : const Color(0xFF00E676),
                      size: 14.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotificationSettings(
    BuildContext context,
    String displayName,
    String prayerKey,
    String currentSetting,
  ) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C2A30), // Dark Theme
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.prayerNotificationTitle(displayName),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.h),
                _buildSettingOption(
                  ctx,
                  title: l10n.notificationSoundAdhan,
                  isSelected: currentSetting == 'adhan',
                  onTap: () {
                    context.read<PrayerBloc>().add(
                      UpdateNotificationSetting(
                        prayerName: prayerKey,
                        soundType: 'adhan',
                      ),
                    );
                    Navigator.pop(ctx);
                  },
                  icon: Icons.notifications_active,
                ),
                _buildSettingOption(
                  ctx,
                  title: l10n.notificationSoundBeep,
                  isSelected: currentSetting == 'beep',
                  onTap: () {
                    context.read<PrayerBloc>().add(
                      UpdateNotificationSetting(
                        prayerName: prayerKey,
                        soundType: 'beep',
                      ),
                    );
                    Navigator.pop(ctx);
                  },
                  icon: Icons.notifications_none,
                ),
                _buildSettingOption(
                  ctx,
                  title: l10n.notificationSoundSilent,
                  isSelected: currentSetting == 'silent',
                  onTap: () {
                    context.read<PrayerBloc>().add(
                      UpdateNotificationSetting(
                        prayerName: prayerKey,
                        soundType: 'silent',
                      ),
                    );
                    Navigator.pop(ctx);
                  },
                  icon: Icons.notifications_off,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingOption(
    BuildContext context, {
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? const Color(0xFF00E676) : Colors.white70,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? const Color(0xFF00E676) : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Color(0xFF00E676))
          : null,
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _showCitySearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return BlocProvider.value(
          value: context.read<PrayerBloc>(),
          child: const _CitySearchDialog(),
        );
      },
    );
  }

  String _getLocalizedName(AppLocalizations l10n, String key) {
    switch (key) {
      case 'Imsak':
        return l10n.prayerImsak;
      case 'Subuh':
        return l10n.prayerFajr;
      case 'Terbit':
        return l10n.prayerSunrise;
      case 'Dzuhur':
        return l10n.prayerDhuhr;
      case 'Ashar':
        return l10n.prayerAsr;
      case 'Maghrib':
        return l10n.prayerMaghrib;
      case 'Isya':
        return l10n.prayerIsha;
      default:
        return key;
    }
  }
}

class _CitySearchDialog extends StatefulWidget {
  const _CitySearchDialog();

  @override
  State<_CitySearchDialog> createState() => __CitySearchDialogState();
}

class __CitySearchDialogState extends State<_CitySearchDialog> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  List<String> _recentSearches = [];
  static const String _recentSearchesKey = 'recent_city_searches';
  static const int _maxRecentSearches = 5;

  @override
  void initState() {
    super.initState();
    // Add listener for auto-search on type
    _controller.addListener(_onSearchChanged);
    // Load recent searches
    _loadRecentSearches();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.removeListener(_onSearchChanged);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final searches = prefs.getStringList(_recentSearchesKey) ?? [];
    if (mounted) {
      setState(() {
        _recentSearches = searches;
      });
    }
  }

  Future<void> _saveRecentSearch(String cityName) async {
    final prefs = await SharedPreferences.getInstance();

    // Remove if already exists (to move to top)
    _recentSearches.remove(cityName);

    // Add to beginning
    _recentSearches.insert(0, cityName);

    // Keep only last N searches
    if (_recentSearches.length > _maxRecentSearches) {
      _recentSearches = _recentSearches.sublist(0, _maxRecentSearches);
    }

    // Save to SharedPreferences
    await prefs.setStringList(_recentSearchesKey, _recentSearches);

    if (mounted) {
      setState(() {});
    }
  }

  void _onSearchChanged() {
    // Cancel previous timer
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    final query = _controller.text.trim();

    // Only search if query is not empty
    if (query.isEmpty) return;

    // Start new timer (500ms debounce)
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.read<PrayerBloc>().add(SearchCityEvent(query));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      backgroundColor: const Color(
        0xFF1E2F36,
      ), // Dark Blue-Gray (matches Settings)
      title: Row(
        children: [
          Expanded(
            child: Text(
              l10n.searchCityTitle,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Current Location Button
          IconButton(
            onPressed: () {
              context.read<PrayerBloc>().add(FetchPrayerTimeByLocation());
              Navigator.pop(context);
            },
            icon: const Icon(Icons.my_location),
            color: const Color(0xFF00E676),
            tooltip: l10n.useCurrentLocation,
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFF00E676).withOpacity(0.1),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: l10n.searchCityHint,
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white54),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF00E676)),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final query = _controller.text.trim();
                if (query.isNotEmpty) {
                  context.read<PrayerBloc>().add(SearchCityEvent(query));
                }
              },
              child: const Text("Search"),
            ),
            SizedBox(height: 16.h),
            // Search Results List
            Flexible(
              child: BlocBuilder<PrayerBloc, PrayerState>(
                builder: (context, state) {
                  if (state.isSearching) {
                    return SizedBox(
                      height: 100.h,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF00E676),
                        ),
                      ),
                    );
                  }
                  if (state.searchResults.isNotEmpty) {
                    return SizedBox(
                      height: 200.h,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: state.searchResults.length,
                        itemBuilder: (context, index) {
                          final city = state.searchResults[index];
                          return ListTile(
                            leading: const Icon(
                              Icons.location_on,
                              color: Color(0xFF00E676),
                            ),
                            title: Text(
                              city.name,
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              "${city.latitude.toStringAsFixed(4)}, ${city.longitude.toStringAsFixed(4)}",
                              style: const TextStyle(color: Colors.white54),
                            ),
                            onTap: () async {
                              // Save to recent searches
                              await _saveRecentSearch(city.name);
                              // Select city
                              if (mounted) {
                                context.read<PrayerBloc>().add(
                                  SelectCity(city),
                                );
                                Navigator.pop(context);
                              }
                            },
                          );
                        },
                      ),
                    );
                  } else if (!state.isSearching &&
                      _controller.text.isNotEmpty) {
                    // Better Empty State
                    return _buildEmptyState();
                  }
                  // Initial State or show recent searches
                  return _buildInitialStateWithRecent();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_off, size: 48.sp, color: Colors.white38),
          SizedBox(height: 12.h),
          Text(
            l10n.locationNotFound,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            l10n.trySearchingWith,
            style: TextStyle(fontSize: 13.sp, color: Colors.white54),
          ),
          SizedBox(height: 8.h),
          _buildSuggestionItem(l10n.searchSuggestionCity),
          _buildSuggestionItem(l10n.searchSuggestionDistrict),
          _buildSuggestionItem(l10n.searchSuggestionAddress),
        ],
      ),
    );
  }

  Widget _buildInitialStateWithRecent() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search, size: 40.sp, color: Colors.white24),
          SizedBox(height: 12.h),
          Text(
            l10n.searchForLocation,
            style: TextStyle(fontSize: 14.sp, color: Colors.white54),
          ),

          // Recent Searches Section
          if (_recentSearches.isNotEmpty) ...[
            SizedBox(height: 16.h),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Recent Searches:",
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white38,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: _recentSearches
                  .map((city) => _buildRecentSearchChip(city))
                  .toList(),
            ),
          ],

          // Popular Cities Section
          SizedBox(height: 12.h),
          Text(
            l10n.popularCities,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.white38,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _buildQuickSearchChip("Jakarta"),
              _buildQuickSearchChip("Bandung"),
              _buildQuickSearchChip("Surabaya"),
              _buildQuickSearchChip("Yogyakarta"),
              _buildQuickSearchChip("Medan"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearchChip(String cityName) {
    return InkWell(
      onTap: () {
        _controller.text = cityName;
        context.read<PrayerBloc>().add(SearchCityEvent(cityName));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: const Color(0xFF00E676).withOpacity(0.15),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFF00E676).withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, size: 14.sp, color: const Color(0xFF00E676)),
            SizedBox(width: 4.w),
            Text(
              cityName,
              style: TextStyle(fontSize: 12.sp, color: const Color(0xFF00E676)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionItem(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.arrow_right, size: 16.sp, color: const Color(0xFF00E676)),
          SizedBox(width: 4.w),
          Text(
            text,
            style: TextStyle(fontSize: 12.sp, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSearchChip(String cityName) {
    return InkWell(
      onTap: () {
        _controller.text = cityName;
        context.read<PrayerBloc>().add(SearchCityEvent(cityName));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Text(
          cityName,
          style: TextStyle(fontSize: 12.sp, color: Colors.white70),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar, {required this.isLandscape});

  final TabBar _tabBar;
  final bool isLandscape;

  @override
  double get minExtent {
    // Landscape: tighter fit. Portrait: more padding.
    final padding = isLandscape ? 26.h : 24.h;
    return _tabBar.preferredSize.height + padding;
  }

  @override
  double get maxExtent => minExtent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Colors.transparent,
      // Adjust container padding based on orientation
      padding: EdgeInsets.symmetric(
        horizontal: isLandscape ? 100.w : 24.w, // Center it more in landscape
        vertical: isLandscape ? 4.h : 8.h,
      ),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(50.r),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: _tabBar,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return oldDelegate.isLandscape != isLandscape ||
        oldDelegate._tabBar != _tabBar;
  }
}

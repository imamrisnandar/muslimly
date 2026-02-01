import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

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
            return Column(
              children: [
                _buildHeader(context, state),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(50.r),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: TabBar(
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
                      fontSize: 15.sp,
                      fontFamily: 'Outfit',
                      letterSpacing: 0.5,
                    ),
                    unselectedLabelStyle: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15.sp,
                      fontFamily: 'Outfit',
                      letterSpacing: 0.5,
                    ),
                    splashBorderRadius: BorderRadius.circular(40.r),
                    tabs: const [
                      Tab(text: "Jadwal"),
                      Tab(text: "Kalender"),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Tab 1: Prayer List
                      RefreshIndicator(
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
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 100.h),
                          child: _buildPrayerContent(context, state),
                        ),
                      ),
                      // Tab 2: Calendar
                      RefreshIndicator(
                        color: const Color(0xFF00E676),
                        onRefresh: () async {
                          // Calendar might not need refresh but consistency is good
                          await Future.delayed(
                            const Duration(milliseconds: 500),
                          );
                        },
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 100.h),
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
                              border: Border.all(
                                color: Colors.white.withOpacity(0.05),
                              ),
                            ),
                            child: IbadahCalendarWidget(
                              fastingService: _fastingService,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
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

    // Fasting Info Logic
    final today = DateTime.now();
    final fastingType = _fastingService.getFastingType(today);
    final fastingEvent = _fastingService.getFastingEvent(today);
    String? fastingName;

    if (fastingType == FastingType.wajib || fastingType == FastingType.sunnah) {
      // Simple local mapping or reuse if possible. For now, manual map to basic keys
      // ideally we use a shared helper, but inline for now to save time
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
      padding: EdgeInsets.all(isLandscape ? 16.w : 24.w),
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
              right: -30,
              top: -30,
              child: Icon(
                Icons.mosque,
                size: isLandscape ? 100.sp : 150.sp,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(isLandscape ? 16.w : 24.w),
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
                                fontSize: 10.sp,
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
                                    size: 12.sp,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    fastingName,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.sp,
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
                              size: 12.sp,
                            ),
                            SizedBox(width: 4.w),
                            Flexible(
                              child: Text(
                                state.currentCity.name,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => _showCitySearchDialog(context),
                              icon: Icon(
                                Icons.edit_location_alt,
                                color: Colors.white70,
                                size: 20.sp,
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
                                size: 20.sp,
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
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        nextPrayer?['time'] ?? '--:--',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 20.sp,
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
          final displayName = getPrayerName(key);
          final isNext = key == nextPrayerName;
          return _buildPrayerItem(context, p, displayName, isNext);
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

  Widget _buildPrayerItem(
    BuildContext context,
    Map<String, String> prayer,
    String displayName,
    bool isHighlighted,
  ) {
    final blocState = context.read<PrayerBloc>().state;
    final key = prayer['key']!;

    String currentSetting = blocState.notificationSettings[key] ?? 'adhan';
    if (key == 'Imsak' || key == 'Terbit') {
      currentSetting = 'beep';
    }

    IconData getIcon() {
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

    final gradient = _getPrayerGradient(key);

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: InkWell(
        onTap: (key == 'Imsak' || key == 'Terbit')
            ? null
            : () => _showNotificationSettings(
                context,
                displayName,
                key,
                currentSetting,
              ),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            gradient: isHighlighted
                ? gradient
                : null, // No gradient if not highlighted
            color: isHighlighted
                ? null
                : const Color(0xFF1C2A30), // Dark Card for unlighted
            borderRadius: BorderRadius.circular(16.r),
            border: isHighlighted
                ? Border.all(
                    color: gradient.colors.last.withOpacity(0.8),
                    width: 1.5,
                  )
                : Border.all(color: const Color(0xFF4E342E).withOpacity(0.1)),
            boxShadow: isHighlighted
                ? [
                    BoxShadow(
                      color: gradient.colors.last.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (isHighlighted)
                    Container(
                      width: 4.w,
                      height: 24.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  SizedBox(width: isHighlighted ? 12.w : 0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: TextStyle(
                          color: isHighlighted ? Colors.white : Colors.white,
                          fontSize: 14.sp,
                          fontWeight: isHighlighted
                              ? FontWeight.bold
                              : FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    prayer['arabic']!,
                    style: TextStyle(
                      color: isHighlighted ? Colors.white70 : Colors.white54,
                      fontSize: 12.sp,
                      fontFamily: 'Amiri',
                      height: 1.5,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    prayer['time']!,
                    style: TextStyle(
                      color: isHighlighted ? Colors.white : Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(
                    getIcon(),
                    color: isHighlighted
                        ? Colors.white70
                        : const Color(0xFF00E676),
                    size: 20.sp,
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
      backgroundColor: Colors.white, // Light
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.prayerNotificationTitle(displayName),
                style: TextStyle(
                  color: const Color(0xFF4E342E),
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
        color: isSelected
            ? const Color(0xFF00E676)
            : const Color(0xFF4E342E).withOpacity(0.5),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? const Color(0xFF00E676) : const Color(0xFF4E342E),
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text(
        l10n.searchCityTitle,
        style: const TextStyle(
          color: Color(0xFF4E342E),
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              style: const TextStyle(color: Color(0xFF4E342E)),
              decoration: InputDecoration(
                hintText: l10n.searchCityHint,
                hintStyle: const TextStyle(color: Colors.grey),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF1B5E20)),
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
                    return const SizedBox(
                      height: 50,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF1B5E20),
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
                            title: Text(
                              city.name,
                              style: const TextStyle(color: Color(0xFF4E342E)),
                            ),
                            subtitle: Text(
                              "${city.latitude}, ${city.longitude}",
                              style: const TextStyle(color: Colors.grey),
                            ),
                            onTap: () {
                              context.read<PrayerBloc>().add(
                                FetchPrayerTime(
                                  latitude: city.latitude,
                                  longitude: city.longitude,
                                  date: DateTime.now(),
                                ),
                              );
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    );
                  } else if (!state.isSearching &&
                      _controller.text.isNotEmpty) {
                    return const Text(
                      "No cities found",
                      style: TextStyle(color: Colors.grey),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
import '../widgets/prayer_header_widget.dart';
import '../widgets/prayer_card_widget.dart';
import 'package:hijri/hijri_calendar.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/services/reminder_service.dart';
import '../../domain/models/reminder_models.dart';
import '../../../../core/di/di_container.dart';

class PrayerPage extends StatefulWidget {
  const PrayerPage({super.key});

  @override
  State<PrayerPage> createState() => _PrayerPageState();
}

class _PrayerPageState extends State<PrayerPage>
    with SingleTickerProviderStateMixin {
  late FastingService _fastingService;
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

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
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C2A30), // Dark Theme
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isLandscape = constraints.maxWidth > constraints.maxHeight;
          if (isLandscape) {
            return _buildLandscapeLayout(context);
          }
          return _buildPortraitLayout(context);
        },
      ),
    );
  }

  // PORTRAIT LAYOUT: NestedScrollView with Immersive Header
  Widget _buildPortraitLayout(BuildContext context) {
    return BlocBuilder<PrayerBloc, PrayerState>(
      builder: (context, state) {
        final l10n = AppLocalizations.of(context)!;
        Map<String, dynamic>? nextPrayer;
        if (state.prayerTime != null) {
          nextPrayer = state.prayerTime!.getNextPrayer(l10n);
        }

        // Get reminder data
        ReminderCardData? reminderData;
        if (state.prayerTime != null) {
          final reminderService = getIt<ReminderService>();
          reminderData = reminderService.getReminderData(
            state.prayerTime!,
            DateTime.now(),
          );
        }

        return NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              // Immersive Header
              SliverAppBar(
                expandedHeight: 340.h, // Increased from 280.h to fix overflow
                pinned: true,
                backgroundColor: const Color(0xFF1C2A30),
                flexibleSpace: FlexibleSpaceBar(
                  background: PrayerHeaderWidget(
                    nextPrayer: nextPrayer,
                    locationName: state.currentCity.name,
                    hijriDate: _getFormattedHijriDate(l10n),
                    nextPrayerTime: nextPrayer?['nextPrayerTime'] as DateTime?,
                    onLocationTap: () => _showCitySearchDialog(context),
                    onQiblaTap: () => context.push('/qibla'),
                    reminderData: reminderData,
                    onTimerFinished: () {
                      context.read<PrayerBloc>().add(
                        FetchPrayerTime(
                          latitude: state.currentCity.latitude,
                          longitude: state.currentCity.longitude,
                          date: DateTime.now(),
                        ),
                      );
                    },
                    currentFasting: state.currentFasting,
                    nextFasting: state.nextFasting,
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(60.h),
                  child: Container(
                    height: 60.h,
                    alignment: Alignment.center,
                    child: _buildFloatingTabBar(context),
                  ),
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
    );
  }

  Widget _buildLandscapeLayout(BuildContext context) {
    return BlocBuilder<PrayerBloc, PrayerState>(
      builder: (context, state) {
        final l10n = AppLocalizations.of(context)!;
        Map<String, dynamic>? nextPrayer;
        if (state.prayerTime != null) {
          nextPrayer = state.prayerTime!.getNextPrayer(l10n);
        }

        // Get reminder data
        ReminderCardData? reminderData;
        if (state.prayerTime != null) {
          final reminderService = getIt<ReminderService>();
          reminderData = reminderService.getReminderData(
            state.prayerTime!,
            DateTime.now(),
          );
        }

        return Row(
          children: [
            // Left Panel: Header (Fixed)
            Expanded(
              flex: 4,
              child: PrayerHeaderWidget(
                nextPrayer: nextPrayer,
                locationName: state.currentCity.name,
                hijriDate: _getFormattedHijriDate(l10n),
                nextPrayerTime: nextPrayer?['nextPrayerTime'] as DateTime?,
                onLocationTap: () => _showCitySearchDialog(context),
                onQiblaTap: () => context.push('/qibla'),
                reminderData: reminderData,
                onTimerFinished: () {
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
            // Right Panel: Content (Tabs + List)
            Expanded(
              flex: 6,
              child: Column(
                children: [
                  SizedBox(height: 16.h),
                  _buildFloatingTabBar(context),
                  SizedBox(height: 16.h),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildPrayerTab(context, state),
                        _buildCalendarTab(context),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFloatingTabBar(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: const Color(0xFF00E676),
          borderRadius: BorderRadius.circular(26.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00E676).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: const Color(0xFF052025),
        unselectedLabelColor: Colors.white70,
        labelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14.sp,
          fontFamily: 'Outfit',
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14.sp,
          fontFamily: 'Outfit',
        ),
        tabs: [
          Tab(text: AppLocalizations.of(context)!.lblSchedule),
          Tab(text: AppLocalizations.of(context)!.lblCalendar),
        ],
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
      child: ListView(
        padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 100.h),
        children: [_buildPrayerContent(context, state)],
      ),
    );
  }

  Widget _buildCalendarTab(BuildContext context) {
    return RefreshIndicator(
      color: const Color(0xFF00E676),
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView(
        padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 100.h),
        children: [IbadahCalendarWidget(fastingService: _fastingService)],
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
        children: prayers.map((p) {
          final key = p['key']!;

          bool isNext = false;
          if (nextPrayerMap['nextPrayerTime'] != null) {
            isNext =
                key == nextPrayerMap['name'] ||
                getPrayerName(key) == nextPrayerMap['name'];
          }

          return PrayerCardWidget(
            name: getPrayerName(key),
            arabicName: p['arabic']!,
            time: p['time']!,
            isCurrent: isNext,
            isNext: isNext,
            icon: _getPrayerIcon(key),
            onTap: () =>
                _showNotificationSettings(context, getPrayerName(key), key),
            notificationStatus: (key == 'Imsak' || key == 'Terbit')
                ? (state.notificationSettings[key] == 'silent'
                      ? 'silent'
                      : 'beep')
                : (state.notificationSettings[key] ?? 'adhan'),
            onNotificationTap: () {
              if (key == 'Imsak' || key == 'Terbit') return;
              _showNotificationSettings(context, getPrayerName(key), key);
            },
          );
        }).toList(),
      );
    }
    return const SizedBox.shrink();
  }

  IconData _getPrayerIcon(String key) {
    switch (key) {
      case 'Fajr':
      case 'Subuh':
        return Icons.wb_twilight;
      case 'Terbit':
        return Icons.wb_sunny;
      case 'Dzuhur':
      case 'Dhuhr':
        return Icons.wb_sunny;
      case 'Ashar':
      case 'Asr':
        return Icons.wb_cloudy;
      case 'Maghrib':
        return Icons.wb_twilight;
      case 'Isya':
      case 'Isha':
        return Icons.nightlight_round;
      case 'Imsak':
      default:
        return Icons.access_time;
    }
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

  // Restore Notification Settings Dialog
  void _showNotificationSettings(
    BuildContext context,
    String displayName,
    String prayerKey,
  ) {
    if (prayerKey == 'Imsak' || prayerKey == 'Terbit')
      return; // No notification for these

    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C2A30),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) {
        final currentSetting =
            context.read<PrayerBloc>().state.notificationSettings[prayerKey] ??
            'adhan';
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

  String _getFormattedHijriDate(AppLocalizations l10n) {
    final hDate = HijriCalendar.now();
    // Example: "14 Ramadan 1446 H"
    return "${hDate.hDay} ${hDate.longMonthName} ${hDate.hYear} H";
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

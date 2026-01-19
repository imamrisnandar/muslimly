import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../prayer/presentation/bloc/prayer_bloc.dart';
import '../../../prayer/presentation/bloc/prayer_event.dart';
import '../../../prayer/presentation/bloc/prayer_state.dart';
import '../../../prayer/domain/entities/prayer_time_extension.dart'; // Ext Impt
import '../../../../l10n/generated/app_localizations.dart';

class PrayerPage extends StatelessWidget {
  const PrayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    // BlocProvider is now in DashboardPage
    return const _PrayerPageView();
  }
}

class _PrayerPageView extends StatelessWidget {
  const _PrayerPageView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: BlocBuilder<PrayerBloc, PrayerState>(
          builder: (context, state) {
            return RefreshIndicator(
              color: const Color(0xFF00E676),
              onRefresh: () async {
                context.read<PrayerBloc>().add(
                  FetchPrayerTime(
                    cityId: state.currentCity.id,
                    date: DateTime.now(),
                  ),
                );
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  // HEADER
                  SliverToBoxAdapter(child: _buildHeader(context, state)),
                  // PRAYER LIST
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 100.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF101820),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30.r),
                          topRight: Radius.circular(30.r),
                        ),
                      ),
                      child: _buildContent(context, state),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, PrayerState state) {
    Map<String, dynamic>? nextPrayer;
    final l10n = AppLocalizations.of(context)!;

    if (state.prayerTime != null) {
      nextPrayer = state.prayerTime!.getNextPrayer(l10n);
    }

    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Container(
        height: 180.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          gradient: const LinearGradient(
            colors: [Color(0xFF2C5364), Color(0xFF203A43)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
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
                Icons.location_on,
                size: 150.sp,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.currentCity.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            state.prayerTime?.date ?? l10n.loading,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14.sp,
                            ),
                          ),
                          Text(
                            state.prayerTime != null
                                ? state.prayerTime!.getHijriDate()
                                : "-",
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => _showCitySearchDialog(context),
                        icon: const Icon(
                          Icons.edit_location_alt,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Upcoming Prayer Info
                  if (nextPrayer != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.upcomingPrayer,
                              style: TextStyle(
                                color: const Color(0xFF00E676),
                                fontSize: 12.sp,
                              ),
                            ),
                            Text(
                              _getLocalizedName(l10n, nextPrayer['name']),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              nextPrayer['time'],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              nextPrayer['timeLeft'],
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  else
                    Text(
                      l10n.prayerSchedule,
                      style: TextStyle(
                        color: const Color(0xFF00E676),
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
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

  Widget _buildContent(BuildContext context, PrayerState state) {
    final l10n = AppLocalizations.of(context)!;

    if (state.status == PrayerStatus.loading && state.prayerTime == null) {
      return const Center(child: CircularProgressIndicator());
    } else if (state.status == PrayerStatus.failure &&
        state.prayerTime == null) {
      return Center(
        child: Text(
          "Error: ${state.errorMessage}",
          style: const TextStyle(color: Colors.white),
        ),
      );
    } else if (state.prayerTime != null) {
      final t = state.prayerTime!;

      // Helper to map keys
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

      // We rely on the API keys 'Subuh', 'Dzuhur' etc to match logic,
      // but display localized name.
      final nextPrayerMap = t.getNextPrayer(l10n);
      final nextPrayerName =
          nextPrayerMap['name']; // This is localized from getNextPrayer

      final prayers = [
        {'key': 'Imsak', 'arabic': 'إمساك', 'time': t.imsak},
        {'key': 'Subuh', 'arabic': 'الفجر', 'time': t.subuh},
        {'key': 'Terbit', 'arabic': 'الشروق', 'time': t.terbit},
        {'key': 'Dzuhur', 'arabic': 'الظهر', 'time': t.dzuhur},
        {'key': 'Ashar', 'arabic': 'العصر', 'time': t.ashar},
        {'key': 'Maghrib', 'arabic': 'المغرب', 'time': t.maghrib},
        {'key': 'Isya', 'arabic': 'العشاء', 'time': t.isya},
      ];

      return Padding(
        padding: EdgeInsets.only(bottom: 24.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: prayers.map((p) {
            final key = p['key']!;
            final displayName = getPrayerName(key);
            // Extension returns key (e.g. 'Subuh') in 'name' field
            final isNext = key == nextPrayerName;
            return _buildPrayerItem(context, p, displayName, isNext);
          }).toList(),
        ),
      );
    }
    return const SizedBox();
  }

  // ... (Gradient helper unchanged)
  LinearGradient _getPrayerGradient(String prayerKey) {
    switch (prayerKey) {
      case 'Subuh':
        return const LinearGradient(
          colors: [Color(0xFF2C3E50), Color(0xFFE1B12C)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );
      case 'Terbit':
        return const LinearGradient(
          colors: [Color(0xFFE1B12C), Color(0xFFF1C40F)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );
      case 'Dzuhur':
        return const LinearGradient(
          colors: [Color(0xFF2980B9), Color(0xFF6DD5FA)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );
      case 'Ashar':
        return const LinearGradient(
          colors: [Color(0xFF6DD5FA), Color(0xFFFF7F50)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );
      case 'Maghrib':
        return const LinearGradient(
          colors: [Color(0xFFFF7F50), Color(0xFF8E44AD)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );
      case 'Isya':
        return const LinearGradient(
          colors: [Color(0xFF8E44AD), Color(0xFF2C3E50)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFF2C3E50), Color(0xFF4CA1AF)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );
    }
  }

  Widget _buildPrayerItem(
    BuildContext context,
    Map<String, String> prayer,
    String displayName,
    bool isHighlighted,
  ) {
    final blocState = context.read<PrayerBloc>().state;
    // Key is internal api key e.g 'Subuh'
    final key = prayer['key']!;
    final currentSetting = blocState.notificationSettings[key] ?? 'adhan';

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

    return InkWell(
      onTap: () =>
          _showNotificationSettings(context, displayName, key, currentSetting),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          gradient: isHighlighted
              ? gradient
              : LinearGradient(
                  colors: [
                    gradient.colors.first.withOpacity(0.2),
                    gradient.colors.last.withOpacity(0.2),
                  ],
                  begin: gradient.begin,
                  end: gradient.end,
                ),
          borderRadius: BorderRadius.circular(16.r),
          border: isHighlighted
              ? Border.all(
                  color: gradient.colors.last.withOpacity(0.8),
                  width: 1.5,
                )
              : Border.all(color: Colors.white10),
          boxShadow: isHighlighted
              ? [
                  BoxShadow(
                    color: gradient.colors.last.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
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
                        color: Colors.white,
                        fontSize: 16.sp,
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
                    color: Colors.white70,
                    fontSize: 14.sp,
                    fontFamily: 'Amiri',
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  prayer['time']!,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(getIcon(), color: Colors.white70, size: 20.sp),
              ],
            ),
          ],
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
      backgroundColor: const Color(0xFF1E272E),
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      backgroundColor: const Color(0xFF1E272E),
      title: Text(
        l10n.searchCityTitle,
        style: const TextStyle(color: Colors.white),
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
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
              ),
              onSubmitted: (val) {
                if (val.isNotEmpty) {
                  context.read<PrayerBloc>().add(SearchCityEvent(val));
                }
              },
            ),
            SizedBox(height: 16.h),
            Flexible(
              child: BlocBuilder<PrayerBloc, PrayerState>(
                builder: (context, state) {
                  if (state.isSearching) {
                    return const LinearProgressIndicator();
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
                              style: const TextStyle(color: Colors.white),
                            ),
                            onTap: () {
                              context.read<PrayerBloc>().add(SelectCity(city));
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.close),
        ),
      ],
    );
  }
}

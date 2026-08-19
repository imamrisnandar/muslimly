import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../prayer/presentation/bloc/prayer_bloc.dart';
import '../../../prayer/presentation/bloc/prayer_event.dart';
import '../../../prayer/presentation/bloc/prayer_state.dart';
import '../../../../core/theme/app_colors.dart';

class CitySearchDialog extends StatefulWidget {
  const CitySearchDialog({super.key});

  @override
  State<CitySearchDialog> createState() => _CitySearchDialogState();
}

class _CitySearchDialogState extends State<CitySearchDialog> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  List<String> _recentSearches = [];
  static const String _recentSearchesKey = 'recent_city_searches';
  static const int _maxRecentSearches = 5;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onSearchChanged);
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
    _recentSearches.remove(cityName);
    _recentSearches.insert(0, cityName);
    if (_recentSearches.length > _maxRecentSearches) {
      _recentSearches = _recentSearches.sublist(0, _maxRecentSearches);
    }
    await prefs.setStringList(_recentSearchesKey, _recentSearches);
    if (mounted) {
      setState(() {});
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    final query = _controller.text.trim();
    if (query.isEmpty) return;
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
      backgroundColor: AppColors.cardDarker,
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
          IconButton(
            onPressed: () {
              context.read<PrayerBloc>().add(FetchPrayerTimeByLocation());
              Navigator.pop(context);
            },
            icon: const Icon(Icons.my_location),
            color: AppColors.accent,
            tooltip: l10n.useCurrentLocation,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.accent.withValues(alpha: 0.1),
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
                  borderSide: BorderSide(color: AppColors.accent),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.quranGreen,
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
            Flexible(
              child: BlocBuilder<PrayerBloc, PrayerState>(
                builder: (context, state) {
                  if (state.isSearching) {
                    return SizedBox(
                      height: 100.h,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.accent,
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
                              color: AppColors.accent,
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
                              await _saveRecentSearch(city.name);
                              // context belongs to the bottom sheet, so check
                              // its own mounted flag, not the State's
                              if (context.mounted) {
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
                    return _buildEmptyState();
                  }
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
          color: AppColors.accent.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, size: 14.sp, color: AppColors.accent),
            SizedBox(width: 4.w),
            Text(
              cityName,
              style: TextStyle(fontSize: 12.sp, color: AppColors.accent),
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
          Icon(Icons.arrow_right, size: 16.sp, color: AppColors.accent),
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
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Text(
          cityName,
          style: TextStyle(fontSize: 12.sp, color: Colors.white70),
        ),
      ),
    );
  }
}

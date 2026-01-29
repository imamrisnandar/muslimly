import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/surah_names.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../core/utils/quran_constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/quran_bloc.dart';
import '../bloc/quran_state.dart';

import 'package:muslimly/src/core/di/di_container.dart';
import 'package:muslimly/src/features/quran/domain/repositories/quran_repository.dart';

class QuranNavigationBottomSheet extends StatefulWidget {
  const QuranNavigationBottomSheet({super.key});

  @override
  State<QuranNavigationBottomSheet> createState() =>
      _QuranNavigationBottomSheetState();
}

class _QuranNavigationBottomSheetState extends State<QuranNavigationBottomSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      height: 0.85.sh,
      decoration: BoxDecoration(
        color: const Color(0xFF121212), // Deep Black/Grey
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Handle & Title
          SizedBox(height: 12.h),
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 12.h),

          // Title
          Text(
            l10n.quranNavigationTitle, // Localized Title
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              fontFamily: "Outfit",
            ),
          ),
          SizedBox(height: 16.h),

          // Tab Bar with Pill Indicator
          Container(
            height: 48.h,
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.white60,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: const Color(0xFF00E676), // Brand Green
                borderRadius: BorderRadius.circular(24.r),
              ),
              labelStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
                fontFamily: "Outfit",
              ),
              dividerColor: Colors.transparent,
              tabs: [
                Tab(text: l10n.navPage),
                Tab(text: l10n.navJuz),
                Tab(text: l10n.navSurah),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_PageTab(), _JuzTab(), _SurahTab()],
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// TAB 1: Page Navigation (Polished)
// -----------------------------------------------------------------------------
class _PageTab extends StatefulWidget {
  @override
  State<_PageTab> createState() => _PageTabState();
}

class _PageTabState extends State<_PageTab> {
  double _currentPage = 1;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '1');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToPage() {
    int page = int.tryParse(_controller.text) ?? 1;
    if (page < 1) page = 1;
    if (page > 604) page = 604;

    context.pop();
    context.push('/mushaf', extra: {'pageNumber': page});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            l10n.hintEnterPage,
            style: TextStyle(color: Colors.white54, fontSize: 16.sp),
          ),
          SizedBox(height: 32.h),

          // Large Page Number Display
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: const Color(0xFF00E676), width: 2.h),
              ),
            ),
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF00E676),
                fontSize: 72.sp,
                fontWeight: FontWeight.bold,
                height: 1.0,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "1",
                hintStyle: TextStyle(
                  color: Colors.white12,
                  fontSize: 72.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onChanged: (val) {
                final n = double.tryParse(val);
                if (n != null && n >= 1 && n <= 604) {
                  setState(() {
                    _currentPage = n;
                  });
                }
              },
              onSubmitted: (_) => _navigateToPage(),
            ),
          ),

          SizedBox(height: 48.h),

          // Custom Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 8.h,
              activeTrackColor: const Color(0xFF00E676),
              inactiveTrackColor: Colors.white12,
              thumbColor: Colors.white,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.r),
              overlayColor: const Color(0xFF00E676).withOpacity(0.2),
            ),
            child: Slider(
              value: _currentPage,
              min: 1,
              max: 604,
              onChanged: (val) {
                setState(() {
                  _currentPage = val;
                  _controller.text = val.round().toString();
                });
              },
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "1",
                style: TextStyle(color: Colors.white30, fontSize: 12.sp),
              ),
              Text(
                "604",
                style: TextStyle(color: Colors.white30, fontSize: 12.sp),
              ),
            ],
          ),

          const Spacer(),

          // Go Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _navigateToPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E676),
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 18.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                elevation: 0,
              ),
              child: Text(
                l10n.goButton,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// TAB 2: Juz Navigation (Polished)
// -----------------------------------------------------------------------------
class _JuzTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: 30,
      itemBuilder: (context, index) {
        final juzNumber = index + 1;
        final startPage = QuranConstants.juzPageStart[juzNumber] ?? 1;

        final hizb1Number = (juzNumber * 2) - 1;
        final hizb2Number = juzNumber * 2;
        final hizb2Page = startPage + 10;

        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 4.h,
              ),
              iconColor: const Color(0xFF00E676),
              collapsedIconColor: Colors.white30,
              title: Row(
                children: [
                  Container(
                    width: 36.w,
                    height: 36.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E676).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      "$juzNumber",
                      style: TextStyle(
                        color: const Color(0xFF00E676),
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Text(
                    "${l10n.navJuz} $juzNumber",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              subtitle: Padding(
                padding: EdgeInsets.only(left: 52.w),
                child: Text(
                  "${l10n.navPage} $startPage",
                  style: TextStyle(color: Colors.white30, fontSize: 13.sp),
                ),
              ),
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                  child: Column(
                    children: [
                      // Start of Juz
                      _buildJuzItem(
                        context,
                        l10n.startOfJuz(juzNumber),
                        startPage,
                        isHighlight: true,
                      ),
                      Divider(
                        color: Colors.white.withOpacity(0.05),
                        height: 16.h,
                      ),

                      // Rub' 1 (Approx start + 2.5 pages) -> Page + 3
                      _buildJuzItem(context, "${l10n.rub} 1", startPage + 3),
                      Divider(
                        color: Colors.white.withOpacity(0.05),
                        height: 16.h,
                      ),

                      // Rub' 2 (Approx start + 5 pages) -> Page + 5
                      _buildJuzItem(context, "${l10n.rub} 2", startPage + 5),
                      Divider(
                        color: Colors.white.withOpacity(0.05),
                        height: 16.h,
                      ),

                      // Rub' 3 (Approx start + 7.5 pages) -> Page + 8
                      _buildJuzItem(context, "${l10n.rub} 3", startPage + 8),
                      Divider(
                        color: Colors.white.withOpacity(0.05),
                        height: 16.h,
                      ),

                      // Hizb 2 (Rub 4) -> start + 10
                      _buildJuzItem(
                        context,
                        "${l10n.hizb} $hizb2Number (Rub 4)",
                        hizb2Page,
                        isHighlight: true,
                      ),
                      Divider(
                        color: Colors.white.withOpacity(0.05),
                        height: 16.h,
                      ),

                      // Rub' 5 (Hizb 2 + 2.5) -> start + 13
                      _buildJuzItem(context, "${l10n.rub} 5", startPage + 13),
                      Divider(
                        color: Colors.white.withOpacity(0.05),
                        height: 16.h,
                      ),

                      // Rub' 6 (Hizb 2 + 5) -> start + 15
                      _buildJuzItem(context, "${l10n.rub} 6", startPage + 15),
                      Divider(
                        color: Colors.white.withOpacity(0.05),
                        height: 16.h,
                      ),

                      // Rub' 7 (Hizb 2 + 7.5) -> start + 18
                      _buildJuzItem(context, "${l10n.rub} 7", startPage + 18),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildJuzItem(
    BuildContext context,
    String title,
    int page, {
    bool isHighlight = false,
  }) {
    return InkWell(
      onTap: () {
        context.pop();
        context.push('/mushaf', extra: {'pageNumber': page});
      },
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(color: Colors.white70, fontSize: 14.sp),
            ),
            Row(
              children: [
                Text(
                  "${AppLocalizations.of(context)!.navPage} $page",
                  style: TextStyle(color: Colors.white30, fontSize: 12.sp),
                ),
                SizedBox(width: 8.w),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white12,
                  size: 12.sp,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// TAB 3: Surah Navigation (Polished)
// -----------------------------------------------------------------------------
class _SurahTab extends StatefulWidget {
  @override
  State<_SurahTab> createState() => _SurahTabState();
}

class _SurahTabState extends State<_SurahTab> {
  int? _selectedSurah;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    if (_selectedSurah != null) {
      return _buildAyahGrid();
    }
    return _buildSurahList();
  }

  Widget _buildSurahList() {
    final l10n = AppLocalizations.of(context)!;
    final quranState = context.read<QuranBloc>().state;
    List surahs = [];
    if (quranState is QuranSurahsLoaded) {
      surahs = quranState.surahs;
    }

    // Filter
    final filtered = surahs.where((s) {
      final q = _searchQuery.toLowerCase();
      return s.englishName.toLowerCase().contains(q) ||
          s.number.toString().contains(q);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: TextField(
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: l10n.searchSurahHint,
              hintStyle: const TextStyle(color: Colors.white30),
              prefixIcon: const Icon(Icons.search, color: Colors.white30),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              contentPadding: EdgeInsets.symmetric(vertical: 12.h),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => SizedBox(height: 8.h),
            itemBuilder: (context, index) {
              final surah = filtered[index];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 4.h,
                  ),
                  leading: Container(
                    width: 36.w,
                    height: 36.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(
                        0xFF00E676,
                      ).withOpacity(0.1), // Unified Green
                    ),
                    child: Text(
                      '${surah.number}',
                      style: TextStyle(
                        color: const Color(0xFF00E676), // Unified Green Text
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp, // Unified Size
                      ),
                    ),
                  ),
                  title: Text(
                    surah.englishName,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                    ),
                  ),
                  subtitle: Text(
                    l10n.surahAyahs(surah.numberOfAyahs),
                    style: TextStyle(color: Colors.white30, fontSize: 12.sp),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: Colors.white30,
                  ),
                  onTap: () {
                    setState(() {
                      _selectedSurah = surah.number;
                    });
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAyahGrid() {
    final l10n = AppLocalizations.of(context)!;
    final surahNumber = _selectedSurah!;
    final totalAyahs = QuranConstants.surahAyahCounts[surahNumber] ?? 7;
    // Assuming simple English lookup for now, can be improved
    final englishName = SurahNames.englishNames[surahNumber - 1];

    return Column(
      children: [
        // Header with Back
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => setState(() => _selectedSurah = null),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.1),
                  padding: EdgeInsets.all(8.w),
                ),
              ),
              SizedBox(width: 16.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$englishName",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    l10n.selectAyah,
                    style: TextStyle(color: Colors.white54, fontSize: 12.sp),
                  ),
                ],
              ),
            ],
          ),
        ),
        Divider(color: Colors.white10, height: 1.h),

        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.all(16.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              childAspectRatio: 1.0,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
            ),
            itemCount: totalAyahs,
            itemBuilder: (context, index) {
              final ayahNum = index + 1;
              return InkWell(
                onTap: () async {
                  final quranRepo = getIt<QuranRepository>();
                  final page = await quranRepo.getPageForAyah(
                    surahNumber,
                    ayahNum,
                  );

                  if (context.mounted) {
                    context.pop();
                    context.push(
                      '/mushaf',
                      extra: {
                        'pageNumber': page,
                        'surahNumber': surahNumber,
                        'ayahNumber': ayahNum,
                      },
                    );
                  }
                },
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.white10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$ayahNum',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

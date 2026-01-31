import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/surah_names.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../core/di/di_container.dart';

import '../../domain/entities/reciter.dart';
import '../bloc/quran_bloc.dart';
import '../bloc/quran_event.dart';
import '../bloc/quran_state.dart';
import '../bloc/audio_bloc.dart';
import '../bloc/audio_event.dart';
import '../widgets/reciter_selector_bottom_sheet.dart';
import '../widgets/quran_navigation_bottom_sheet.dart';

import '../../../../core/presentation/widgets/premium_showcase.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuranPage extends StatefulWidget {
  final bool isVisible;
  const QuranPage({super.key, this.isVisible = false});

  @override
  State<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final GlobalKey _searchKey = GlobalKey();
  final GlobalKey _bookmarksKey = GlobalKey();
  final GlobalKey _surahItemKey = GlobalKey();
  final GlobalKey _playButtonKey = GlobalKey();
  final GlobalKey _navigationKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(QuranPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      // We rely on BlocBuilder/Listener to trigger showcase
      // when the widget becomes visible and state is loaded.
      setState(() {}); // Trigger rebuild to hit the builder check
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      builder: (context) {
        return BlocProvider(
          create: (context) => getIt<QuranBloc>()..add(QuranFetchSurahs()),
          child: BlocConsumer<QuranBloc, QuranState>(
            listener: (context, state) {
              if (widget.isVisible &&
                  state is QuranSurahsLoaded &&
                  state.surahs.isNotEmpty) {
                _checkAndShowShowcase(context);
              }
            },
            builder: (context, state) {
              // Fallback: If state is already loaded, listener might miss it.
              if (widget.isVisible &&
                  state is QuranSurahsLoaded &&
                  state.surahs.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _checkAndShowShowcase(context);
                });
              }
              return Scaffold(
                backgroundColor: Colors.transparent,
                body: Stack(
                  children: [
                    SafeArea(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header & Search
                          Padding(
                            padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 8.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!.quranTitle,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    // Global Navigation Button
                                    PremiumShowcase(
                                      globalKey: _navigationKey,
                                      title: "Navigation", // Todo: Localize
                                      description: AppLocalizations.of(
                                        context,
                                      )!.showcaseQuranNavigation,
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.grid_view_rounded,
                                          color: Colors.white,
                                        ),
                                        tooltip: 'Smart Jump',
                                        onPressed: () {
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            backgroundColor: Colors.transparent,
                                            builder: (_) => BlocProvider.value(
                                              value: context.read<QuranBloc>(),
                                              child:
                                                  const QuranNavigationBottomSheet(),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    PremiumShowcase(
                                      globalKey: _bookmarksKey,
                                      title: 'Bookmarks',
                                      description: AppLocalizations.of(
                                        context,
                                      )!.showcaseQuranBookmarks,
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.bookmarks_outlined,
                                          color: Colors.white,
                                        ),
                                        onPressed: () =>
                                            context.push('/quran/bookmarks'),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16.h),
                                // Search Bar
                                PremiumShowcase(
                                  globalKey: _searchKey,
                                  title: 'Search',
                                  description: AppLocalizations.of(
                                    context,
                                  )!.showcaseQuranSearch,
                                  child: TextField(
                                    controller: _searchController,
                                    style: const TextStyle(color: Colors.white),
                                    onChanged: (value) {
                                      setState(() {
                                        _searchQuery = value;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white.withOpacity(0.05),
                                      hintText: AppLocalizations.of(
                                        context,
                                      )!.searchSurahHint,
                                      hintStyle: const TextStyle(
                                        color: Colors.white54,
                                      ),
                                      prefixIcon: const Icon(
                                        Icons.search,
                                        color: Colors.white54,
                                      ),
                                      suffixIcon: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (_searchQuery.isNotEmpty)
                                            IconButton(
                                              icon: const Icon(
                                                Icons.clear,
                                                color: Colors.white54,
                                              ),
                                              onPressed: () {
                                                _searchController.clear();
                                                setState(() {
                                                  _searchQuery = '';
                                                });
                                              },
                                            ),
                                          IconButton(
                                            onPressed: () {
                                              final audioBloc = context
                                                  .read<AudioBloc>();
                                              showModalBottomSheet(
                                                context: context,
                                                backgroundColor:
                                                    Colors.transparent,
                                                isScrollControlled: true,
                                                builder: (_) => BlocProvider.value(
                                                  value: audioBloc,
                                                  child:
                                                      const ReciterSelectorBottomSheet(
                                                        filterSource:
                                                            AudioSourceType
                                                                .quranComChapter,
                                                      ),
                                                ),
                                              );
                                            },
                                            icon: Icon(
                                              Icons.headphones,
                                              color: const Color(0xFF00E676),
                                              size: 24.sp,
                                            ),
                                            tooltip: 'Pilih Qori',
                                          ),
                                          SizedBox(width: 8.w),
                                        ],
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: BlocBuilder<QuranBloc, QuranState>(
                              builder: (context, state) {
                                if (state is QuranLoading) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                } else if (state is QuranError) {
                                  return Center(
                                    child: Text(
                                      state.message,
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  );
                                } else if (state is QuranSurahsLoaded) {
                                  final filteredSurahs = state.surahs.where((
                                    surah,
                                  ) {
                                    if (_searchQuery.isEmpty) return true;
                                    final query = _searchQuery.toLowerCase();
                                    final locale = Localizations.localeOf(
                                      context,
                                    ).languageCode;
                                    final localizedName = SurahNames.getName(
                                      surah.number,
                                      locale,
                                      surah.englishName,
                                    ).toLowerCase();
                                    final englishName = surah.englishName
                                        .toLowerCase();
                                    final arabicName = surah.name;
                                    final number = surah.number.toString();
                                    return localizedName.contains(query) ||
                                        englishName.contains(query) ||
                                        arabicName.contains(query) ||
                                        number.contains(query);
                                  }).toList();

                                  // Remove the early exit. We handle empty surahs inside ListView to show the button.
                                  if (filteredSurahs.isEmpty &&
                                      _searchQuery.isEmpty) {
                                    return Center(
                                      child: Text(
                                        "No Surahs found",
                                        style: TextStyle(color: Colors.white54),
                                      ),
                                    );
                                  }

                                  return ListView.separated(
                                    padding: EdgeInsets.fromLTRB(
                                      24.w,
                                      8.h,
                                      24.w,
                                      100.h,
                                    ),
                                    itemCount:
                                        filteredSurahs.length +
                                        (_searchQuery.isNotEmpty ? 1 : 0),
                                    separatorBuilder: (context, index) =>
                                        Divider(
                                          color: Colors.white.withOpacity(0.05),
                                        ),
                                    itemBuilder: (context, index) {
                                      if (_searchQuery.isNotEmpty) {
                                        if (index == 0) {
                                          return InkWell(
                                            onTap: () {
                                              context.push(
                                                Uri(
                                                  path: '/search',
                                                  queryParameters: {
                                                    'q': _searchQuery,
                                                  },
                                                ).toString(),
                                              );
                                            },
                                            borderRadius: BorderRadius.circular(
                                              12.r,
                                            ),
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                vertical: 16.h,
                                                horizontal: 16.w,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(
                                                  0xFF00E676,
                                                ).withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(12.r),
                                                border: Border.all(
                                                  color: const Color(
                                                    0xFF00E676,
                                                  ).withOpacity(0.3),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.search,
                                                    color: const Color(
                                                      0xFF00E676,
                                                    ),
                                                    size: 24.sp,
                                                  ),
                                                  SizedBox(width: 16.w),
                                                  Expanded(
                                                    child: Text(
                                                      AppLocalizations.of(
                                                        context,
                                                      )!.searchInAyahs(
                                                        _searchQuery,
                                                      ),
                                                      style: TextStyle(
                                                        color: const Color(
                                                          0xFF00E676,
                                                        ),
                                                        fontSize: 16.sp,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                  Icon(
                                                    Icons.arrow_forward_ios,
                                                    color: const Color(
                                                      0xFF00E676,
                                                    ),
                                                    size: 16.sp,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }
                                        index =
                                            index -
                                            1; // Adjust index for surahs
                                      }

                                      final surah = filteredSurahs[index];
                                      final isFirst = index == 0;
                                      Widget item = InkWell(
                                        onTap: () {
                                          _showReadingModeDialog(
                                            context,
                                            surah,
                                          );
                                        },
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 12.h,
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 36.w,
                                                height: 36.w,
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.05),
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: const Color(
                                                      0xFF00E676,
                                                    ),
                                                    width: 1.5,
                                                  ),
                                                ),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  '${surah.number}',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12.sp,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 16.w),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Flexible(
                                                          child: Text(
                                                            SurahNames
                                                                .indonesianNames[surah
                                                                    .number -
                                                                1],
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 16.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                        SizedBox(width: 8.w),
                                                        Container(
                                                          padding:
                                                              EdgeInsets.symmetric(
                                                                horizontal: 6.w,
                                                                vertical: 2.h,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color: Colors.white
                                                                .withOpacity(
                                                                  0.1,
                                                                ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  4.r,
                                                                ),
                                                          ),
                                                          child: Text(
                                                            surah
                                                                .revelationType,
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .white70,
                                                              fontSize: 10.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 4.h),
                                                    Text(
                                                      '${Localizations.localeOf(context).languageCode == 'id' ? surah.indonesianNameTranslation : surah.englishNameTranslation} • ${AppLocalizations.of(context)!.versesCount(surah.numberOfAyahs)}',
                                                      style: TextStyle(
                                                        color: Colors.white54,
                                                        fontSize: 12.sp,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Text(
                                                surah.name,
                                                style: TextStyle(
                                                  color: const Color(
                                                    0xFF00E676,
                                                  ),
                                                  fontSize: 20.sp,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'Amiri',
                                                ),
                                              ),
                                              SizedBox(width: 12.w),
                                              isFirst
                                                  ? PremiumShowcase(
                                                      globalKey: _playButtonKey,
                                                      title: 'Play Audio',
                                                      description:
                                                          AppLocalizations.of(
                                                            context,
                                                          )!.showcaseQuranPlay,
                                                      child: IconButton(
                                                        onPressed: () {
                                                          context
                                                              .read<AudioBloc>()
                                                              .add(
                                                                PlaySurah(
                                                                  surahId: surah
                                                                      .number,
                                                                  surahName: surah
                                                                      .englishName,
                                                                ),
                                                              );
                                                        },
                                                        icon: const Icon(
                                                          Icons
                                                              .play_circle_outline,
                                                          color: Color(
                                                            0xFF00E676,
                                                          ),
                                                        ),
                                                        padding:
                                                            EdgeInsets.zero,
                                                        constraints:
                                                            const BoxConstraints(),
                                                      ),
                                                    )
                                                  : IconButton(
                                                      onPressed: () {
                                                        context
                                                            .read<AudioBloc>()
                                                            .add(
                                                              PlaySurah(
                                                                surahId: surah
                                                                    .number,
                                                                surahName: surah
                                                                    .englishName,
                                                              ),
                                                            );
                                                      },
                                                      icon: const Icon(
                                                        Icons
                                                            .play_circle_outline,
                                                        color: Color(
                                                          0xFF00E676,
                                                        ),
                                                      ),
                                                      padding: EdgeInsets.zero,
                                                      constraints:
                                                          const BoxConstraints(),
                                                    ),
                                            ],
                                          ),
                                        ),
                                      );
                                      return isFirst
                                          ? PremiumShowcase(
                                              globalKey: _surahItemKey,
                                              title: 'Read Surah',
                                              description: AppLocalizations.of(
                                                context,
                                              )!.showcaseQuranItem,
                                              child: item,
                                            )
                                          : item;
                                    },
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showReadingModeDialog(BuildContext context, dynamic surah) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow full height for landscape
      backgroundColor: const Color(0xFF0F2027),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.all(24.w),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.readingModeTitle,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 24.h),
              _buildModeTile(
                context,
                icon: Icons.list,
                title: AppLocalizations.of(context)!.modeListTitle,
                subtitle: AppLocalizations.of(context)!.modeListSubtitle,
                onTap: () {
                  context.pop(); // Close sheet
                  context.push('/quran/${surah.number}', extra: surah);
                },
              ),
              SizedBox(height: 16.h),
              _buildModeTile(
                context,
                icon: Icons.menu_book,
                title: AppLocalizations.of(context)!.modeMushafTitle,
                subtitle: AppLocalizations.of(context)!.modeMushafSubtitle,
                onTap: () {
                  context.pop(); // Close sheet
                  context.push('/quran/mushaf/${surah.number}', extra: surah);
                },
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF00E676), size: 28.sp),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.white54, fontSize: 12.sp),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white24,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkAndShowShowcase(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final hasShown = prefs.getBool('hasShownQuranListShowcase') ?? false;

    if (hasShown) return;

    // Retry logic: Try up to 3 times to find the keys
    int attempts = 0;
    while (attempts < 3) {
      if (!context.mounted) return;

      // Wait increasing duration (500ms, 1000ms, 1500ms)
      await Future.delayed(Duration(milliseconds: 500 * (attempts + 1)));

      if (context.mounted) {
        try {
          ShowCaseWidget.of(context).startShowCase([
            _searchKey,
            _navigationKey,
            _bookmarksKey,
            _surahItemKey,
            _playButtonKey,
          ]);
          await prefs.setBool('hasShownQuranListShowcase', true);
          return; // Success, exit
        } catch (e) {
          // Ignore error and retry
        }
      }
      attempts++;
    }
  }
}

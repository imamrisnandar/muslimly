import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/surah_names.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../core/di/di_container.dart';
import '../../domain/entities/surah.dart';
import '../../domain/entities/reciter.dart';
import '../bloc/quran_bloc.dart';
import '../bloc/quran_event.dart';
import '../bloc/quran_state.dart';
import '../bloc/audio_bloc.dart';
import '../bloc/audio_event.dart';
import '../bloc/audio_state.dart';
import '../widgets/reciter_selector_bottom_sheet.dart';
import '../widgets/draggable_audio_player.dart';
import 'package:showcaseview/showcaseview.dart';
import '../../../../features/settings/data/repositories/settings_repository.dart';

class QuranPage extends StatefulWidget {
  const QuranPage({super.key});

  @override
  State<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final GlobalKey _dragKey = GlobalKey();
  final GlobalKey _qoriKey = GlobalKey();
  bool _showcaseChecked = false;

  void _checkAndStartShowcase(BuildContext context) async {
    if (_showcaseChecked) return;
    _showcaseChecked = true;

    final settings = getIt<SettingsRepository>();
    if (!await settings.hasShownPlayerShowcase()) {
      if (context.mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await Future.delayed(const Duration(milliseconds: 500));
          if (context.mounted) {
            ShowCaseWidget.of(context).startShowCase([_dragKey, _qoriKey]);
            await settings.setPlayerShowcaseShown(true);
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<QuranBloc>()..add(QuranFetchSurahs()),
      child: ShowCaseWidget(
        builder: (context) {
          return BlocListener<AudioBloc, AudioState>(
            listener: (context, state) {
              if (state.status == AudioStatus.playing) {
                _checkAndStartShowcase(context);
              }
            },
            child: Scaffold(
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
                                  IconButton(
                                    icon: const Icon(
                                      Icons.bookmarks_outlined,
                                      color: Colors.white,
                                    ),
                                    onPressed: () =>
                                        context.push('/quran/bookmarks'),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16.h),
                              // Search Bar
                              TextField(
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
                                            backgroundColor: Colors.transparent,
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
                                    borderRadius: BorderRadius.circular(12.r),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
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
                                // Filter Logic
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
                                  final arabicName = surah
                                      .name; // Arabic comparison might be tricky without normalization
                                  final number = surah.number.toString();

                                  return localizedName.contains(query) ||
                                      englishName.contains(query) ||
                                      arabicName.contains(query) ||
                                      number.contains(query);
                                }).toList();

                                if (filteredSurahs.isEmpty) {
                                  return Center(
                                    child: Text(
                                      "Not found",
                                      style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: 16.sp,
                                      ),
                                    ),
                                  );
                                }

                                return ListView.separated(
                                  padding: EdgeInsets.fromLTRB(
                                    24.w,
                                    8.h,
                                    24.w,
                                    100.h,
                                  ), // Added bottom padding
                                  itemCount: filteredSurahs.length,
                                  separatorBuilder: (context, index) => Divider(
                                    color: Colors.white.withOpacity(0.05),
                                  ),
                                  itemBuilder: (context, index) {
                                    final surah = filteredSurahs[index];

                                    return InkWell(
                                      onTap: () {
                                        _showReadingModeDialog(context, surah);
                                      },
                                      borderRadius: BorderRadius.circular(12.r),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 12.h,
                                        ),
                                        child: Row(
                                          children: [
                                            // Surah Number Badge
                                            Container(
                                              width: 36.w,
                                              height: 36.w,
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(
                                                  0.05,
                                                ),
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
                                                      Text(
                                                        SurahNames
                                                            .indonesianNames[surah
                                                                .number -
                                                            1],
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16.sp,
                                                          fontWeight:
                                                              FontWeight.w600,
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
                                                              .withOpacity(0.1),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                4.r,
                                                              ),
                                                        ),
                                                        child: Text(
                                                          surah.revelationType,
                                                          style: TextStyle(
                                                            color:
                                                                Colors.white70,
                                                            fontSize: 10.sp,
                                                            fontWeight:
                                                                FontWeight.w500,
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
                                              surah.name, // Arabic Name
                                              style: TextStyle(
                                                color: const Color(
                                                  0xFF00E676,
                                                ), // Accent Green
                                                fontSize: 20.sp,
                                                fontWeight: FontWeight.bold,
                                                fontFamily:
                                                    'Amiri', // Assuming Font
                                              ),
                                            ),
                                            SizedBox(width: 12.w),
                                            IconButton(
                                              onPressed: () {
                                                context.read<AudioBloc>().add(
                                                  PlaySurah(
                                                    surahId: surah.number,
                                                    surahName:
                                                        surah.englishName,
                                                  ),
                                                );
                                              },
                                              icon: const Icon(
                                                Icons.play_circle_outline,
                                                color: Color(0xFF00E676),
                                              ),
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
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
                  DraggableAudioPlayer(
                    dragShowcaseKey: _dragKey,
                    qoriShowcaseKey: _qoriKey,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showReadingModeDialog(BuildContext context, dynamic surah) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F2027),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.all(24.w),
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
}

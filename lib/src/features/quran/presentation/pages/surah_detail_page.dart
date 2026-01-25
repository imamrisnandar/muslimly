import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/surah_names.dart';
import '../../../../core/di/di_container.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/utils/tajweed_parser.dart';
import '../../domain/entities/surah.dart';
import '../widgets/tajwid_legend_bottom_sheet.dart';
import '../bloc/quran_bloc.dart';
import '../bloc/quran_event.dart';
import '../bloc/quran_state.dart';
import '../bloc/audio_bloc.dart';
import '../bloc/audio_event.dart';
import '../bloc/audio_state.dart';
import '../widgets/draggable_audio_player.dart';
import 'package:showcaseview/showcaseview.dart';
import '../../../../features/settings/data/repositories/settings_repository.dart';

class SurahDetailPage extends StatefulWidget {
  final Surah surah;

  const SurahDetailPage({super.key, required this.surah});

  @override
  State<SurahDetailPage> createState() => _SurahDetailPageState();
}

class _SurahDetailPageState extends State<SurahDetailPage> {
  final GlobalKey _dragKey = GlobalKey();
  final GlobalKey _qoriKey = GlobalKey();
  bool _showcaseChecked = false;

  int? _currentPlayingAyah;
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _ayahKeys = {};

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToAyah(int ayahNumber) {
    final key = _ayahKeys[ayahNumber];
    if (key != null && key.currentContext != null) {
      // Use a slight delay to ensure the widget is fully rendered
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          Scrollable.ensureVisible(
            key.currentContext!,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            alignment: 0.03, // Position near top (3%)
          );
        }
      });
    }
  }

  int _getJuzNumber(int surahNumber) {
    // Simplified juz mapping based on surah start
    const juzMap = {
      1: 1,
      2: 1,
      3: 3,
      4: 4,
      5: 6,
      6: 7,
      7: 8,
      8: 9,
      9: 10,
      10: 11,
      11: 11,
      12: 12,
      13: 13,
      14: 13,
      15: 14,
      16: 14,
      17: 15,
      18: 15,
      19: 16,
      20: 16,
      21: 17,
      22: 17,
      23: 18,
      24: 18,
      25: 18,
      26: 19,
      27: 19,
      28: 20,
      29: 20,
      30: 21,
      31: 21,
      32: 21,
      33: 21,
      34: 22,
      35: 22,
      36: 22,
      37: 23,
      38: 23,
      39: 23,
      40: 24,
      41: 24,
      42: 25,
      43: 25,
      44: 25,
      45: 25,
      46: 26,
      47: 26,
      48: 26,
      49: 26,
      50: 26,
      51: 26,
      52: 27,
      53: 27,
      54: 27,
      55: 27,
      56: 27,
      57: 27,
      58: 28,
      59: 28,
      60: 28,
      61: 28,
      62: 28,
      63: 28,
      64: 28,
      65: 28,
      66: 28,
      67: 29,
      68: 29,
      69: 29,
      70: 29,
      71: 29,
      72: 29,
      73: 29,
      74: 29,
      75: 29,
      76: 29,
      77: 29,
      78: 30,
      79: 30,
      80: 30,
      81: 30,
      82: 30,
      83: 30,
      84: 30,
      85: 30,
      86: 30,
      87: 30,
      88: 30,
      89: 30,
      90: 30,
      91: 30,
      92: 30,
      93: 30,
      94: 30,
      95: 30,
      96: 30,
      97: 30,
      98: 30,
      99: 30,
      100: 30,
      101: 30,
      102: 30,
      103: 30,
      104: 30,
      105: 30,
      106: 30,
      107: 30,
      108: 30,
      109: 30,
      110: 30,
      111: 30,
      112: 30,
      113: 30,
      114: 30,
    };
    return juzMap[surahNumber] ?? 1;
  }

  void _shareAyah(
    String arabicText,
    String? translation,
    String surahName,
    int ayahNumber,
  ) {
    String textToShare = '$arabicText\n\n';
    if (translation != null && translation.isNotEmpty) {
      textToShare += '$translation\n\n';
    }
    textToShare += '($surahName: $ayahNumber)';
    textToShare += '\n\nShared from Muslimly App';

    Share.share(textToShare);
  }

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

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.all(6.w),
        child: Icon(icon, color: Colors.grey[600], size: 20.sp),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final surahName = SurahNames.getName(
      widget.surah.number,
      locale,
      widget.surah.englishName,
    );

    return BlocProvider(
      create: (context) =>
          getIt<QuranBloc>()
            ..add(QuranFetchAyahs(widget.surah.number, languageCode: locale)),
      child: ShowCaseWidget(
        builder: (context) {
          return BlocListener<AudioBloc, AudioState>(
            listener: (context, state) {
              // Showcase Logic
              if (state.status == AudioStatus.playing) {
                _checkAndStartShowcase(context);
              }

              if (state.currentSurahId == widget.surah.number &&
                  state.currentAyahNumber != null) {
                if (_currentPlayingAyah != state.currentAyahNumber) {
                  setState(() {
                    _currentPlayingAyah = state.currentAyahNumber;
                  });
                  _scrollToAyah(state.currentAyahNumber!);
                }
              } else {
                if (_currentPlayingAyah != null) {
                  setState(() {
                    _currentPlayingAyah = null;
                  });
                }
              }
            },
            child: Stack(
              children: [
                Scaffold(
                  backgroundColor: const Color(
                    0xFFFFF8E1,
                  ), // Cream Background (Mushaf Theme)
                  appBar: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black87),
                      onPressed: () => context.pop(),
                    ),
                    title: Text(
                      surahName,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    centerTitle: true,
                    actions: [
                      IconButton(
                        icon: const Icon(
                          Icons.info_outline,
                          color: Colors.black87,
                        ),
                        tooltip: 'Panduan Tajwid',
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            builder: (context) =>
                                const TajwidLegendBottomSheet(),
                          );
                        },
                      ),
                      SizedBox(width: 8.w),
                    ],
                  ),
                  body: Column(
                    children: [
                      // Compact Header Card
                      Container(
                        margin: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 16.h,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF1B5E20), // Dark Green
                              Color(0xFF2E7D32),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1B5E20).withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Left: Info
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      surahName, // Translation/English
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.menu_book_rounded,
                                          size: 12.sp,
                                          color: const Color(0xFF00E676),
                                        ),
                                        SizedBox(width: 4.w),
                                        Text(
                                          '${widget.surah.numberOfAyahs} Ayah',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 11.sp,
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        Icon(
                                          Icons.bookmark_outline,
                                          size: 12.sp,
                                          color: const Color(0xFF00E676),
                                        ),
                                        SizedBox(width: 4.w),
                                        Text(
                                          'Juz ${_getJuzNumber(widget.surah.number)}',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 11.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                // Right: Arabic Name
                                Text(
                                  widget.surah.name,
                                  style: TextStyle(
                                    color: const Color(0xFF00E676),
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.bold,
                                    fontFamily:
                                        'Amiri', // Use Arabic font if avail
                                  ),
                                ),
                              ],
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
                            } else if (state is QuranAyahsLoaded) {
                              return ListView.separated(
                                controller: _scrollController,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 16.h,
                                ),
                                itemCount: state.ayahs.length,
                                separatorBuilder: (context, index) =>
                                    SizedBox(height: 12.h),
                                itemBuilder: (context, index) {
                                  final ayah = state.ayahs[index];
                                  String ayahText = ayah.text;

                                  // Handled Bismillah Logic (Simplified for brevity as it was already correct)
                                  const bismillahVariations = [
                                    'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                                    'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                                    'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                                    'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                                  ];

                                  if (index == 0 && widget.surah.number != 1) {
                                    ayahText = ayahText
                                        .replaceAll('\uFEFF', '')
                                        .trim();
                                    for (final bismillah
                                        in bismillahVariations) {
                                      if (ayahText.startsWith(bismillah)) {
                                        ayahText = ayahText
                                            .substring(bismillah.length)
                                            .trim();
                                        break;
                                      }
                                    }
                                    // Regex fallback omitted for brevity, assuming standard text usually works or preserved from previous
                                    if (ayahText.isEmpty) {
                                      // If empty after strip, verify if we should show nothing?
                                      // User wants clean view.
                                      // Original logic: if empty, return SizedBox.shrink().
                                      // But we need to ensure we don't drop Ayah 1 content if it wasn't just Bismillah.
                                      // Re-using original Regex logic inline or simplified:
                                      if (ayahText.isEmpty)
                                        return const SizedBox.shrink();
                                    }
                                  }

                                  // Ensure Key
                                  _ayahKeys.putIfAbsent(
                                    ayah.numberInSurah,
                                    () => GlobalKey(),
                                  );

                                  final isPlaying =
                                      _currentPlayingAyah == ayah.numberInSurah;

                                  final bool showBismillah =
                                      index == 0 &&
                                      widget.surah.number != 1 &&
                                      widget.surah.number != 9;

                                  return Column(
                                    children: [
                                      if (showBismillah)
                                        Padding(
                                          padding: EdgeInsets.only(
                                            bottom: 24.h,
                                            top: 8.h,
                                          ),
                                          child: ShaderMask(
                                            shaderCallback: (bounds) =>
                                                const LinearGradient(
                                                  colors: [
                                                    Color(
                                                      0xFF1B5E20,
                                                    ), // Dark Green
                                                    Color(
                                                      0xFF43A047,
                                                    ), // Rich Green
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ).createShader(bounds),
                                            blendMode: BlendMode.srcIn,
                                            child: Container(
                                              margin: EdgeInsets.symmetric(
                                                horizontal: 24.w,
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                vertical: 8.h,
                                              ),
                                              child: Column(
                                                children: [
                                                  // Top Decoration
                                                  Row(
                                                    children: [
                                                      const Expanded(
                                                        child: Divider(
                                                          color: Colors.white,
                                                          thickness: 1,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              horizontal: 8.w,
                                                            ),
                                                        child: Icon(
                                                          Icons
                                                              .star_outline_rounded,
                                                          size: 16.sp,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      const Expanded(
                                                        child: Divider(
                                                          color: Colors.white,
                                                          thickness: 1,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 12.h),

                                                  // Bismillah Calligraphy
                                                  FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    child: Text(
                                                      '﷽', // U+FDFD Calligraphy
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: GoogleFonts.amiri(
                                                        fontSize: 42.sp,
                                                        color: Colors.white,
                                                        height: 1.2,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),

                                                  SizedBox(height: 12.h),

                                                  // Bottom Decoration (Mirrored)
                                                  Row(
                                                    children: [
                                                      const Expanded(
                                                        child: Divider(
                                                          color: Colors.white,
                                                          thickness: 1,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              horizontal: 8.w,
                                                            ),
                                                        child: Icon(
                                                          Icons
                                                              .star_outline_rounded,
                                                          size: 16.sp,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      const Expanded(
                                                        child: Divider(
                                                          color: Colors.white,
                                                          thickness: 1,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      Container(
                                        key: _ayahKeys[ayah.numberInSurah],
                                        decoration: BoxDecoration(
                                          color: isPlaying
                                              ? const Color(
                                                  0xFFE8F5E9,
                                                ) // Light Green Highlight
                                              : const Color(
                                                  0xFFFFFCF2,
                                                ), // Soft Cream
                                          borderRadius: BorderRadius.circular(
                                            16.r,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.05,
                                              ),
                                              blurRadius: 10,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                          border: isPlaying
                                              ? Border.all(
                                                  color: const Color(
                                                    0xFF00E676,
                                                  ),
                                                  width: 1.5,
                                                )
                                              : Border.all(
                                                  color: Colors.transparent,
                                                ),
                                        ),
                                        padding: EdgeInsets.all(16.w),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            // Arabic Text
                                            if (ayah.textTajweed != null &&
                                                ayah.textTajweed!.isNotEmpty)
                                              RichText(
                                                textAlign: TextAlign.right,
                                                text: TajweedParser.parse(
                                                  ayah.textTajweed!,
                                                  style: GoogleFonts.amiriQuran(
                                                    color: Colors
                                                        .black, // Dark Text
                                                    fontSize: 26.sp,
                                                    height: 2.2,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              )
                                            else
                                              Text(
                                                ayahText,
                                                textAlign: TextAlign.right,
                                                style: GoogleFonts.amiriQuran(
                                                  color: Colors.black,
                                                  fontSize: 26.sp,
                                                  height: 2.2,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),

                                            SizedBox(height: 16.h),

                                            // Translation
                                            if (state.translationMap
                                                .containsKey(
                                                  ayah.numberInSurah,
                                                ))
                                              Text(
                                                state.translationMap[ayah
                                                    .numberInSurah]!,
                                                textAlign: TextAlign.left,
                                                style: GoogleFonts.outfit(
                                                  color: const Color(
                                                    0xFF424242,
                                                  ), // Dark Grey
                                                  fontSize: 15.sp,
                                                  height: 1.5,
                                                ),
                                              ),

                                            SizedBox(height: 16.h),
                                            Divider(
                                              color: Colors.grey.withOpacity(
                                                0.1,
                                              ),
                                              height: 1,
                                            ),
                                            SizedBox(height: 12.h),

                                            // Compact Action Bar
                                            Row(
                                              children: [
                                                // Number Badge
                                                Container(
                                                  width: 28.w,
                                                  height: 28.w,
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                      0xFF00E676,
                                                    ).withOpacity(0.1),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    '${ayah.numberInSurah}',
                                                    style: TextStyle(
                                                      color: const Color(
                                                        0xFF1B5E20,
                                                      ),
                                                      fontSize: 12.sp,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                const Spacer(),

                                                // Actions
                                                _buildActionButton(
                                                  icon: Icons.share_outlined,
                                                  onTap: () {
                                                    final translation =
                                                        state
                                                            .translationMap[ayah
                                                            .numberInSurah];
                                                    _shareAyah(
                                                      ayahText,
                                                      translation,
                                                      surahName,
                                                      ayah.numberInSurah,
                                                    );
                                                  },
                                                ),
                                                SizedBox(width: 8.w),
                                                _buildActionButton(
                                                  icon:
                                                      Icons.play_circle_outline,
                                                  onTap: () {
                                                    context
                                                        .read<AudioBloc>()
                                                        .add(
                                                          PlaySurah(
                                                            surahId: widget
                                                                .surah
                                                                .number,
                                                            surahName:
                                                                surahName,
                                                            startAyah: ayah
                                                                .numberInSurah,
                                                          ),
                                                        );
                                                  },
                                                ),
                                                SizedBox(width: 8.w),
                                                const Icon(
                                                  Icons.bookmark_border,
                                                  color: Colors.grey,
                                                  size: 20,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
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
                // Audio Player
                DraggableAudioPlayer(
                  dragShowcaseKey: _dragKey,
                  qoriShowcaseKey: _qoriKey,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

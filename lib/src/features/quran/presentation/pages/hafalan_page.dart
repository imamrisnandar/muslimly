import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import 'package:muslimly/src/features/quran/presentation/utils/glyph_helper.dart';
import 'package:muslimly/src/features/quran/presentation/widgets/mushaf_header_widget.dart';
import 'package:muslimly/src/features/quran/presentation/widgets/mushaf_basmalah_widget.dart';

import 'package:muslimly/src/features/quran/presentation/utils/arabic_utils.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:muslimly/src/core/widgets/islamic_loading_indicator.dart';
import 'package:muslimly/src/features/quran/domain/entities/surah.dart';
import 'package:muslimly/src/features/quran/domain/entities/ayah.dart';
import 'package:muslimly/src/features/quran/presentation/bloc/quran_bloc.dart';
import 'package:muslimly/src/features/quran/presentation/bloc/quran_event.dart';
import 'package:muslimly/src/features/quran/presentation/bloc/quran_state.dart';
import 'package:muslimly/src/features/quran/presentation/bloc/hafalan/hafalan_bloc.dart';
import 'package:muslimly/src/features/quran/presentation/bloc/hafalan/hafalan_event.dart';
import 'package:muslimly/src/features/quran/presentation/bloc/hafalan/hafalan_state.dart';
import 'package:muslimly/src/features/quran/domain/utils/arabic_text_matcher.dart';
import 'package:muslimly/src/core/di/di_container.dart';
import 'package:muslimly/src/core/utils/quran_constants.dart';
import 'package:muslimly/src/core/utils/surah_names.dart';
import 'package:muslimly/src/features/quran/data/surah_details.dart';
import '../../data/datasources/font_cache_service.dart';
import '../../../../core/utils/custom_snackbar.dart';

import 'package:dio/dio.dart';

import '../../data/datasources/local/quran_library/quran.dart' as quran_lib;

class HafalanPage extends StatefulWidget {
  final Surah? surah;
  final int? initialPage;

  const HafalanPage({super.key, this.surah, this.initialPage});

  @override
  State<HafalanPage> createState() => _HafalanPageState();
}

class _HafalanPageState extends State<HafalanPage> {
  PageController? _pageController;
  bool _isNavigating = false;
  late Surah _surah;

  @override
  void initState() {
    super.initState();
    _initializeSurah();
  }

  void _initializeSurah() {
    if (widget.surah != null) {
      _surah = widget.surah!;
    } else if (widget.initialPage != null) {
      final page = widget.initialPage!;
      int foundSurahNum = 1;
      for (var entry in QuranConstants.surahPageStart.entries) {
        if (entry.value <= page) {
          foundSurahNum = entry.key;
        } else {
          break;
        }
      }
      final englishName = SurahNames.englishNames[foundSurahNum - 1];
      final indonesianName = SurahNames.indonesianNames[foundSurahNum - 1];
      final ayaCount = QuranConstants.surahAyahCounts[foundSurahNum] ?? 7;

      _surah = Surah(
        number: foundSurahNum,
        name: "Surah $foundSurahNum",
        englishName: englishName,
        englishNameTranslation: "",
        indonesianNameTranslation: indonesianName,
        numberOfAyahs: ayaCount,
        revelationType: "Meccan",
      );
    } else {
      _surah = const Surah(
        number: 1,
        name: "Al-Fatihah",
        englishName: "Al-Fatihah",
        englishNameTranslation: "The Opening",
        indonesianNameTranslation: "Pembukaan",
        numberOfAyahs: 7,
        revelationType: "Meccan",
      );
    }
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  void _goToPreviousSurah() {
    if (_isNavigating) return; // Prevent multiple calls

    if (_surah.number > 1) {
      _isNavigating = true;
      final prevSurahNumber = _surah.number - 1;
      final prevSurahData = surahDetails.firstWhere(
        (element) => element['number'] == prevSurahNumber,
        orElse: () => {},
      );

      if (prevSurahData.isNotEmpty) {
        final prevSurah = Surah(
          number: prevSurahData['number'],
          name: prevSurahData['name'],
          englishName: prevSurahData['englishName'],
          englishNameTranslation: '',
          indonesianNameTranslation: '',
          numberOfAyahs: prevSurahData['numberOfAyahs'],
          revelationType: prevSurahData['revelationType'],
        );

        showCustomSnackBar(
          context,
          message: AppLocalizations.of(context)!.sbOpeningSurah(prevSurah.englishName),
          type: SnackBarType.info,
          duration: const Duration(milliseconds: 800),
        );

        Future.delayed(const Duration(milliseconds: 300), () {
          if (!mounted) return;
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          context.pushReplacement(
            '/quran/hafalan/${prevSurah.number}',
            extra: prevSurah,
          );
        });
      } else {
        _isNavigating = false;
      }
    } else {
      showCustomSnackBar(
        context,
        message: AppLocalizations.of(context)!.sbStartOfQuran,
        type: SnackBarType.info,
      );
    }
  }

  void _goToNextSurah() {
    if (_isNavigating) return;

    if (_surah.number < 114) {
      _isNavigating = true;
      final nextSurahNumber = _surah.number + 1;
      final nextSurahData = surahDetails.firstWhere(
        (element) => element['number'] == nextSurahNumber,
        orElse: () => {},
      );

      if (nextSurahData.isNotEmpty) {
        final nextSurah = Surah(
          number: nextSurahData['number'],
          name: nextSurahData['name'],
          englishName: nextSurahData['englishName'],
          englishNameTranslation: '',
          indonesianNameTranslation: '',
          numberOfAyahs: nextSurahData['numberOfAyahs'],
          revelationType: nextSurahData['revelationType'],
        );

        showCustomSnackBar(
          context,
          message: AppLocalizations.of(context)!.sbOpeningSurah(nextSurah.englishName),
          type: SnackBarType.info,
          duration: const Duration(milliseconds: 800),
        );

        Future.delayed(const Duration(milliseconds: 300), () {
          if (!mounted) return;
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          context.pushReplacement(
            '/quran/hafalan/${nextSurah.number}',
            extra: nextSurah,
          );
        });
      } else {
        _isNavigating = false;
        showCustomSnackBar(
          context,
          message: AppLocalizations.of(context)!.sbNextSurahNotFound,
          type: SnackBarType.error,
        );
      }
    } else {
      showCustomSnackBar(
        context,
        message: AppLocalizations.of(context)!.sbEndOfQuran,
        type: SnackBarType.info,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              getIt<QuranBloc>()..add(QuranFetchAyahs(_surah.number)),
        ),
        BlocProvider(create: (context) => HafalanBloc()..add(InitSpeech())),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF8E1),
        body: SafeArea(
          child: BlocBuilder<QuranBloc, QuranState>(
            builder: (context, state) {
              if (state is QuranLoading) {
                return const Center(child: IslamicLoadingIndicator(size: 48));
              } else if (state is QuranError) {
                return Center(child: Text(state.message));
              } else if (state is QuranAyahsLoaded) {
                final Map<int, List<Ayah>> pages = {};
                for (var ayah in state.ayahs) {
                  if (!pages.containsKey(ayah.page)) {
                    pages[ayah.page] = [];
                  }
                  pages[ayah.page]!.add(ayah);
                }

                final sortedPages = pages.keys.toList()..sort();

                if (_pageController == null) {
                  int initialIndex = 0;
                  if (widget.initialPage != null &&
                      sortedPages.contains(widget.initialPage)) {
                    initialIndex = sortedPages.indexOf(widget.initialPage!);
                  }
                  _pageController = PageController(initialPage: initialIndex);

                  if (sortedPages.isNotEmpty) {
                    final initialAyahs = pages[sortedPages[initialIndex]]!;
                    context.read<HafalanBloc>().setAyahs(initialAyahs);
                  }
                }

                return Stack(
                  children: [
                    NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (notification is ScrollUpdateNotification &&
                            notification.dragDetails != null) {
                          if (notification.metrics.pixels >
                              notification.metrics.maxScrollExtent + 20) {
                            if (_pageController!.page != null &&
                                _pageController!.page!.round() ==
                                    sortedPages.length - 1) {
                              _goToNextSurah();
                            }
                          }
                          if (notification.metrics.pixels < -20) {
                            if (_pageController!.page != null &&
                                _pageController!.page!.round() == 0) {
                              _goToPreviousSurah();
                            }
                          }
                        }
                        return false;
                      },
                      child: PageView.builder(
                        controller: _pageController!,
                        reverse: true,
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        onPageChanged: (index) {
                          final newAyahs = pages[sortedPages[index]]!;
                          final hafalanBloc = context.read<HafalanBloc>();
                          hafalanBloc.setAyahs(newAyahs);
                          hafalanBloc.add(ResetHafalan());
                        },
                        itemCount: sortedPages.length,
                        itemBuilder: (context, index) {
                          final pageNumber = sortedPages[index];
                          final ayahsOnPage = pages[pageNumber]!;

                          return _HafalanSinglePage(
                            pageNumber: pageNumber,
                            ayahs: ayahsOnPage,
                            surahName: _surah.englishName,
                            surahNumber: _surah.number,
                          );
                        },
                      ),
                    ),
                    Positioned(
                      top: 5.h,
                      left: 16.w,
                      child: CircleAvatar(
                        backgroundColor: Colors.black.withOpacity(0.0),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                          ),
                          onPressed: () => context.pop(),
                        ),
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Single Page Widget
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _HafalanSinglePage extends StatefulWidget {
  final int pageNumber;
  final List<Ayah> ayahs;
  final String surahName;
  final int surahNumber;

  const _HafalanSinglePage({
    required this.pageNumber,
    required this.ayahs,
    required this.surahName,
    required this.surahNumber,
  });

  @override
  State<_HafalanSinglePage> createState() => _HafalanSinglePageState();
}

class _HafalanSinglePageState extends State<_HafalanSinglePage>
    with SingleTickerProviderStateMixin {
  final TransformationController _transformationController =
      TransformationController();
  Future<void>? _fontFuture;
  late AnimationController _pulseController;

  /// Cache completed ayah spans — they never change once completed (#7)
  final Map<int, List<InlineSpan>> _completedSpanCache = {};


  @override
  void initState() {
    super.initState();
    _transformationController.value = Matrix4.identity()..scale(1.0);
    _fontFuture = _loadFont();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  Future<void> _loadFont() async {
    final fontService = FontCacheService(Dio());
    await fontService.loadPageFont(widget.pageNumber);
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int page = widget.pageNumber;
    final bool isFatihahOrBaqarahStart = page == 1 || page == 2;

    double fontSize;
    if (page == 1 || page == 2) {
      fontSize = 28.sp;
    } else if (page == 145 || page == 201) {
      fontSize = 22.4.sp;
    } else if (page == 532 || page == 533) {
      fontSize = 22.5.sp;
    } else {
      fontSize = 23.1.sp;
    }

    final double lineHeight = isFatihahOrBaqarahStart ? 2.0 : 1.95;
    final String pageStr = widget.pageNumber.toString().padLeft(3, '0');
    final String fontFamily = 'QCF_P$pageStr';

    final List<Map<String, dynamic>> glyphs = GlyphHelper.getPageGlyphs(
      widget.pageNumber,
    );

    return Column(
      children: [
        // ━━━ Header — only rebuilds when isPeeking changes (#1) ━━━
        BlocSelector<HafalanBloc, HafalanState, bool>(
          selector: (state) => state.isPeeking,
          builder: (context, isPeeking) {
            return Container(
              height: 60,
              color: const Color(0xffF1EEE5),
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              alignment: Alignment.center,
              child: Row(
                children: [
                  SizedBox(width: 40.w),
                  Expanded(
                    child: Text(
                      quran_lib.getSurahNameArabic(widget.surahNumber),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: "UthmanicHafs13",
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  // Peek Button (long-press to reveal)
                  GestureDetector(
                    onLongPressStart: (_) {
                      context.read<HafalanBloc>().add(const TogglePeek(true));
                    },
                    onLongPressEnd: (_) {
                      context.read<HafalanBloc>().add(const TogglePeek(false));
                    },
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      child: Icon(
                        Icons.visibility_outlined,
                        color: isPeeking
                            ? const Color(0xFF00E676)
                            : Colors.black54,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        // ━━━ Progress Bar — rebuilds on progress changes only (#1) ━━━
        BlocSelector<
          HafalanBloc,
          HafalanState,
          ({
            int completed,
            int matched,
            int total,
            bool listening,
            double accuracy,
            HafalanStatus status,
          })
        >(
          selector: (state) => (
            completed: state.completedAyahs.length,
            matched: state.currentMatchedWordCount,
            total: state.currentTotalWordCount,
            listening: state.isListening,
            accuracy: state.overallAccuracy,
            status: state.status,
          ),
          builder: (context, data) {
            return Container(
              color: const Color(0xffF1EEE5),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 4.h),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.hafalanProgressAyat(
                          data.completed.toString(),
                          widget.ayahs.length.toString(),
                        ),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      // Status / Accuracy info
                      if (data.status == HafalanStatus.completed)
                        Row(
                          children: [
                            const Icon(
                              Icons.celebration,
                              color: Color(0xFF00E676),
                              size: 16,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              AppLocalizations.of(context)!.hafalanAccuracy(
                                (data.accuracy * 100).toStringAsFixed(0),
                              ),
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF00E676),
                              ),
                            ),
                          ],
                        )
                      else if (data.listening && data.total > 0)
                        Text(
                          AppLocalizations.of(context)!.hafalanProgressKata(
                            data.matched.toString(),
                            data.total.toString(),
                          ),
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: LinearProgressIndicator(
                      value: widget.ayahs.isEmpty
                          ? 0
                          : data.completed / widget.ayahs.length,
                      backgroundColor: Colors.black12,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF00E676),
                      ),
                      minHeight: 6.h,
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        // ━━━ Mushaf Content — Use Stack for floating controls ━━━
        Expanded(
          child: LayoutBuilder(
            builder: (context, stackConstraints) {
              return Stack(
                children: [
                  // ═══ Mushaf content (full area, scrollable) ═══
                  Container(
                    color: const Color(0xffF1EEE5),
                    width: double.infinity,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return FutureBuilder<void>(
                          future: _fontFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState !=
                                ConnectionState.done) {
                              return const Center(
                                child: IslamicLoadingIndicator(size: 40),
                              );
                            }
                            if (snapshot.hasError) {
                              return Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.error_outline,
                                      color: Colors.red,
                                      size: 40,
                                    ),
                                    SizedBox(height: 10.h),
                                    Text(
                                      'Font download error',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.sp,
                                      ),
                                    ),
                                    SizedBox(height: 15.h),
                                    FilledButton(
                                      onPressed: () {
                                        setState(() {
                                          _fontFuture = _loadFont();
                                        });
                                      },
                                      child: const Text('Coba Lagi'),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return BlocSelector<
                              HafalanBloc,
                              HafalanState,
                              ({
                                Map<int, Set<int>> revealed,
                                Map<int, Set<int>> mismatched,
                                Set<int> completed,
                                int currentIdx,
                                bool peeking,
                              })
                            >(
                              selector: (state) => (
                                revealed: state.revealedWords,
                                mismatched: state.mismatchedWords,
                                completed: state.completedAyahs,
                                currentIdx: state.currentAyahIndex,
                                peeking: state.isPeeking,
                              ),
                              builder: (context, mushafData) {
                                final hafalanState = context
                                    .read<HafalanBloc>()
                                    .state;
                                return InteractiveViewer(
                                  transformationController:
                                      _transformationController,
                                  minScale: 1.0,
                                  maxScale: 5.0,
                                  constrained: false,
                                  child: Container(
                                    width: constraints.maxWidth,
                                    padding: EdgeInsets.only(
                                      left: 12.w,
                                      right: 12.w,
                                      bottom: 80.h,
                                    ),
                                    alignment: Alignment.center,
                                    child: RichText(
                                      textDirection: TextDirection.rtl,
                                      textAlign: isFatihahOrBaqarahStart
                                          ? TextAlign.center
                                          : TextAlign.justify,
                                      text: TextSpan(
                                        style: TextStyle(
                                          fontFamily: fontFamily,
                                          fontSize: fontSize,
                                          color: Colors.black,
                                          height: lineHeight,
                                          letterSpacing: 0,
                                          wordSpacing: 0,
                                        ),
                                        children: _buildHafalanSpans(
                                          context,
                                          glyphs,
                                          hafalanState,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),

                  // ═══ Bottom Bar: STT text + Controls side by side ═══
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      top: false,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.white,
                              Colors.white.withOpacity(0.95),
                              Colors.white.withOpacity(0.0),
                            ],
                            stops: const [0.0, 0.7, 1.0],
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // ═══ STT spoken text (left, expands) ═══
                            Expanded(
                              child: BlocSelector<HafalanBloc, HafalanState, String>(
                                selector: (state) => state.spokenText,
                                builder: (context, spokenText) {
                                  if (spokenText.trim().isEmpty) {
                                    return const SizedBox.shrink();
                                  }
                                  return Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                      vertical: 6.h,
                                    ),
                                    margin: EdgeInsets.only(right: 8.w),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.65),
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: Text(
                                      spokenText,
                                      textDirection: TextDirection.rtl,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: "UthmanicHafs13",
                                        height: 1.5,
                                        color: Colors.white,
                                        fontSize: 16.sp,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            // ═══ Controls (right, compact) ═══
                            BlocSelector<
                              HafalanBloc,
                              HafalanState,
                              ({HafalanStatus status, bool listening})
                            >(
                              selector: (state) => (
                                status: state.status,
                                listening: state.isListening,
                              ),
                              builder: (context, data) {
                                final hafalanState = context
                                    .read<HafalanBloc>()
                                    .state;
                                return Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 6.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(28.r),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Skip Button
                                      if (data.status != HafalanStatus.completed)
                                        _buildSmallButton(
                                          icon: Icons.skip_next,
                                          onTap: () => context
                                              .read<HafalanBloc>()
                                              .add(SkipAyah()),
                                          color: Colors.white70,
                                        ),
                                      if (data.status != HafalanStatus.completed)
                                        SizedBox(width: 8.w),

                                      // Mic Button (center, larger)
                                      _buildMicButton(context, hafalanState),

                                      SizedBox(width: 8.w),
                                      // Reset Button
                                      _buildSmallButton(
                                        icon: Icons.refresh,
                                        onTap: () {
                                          _completedSpanCache.clear();
                                          context.read<HafalanBloc>()
                                            ..setAyahs(widget.ayahs)
                                            ..add(ResetHafalan());
                                        },
                                        color: Colors.white70,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        // ━━━ Footer: Page Number (static, never rebuilds) ━━━
        Container(
          height: 30.h,
          width: double.infinity,
          color: const Color(0xffF1EEE5),
          alignment: Alignment.center,
          child: Text(
            ArabicUtils.toArabicDigits(page),
            style: TextStyle(
              fontFamily: "UthmanicHafs13",
              fontSize: 16.sp,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSmallButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32.w,
        height: 32.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.15),
        ),
        child: Icon(icon, color: color, size: 18.sp),
      ),
    );
  }

  Widget _buildMicButton(BuildContext context, HafalanState hafalanState) {
    final bool isCompleted = hafalanState.status == HafalanStatus.completed;
    final bool isListening = hafalanState.isListening;
    final bool isPaused = hafalanState.status == HafalanStatus.paused;
    final bool isError = hafalanState.status == HafalanStatus.error;

    return GestureDetector(
      onTap: () {
        if (isCompleted) return;
        final bloc = context.read<HafalanBloc>();
        if (isListening) {
          bloc.add(StopListening()); // → paused
        } else {
          bloc.add(StartListening()); // start or resume
        }
      },
      child: _AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final double scale = isListening
              ? 1.0 + (_pulseController.value * 0.15)
              : 1.0;
          final double glowOpacity = isListening
              ? 0.3 + (_pulseController.value * 0.3)
              : 0.0;

          // Determine button color
          Color buttonColor;
          if (isCompleted) {
            buttonColor = Colors.grey;
          } else if (isListening) {
            buttonColor = Colors.red;
          } else if (isPaused) {
            buttonColor = Colors.blue; // Blue = resume available
          } else if (isError) {
            buttonColor = Colors.orange;
          } else {
            buttonColor = const Color(0xFF00E676); // Green = start
          }

          // Determine icon
          IconData buttonIcon;
          if (isCompleted) {
            buttonIcon = Icons.check;
          } else if (isListening) {
            buttonIcon = Icons.pause; // Pause icon when listening
          } else if (isPaused) {
            buttonIcon = Icons.play_arrow; // Play/resume icon when paused
          } else {
            buttonIcon = Icons.mic; // Mic icon to start
          }

          return Transform.scale(
            scale: scale,
            child: Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: buttonColor,
                boxShadow: isListening
                    ? [
                        BoxShadow(
                          color: Colors.red.withOpacity(glowOpacity),
                          blurRadius: 14,
                          spreadRadius: 3,
                        ),
                      ]
                    : null,
              ),
              child: Icon(buttonIcon, color: Colors.white, size: 22.sp),
            ),
          );
        },
      ),
    );
  }

  /// Each QCF glyph string contains space-separated characters where each
  /// character represents roughly one visual "word" in the mushaf.
  /// We split these into individual TextSpans so each can be colored
  /// independently based on the speech matching progress.
  List<InlineSpan> _buildHafalanSpans(
    BuildContext context,
    List<Map<String, dynamic>> glyphs,
    HafalanState hafalanState,
  ) {
    List<InlineSpan> spans = [];
    final revealedWords = hafalanState.revealedWords;
    final mismatchedWords = hafalanState.mismatchedWords;
    final completedAyahs = hafalanState.completedAyahs;
    final currentAyahNum = hafalanState.currentAyahIndex < widget.ayahs.length
        ? widget.ayahs[hafalanState.currentAyahIndex].numberInSurah
        : -1;
    final isPeeking = hafalanState.isPeeking;

    // Pre-calculate text word counts per ayah
    final Map<int, int> ayahWordCounts = {};
    final Map<int, List<int>> ayahWordLengths = {};
    for (var ayah in widget.ayahs) {
      final words = ayah.text
          .split(RegExp(r'\s+'))
          .where((w) => w.isNotEmpty)
          .toList();
      ayahWordCounts[ayah.numberInSurah] = words.length;

      final lengths = words
          .map((w) => ArabicTextMatcher.normalizeArabic(w).length)
          .map((len) => len <= 0 ? 1 : len)
          .toList();
      ayahWordLengths[ayah.numberInSurah] = lengths;

    }

    // Pre-calculate QCF content character counts per ayah (Surah + Ayah composite key)
    final Map<String, int> ayahQcfCharCounts = {};
    for (var glyph in glyphs) {
      final surah = glyph['surah'] as int;
      final ayah = glyph['ayah'] as int;
      final key = '${surah}_$ayah';
      final cleanGlyph = glyph['glyph'].toString().replaceAll(' ', '');
      final contentLen = cleanGlyph.length > 1
          ? cleanGlyph.length - 1
          : cleanGlyph.length;
      ayahQcfCharCounts[key] = (ayahQcfCharCounts[key] ?? 0) + contentLen;
      
      if (surah == 5 && ayah == 1) {
        debugPrint('[QCF DEBUG] S\$surah:A\$ayah has \$contentLen QCF chars.');
      }
    }
    
    if (widget.surahNumber == 5) {
      debugPrint('[QCF DEBUG] Surah 5 Ayah 1 has \${ayahWordCounts[1]} Text words.');
    }

    // Track cumulative QCF char index per ayah (Surah + Ayah composite key)
    final Map<String, int> ayahCharIndex = {};

    for (var i = 0; i < glyphs.length; i++) {
      final glyph = glyphs[i];
      final int surah = glyph['surah'];
      final int ayah = glyph['ayah'];
      final String compositeKey = '${surah}_$ayah';

      final bool isTargetSurah = surah == widget.surahNumber;
      final bool isAyahCompleted =
          isTargetSurah && completedAyahs.contains(ayah);
      final bool isCurrent = isTargetSurah && ayah == currentAyahNum;
      final Set<int> revealedWordSet = revealedWords[ayah] ?? {};
      final Set<int> mismatchedWordSet = mismatchedWords[ayah] ?? {};
      final int totalTextWords = ayahWordCounts[ayah] ?? 1;
      final int totalQcfChars = ayahQcfCharCounts[compositeKey] ?? 1;
      final int visualRevealLimit = isCurrent && !isAyahCompleted
          ? hafalanState.currentMatchedWordCount
          : totalTextWords;
      final List<int> wordUnitCumulativeEnds = _buildWordUnitCumulativeEnds(
        wordLengths: ayahWordLengths[ayah] ?? const [1],
        totalQcfUnits: totalQcfChars,
      );

      // Insert Surah Header at Ayah 1
      final int startCharIdx = ayahCharIndex[compositeKey] ?? 0;
      if (ayah == 1 && startCharIdx == 0) {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: MushafHeaderWidget(
              surahNumber: surah,
              surahNameArabic: quran_lib.getSurahNameArabic(surah),
              verseCount: quran_lib.getVerseCount(surah),
            ),
          ),
        );

        if (surah != 1 && surah != 9) {
          spans.add(
            const WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: MushafBasmalahWidget(),
            ),
          );
        }
      }

      final String cleanGlyph = glyph['glyph'].toString().replaceAll(' ', '');

      if (cleanGlyph.length > 1) {
        final String contentText = cleanGlyph.substring(
          0,
          cleanGlyph.length - 1,
        );
        final String markerChar = cleanGlyph.substring(cleanGlyph.length - 1);

        // Group consecutive characters with the same color into a single TextSpan
        // to preserve Uthmanic font kerning, ligatures, and Kashida justification.
        Color? lastColor;
        StringBuffer textBuffer = StringBuffer();

        for (int ci = 0; ci < contentText.length; ci++) {
          final int globalCharIdx = startCharIdx + ci;

          // Map QCF units to words using cumulative normalized word lengths,
          // not flat word count distribution. This is more stable for long
          // ayahs with repeated short words such as "ولا", where uniform
          // proportional mapping can make the next word appear green early.
          final int wordIdx = totalQcfChars > 0
              ? _resolveWordIndexFromAllocatedUnits(
                  globalCharIdx: globalCharIdx,
                  cumulativeWordEnds: wordUnitCumulativeEnds,
                ).clamp(0, totalTextWords - 1)
              : 0;

          final bool isWordRevealed = revealedWordSet.contains(wordIdx) &&
              (!isCurrent || wordIdx < visualRevealLimit);
          final bool isWordMismatched = mismatchedWordSet.contains(wordIdx);

          Color charColor;
          if (!isTargetSurah) {
            charColor = Colors.black87; // Normal visibility for other surahs
          } else if (isPeeking) {
            charColor = Colors.black.withOpacity(0.3);
          } else if (isAyahCompleted) {
            if (isWordMismatched) {
              charColor = const Color(
                0xFFB71C1C,
              ); // Dark red for completed mismatch
            } else {
              charColor = const Color(
                0xFF2E7D32,
              ); // Dark green for completed match
            }
          } else if (isCurrent) {
            if (isWordMismatched) {
              charColor = const Color(0xFFEF5350); // Red for mismatched (priority over green)
            } else if (isWordRevealed) {
              charColor = const Color(0xFF00E676); // Bright green for matched
            } else {
              charColor = Colors.black.withOpacity(0.08); // Barely visible
            }
          } else {
            charColor = Colors.transparent; // Hidden
          }

          if (lastColor != null && lastColor != charColor) {
            // Color changed, emit the accumulated characters
            spans.add(
              TextSpan(
                text: textBuffer.toString(),
                style: TextStyle(color: lastColor),
              ),
            );
            textBuffer.clear();
          }

          textBuffer.write(contentText[ci]);
          lastColor = charColor;
        }

        // Emit any remaining characters
        if (textBuffer.isNotEmpty && lastColor != null) {
          spans.add(
            TextSpan(
              text: textBuffer.toString(),
              style: TextStyle(color: lastColor),
            ),
          );
        }

        // Update cumulative char count
        ayahCharIndex[compositeKey] = startCharIdx + contentText.length;

        // Ayah marker — always visible
        spans.add(
          TextSpan(
            text: markerChar,
            style: TextStyle(
              foreground: Paint()
                ..shader = LinearGradient(
                  colors: !isTargetSurah
                      ? [Colors.black87, Colors.black87]
                      : isCurrent && !isAyahCompleted
                      ? [const Color(0xFF00E676), Colors.blue]
                      : isAyahCompleted
                      ? [const Color(0xFF2E7D32), const Color(0xFF1B5E20)]
                      : [Colors.black26, Colors.black12],
                ).createShader(const Rect.fromLTWH(0.0, 0.0, 20.0, 20.0)),
            ),
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: cleanGlyph,
            style: TextStyle(
              color: !isTargetSurah
                  ? Colors.black87
                  : isAyahCompleted
                  ? const Color(0xFF2E7D32)
                  : isCurrent
                  ? Colors.black.withOpacity(0.08)
                  : Colors.transparent,
            ),
          ),
        );
      }
    }
    return spans;
  }

  List<int> _buildWordUnitCumulativeEnds({
    required List<int> wordLengths,
    required int totalQcfUnits,
  }) {
    if (wordLengths.isEmpty) {
      return const [1];
    }

    final safeLengths = wordLengths.map((len) => len <= 0 ? 1 : len).toList();
    final wordCount = safeLengths.length;
    final totalUnits = totalQcfUnits < wordCount ? wordCount : totalQcfUnits;

    // Give each word at least one visual unit so short repeated words such as
    // "ولا" never disappear or get merged into the next word's color region.
    final allocation = List<int>.filled(wordCount, 1);
    int remaining = totalUnits - wordCount;

    if (remaining > 0) {
      final totalLength = safeLengths.fold<int>(0, (a, b) => a + b);
      final fractional = <({int index, double fraction})>[];

      for (int i = 0; i < wordCount; i++) {
        final exactExtra = (safeLengths[i] / totalLength) * remaining;
        final wholeExtra = exactExtra.floor();
        allocation[i] += wholeExtra;
        fractional.add((index: i, fraction: exactExtra - wholeExtra));
      }

      int distributed = allocation.fold<int>(0, (a, b) => a + b);
      int leftover = totalUnits - distributed;

      fractional.sort((a, b) => b.fraction.compareTo(a.fraction));
      for (int i = 0; i < leftover; i++) {
        allocation[fractional[i % fractional.length].index]++;
      }
    }

    final cumulativeEnds = <int>[];
    int running = 0;
    for (final units in allocation) {
      running += units;
      cumulativeEnds.add(running);
    }
    return cumulativeEnds;
  }

  int _resolveWordIndexFromAllocatedUnits({
    required int globalCharIdx,
    required List<int> cumulativeWordEnds,
  }) {
    if (cumulativeWordEnds.isEmpty) {
      return 0;
    }

    for (int i = 0; i < cumulativeWordEnds.length; i++) {
      if (globalCharIdx < cumulativeWordEnds[i]) {
        return i;
      }
    }

    return cumulativeWordEnds.length - 1;
  }
}

/// AnimatedBuilder helper (uses AnimatedWidget pattern)
class _AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext context, Widget? child) builder;

  const _AnimatedBuilder({
    required Animation<double> animation,
    required this.builder,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return builder(context, null);
  }
}

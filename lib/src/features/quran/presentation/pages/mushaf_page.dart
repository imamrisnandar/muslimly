import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import 'package:muslimly/src/features/quran/presentation/utils/glyph_helper.dart';
import 'package:muslimly/src/features/quran/presentation/widgets/mushaf_header_widget.dart';
import 'package:muslimly/src/features/quran/presentation/widgets/mushaf_basmalah_widget.dart';
import 'package:muslimly/src/features/quran/presentation/widgets/tafsir_bottom_sheet.dart';
import 'package:muslimly/src/features/quran/data/surah_details.dart';
import 'package:muslimly/src/features/quran/presentation/utils/arabic_utils.dart'; // Added utility

import 'package:muslimly/src/l10n/generated/app_localizations.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:muslimly/src/core/di/di_container.dart';
import 'package:muslimly/src/features/quran/domain/entities/surah.dart';
import 'package:muslimly/src/features/quran/domain/entities/ayah.dart';
import 'package:muslimly/src/features/quran/presentation/bloc/quran_bloc.dart';
import 'dart:async'; // Timer
import 'package:muslimly/src/features/quran/presentation/bloc/quran_event.dart';
import 'package:muslimly/src/features/quran/presentation/bloc/quran_state.dart';
import 'package:muslimly/src/features/quran/presentation/bloc/reading/reading_bloc.dart';
import 'package:muslimly/src/features/quran/presentation/bloc/reading/reading_event.dart';
import 'package:muslimly/src/features/quran/presentation/bloc/bookmark/bookmark_bloc.dart';
import 'package:muslimly/src/features/quran/presentation/bloc/bookmark/bookmark_event.dart';
import 'package:muslimly/src/features/quran/presentation/bloc/bookmark/bookmark_state.dart';
import 'package:muslimly/src/features/quran/domain/entities/quran_bookmark.dart';
import 'package:muslimly/src/features/quran/domain/entities/last_read.dart';
import 'package:muslimly/src/features/quran/data/datasources/font_cache_service.dart';
import 'package:dio/dio.dart';
import 'dart:ui' as ui;
import 'package:muslimly/src/features/quran/presentation/widgets/audio_bottom_sheet.dart';
import 'package:muslimly/src/features/quran/presentation/widgets/draggable_audio_player.dart';
import 'package:muslimly/src/features/quran/presentation/bloc/audio_bloc.dart';
import 'package:muslimly/src/features/quran/presentation/bloc/audio_event.dart';
import 'package:muslimly/src/features/quran/presentation/bloc/audio_state.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../features/settings/data/repositories/settings_repository.dart';

class MushafPage extends StatefulWidget {
  final Surah surah;
  final bool startAtEnd;
  final int? initialPage;

  const MushafPage({
    super.key,
    required this.surah,
    this.startAtEnd = false,
    this.initialPage,
  });

  @override
  State<MushafPage> createState() => _MushafPageState();
}

class _MushafPageState extends State<MushafPage> {
  PageController? _pageController;
  bool _isNavigating = false; // Debounce flag

  // Reading Tracking
  final Stopwatch _readStopwatch = Stopwatch();
  int _lastPageNumber = -1; // Track the page being read

  // Showcase Keys
  final GlobalKey _swipeKey = GlobalKey();
  final GlobalKey _bookmarkKey = GlobalKey();
  final GlobalKey _completionKey = GlobalKey();
  final GlobalKey _dragKey = GlobalKey();
  final GlobalKey _qoriKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Start stopwatch when entering the view
    _readStopwatch.start();

    // Check for showcase
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkShowcase());
  }

  Future<void> _checkShowcase() async {
    final prefs = await SharedPreferences.getInstance();
    final hasShown = prefs.getBool('hasShownMushafShowcase') ?? false;

    if (!hasShown && mounted) {
      ShowCaseWidget.of(
        context,
      ).startShowCase([_swipeKey, _bookmarkKey, _completionKey]);
      prefs.setBool('hasShownMushafShowcase', true);
    }
  }

  Future<void> _checkPlayerShowcase() async {
    final settings = getIt<SettingsRepository>();
    if (!await settings.hasShownPlayerShowcase()) {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            ShowCaseWidget.of(context).startShowCase([_dragKey, _qoriKey]);
            await settings.setPlayerShowcaseShown(true);
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _pageController?.dispose();
    _readStopwatch.stop();
    // note: difficult to log on dispose because context might be invalid,
    // but usually BlocProvider closes the bloc.
    // Ideally we assume the last page session might be short or we try to log if possible.
    super.dispose();
  }

  void _logReading(BuildContext context, int pageNum, {bool manual = false}) {
    // If manual, we bypass the 20s check
    if (manual || _readStopwatch.elapsed.inSeconds > 20) {
      context.read<ReadingBloc>().add(
        LogPageRead(
          pageNumber: pageNum,
          durationSeconds: _readStopwatch.elapsed.inSeconds,
          surahNumber: widget.surah.number,
        ),
      );

      // Visual Feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            manual
                ? AppLocalizations.of(context)!.markAsRead
                : "Page $pageNum recorded!",
          ),
          duration: const Duration(milliseconds: 800),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF00E676),
        ),
      );
    }
    _readStopwatch.reset();
    _readStopwatch.start();
  }

  // ... (Previous methods: _goToPreviousSurah, _goToNextSurah)

  void _goToPreviousSurah(BuildContext context) {
    if (widget.surah.number > 1) {
      // Can go back if > 1 (Al-Fatihah is 1)
      _isNavigating = true;

      final prevSurahNumber = widget.surah.number - 1;

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

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening ${prevSurah.englishName}...'),
            duration: const Duration(seconds: 1),
          ),
        );

        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            // To open at the END of the previous Surah, we might need logic in MushafPage to scroll to end?
            // For now, standard open (starts at page 1 of that Surah) is standard behavior unless requested specifically "End of Page".
            // User said "arahkan ke surat sebelumnya pada akhir halaman" -> "Direct to previous surah at the end page".
            // This is complex because we calculate pages dynamically.
            // We'll stick to opening the Surah for now, as passing "JumpToEnd" param requires more refactoring.
            context.pushReplacement(
              '/quran/mushaf/${prevSurah.number}?startAtEnd=true',
              extra: prevSurah,
            );
          }
        });
      } else {
        _isNavigating = false;
      }
    } else {
      // Start of Quran
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Start of Quran')));
    }
  }

  void _goToNextSurah(BuildContext context) {
    // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Navigating...')));

    if (_isNavigating) return; // Prevent multiple calls

    if (widget.surah.number < 114) {
      _isNavigating = true; // Set flag

      final nextSurahNumber = widget.surah.number + 1;

      // print("Looking for Surah $nextSurahNumber");

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

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening ${nextSurah.englishName}...'),
            duration: const Duration(seconds: 1),
          ),
        );

        // Delay slightly for visual feedback then navigate
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            context.pushReplacement(
              '/quran/mushaf/${nextSurah.number}', // Corrected route with ID
              extra: nextSurah,
            );
          }
        });
      } else {
        _isNavigating = false; // Reset if failed
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Next Surah Data Not Found!')),
        );
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('End of Quran')));
    }
  }

  // ... (build)

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              getIt<QuranBloc>()..add(QuranFetchAyahs(widget.surah.number)),
        ),
        BlocProvider(create: (context) => getIt<ReadingBloc>()),
        BlocProvider(create: (context) => getIt<BookmarkBloc>()),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF8E1), // Cream background for Mushaf
        body: Builder(
          builder: (context) {
            return BlocListener<AudioBloc, AudioState>(
              listener: (context, audioState) {
                if (audioState.status == AudioStatus.playing) {
                  _checkPlayerShowcase();
                }
                if (audioState.currentSurahId == widget.surah.number &&
                    audioState.currentAyahNumber != null) {
                  final quranState = context.read<QuranBloc>().state;
                  if (quranState is QuranAyahsLoaded) {
                    try {
                      final ayah = quranState.ayahs.firstWhere(
                        (a) => a.numberInSurah == audioState.currentAyahNumber,
                      );
                      final uniquePages =
                          quranState.ayahs.map((e) => e.page).toSet().toList()
                            ..sort();
                      final index = uniquePages.indexOf(ayah.page);
                      if (index != -1 &&
                          _pageController != null &&
                          _pageController!.hasClients) {
                        if ((_pageController!.page?.round() ?? -1) != index) {
                          _pageController!.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      }
                    } catch (_) {}
                  }
                }
              },
              child: SafeArea(
                child: Stack(
                  children: [
                    BlocBuilder<QuranBloc, QuranState>(
                      builder: (context, state) {
                        if (state is QuranLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (state is QuranError) {
                          return Center(child: Text(state.message));
                        } else if (state is QuranAyahsLoaded) {
                          // Group Ayahs by Page
                          final Map<int, List<Ayah>> pages = {};
                          for (var ayah in state.ayahs) {
                            if (!pages.containsKey(ayah.page)) {
                              pages[ayah.page] = [];
                            }
                            pages[ayah.page]!.add(ayah);
                          }

                          final sortedDid = pages.keys.toList()..sort();

                          // Init PageController with correct initial page
                          if (_pageController == null) {
                            int initialIndex = 0;
                            if (widget.initialPage != null &&
                                sortedDid.contains(widget.initialPage)) {
                              initialIndex = sortedDid.indexOf(
                                widget.initialPage!,
                              );
                            } else if (widget.startAtEnd) {
                              initialIndex = sortedDid.length - 1;
                            }

                            _pageController = PageController(
                              initialPage: initialIndex,
                            );

                            if (sortedDid.isNotEmpty) {
                              _lastPageNumber = sortedDid[initialIndex];
                            }
                          }

                          return NotificationListener<ScrollNotification>(
                            onNotification: (notification) {
                              if (notification is ScrollUpdateNotification &&
                                  notification.dragDetails != null) {
                                // NEXT SURAH (End of Page)
                                if (notification.metrics.pixels >
                                    notification.metrics.maxScrollExtent + 20) {
                                  if (_pageController!.page != null &&
                                      _pageController!.page!.round() ==
                                          sortedDid.length - 1) {
                                    _goToNextSurah(context);
                                  }
                                }

                                // PREVIOUS SURAH (Start of Page)
                                if (notification.metrics.pixels < -20) {
                                  if (_pageController!.page != null &&
                                      _pageController!.page!.round() == 0) {
                                    _goToPreviousSurah(context);
                                  }
                                }
                              }
                              return false;
                            },
                            child: Showcase(
                              key: _swipeKey,
                              description: AppLocalizations.of(
                                context,
                              )!.showcaseNavigation, // Localized
                              child: PageView.builder(
                                controller: _pageController!,
                                reverse: true, // Right-to-Left swipe for Quran
                                physics: const AlwaysScrollableScrollPhysics(
                                  parent: BouncingScrollPhysics(),
                                ),
                                onPageChanged: (index) {
                                  // Log previous page
                                  if (_lastPageNumber != -1) {
                                    _logReading(context, _lastPageNumber);
                                  }
                                  // Update tracking
                                  final newPage = sortedDid[index];

                                  // Save Last Read
                                  final lastRead = LastRead(
                                    pageNumber: newPage,
                                    surahName: widget.surah.englishName,
                                    surahNumber: widget.surah.number,
                                    // Note: We don't have exact Ayah here easily without finding first ayah of newPage
                                    // But pageNumber is enough for navigation.
                                  );
                                  context.read<BookmarkBloc>().add(
                                    SaveLastRead(lastRead),
                                  );

                                  setState(() {
                                    _lastPageNumber = newPage;
                                  });
                                },
                                itemCount: sortedDid.length,
                                itemBuilder: (context, index) {
                                  final pageNumber = sortedDid[index];
                                  final ayahsOnPage = pages[pageNumber]!;

                                  return MushafSinglePage(
                                    pageNumber: pageNumber,
                                    ayahs: ayahsOnPage,
                                    surahName: widget.surah.englishName,
                                    surahNumber: widget.surah.number,
                                    panEnabled: true,
                                  );
                                },
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),

                    // Floating Back Button
                    Positioned(
                      top: 5.h,
                      left: 16.w,
                      child: CircleAvatar(
                        backgroundColor: Colors.black.withOpacity(
                          0.0,
                        ), // Transparent
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                          ),
                          onPressed: () => context.pop(),
                        ),
                      ),
                    ),

                    // Bookmark Button
                    Positioned(
                      top: 5.h,
                      right: 16.w,
                      child: BlocConsumer<BookmarkBloc, BookmarkState>(
                        listener: (context, state) {
                          if (state is BookmarkOperationSuccess) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Bookmark Added!'),
                                backgroundColor: Color(0xFF00E676),
                              ),
                            );
                          }
                        },
                        builder: (context, state) {
                          return CircleAvatar(
                            backgroundColor: Colors.black.withOpacity(
                              0.0,
                            ), // Transparent
                            child: Showcase(
                              key: _bookmarkKey,
                              description: AppLocalizations.of(
                                context,
                              )!.showcaseBookmark,
                              targetShapeBorder: const CircleBorder(),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.bookmark_border,
                                  color: Colors.black,
                                ),
                                onPressed: () {
                                  // Get current page info
                                  if (_lastPageNumber != -1) {
                                    final bookmark = QuranBookmark(
                                      surahNumber: widget.surah.number,
                                      surahName: widget.surah.englishName,
                                      pageNumber: _lastPageNumber,
                                      createdAt:
                                          DateTime.now().millisecondsSinceEpoch,
                                    );

                                    context.read<BookmarkBloc>().add(
                                      AddBookmark(bookmark),
                                    );

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Bookmarked Page $_lastPageNumber',
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Manual Completion Button (Bottom Right)
                    Positioned(
                      bottom: 40.h,
                      right: 16.w,
                      child: Opacity(
                        opacity: 0.4,
                        child: SizedBox(
                          width: 40.w,
                          height: 40.w,
                          child: FloatingActionButton(
                            mini: true,
                            elevation: 0,
                            heroTag: 'finish_reading_btn',
                            backgroundColor: const Color(0xFF00E676),
                            child: Showcase(
                              key: _completionKey,
                              description: AppLocalizations.of(
                                context,
                              )!.showcaseCompletion,
                              targetShapeBorder: const CircleBorder(),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            onPressed: () {
                              if (_lastPageNumber != -1) {
                                _logReading(
                                  context,
                                  _lastPageNumber,
                                  manual: true,
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    // Audio Player
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
      ),
    );
  }
}

class MushafSinglePage extends StatefulWidget {
  final int pageNumber;
  final List<Ayah> ayahs;
  final String surahName;
  final int surahNumber;
  final bool panEnabled;

  const MushafSinglePage({
    super.key,
    required this.pageNumber,
    required this.ayahs,
    required this.surahName,
    required this.surahNumber,
    this.panEnabled = true,
  });

  @override
  State<MushafSinglePage> createState() => _MushafSinglePageState();
}

class _MushafSinglePageState extends State<MushafSinglePage> {
  final TransformationController _transformationController =
      TransformationController();

  // State for highlighting
  int? _selectedSurah;
  int? _selectedAyah;
  Offset? _tapPosition;

  Future<void>? _fontFuture;

  @override
  void initState() {
    super.initState();
    _transformationController.value = Matrix4.identity()..scale(1.0);
    _fontFuture = _loadFont();
  }

  Future<void> _loadFont() async {
    final fontService = FontCacheService(Dio());
    await fontService.loadPageFont(widget.pageNumber);
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Exact logic from reference app for font sizing and layout
    final int page = widget.pageNumber;
    final bool isFatihahOrBaqarahStart = page == 1 || page == 2;

    // Font Size Logic (Reference: quran_page.dart line 348)
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

    // Line Height Logic (Reference: quran_page.dart line 337)
    final double lineHeight = isFatihahOrBaqarahStart ? 2.0 : 1.95;

    final String pageStr = widget.pageNumber.toString().padLeft(3, '0');
    final String fontFamily = 'QCF_P$pageStr';

    final List<Map<String, dynamic>> glyphs = GlyphHelper.getPageGlyphs(
      widget.pageNumber,
    );

    return BlocListener<AudioBloc, AudioState>(
      listener: (context, state) {
        if (state.currentSurahId != null && state.currentAyahNumber != null) {
          final isAyahOnPage =
              (widget.surahNumber == state.currentSurahId) &&
              widget.ayahs.any(
                (a) => a.numberInSurah == state.currentAyahNumber,
              );
          if (isAyahOnPage) {
            setState(() {
              _selectedSurah = state.currentSurahId;
              _selectedAyah = state.currentAyahNumber;
              _tapPosition = null;
            });
          } else {
            if (_selectedSurah != null || _selectedAyah != null) {
              setState(() {
                _selectedSurah = null;
                _selectedAyah = null;
                _tapPosition = null;
              });
            }
          }
        }
      },
      child: Column(
        children: [
          // Header
          // Header
          // Header
          Container(
            height: 60.h,
            color: const Color(0xffF1EEE5),
            padding: EdgeInsets.symmetric(horizontal: 64.w),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween, // Distribute to edges
              children: [
                // Left Side = Surah Name
                Text(
                  getSurahNameArabic(widget.surahNumber),
                  style: TextStyle(
                    fontFamily: "UthmanicHafs13",
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                // Play Button (Center)
                IconButton(
                  onPressed: () {
                    context.read<AudioBloc>().add(
                      PlaySurah(
                        surahId: widget.surahNumber,
                        surahName:
                            widget.surahName, // English Name passed in widget
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Playing Surah ${widget.surahName}'),
                        duration: const Duration(milliseconds: 800),
                        backgroundColor: const Color(0xFF00E676),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.play_circle_fill,
                    color: const Color(0xFF00E676),
                    size: 32.sp,
                  ),
                  tooltip: 'Play Full Surah',
                ),

                // Right Side = Juz Info
                Text(
                  'الجزء ${ArabicUtils.toArabicDigits(widget.ayahs.isNotEmpty ? widget.ayahs.first.juz : 1)}',
                  style: TextStyle(
                    fontFamily: "UthmanicHafs13",
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),

          // Page Content with Side Markers
          Expanded(
            child: Stack(
              children: [
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
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snapshot.hasError) {
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.w),
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
                                      AppLocalizations.of(
                                        context,
                                      )!.fontDownloadError,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.sp,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 5.h),
                                    Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.checkInternetConnection,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    SizedBox(height: 15.h),
                                    FilledButton(
                                      onPressed: () {
                                        setState(() {
                                          _fontFuture = _loadFont();
                                        });
                                      },
                                      child: Text(
                                        AppLocalizations.of(context)!.tryAgain,
                                      ),
                                    ),
                                    SizedBox(height: 20.h),
                                    Container(
                                      padding: EdgeInsets.all(8.w),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                      ),
                                      child: SelectableText(
                                        "Debug Info: ${snapshot.error}",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 10.sp,
                                          fontFamily: 'Courier',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          return InteractiveViewer(
                            panEnabled: widget.panEnabled,
                            transformationController: _transformationController,
                            minScale: 1.0,
                            maxScale: 5.0,
                            constrained:
                                false, // Allow content to exceed viewport height
                            child: Container(
                              // Constrain width to viewport width to force text wrapping
                              width: constraints.maxWidth,
                              // Allow height to be intrinsic (grow as needed)
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
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
                                  children: _buildPageSpans(context, glyphs),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                // Side Marker
                // Odd Page -> Right Side (Positioned Right)
                // Even Page -> Left Side (Positioned Left)
                if (page % 2 != 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 5.w,
                      height: 50.h, // Approx height for 2 lines
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E676).withOpacity(0.8),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(4.r),
                        ),
                      ),
                    ),
                  ),

                if (page % 2 == 0)
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      width: 5.w,
                      height: 50.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E676).withOpacity(0.8),
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(4.r),
                        ),
                      ),
                    ),
                  ),

                // Floating Bubble Menu
                if (_tapPosition != null && _selectedAyah != null)
                  _buildFloatingBubble(),
              ],
            ),
          ),

          // Footer: Page Number
          Container(
            height: 40.h,
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
      ),
    );
  }

  List<InlineSpan> _buildPageSpans(
    BuildContext context,
    List<Map<String, dynamic>> glyphs,
  ) {
    List<InlineSpan> spans = [];

    for (var i = 0; i < glyphs.length; i++) {
      final glyph = glyphs[i];
      final int surah = glyph['surah'];
      final int ayah = glyph['ayah'];

      // Check if this glyph belongs to the selected Ayah
      final bool isSelected = surah == _selectedSurah && ayah == _selectedAyah;

      // Check for Start of Surah (Ayah 1)
      if (ayah == 1) {
        // 1. Insert Header
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: MushafHeaderWidget(
              surahNumber: surah,
              surahNameArabic: getSurahNameArabic(surah),
              verseCount: getVerseCount(surah),
            ),
          ),
        );

        // 2. Insert Basmalah (Conditions: Not Surah 1 (Fatihah) and Not Surah 9 (Tawbah))
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

      // Split Marker: Usually the last character is the end-of-ayah marker (containing the number)
      // Check length to be safe
      if (cleanGlyph.length > 1) {
        final String contentText = cleanGlyph.substring(
          0,
          cleanGlyph.length - 1,
        );
        final String markerChar = cleanGlyph.substring(cleanGlyph.length - 1);

        // 1. Content Text
        spans.add(
          TextSpan(
            text: contentText,
            style: isSelected
                ? TextStyle(backgroundColor: const Color(0x6600E676))
                : null,
            recognizer: TapGestureRecognizer()
              ..onTapUp = (details) {
                setState(() {
                  if (_selectedSurah == surah && _selectedAyah == ayah) {
                    _selectedSurah = null;
                    _selectedAyah = null;
                    _tapPosition = null;
                  } else {
                    _selectedSurah = surah;
                    _selectedAyah = ayah;
                    _tapPosition = details.localPosition;
                  }
                });
              },
          ),
        );

        // 2. Ayah Marker with Gradient
        // Note: Gradient on Text requires usage of foreground Paint
        spans.add(
          TextSpan(
            text: markerChar,
            style: TextStyle(
              backgroundColor: isSelected ? const Color(0x6600E676) : null,
              foreground: Paint()
                ..shader =
                    const LinearGradient(
                      colors: [Color(0xFF00E676), Colors.blue],
                    ).createShader(
                      const Rect.fromLTWH(0.0, 0.0, 20.0, 20.0),
                    ), // Approx bounds for the glyph
            ),
            recognizer: TapGestureRecognizer()
              ..onTapUp = (details) {
                setState(() {
                  if (_selectedSurah == surah && _selectedAyah == ayah) {
                    _selectedSurah = null;
                    _selectedAyah = null;
                    _tapPosition = null;
                  } else {
                    _selectedSurah = surah;
                    _selectedAyah = ayah;
                    _tapPosition = details.localPosition;
                  }
                });
              },
          ),
        );
      } else {
        // Fallback for single char or empty (unlikely for full ayah but possible)
        spans.add(
          TextSpan(
            text: cleanGlyph,
            style: isSelected
                ? TextStyle(
                    backgroundColor: const Color(0x6600E676),
                  ) // Green highlight matching buttons
                : null,
            recognizer: TapGestureRecognizer()
              ..onTapUp = (details) {
                setState(() {
                  if (_selectedSurah == surah && _selectedAyah == ayah) {
                    _selectedSurah = null;
                    _selectedAyah = null;
                    _tapPosition = null;
                  } else {
                    _selectedSurah = surah;
                    _selectedAyah = ayah;
                    _tapPosition = details.localPosition;
                  }
                });
              },
          ),
        );
      }
    }
    return spans;
  }

  Widget _buildFloatingBubble() {
    if (_tapPosition == null) return const SizedBox.shrink();

    // Dimensions
    final double bubbleWidth = 170.w;
    final double screenWidth = MediaQuery.of(context).size.width;

    // X Position: Centered horizontally if possible, or clamped
    double left = _tapPosition!.dx - (bubbleWidth / 2);
    if (left < 16.w) left = 16.w;
    if (left + bubbleWidth > screenWidth - 16.w) {
      left = screenWidth - bubbleWidth - 16.w;
    }

    // Y Position: Above finger by default
    double top = _tapPosition!.dy - 280.h; // Increased height
    if (top < 100.h) {
      top = _tapPosition!.dy + 30.h;
    }

    final l10n = AppLocalizations.of(context)!;

    // Get Surah Name
    String surahName = "Surah $_selectedSurah";
    if (_selectedSurah != null) {
      final surahData = surahDetails.firstWhere(
        (s) => s['number'] == _selectedSurah,
        orElse: () => {},
      );
      if (surahData.isNotEmpty) {
        surahName = surahData['englishName'];
      }
    }

    return Positioned(
      top: top,
      left: left,
      child: Material(
        color: Colors.transparent,
        elevation: 8,
        borderRadius: BorderRadius.circular(16.r),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: bubbleWidth,
              padding: EdgeInsets.symmetric(vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFF263238).withOpacity(0.85),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 8.h,
                      horizontal: 12.w,
                    ),
                    child: Column(
                      children: [
                        Text(
                          surahName,
                          style: TextStyle(
                            color: const Color(0xFF00E676),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "Ayah $_selectedAyah",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 4.h,
                    ),
                    height: 1,
                    color: Colors.white10,
                  ),
                  _buildBubbleItem(
                    icon: Icons.play_circle_outline,
                    label: l10n.menuPlay,
                    onTap: () {
                      if (_selectedSurah != null) {
                        context.read<AudioBloc>().add(
                          PlaySurah(
                            surahId: _selectedSurah!,
                            surahName: surahName,
                            startAyah: _selectedAyah,
                          ),
                        );
                        // Hide bubble
                        setState(() {
                          _tapPosition = null;
                        });
                      }
                    },
                  ),
                  _buildDivider(),
                  _buildBubbleItem(
                    icon: Icons.translate,
                    label: l10n.menuTranslation,
                    onTap: () {
                      // Hide bubble first
                      setState(() {
                        _tapPosition = null;
                      });

                      // Find Ayah Text
                      // Find Ayah Text
                      final ayah = widget.ayahs.firstWhere(
                        (a) => a.numberInSurah == (_selectedAyah ?? 1),
                        orElse: () => widget.ayahs.first,
                      );

                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => TafsirBottomSheet(
                          surahId: _selectedSurah ?? widget.surahNumber,
                          surahName: surahName, // from scope
                          ayahNumber: _selectedAyah ?? 1,
                          arabicText: ayah.text,
                        ),
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildBubbleItem(
                    icon: Icons.library_books,
                    label: l10n.menuTafsir,
                    onTap: () {
                      // Hide bubble first
                      setState(() {
                        _tapPosition = null;
                      });

                      // Find Ayah Text
                      // Find Ayah Text
                      final ayah = widget.ayahs.firstWhere(
                        (a) => a.numberInSurah == (_selectedAyah ?? 1),
                        orElse: () => widget.ayahs.first,
                      );

                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => TafsirBottomSheet(
                          surahId: _selectedSurah ?? widget.surahNumber,
                          surahName: surahName,
                          ayahNumber: _selectedAyah ?? 1,
                          initialTabIndex: 1, // Open directly to Tafsir
                          arabicText: ayah.text,
                        ),
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildBubbleItem(
                    icon: Icons.bookmark_border,
                    label: l10n.menuBookmark,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Bookmarked!')),
                      );
                    },
                  ),
                  // Close Button (Small at bottom or rely on outside tap)
                  // Let's add a small divider and Close
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 4.h),
                    height: 1,
                    color: Colors.white10,
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _selectedSurah = null;
                        _selectedAyah = null;
                        _tapPosition = null;
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: Icon(
                        Icons.keyboard_arrow_up,
                        color: Colors.white54,
                        size: 20.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBubbleItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.white10,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20.sp),
            SizedBox(width: 12.w),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      height: 1,
      color: Colors.white10,
    );
  }
}

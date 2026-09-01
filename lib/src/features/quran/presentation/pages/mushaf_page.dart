import 'package:flutter/material.dart';

import 'package:muslimly/src/features/quran/data/surah_details.dart';

import 'package:muslimly/src/l10n/generated/app_localizations.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:muslimly/src/core/di/di_container.dart';
import '../../../../core/services/showcase_preferences_service.dart';
import 'package:muslimly/src/core/widgets/islamic_loading_indicator.dart';
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
import 'package:muslimly/src/features/quran/presentation/bloc/bookmark/bookmark_operation_type.dart';
import 'package:muslimly/src/features/quran/domain/entities/quran_bookmark.dart';
import 'package:muslimly/src/features/quran/domain/entities/last_read.dart';
import 'package:muslimly/src/features/quran/presentation/widgets/bookmark_folder_picker_sheet.dart';
// import 'package:wakelock_plus/wakelock_plus.dart'; // Temporarily disabled if package missing
import '../../../../core/utils/custom_snackbar.dart'; // Import Custom SnackBar

import 'package:muslimly/src/features/quran/presentation/widgets/draggable_audio_player.dart';
import '../widgets/mushaf_single_page.dart';
import 'package:muslimly/src/features/quran/presentation/bloc/audio_bloc.dart';
import 'package:muslimly/src/features/quran/presentation/bloc/audio_state.dart';
import 'package:showcaseview/showcaseview.dart';
import '../../../../core/presentation/widgets/premium_showcase.dart';

import 'package:muslimly/src/features/quran/presentation/widgets/ayah_selector_bottom_sheet.dart';
import 'package:muslimly/src/core/utils/quran_constants.dart';
import 'package:muslimly/src/core/utils/surah_names.dart';
import '../../../../core/theme/app_colors.dart';

class MushafPage extends StatefulWidget {
  final Surah? surah;
  final bool startAtEnd;
  final int? initialPage;
  final int? initialAyah;

  const MushafPage({
    super.key,
    this.surah,
    this.startAtEnd = false,
    this.initialPage,
    this.initialAyah,
  });

  @override
  State<MushafPage> createState() => _MushafPageState();
}

class _MushafPageState extends State<MushafPage> {
  PageController? _pageController;
  bool _isNavigating = false; // Debounce flag
  late Surah _surah; // Local state for Surah

  // Reading Tracking
  final Stopwatch _readStopwatch = Stopwatch();
  int _lastPageNumber = -1; // Track the page being read
  int? _highlightedAyah; // For jump navigation

  // Showcase Keys
  final GlobalKey _swipeKey = GlobalKey();
  final GlobalKey _bookmarkKey = GlobalKey();
  final GlobalKey _completionKey = GlobalKey();
  final GlobalKey _jumpToAyahKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late ShowcaseView _showcaseView;
  final String _showcaseScope = ShowcaseScopes.mushaf();

  // Tracks the surah the audio player was on during the previous AudioState
  // emission, so auto-navigation only triggers when the audio *moves away
  // from this page's surah* — not when this page is opened while another
  // surah is already playing.
  int? _lastAudioSurahId;

  // Owned directly by state to avoid context.read<ReadingBloc>() calls that
  // can fail when the calling context is above the MultiBlocProvider returned
  // from build() (e.g. closures captured before the provider subtree exists).
  late final ReadingBloc _readingBloc;

  @override
  void initState() {
    super.initState();
    _readingBloc = getIt<ReadingBloc>();
    _showcaseView = ShowcaseView.register(scope: _showcaseScope);
    // Initialize Surah
    _initializeSurah();

    // Set highlighted ayah from navigation
    if (widget.initialAyah != null) {
      _highlightedAyah = widget.initialAyah;
    }

    // Start stopwatch when entering the view
    _readStopwatch.start();

    // Check for showcase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowShowcase();
    });
  }

  Future<void> _checkAndShowShowcase() async {
    final showcaseService = getIt<ShowcasePreferencesService>();
    final hasShown = await showcaseService.hasShown(ShowcaseKeys.mushaf);

    if (!hasShown && mounted) {
      _showcaseView.startShowCase([_swipeKey, _bookmarkKey, _completionKey]);
      await showcaseService.markShown(ShowcaseKeys.mushaf);
    }
  }

  void _initializeSurah() {
    if (widget.surah != null) {
      _surah = widget.surah!;
    } else if (widget.initialPage != null) {
      // Find Surah from Page
      final page = widget.initialPage!;
      // Iterate map to find range
      int foundSurahNum = 1;
      for (var entry in QuranConstants.surahPageStart.entries) {
        if (entry.value <= page) {
          foundSurahNum = entry.key;
        } else {
          break;
        }
      }

      // Construct Surah Object manually from Constants to avoid Provider lookup issue in initState
      // Use core utils SurahNames and QuranConstants
      final englishName =
          SurahNames.englishNames[foundSurahNum - 1]; // indonesianNames aligned
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
      // Should not happen
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
    // Dismiss before unregister: unregister() only removes the overlay entry
    // when currentScope still matches this page's scope, so a showcase left
    // running while another scope took over would leak its overlay and crash
    // on a later rebuild once no scope is registered.
    _readingBloc.close();
    if (_showcaseView.isShowcaseRunning) {
      _showcaseView.dismiss();
    }
    _showcaseView.unregister();
    _pageController?.dispose();
    _readStopwatch.stop();
    super.dispose();
  }

  void _logReading(BuildContext context, int pageNum, {bool manual = false}) {
    // If manual, we bypass the 20s check
    if (manual || _readStopwatch.elapsed.inSeconds > 20) {
      final duration = _readStopwatch.elapsed.inSeconds;

      _readingBloc.add(
        LogPageRead(
          pageNumber: pageNum,
          durationSeconds: duration,
          surahNumber: _surah.number,
        ),
      );

      // Trigger background sync
      _readingBloc.add(SyncReadingData());

      String durationStr;
      if (duration < 60) {
        durationStr = "${duration}s";
      } else {
        final minutes = duration ~/ 60;
        final seconds = duration % 60;
        durationStr = "${minutes}m ${seconds}s";
      }

      // Subtle notification - small toast at bottom
      showCustomSnackBar(
        context,
        message: AppLocalizations.of(
          context,
        )!.sbPageReadLogged(durationStr, pageNum.toString()),
        type: SnackBarType.info,
        duration: const Duration(seconds: 3),
      );
    }
    _readStopwatch.reset();
    _readStopwatch.start();
  }

  void _showJumpToAyah(BuildContext context) {
    // Capture bloc and localization BEFORE showModalBottomSheet
    // to avoid ProviderNotFoundException in bottom sheet's context
    final quranBloc = context.read<QuranBloc>();
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => AyahSelectorBottomSheet(
        totalAyahs: _surah.numberOfAyahs,
        surahName: _surah.englishName,
        onAyahSelected: (ayahNumber) {
          // Use captured references from parent context
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              setState(() {
                _highlightedAyah = ayahNumber;
              });

              // Use captured bloc reference
              final state = quranBloc.state;
              if (state is QuranAyahsLoaded) {
                try {
                  final targetAyah = state.ayahs.firstWhere(
                    (a) => a.numberInSurah == ayahNumber,
                  );
                  // Find page
                  final uniquePages =
                      state.ayahs.map((e) => e.page).toSet().toList()..sort();
                  final index = uniquePages.indexOf(targetAyah.page);

                  if (index != -1 && _pageController != null) {
                    _pageController!.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );

                    showCustomSnackBar(
                      _scaffoldKey.currentContext!,
                      message: l10n.sbJumpedToAyah(ayahNumber.toString()),
                      type: SnackBarType.success,
                    );
                  }
                } catch (e) {
                  // Error handling
                }
              }
            }
          });
        },
      ),
    );
  }

  // ... (Previous methods: _goToPreviousSurah, _goToNextSurah)

  void _goToPreviousSurah(BuildContext context) {
    if (_isNavigating) return; // Prevent multiple calls

    if (_surah.number > 1) {
      // Can go back if > 1 (Al-Fatihah is 1)
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
          message: AppLocalizations.of(
            context,
          )!.sbOpeningSurah(prevSurah.englishName),
          type: SnackBarType.info,
          duration: const Duration(milliseconds: 800),
        );

        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
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
      showCustomSnackBar(
        context,
        message: AppLocalizations.of(context)!.sbStartOfQuran,
        type: SnackBarType.info,
      );
    }
  }

  void _goToNextSurah(BuildContext context) {
    // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Navigating...')));

    if (_isNavigating) return; // Prevent multiple calls

    if (_surah.number < 114) {
      _isNavigating = true; // Set flag

      final nextSurahNumber = _surah.number + 1;

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

        showCustomSnackBar(
          context,
          message: AppLocalizations.of(
            context,
          )!.sbOpeningSurah(nextSurah.englishName),
          type: SnackBarType.info,
          duration: const Duration(milliseconds: 800),
        );

        // Delay slightly for visual feedback then navigate
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            context.pushReplacement(
              '/quran/mushaf/${nextSurah.number}', // Corrected route with ID
              extra: nextSurah,
            );
          }
        });
      } else {
        _isNavigating = false; // Reset if failed
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

  // ... (build)

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              getIt<QuranBloc>()..add(QuranFetchAyahs(_surah.number)),
        ),
        BlocProvider.value(value: _readingBloc),
        BlocProvider(create: (context) => getIt<BookmarkBloc>()),
      ],
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFFFFF8E1), // Cream background for Mushaf
        body: BlocListener<AudioBloc, AudioState>(
          listenWhen: (previous, current) {
            return previous.currentSurahId != current.currentSurahId ||
                previous.currentAyahNumber != current.currentAyahNumber ||
                previous.status != current.status;
          },
          listener: (context, audioState) {
            final cameFromThisSurah = _lastAudioSurahId == _surah.number;
            _lastAudioSurahId = audioState.currentSurahId;

            // 1. Auto-Scroll to Ayah if on same Surah
            if (audioState.currentSurahId == _surah.number &&
                audioState.currentAyahNumber != null) {
              final quranState = context.read<QuranBloc>().state;
              if (quranState is QuranAyahsLoaded) {
                try {
                  final ayah = quranState.ayahs.firstWhere(
                    (a) => a.numberInSurah == audioState.currentAyahNumber,
                  );
                  // Determine the Index of the page this ayah belongs to
                  final uniquePages =
                      quranState.ayahs.map((e) => e.page).toSet().toList()
                        ..sort();
                  final targetPageIndex = uniquePages.indexOf(ayah.page);

                  if (targetPageIndex != -1 &&
                      _pageController != null &&
                      _pageController!.hasClients) {
                    final currentPageIndex =
                        _pageController!.page?.round() ?? -1;

                    if (currentPageIndex != targetPageIndex) {
                      // Animate to the correct page
                      _pageController!.animateToPage(
                        targetPageIndex,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    }
                  }
                } catch (_) {
                  // Fail silently if ayah not found or weird state
                }
              }
            }
            // 2. Auto-Navigate if Surah Changed (Audio moved to next/prev
            // Surah) — only when the audio actually moved away from this
            // page's surah, so opening another surah while audio is
            // playing doesn't hijack navigation
            else if (cameFromThisSurah &&
                audioState.status == AudioStatus.playing &&
                audioState.currentSurahId != null &&
                audioState.currentSurahId != _surah.number) {
              // Find new Surah Data
              final newSurahId = audioState.currentSurahId!;
              final nextSurahData = surahDetails.firstWhere(
                (element) => element['number'] == newSurahId,
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

                // Navigate
                context.pushReplacement(
                  '/quran/mushaf/${nextSurah.number}',
                  extra: nextSurah,
                );
              }
            }
          },
          child: Stack(
            children: [
              SafeArea(
                child: Stack(
                  children: [
                    BlocBuilder<QuranBloc, QuranState>(
                      builder: (context, state) {
                        if (state is QuranLoading) {
                          return const Center(
                            child: IslamicLoadingIndicator(size: 48),
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
                            child: PremiumShowcase(
                              globalKey: _swipeKey,
                              scope: _showcaseScope,
                              title: AppLocalizations.of(
                                context,
                              )!.quranNavigationTitle,
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
                                    surahName: _surah.englishName,
                                    surahNumber: _surah.number,
                                    // Note: We don't have exact Ayah here easily without finding first ayah of newPage
                                    // But pageNumber is enough for navigation.
                                  );
                                  context.read<BookmarkBloc>().add(
                                    SaveLastRead(lastRead),
                                  );

                                  // Trigger background sync for Last Read
                                  _readingBloc.add(
                                    SyncLastRead(
                                      pageNumber: lastRead.pageNumber,
                                      surahNumber: lastRead.surahNumber,
                                      surahName: lastRead.surahName,
                                      ayahNumber: lastRead.ayahNumber,
                                      mode: 'mushaf',
                                    ),
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
                                    surahName: _surah.englishName,
                                    surahNumber: _surah.number,
                                    panEnabled: true,
                                    onJumpTap: () => _showJumpToAyah(context),
                                    jumpKey: _jumpToAyahKey,
                                    highlightedAyah: _highlightedAyah,
                                    showcaseScope: _showcaseScope,
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
                        backgroundColor: Colors.black.withValues(
                          alpha: 0.0,
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
                            final l10n = AppLocalizations.of(context)!;
                            final message =
                                state.type == BookmarkOperationType.saved
                                ? l10n.sbBookmarkSaved
                                : l10n.sbBookmarkRemoved;

                            showCustomSnackBar(
                              context,
                              message: message,
                              type: state.type == BookmarkOperationType.removed
                                  ? SnackBarType.info
                                  : SnackBarType.success,
                            );
                          } else if (state is BookmarkError) {
                            showCustomSnackBar(
                              context,
                              message: state.message,
                              type: SnackBarType.error,
                            );
                          }
                        },
                        builder: (context, state) {
                          bool isBookmarked = false;
                          if (state is BookmarkLoaded) {
                            isBookmarked = state.bookmarks.any(
                              (b) =>
                                  b.pageNumber == _lastPageNumber &&
                                  b.mode == 'mushaf' &&
                                  b.ayahNumber == null,
                            );
                          }

                          return CircleAvatar(
                            backgroundColor: Colors.black.withValues(
                              alpha: 0.0,
                            ), // Transparent
                            child: PremiumShowcase(
                              globalKey: _bookmarkKey,
                              scope: _showcaseScope,
                              title: AppLocalizations.of(context)!.menuBookmark,
                              description: AppLocalizations.of(
                                context,
                              )!.showcaseBookmark,
                              targetShapeBorder: const CircleBorder(),
                              child: IconButton(
                                icon: Icon(
                                  isBookmarked
                                      ? Icons.bookmark
                                      : Icons.bookmark_border,
                                  color: isBookmarked
                                      ? AppColors.accent
                                      : Colors.black,
                                ),
                                onPressed: () async {
                                  if (_lastPageNumber == -1) return;

                                  final bookmarkBloc = context
                                      .read<BookmarkBloc>();
                                  int? folderId;
                                  // Removing is instant; adding asks the folder.
                                  if (!isBookmarked) {
                                    final choice = await showBookmarkFolderPicker(
                                      context,
                                      mode: 'mushaf',
                                    );
                                    if (choice == null) return;
                                    folderId = choice.folderId;
                                  }
                                  if (!mounted) return;

                                  final bookmark = QuranBookmark(
                                    surahNumber: _surah.number,
                                    surahName: _surah.englishName,
                                    pageNumber: _lastPageNumber,
                                    createdAt:
                                        DateTime.now().millisecondsSinceEpoch,
                                    mode: 'mushaf',
                                    folderId: folderId,
                                  );

                                  bookmarkBloc.add(ToggleBookmark(bookmark));
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
                      child: Builder(
                        builder: (ctx) => Opacity(
                          opacity: 0.4,
                          child: PremiumShowcase(
                            globalKey: _completionKey,
                            scope: _showcaseScope,
                            title: AppLocalizations.of(ctx)!.markAsRead,
                            description: AppLocalizations.of(
                              ctx,
                            )!.showcaseCompletion,
                            targetShapeBorder: const CircleBorder(),
                            child: SizedBox(
                              width: 40.w,
                              height: 40.w,
                              child: FloatingActionButton(
                                mini: true,
                                elevation: 0,
                                heroTag: 'finish_reading_btn',
                                backgroundColor: AppColors.accent,
                                onPressed: () {
                                  if (_lastPageNumber != -1) {
                                    _logReading(
                                      ctx,
                                      _lastPageNumber,
                                      manual: true,
                                    );
                                    showCustomSnackBar(
                                      ctx,
                                      message: AppLocalizations.of(
                                        ctx,
                                      )!.sbReadingSaved,
                                      type: SnackBarType.success,
                                    );
                                  }
                                },
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Audio Player
                  ],
                ),
              ),
              // Audio Player (Moved outside SafeArea)
              // Audio Player (Moved outside SafeArea)
              DraggableAudioPlayer(
                showcasePrefsKey: 'hasShownMushafPlayerShowcase',
                enableShowcase: false,
                showcaseScope: _showcaseScope,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

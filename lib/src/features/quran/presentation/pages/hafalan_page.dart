import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:muslimly/src/core/widgets/islamic_loading_indicator.dart';
import 'package:muslimly/src/features/quran/domain/entities/surah.dart';
import 'package:muslimly/src/features/quran/domain/entities/ayah.dart';
import 'package:muslimly/src/features/quran/domain/entities/hafalan_session.dart';
import 'package:muslimly/src/features/quran/presentation/bloc/quran_bloc.dart';
import 'package:muslimly/src/features/quran/presentation/bloc/quran_event.dart';
import 'package:muslimly/src/features/quran/presentation/bloc/quran_state.dart';
import 'package:muslimly/src/features/quran/presentation/bloc/hafalan/hafalan_bloc.dart';
import 'package:muslimly/src/features/quran/presentation/bloc/hafalan/hafalan_event.dart';
import 'package:muslimly/src/features/quran/presentation/bloc/hafalan/hafalan_state.dart';
import 'package:muslimly/src/core/database/database_service.dart';
import 'package:muslimly/src/core/di/di_container.dart';
import 'package:muslimly/src/core/utils/quran_constants.dart';
import 'package:muslimly/src/core/utils/surah_names.dart';
import 'package:muslimly/src/features/quran/data/surah_details.dart';
import 'package:muslimly/src/features/quran/presentation/widgets/draggable_audio_player.dart';
import 'package:muslimly/src/features/settings/presentation/bloc/settings_cubit.dart';
import '../../../../core/utils/custom_snackbar.dart';
import '../widgets/hafalan_single_page.dart';

import '../../../../core/theme/app_colors.dart';

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

  /// Ayahs of the mushaf page currently shown in the PageView — tracked
  /// outside HafalanBloc so a completed session can be persisted with the
  /// right (surah, page, ayah range) once HafalanState.status flips to
  /// completed, regardless of which page the shared bloc is currently on.
  int? _currentPageNumber;
  List<Ayah> _currentPageAyahs = const [];

  Future<void> _recordCompletedSession(
    double accuracy,
    String? audioFilePath,
  ) async {
    final ayahs = _currentPageAyahs;
    final pageNumber = _currentPageNumber;
    if (ayahs.isEmpty || pageNumber == null) return;

    final now = DateTime.now();
    final session = HafalanSession(
      surahNumber: _surah.number,
      pageNumber: pageNumber,
      startAyah: ayahs.first.numberInSurah,
      endAyah: ayahs.last.numberInSurah,
      ayahCount: ayahs.length,
      accuracy: accuracy,
      date: DateFormat('yyyy-MM-dd').format(now),
      timestamp: now.millisecondsSinceEpoch,
      audioFilePath: audioFilePath,
    );

    try {
      final db = getIt<DatabaseService>();
      // Retention (§F): a fresh recording for this same (surah, halaman)
      // unit replaces any earlier one — purge old sessions' audio first so
      // storage doesn't grow unbounded, unless the user explicitly
      // protected one via the "save" toggle (isAudioSaved).
      if (audioFilePath != null) {
        await _purgeOldAudioForUnit(db, _surah.number, pageNumber);
      }
      await db.insertHafalanSession(session);
    } catch (_) {
      // Best-effort: a failed local write shouldn't disrupt the reveal UX.
    }
  }

  Future<void> _purgeOldAudioForUnit(
    DatabaseService db,
    int surahNumber,
    int pageNumber,
  ) async {
    final priorWithAudio = await db.getHafalanSessionsWithAudioForUnit(
      surahNumber,
      pageNumber,
    );
    for (final old in priorWithAudio) {
      if (old.isAudioSaved == 1 || old.audioFilePath == null) continue;
      try {
        final file = File(old.audioFilePath!);
        if (await file.exists()) await file.delete();
      } catch (_) {
        // Best-effort: an orphaned file on disk is harmless.
      }
      if (old.id != null) {
        await db.clearHafalanAudioFilePath(old.id!);
      }
    }
  }

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
          message: AppLocalizations.of(
            context,
          )!.sbOpeningSurah(prevSurah.englishName),
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
          message: AppLocalizations.of(
            context,
          )!.sbOpeningSurah(nextSurah.englishName),
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
        BlocProvider(
          create: (context) => HafalanBloc(
            kidsMode: context.read<SettingsCubit>().state.kidsMode,
            recordAudio: context.read<SettingsCubit>().state.recordHafalan,
          )..add(InitSpeech()),
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.creamBg,
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
                    final initialPageNumber = sortedPages[initialIndex];
                    final initialAyahs = pages[initialPageNumber]!;
                    _currentPageNumber = initialPageNumber;
                    _currentPageAyahs = initialAyahs;
                    context.read<HafalanBloc>().setAyahs(initialAyahs);
                  }
                }

                return BlocListener<HafalanBloc, HafalanState>(
                  listenWhen: (prev, curr) =>
                      prev.status != HafalanStatus.completed &&
                      curr.status == HafalanStatus.completed,
                  listener: (context, state) {
                    _recordCompletedSession(
                      state.overallAccuracy,
                      state.audioFilePath,
                    );
                  },
                  child: Stack(
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
                            final newPageNumber = sortedPages[index];
                            final newAyahs = pages[newPageNumber]!;
                            _currentPageNumber = newPageNumber;
                            _currentPageAyahs = newAyahs;
                            final hafalanBloc = context.read<HafalanBloc>();
                            hafalanBloc.setAyahs(newAyahs);
                            hafalanBloc.add(ResetHafalan());
                          },
                          itemCount: sortedPages.length,
                          itemBuilder: (context, index) {
                            final pageNumber = sortedPages[index];
                            final ayahsOnPage = pages[pageNumber]!;

                            return HafalanSinglePage(
                              pageNumber: pageNumber,
                              ayahs: ayahsOnPage,
                              surahName: _surah.englishName,
                              surahNumber: _surah.number,
                              kidsMode: context
                                  .read<SettingsCubit>()
                                  .state
                                  .kidsMode,
                            );
                          },
                        ),
                      ),
                      Positioned(
                        top: 5.h,
                        left: 16.w,
                        child: CircleAvatar(
                          backgroundColor: Colors.black.withValues(alpha: 0.0),
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.black,
                            ),
                            onPressed: () => context.pop(),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 5.h,
                        right: 16.w,
                        child: CircleAvatar(
                          backgroundColor: Colors.black.withValues(alpha: 0.0),
                          child: IconButton(
                            icon: const Icon(
                              Icons.bar_chart_rounded,
                              color: Colors.black,
                            ),
                            tooltip: AppLocalizations.of(
                              context,
                            )!.hafalanProgressPageTitle,
                            onPressed: () =>
                                context.push('/quran/hafalan/progress'),
                          ),
                        ),
                      ),
                      // Mode Anak's "Dengar Ayat Ini" button needs somewhere
                      // to surface playback controls — this page doesn't
                      // otherwise mount a player.
                      if (context.watch<SettingsCubit>().state.kidsMode)
                        DraggableAudioPlayer(
                          enableShowcase: false,
                          // Clears HafalanSinglePage's own bottom mic/skip/
                          // reset control bar (~44.w mic button + padding +
                          // safe area) so the docked mini player doesn't sit
                          // on top of it.
                          miniBottomOffset: 100.h,
                        ),
                    ],
                  ),
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

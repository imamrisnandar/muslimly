import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/di_container.dart';
import '../../../../core/utils/surah_names.dart';
import '../../domain/entities/surah.dart';
import '../../data/surah_details.dart'; // To reconstruct Surah object for logic
import '../bloc/bookmark/bookmark_bloc.dart';
import '../../domain/entities/last_read.dart';
import '../bloc/bookmark/bookmark_event.dart';
import '../bloc/bookmark/bookmark_state.dart';
import '../bloc/reading/reading_bloc.dart';
import '../bloc/reading/reading_event.dart';
import '../bloc/reading/reading_state.dart';

import '../../../../l10n/generated/app_localizations.dart';

class BookmarksPage extends StatelessWidget {
  const BookmarksPage({super.key});

  @override
  Widget build(BuildContext context) {
    // We need access to ReadingBloc to know the targetUnit settings
    // But ReadingBloc might not be provided above this page if navigated directly?
    // Usually SettingsBloc is better for settings, but ReadingBloc holds it too.
    // Let's assume ReadingBloc is singleton or we create it.
    // Actually, creating a new ReadingBloc just for settings reference is fine.

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<BookmarkBloc>()..add(LoadBookmarks()),
        ),
        BlocProvider(
          create: (context) =>
              getIt<ReadingBloc>()
                ..add(LoadReadingOverview()), // To fetch settings
        ),
      ],
      child: BlocBuilder<ReadingBloc, ReadingState>(
        builder: (context, readingState) {
          // Determine initial index
          final initialIndex = readingState.targetUnit == 'ayah' ? 0 : 1;

          return DefaultTabController(
            key: ValueKey(
              'bookmark_tab_$initialIndex',
            ), // Force rebuild if index changes
            length: 2,
            initialIndex: initialIndex,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0F2027),
                    Color(0xFF203A43),
                    Color(0xFF2C5364),
                  ],
                ),
              ),
              child: Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  centerTitle: true,
                  leading: const BackButton(color: Colors.white),
                  title: Text(
                    AppLocalizations.of(context)!.lblBookmarks ?? "Bookmarks",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Outfit',
                    ),
                  ),
                  bottom: PreferredSize(
                    preferredSize: Size.fromHeight(60.h),
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(50.r),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: TabBar(
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(40.r),
                          color: const Color(0xFF00E676),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00E676).withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        labelColor: const Color(0xFF052025),
                        unselectedLabelColor: Colors.white70,
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15.sp,
                          fontFamily: 'Outfit',
                          letterSpacing: 0.5,
                        ),
                        unselectedLabelStyle: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15.sp,
                          fontFamily: 'Outfit',
                          letterSpacing: 0.5,
                        ),
                        splashBorderRadius: BorderRadius.circular(40.r),
                        tabs: [
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.format_list_bulleted_rounded,
                                  size: 18,
                                ),
                                SizedBox(width: 6.w),
                                Flexible(
                                  child: Text(
                                    AppLocalizations.of(context)!.lblListType ??
                                        "Ayah",
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.menu_book_rounded, size: 18),
                                SizedBox(width: 6.w),
                                Flexible(
                                  child: Text(
                                    AppLocalizations.of(
                                          context,
                                        )!.lblMushafType ??
                                        "Mushaf",
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                body: BlocBuilder<BookmarkBloc, BookmarkState>(
                  builder: (context, state) {
                    if (state is BookmarkLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF00E676),
                        ),
                      );
                    } else if (state is BookmarkLoaded) {
                      // Filter Bookmarks
                      final listBookmarks = state.bookmarks
                          .where(
                            (b) => b.ayahNumber != null && b.ayahNumber! > 0,
                          )
                          .toList();
                      final mushafBookmarks = state.bookmarks
                          .where(
                            (b) => b.ayahNumber == null || b.ayahNumber == 0,
                          )
                          .toList();

                      return TabBarView(
                        children: [
                          // --- TAB 1: LIST MODE ---
                          _buildBookmarkList(
                            context: context,
                            bookmarks: listBookmarks,
                            lastRead: state.lastReadList,
                            isListMode: true,
                            emptyMessageTitle:
                                AppLocalizations.of(
                                  context,
                                )!.emptyBookmarkAyahTitle ??
                                "No Ayah Bookmarks",
                            emptyMessageSubtitle:
                                AppLocalizations.of(
                                  context,
                                )!.emptyBookmarkAyahSubtitle ??
                                "Your marked ayahs will appear here",
                          ),

                          // --- TAB 2: MUSHAF MODE ---
                          _buildBookmarkList(
                            context: context,
                            bookmarks: mushafBookmarks,
                            lastRead: state.lastReadMushaf,
                            isListMode: false,
                            emptyMessageTitle:
                                AppLocalizations.of(
                                  context,
                                )!.emptyBookmarkPageTitle ??
                                "No Page Bookmarks",
                            emptyMessageSubtitle:
                                AppLocalizations.of(
                                  context,
                                )!.emptyBookmarkPageSubtitle ??
                                "Your marked pages will appear here",
                          ),
                        ],
                      );
                    } else if (state is BookmarkError) {
                      return Center(
                        child: Text(
                          state.message,
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBookmarkList({
    required BuildContext context,
    required List<dynamic> bookmarks, // List<QuranBookmark>
    required dynamic lastRead, // LastRead?
    required bool isListMode,
    required String emptyMessageTitle,
    required String emptyMessageSubtitle,
  }) {
    // If absolutely empty
    if (bookmarks.isEmpty && lastRead == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isListMode
                    ? Icons.format_list_bulleted_rounded
                    : Icons.menu_book_rounded,
                size: 48.sp,
                color: Colors.white24,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              emptyMessageTitle,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'Outfit',
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              emptyMessageSubtitle,
              style: TextStyle(color: Colors.white54, fontSize: 14.sp),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      children: [
        // --- LAST READ HERO CARD ---
        if (lastRead != null) ...[
          Padding(
            padding: EdgeInsets.only(left: 4.w, bottom: 12.h),
            child: Row(
              children: [
                Icon(
                  Icons.history,
                  color: const Color(0xFF00E676),
                  size: 18.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  AppLocalizations.of(context)!.cardContinueReading,
                  style: TextStyle(
                    color: const Color(0xFF00E676),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    fontFamily: 'Outfit',
                  ),
                ),
              ],
            ),
          ),
          _buildLastReadCard(context, lastRead, isListMode: isListMode),
          SizedBox(height: 32.h),
        ],

        // --- BOOKMARKS LIST ---
        if (bookmarks.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(left: 4.w, bottom: 12.h),
            child: Row(
              children: [
                Icon(
                  Icons.bookmark_outline,
                  color: Colors.white70,
                  size: 18.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  AppLocalizations.of(context)!.lblSavedBookmarks ??
                      "SAVED BOOKMARKS",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    fontFamily: 'Outfit',
                  ),
                ),
              ],
            ),
          ),

        ...bookmarks.map((bookmark) {
          final surahName =
              (bookmark.surahNumber >= 1 && bookmark.surahNumber <= 114)
              ? SurahNames.indonesianNames[bookmark.surahNumber - 1]
              : bookmark.surahName;

          return Container(
            margin: EdgeInsets.only(bottom: 12.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03), // Lighter/Darker than hero
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: Colors.white.withOpacity(0.05),
              ), // Subtle border
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16.r),
                onTap: () {
                  // Navigate
                  final surahData = surahDetails.firstWhere(
                    (e) => e['number'] == bookmark.surahNumber,
                    orElse: () => {},
                  );
                  if (surahData.isNotEmpty) {
                    final surah = Surah(
                      number: surahData['number'],
                      name: surahData['name'],
                      englishName: surahData['englishName'],
                      englishNameTranslation: '',
                      indonesianNameTranslation: '',
                      numberOfAyahs: surahData['numberOfAyahs'],
                      revelationType: surahData['revelationType'],
                    );
                    if (isListMode) {
                      context.push(
                        '/quran/${surah.number}',
                        extra: {
                          'surah': surah,
                          'initialAyah': bookmark.ayahNumber,
                        },
                      );
                    } else {
                      context.push(
                        '/quran/mushaf/${surah.number}',
                        extra: {
                          'surah': surah,
                          'initialPage': bookmark.pageNumber,
                        },
                      );
                    }
                  }
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  child: Row(
                    children: [
                      // Minimalist Icon
                      Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          isListMode
                              ? Icons.format_list_bulleted
                              : Icons.menu_book,
                          color: Colors.white60,
                          size: 20.sp,
                        ),
                      ),
                      SizedBox(width: 16.w),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              surahName,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.9),
                                fontFamily: 'Outfit',
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              isListMode
                                  ? "${AppLocalizations.of(context)!.lblAyah ?? 'Ayah'} ${bookmark.ayahNumber}"
                                  : "${AppLocalizations.of(context)!.lblPage ?? 'Page'} ${bookmark.pageNumber}",
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.white54,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Delete Action
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: Colors.white24,
                          size: 20.sp,
                        ),
                        onPressed: () {
                          context.read<BookmarkBloc>().add(
                            DeleteBookmark(bookmark.id!),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildLastReadCard(
    BuildContext context,
    LastRead lastRead, {
    required bool isListMode,
  }) {
    final surahName = (lastRead.surahNumber >= 1 && lastRead.surahNumber <= 114)
        ? SurahNames.indonesianNames[lastRead.surahNumber - 1]
        : lastRead.surahName;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        // Premium Gradient
        gradient: const LinearGradient(
          colors: [Color(0xFF00BFA5), Color(0xFF00E676)], // Teal to Green
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E676).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (isListMode) {
              context.push(
                '/quran/${lastRead.surahNumber}',
                extra: {
                  'surah': Surah(
                    number: lastRead.surahNumber,
                    name: lastRead.surahName,
                    englishName: lastRead.surahName,
                    englishNameTranslation: '',
                    numberOfAyahs: 0,
                    revelationType: '',
                    indonesianNameTranslation: '',
                  ),
                  'initialAyah': lastRead.ayahNumber,
                },
              );
            } else {
              // Navigate Mushaf
              context.push(
                '/quran/mushaf/${lastRead.surahNumber}',
                extra: {
                  'surah': Surah(
                    number: lastRead.surahNumber,
                    englishName: lastRead.surahName,
                    name: '',
                    englishNameTranslation: '',
                    numberOfAyahs: 0,
                    revelationType: '',
                    indonesianNameTranslation: '',
                  ),
                  'initialPage': lastRead.pageNumber,
                },
              );
            }
          },
          borderRadius: BorderRadius.circular(20.r),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          isListMode
                              ? "CONTINUE READING (AYAH)"
                              : "CONTINUE READING (PAGE)",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        surahName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Outfit',
                          height: 1.1,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        isListMode
                            ? "Ayah ${lastRead.ayahNumber}"
                            : "Page ${lastRead.pageNumber}",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Play Icon Button Style
                Container(
                  height: 48.w,
                  width: 48.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: const Color(0xFF00BFA5),
                    size: 28.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

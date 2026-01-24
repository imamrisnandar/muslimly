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
import '../bloc/bookmark/bookmark_event.dart';
import '../bloc/bookmark/bookmark_state.dart';

import '../../../../l10n/generated/app_localizations.dart';

class BookmarksPage extends StatelessWidget {
  const BookmarksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<BookmarkBloc>()..add(LoadBookmarks()),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: const BackButton(color: Colors.white),
            title: Text(
              'Bookmarks',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: BlocBuilder<BookmarkBloc, BookmarkState>(
            builder: (context, state) {
              if (state is BookmarkLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF00E676)),
                );
              } else if (state is BookmarkLoaded) {
                return Column(
                  children: [
                    // --- LAST READ CARD ---
                    if (state.lastRead != null)
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.all(16.w),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              final surahData = surahDetails.firstWhere(
                                (e) =>
                                    e['number'] == state.lastRead!.surahNumber,
                                orElse: () => {},
                              );

                              if (surahData.isNotEmpty) {
                                final surah = Surah(
                                  number: surahData['number'],
                                  name: surahData['name'],
                                  englishName: surahData['englishName'],
                                  englishNameTranslation: '',
                                  indonesianNameTranslation:
                                      '', // TODO: Update surahDetails
                                  numberOfAyahs: surahData['numberOfAyahs'],
                                  revelationType: surahData['revelationType'],
                                );

                                context.push(
                                  '/quran/mushaf/${surah.number}',
                                  extra: {
                                    'surah': surah,
                                    'initialPage': state.lastRead!.pageNumber,
                                  },
                                );
                              }
                            },
                            borderRadius: BorderRadius.circular(16.r),
                            child: Container(
                              padding: EdgeInsets.all(20.w),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF00E676),
                                    Color(0xFF00C853),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(12.w),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.menu_book,
                                      color: Colors.white,
                                      size: 24.sp,
                                    ),
                                  ),
                                  SizedBox(width: 16.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Continue Reading",
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          (state.lastRead!.surahNumber >= 1 &&
                                                  state.lastRead!.surahNumber <=
                                                      114)
                                              ? "Surah ${SurahNames.indonesianNames[state.lastRead!.surahNumber - 1]}"
                                              : "Surah ${state.lastRead!.surahName}",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "Page ${state.lastRead!.pageNumber}",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.white70,
                                    size: 16.sp,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                    // --- BOOKMARKS LIST ---
                    Expanded(
                      child: state.bookmarks.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.bookmark_border,
                                    size: 64.sp,
                                    color: Colors.white54,
                                  ),
                                  SizedBox(height: 16.h),
                                  Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.emptyBookmarkTitle,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.emptyBookmarkSubtitle,
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                  SizedBox(height: 24.h),
                                  ElevatedButton(
                                    onPressed: () {
                                      // Switch tab to Quran (Index 2)
                                      context.go('/dashboard?index=2');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF00E676),
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 24.w,
                                        vertical: 12.h,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                      ),
                                      elevation: 4,
                                      shadowColor: const Color(
                                        0xFF00E676,
                                      ).withOpacity(0.4),
                                    ),
                                    child: Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.btnGoToQuran,
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              itemCount: state.bookmarks.length,
                              itemBuilder: (context, index) {
                                final bookmark = state.bookmarks[index];
                                return Card(
                                  color: Colors.white.withOpacity(0.05),
                                  margin: EdgeInsets.only(bottom: 12.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                    side: BorderSide(
                                      color: Colors.white.withOpacity(0.1),
                                    ),
                                  ),
                                  elevation: 0,
                                  child: ListTile(
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 8.h,
                                    ),
                                    leading: CircleAvatar(
                                      backgroundColor: const Color(
                                        0xFF00E676,
                                      ).withOpacity(0.2),
                                      child: Text(
                                        "${index + 1}",
                                        style: const TextStyle(
                                          color: Color(0xFF00E676),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      (bookmark.surahNumber >= 1 &&
                                              bookmark.surahNumber <= 114)
                                          ? "Surah ${SurahNames.indonesianNames[bookmark.surahNumber - 1]}"
                                          : "Surah ${bookmark.surahName}",
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Page ${bookmark.pageNumber}",
                                          style: const TextStyle(
                                            color: Colors.white70,
                                          ),
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          DateFormat(
                                            'dd MMM yyyy, HH:mm',
                                          ).format(
                                            DateTime.fromMillisecondsSinceEpoch(
                                              bookmark.createdAt,
                                            ),
                                          ),
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: Colors.white54,
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.redAccent,
                                      ),
                                      onPressed: () {
                                        context.read<BookmarkBloc>().add(
                                          DeleteBookmark(bookmark.id!),
                                        );
                                      },
                                    ),
                                    onTap: () {
                                      final surahData = surahDetails.firstWhere(
                                        (e) =>
                                            e['number'] == bookmark.surahNumber,
                                        orElse: () => {},
                                      );

                                      if (surahData.isNotEmpty) {
                                        final surah = Surah(
                                          number: surahData['number'],
                                          name: surahData['name'],
                                          englishName: surahData['englishName'],
                                          englishNameTranslation: '',
                                          indonesianNameTranslation:
                                              '', // TODO: Update surahDetails
                                          numberOfAyahs:
                                              surahData['numberOfAyahs'],
                                          revelationType:
                                              surahData['revelationType'],
                                        );

                                        context.push(
                                          '/quran/mushaf/${surah.number}',
                                          extra: {
                                            'surah': surah,
                                            'initialPage': bookmark.pageNumber,
                                          },
                                        );
                                      }
                                    },
                                  ),
                                );
                              },
                            ),
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
  }
}

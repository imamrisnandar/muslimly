import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/di_container.dart';
import '../../../../core/presentation/widgets/app_transparent_app_bar.dart';
import '../../../../core/widgets/islamic_loading_indicator.dart';
import '../../../../core/utils/surah_names.dart';
import '../../domain/entities/surah.dart';
import '../../domain/entities/quran_bookmark.dart';
import '../../domain/entities/quran_folder.dart';
import '../../data/surah_details.dart'; // To reconstruct Surah object for logic
import '../bloc/bookmark/bookmark_bloc.dart';
import '../../domain/entities/last_read.dart';
import '../bloc/bookmark/bookmark_event.dart';
import '../bloc/bookmark/bookmark_state.dart';
import '../bloc/folder/folder_bloc.dart';
import '../bloc/folder/folder_event.dart';
import '../bloc/folder/folder_state.dart';
import '../bloc/reading/reading_bloc.dart';
import '../bloc/reading/reading_event.dart';
import '../bloc/reading/reading_state.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';

/// A folder-filter selection for one tab. Records compare by value, so this
/// can be used directly as chip-selection state.
typedef FolderFilter = ({bool isAll, bool isUncategorized, int? folderId});

const kAllFolderFilter = (isAll: true, isUncategorized: false, folderId: null);
const kUncategorizedFolderFilter = (isAll: false, isUncategorized: true, folderId: null);

FolderFilter specificFolderFilter(int id) =>
    (isAll: false, isUncategorized: false, folderId: id);

class BookmarksPage extends StatefulWidget {
  const BookmarksPage({super.key});

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  final Map<String, FolderFilter> _filterByMode = {
    'list': kAllFolderFilter,
    'mushaf': kAllFolderFilter,
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // getIt directly, not context.read: FolderBloc's own BlocProvider is
      // created inside this State's build() — a descendant of this State's
      // context, not an ancestor — so a Provider lookup from here throws
      // ProviderNotFoundException. getIt<FolderBloc>() returns the same
      // singleton instance the provider below wraps, without that lookup.
      final folderBloc = getIt<FolderBloc>();
      if (folderBloc.state is FolderInitial) {
        final l10n = AppLocalizations.of(context)!;
        folderBloc.add(
          LoadFolders(hapalanLabel: l10n.lblFolderHapalan, bacaanLabel: l10n.lblFolderBacaan),
        );
      }
    });
  }

  bool _matchesFilter(QuranBookmark bookmark, FolderFilter filter) {
    if (filter.isAll) return true;
    if (filter.isUncategorized) return bookmark.folderId == null;
    return bookmark.folderId == filter.folderId;
  }

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
        // FolderBloc is a lazy singleton (getIt.registerLazySingleton) shared
        // across the app, so it's provided via .value — a regular
        // BlocProvider(create: ...) would close() it when this page is
        // disposed, breaking it for the next time this page (or any other
        // consumer) reads it.
        BlocProvider.value(value: getIt<FolderBloc>()),
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
                    AppColors.bgGradientStart,
                    AppColors.bgGradientMid,
                    AppColors.bgGradientEnd,
                  ],
                ),
              ),
              child: Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppTransparentAppBar(
                  title: AppLocalizations.of(context)!.lblBookmarks,
                  centerTitle: true,
                  titleFontSize: 20.sp,
                  bottom: PreferredSize(
                    preferredSize: Size.fromHeight(60.h),
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(50.r),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: TabBar(
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(40.r),
                          color: AppColors.accent,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withValues(alpha: 0.3),
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
                                    AppLocalizations.of(context)!.lblListType,
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
                                    AppLocalizations.of(context)!.lblMushafType,
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
                        child: IslamicLoadingIndicator(size: 64),
                      );
                    } else if (state is BookmarkLoaded) {
                      // Filter Bookmarks based on MODE
                      final listBookmarks = state.bookmarks
                          .where((b) => b.mode == 'list')
                          .toList();
                      final mushafBookmarks = state.bookmarks
                          .where(
                            (b) =>
                                b.mode ==
                                'mushaf', // Includes both page and ayah bookmarks in mushaf mode
                          )
                          .toList();

                      return TabBarView(
                        children: [
                          // --- TAB 1: LIST MODE ---
                          _buildBookmarkList(
                            context: context,
                            mode: 'list',
                            bookmarks: listBookmarks,
                            lastRead: state.lastReadList,
                            isListMode: true,
                            emptyMessageTitle: AppLocalizations.of(
                              context,
                            )!.emptyBookmarkAyahTitle,
                            emptyMessageSubtitle: AppLocalizations.of(
                              context,
                            )!.emptyBookmarkAyahSubtitle,
                          ),

                          // --- TAB 2: MUSHAF MODE ---
                          _buildBookmarkList(
                            context: context,
                            mode: 'mushaf',
                            bookmarks: mushafBookmarks,
                            lastRead: state.lastReadMushaf,
                            isListMode: false,
                            emptyMessageTitle: AppLocalizations.of(
                              context,
                            )!.emptyBookmarkPageTitle,
                            emptyMessageSubtitle: AppLocalizations.of(
                              context,
                            )!.emptyBookmarkPageSubtitle,
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
    required String mode,
    required List<QuranBookmark> bookmarks,
    required dynamic lastRead, // LastRead?
    required bool isListMode,
    required String emptyMessageTitle,
    required String emptyMessageSubtitle,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final filter = _filterByMode[mode]!;
    final filteredBookmarks = bookmarks.where((b) => _matchesFilter(b, filter)).toList();

    return BlocBuilder<FolderBloc, FolderState>(
      builder: (context, folderState) {
        final folders = folderState is FolderLoaded ? folderState.forMode(mode) : <QuranFolder>[];

        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
              sliver: SliverToBoxAdapter(
                child: _buildFolderChipRow(context, mode: mode, folders: folders, filter: filter),
              ),
            ),
            if (bookmarks.isEmpty && lastRead == null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildEmptyState(
                  context,
                  isListMode: isListMode,
                  title: emptyMessageTitle,
                  subtitle: emptyMessageSubtitle,
                ),
              )
            else ...[
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // --- LAST READ HERO CARD ---
                    if (lastRead != null) ...[
                      Padding(
                        padding: EdgeInsets.only(left: 4.w, bottom: 12.h),
                        child: Row(
                          children: [
                            Icon(Icons.history, color: AppColors.accent, size: 18.sp),
                            SizedBox(width: 8.w),
                            Text(
                              l10n.cardContinueReading,
                              style: TextStyle(
                                color: AppColors.accent,
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
                    // --- BOOKMARKS HEADER ---
                    if (filteredBookmarks.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(left: 4.w, bottom: 12.h),
                        child: Row(
                          children: [
                            Icon(Icons.bookmark_outline, color: Colors.white70, size: 18.sp),
                            SizedBox(width: 8.w),
                            Text(
                              l10n.lblSavedBookmarks,
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
                      )
                    else if (!filter.isAll)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.h),
                        child: Center(
                          child: Text(
                            l10n.msgNoBookmarksInFolder,
                            style: TextStyle(color: Colors.white38, fontSize: 13.sp),
                          ),
                        ),
                      ),
                  ]),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                sliver: SliverList.builder(
                  itemCount: filteredBookmarks.length,
                  itemBuilder: (context, i) {
                    final bookmark = filteredBookmarks[i];
                    return _buildBookmarkRow(
                      context,
                      bookmark: bookmark,
                      mode: mode,
                      isListMode: isListMode,
                      folders: folders,
                    );
                  },
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required bool isListMode,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16.w), // Even smaller padding
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isListMode ? Icons.format_list_bulleted_rounded : Icons.menu_book_rounded,
                size: 28.sp, // Even smaller icon
                color: Colors.white24,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp, // Even smaller font
                fontWeight: FontWeight.bold,
                fontFamily: 'Outfit',
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              subtitle,
              style: TextStyle(color: Colors.white54, fontSize: 12.sp), // Even smaller font
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () {
                // Go to Quran Tab (Index 2)
                context.go('/dashboard?index=2');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
              ),
              child: Text(
                AppLocalizations.of(context)!.btnGoToQuran,
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 24.h), // Reduced from 80.h
          ],
        ),
      ),
    );
  }

  Widget _buildFolderChipRow(
    BuildContext context, {
    required String mode,
    required List<QuranFolder> folders,
    required FolderFilter filter,
  }) {
    final l10n = AppLocalizations.of(context)!;

    Widget chip({
      required String label,
      required bool selected,
      required VoidCallback onTap,
      VoidCallback? onLongPress,
      IconData? icon,
    }) {
      return Padding(
        padding: EdgeInsets.only(right: 8.w),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20.r),
            onTap: onTap,
            onLongPress: onLongPress,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 9.h),
              decoration: BoxDecoration(
                color: selected ? AppColors.accent : Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(20.r),
                border: selected
                    ? null
                    : Border.all(color: Colors.white.withValues(alpha: 0.1)),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.28),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: 13.sp,
                      color: selected ? const Color(0xFF052025) : Colors.white.withValues(alpha: 0.6),
                    ),
                    SizedBox(width: 6.w),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      color: selected ? const Color(0xFF052025) : Colors.white.withValues(alpha: 0.75),
                      fontSize: 13.sp,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                      fontFamily: 'Outfit',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 40.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          chip(
            label: l10n.lblFolderAll,
            selected: filter.isAll,
            onTap: () => setState(() => _filterByMode[mode] = kAllFolderFilter),
          ),
          chip(
            label: l10n.lblFolderUncategorized,
            selected: filter.isUncategorized,
            onTap: () => setState(() => _filterByMode[mode] = kUncategorizedFolderFilter),
          ),
          for (final folder in folders)
            chip(
              label: folder.name,
              icon: Icons.folder_outlined,
              selected: !filter.isAll && !filter.isUncategorized && filter.folderId == folder.id,
              onTap: () => setState(() => _filterByMode[mode] = specificFolderFilter(folder.id!)),
              onLongPress: () => _showFolderActionsSheet(context, folder: folder, mode: mode),
            ),
          Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20.r),
                onTap: () => _showAddFolderDialog(context, mode),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: AppColors.accent.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 14.sp, color: AppColors.accent),
                      SizedBox(width: 5.w),
                      Text(
                        l10n.lblAddFolder,
                        style: TextStyle(
                          color: AppColors.accent,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Outfit',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarkRow(
    BuildContext context, {
    required QuranBookmark bookmark,
    required String mode,
    required bool isListMode,
    required List<QuranFolder> folders,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final surahName = (bookmark.surahNumber >= 1 && bookmark.surahNumber <= 114)
        ? SurahNames.indonesianNames[bookmark.surahNumber - 1]
        : bookmark.surahName;

    // Format Date
    final date = DateTime.fromMillisecondsSinceEpoch(bookmark.createdAt);
    final formattedDate = DateFormat('d MMM, HH:mm').format(date);
    final currentFolder = bookmark.folderId == null
        ? null
        : folders.where((f) => f.id == bookmark.folderId).firstOrNull;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03), // Lighter/Darker than hero
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)), // Subtle border
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
                  extra: {'surah': surah, 'initialAyah': bookmark.ayahNumber},
                );
              } else {
                // Navigate Mushaf
                // Handles both Page bookmarks (ayahNumber is null) and Ayah bookmarks (ayahNumber set)
                context.push(
                  '/quran/mushaf/${surah.number}',
                  extra: {
                    'surah': surah,
                    'initialPage': bookmark.pageNumber,
                    // NEW: Pass initialAyah if available (for highlighting)
                    'initialAyah': bookmark.ayahNumber,
                  },
                );
              }
            }
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              children: [
                // Minimalist Icon
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    (bookmark.ayahNumber != null && bookmark.ayahNumber! > 0)
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
                          color: Colors.white.withValues(alpha: 0.9),
                          fontFamily: 'Outfit',
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            (bookmark.ayahNumber != null && bookmark.ayahNumber! > 0)
                                ? "${l10n.lblAyah} ${bookmark.ayahNumber}"
                                : "${l10n.lblPage} ${bookmark.pageNumber}",
                            style: TextStyle(fontSize: 13.sp, color: Colors.white54),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 6.w),
                            width: 3.w,
                            height: 3.w,
                            decoration: const BoxDecoration(
                              color: Colors.white30,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Text(
                            formattedDate,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.white38,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          if (currentFolder != null) ...[
                            SizedBox(width: 6.w),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Text(
                                currentFolder.name,
                                style: TextStyle(
                                  color: AppColors.accent,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Move-to-folder action
                IconButton(
                  icon: Icon(Icons.folder_outlined, color: Colors.white.withValues(alpha: 0.5), size: 19.sp),
                  onPressed: () => _showMoveToFolderSheet(
                    context,
                    bookmark: bookmark,
                    mode: mode,
                    folders: folders,
                  ),
                ),

                // Delete Action
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white24, size: 20.sp),
                  onPressed: () {
                    context.read<BookmarkBloc>().add(DeleteBookmark(bookmark.id!));
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddFolderDialog(BuildContext context, String mode) {
    final l10n = AppLocalizations.of(context)!;
    final folderBloc = context.read<FolderBloc>();
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return _FolderNameDialog(
          title: l10n.lblAddFolder,
          controller: controller,
          hintText: l10n.hintFolderName,
          confirmLabel: l10n.btnCreateFolder,
          errorText: l10n.errFolderNameRequired,
          onConfirm: (name) => folderBloc.add(CreateFolder(mode, name)),
        );
      },
    );
  }

  void _showFolderActionsSheet(
    BuildContext context, {
    required QuranFolder folder,
    required String mode,
  }) {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _DarkBottomSheet(
          children: [
            ListTile(
              leading: const Icon(Icons.drive_file_rename_outline, color: Colors.white70),
              title: Text(
                l10n.btnRenameFolder,
                style: const TextStyle(color: Colors.white, fontFamily: 'Outfit'),
              ),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _showRenameFolderDialog(context, folder);
              },
            ),
            if (!folder.isSystem)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Color(0xFFFF5252)),
                title: Text(
                  l10n.btnDeleteFolder,
                  style: const TextStyle(color: Color(0xFFFF5252), fontFamily: 'Outfit'),
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _confirmDeleteFolder(context, folder);
                },
              ),
          ],
        );
      },
    );
  }

  void _showRenameFolderDialog(BuildContext context, QuranFolder folder) {
    final l10n = AppLocalizations.of(context)!;
    final folderBloc = context.read<FolderBloc>();
    final controller = TextEditingController(text: folder.name);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return _FolderNameDialog(
          title: l10n.dlgRenameFolderTitle,
          controller: controller,
          hintText: l10n.hintFolderName,
          confirmLabel: l10n.btnRenameFolder,
          errorText: l10n.errFolderNameRequired,
          onConfirm: (name) => folderBloc.add(RenameFolder(folder.id!, name)),
        );
      },
    );
  }

  void _confirmDeleteFolder(BuildContext context, QuranFolder folder) {
    final l10n = AppLocalizations.of(context)!;
    final folderBloc = context.read<FolderBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF152730),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          title: Text(l10n.dlgDeleteFolderTitle, style: const TextStyle(color: Colors.white)),
          content: Text(
            l10n.dlgDeleteFolderMessage,
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                MaterialLocalizations.of(context).cancelButtonLabel,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
            TextButton(
              onPressed: () {
                folderBloc.add(DeleteFolder(folder.id!));
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                l10n.btnDeleteFolder,
                style: const TextStyle(color: Color(0xFFFF5252), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showMoveToFolderSheet(
    BuildContext context, {
    required QuranBookmark bookmark,
    required String mode,
    required List<QuranFolder> folders,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final bookmarkBloc = context.read<BookmarkBloc>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _DarkBottomSheet(
          title: l10n.lblMoveToFolder,
          children: [
            ListTile(
              leading: Icon(
                Icons.close,
                color: bookmark.folderId == null ? AppColors.accent : Colors.white54,
              ),
              title: Text(
                l10n.lblNoFolder,
                style: const TextStyle(color: Colors.white, fontFamily: 'Outfit'),
              ),
              trailing: bookmark.folderId == null
                  ? const Icon(Icons.check_circle, color: AppColors.accent)
                  : null,
              onTap: () {
                bookmarkBloc.add(AssignBookmarkFolder(bookmark.id!, null));
                Navigator.of(sheetContext).pop();
              },
            ),
            for (final folder in folders)
              ListTile(
                leading: Icon(
                  Icons.folder_outlined,
                  color: bookmark.folderId == folder.id ? AppColors.accent : Colors.white54,
                ),
                title: Text(
                  folder.name,
                  style: const TextStyle(color: Colors.white, fontFamily: 'Outfit'),
                ),
                trailing: bookmark.folderId == folder.id
                    ? const Icon(Icons.check_circle, color: AppColors.accent)
                    : null,
                onTap: () {
                  bookmarkBloc.add(AssignBookmarkFolder(bookmark.id!, folder.id));
                  Navigator.of(sheetContext).pop();
                },
              ),
          ],
        );
      },
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
          colors: [Color(0xFF00BFA5), AppColors.accent], // Teal to Green
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.3),
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
                          color: Colors.black.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          isListMode
                              ? AppLocalizations.of(
                                  context,
                                )!.continueReadingAyah
                              : AppLocalizations.of(
                                  context,
                                )!.continueReadingPage,
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
                            ? "${AppLocalizations.of(context)!.lblAyah} ${lastRead.ayahNumber}"
                            : "${AppLocalizations.of(context)!.lblPage} ${lastRead.pageNumber}",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
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
                        color: Colors.black.withValues(alpha: 0.1),
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

/// Shared dark bottom-sheet chrome (grab handle + rounded top corners)
/// matching the app's existing sheet styling.
class _DarkBottomSheet extends StatelessWidget {
  final String? title;
  final List<Widget> children;

  const _DarkBottomSheet({this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF152730),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      padding: EdgeInsets.only(top: 12.h, bottom: 24.h + MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          if (title != null) ...[
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title!,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Outfit',
                  ),
                ),
              ),
            ),
          ],
          SizedBox(height: 8.h),
          // Wrapped in its own Material so the ListTiles' ink splashes paint
          // above this widget's own BoxDecoration background instead of
          // being hidden behind it.
          Material(
            color: Colors.transparent,
            child: Column(mainAxisSize: MainAxisSize.min, children: children),
          ),
        ],
      ),
    );
  }
}

/// Shared dialog for creating/renaming a folder — matching the app's dark
/// card styling used elsewhere.
class _FolderNameDialog extends StatefulWidget {
  final String title;
  final TextEditingController controller;
  final String hintText;
  final String confirmLabel;
  final String errorText;
  final ValueChanged<String> onConfirm;

  const _FolderNameDialog({
    required this.title,
    required this.controller,
    required this.hintText,
    required this.confirmLabel,
    required this.errorText,
    required this.onConfirm,
  });

  @override
  State<_FolderNameDialog> createState() => _FolderNameDialogState();
}

class _FolderNameDialogState extends State<_FolderNameDialog> {
  String? _error;

  void _submit() {
    final name = widget.controller.text.trim();
    if (name.isEmpty) {
      setState(() => _error = widget.errorText);
      return;
    }
    widget.onConfirm(name);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF152730),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      title: Text(widget.title, style: const TextStyle(color: Colors.white, fontFamily: 'Outfit')),
      content: TextField(
        controller: widget.controller,
        autofocus: true,
        maxLength: 30,
        style: const TextStyle(color: Colors.white),
        cursorColor: AppColors.accent,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: const TextStyle(color: Colors.white38),
          errorText: _error,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
          ),
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            MaterialLocalizations.of(context).cancelButtonLabel,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
        TextButton(
          onPressed: _submit,
          child: Text(
            widget.confirmLabel,
            style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

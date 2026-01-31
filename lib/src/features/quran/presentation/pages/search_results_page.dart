import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../l10n/generated/app_localizations.dart';

import '../../../../core/di/di_container.dart';
import '../../../../core/utils/surah_names.dart';
import '../../domain/entities/search_result.dart';
import '../../domain/entities/surah.dart';
import '../bloc/search/search_bloc.dart';
import '../bloc/search/search_event.dart';
import '../bloc/search/search_state.dart';

class SearchResultsPage extends StatelessWidget {
  final String initialQuery;

  const SearchResultsPage({Key? key, required this.initialQuery})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    return BlocProvider(
      create: (context) =>
          getIt<SearchBloc>()
            ..add(SearchSubmitted(initialQuery, languageCode: languageCode)),
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView();

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  late TextEditingController _searchController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<SearchBloc>().add(SearchLoadMore());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Theme colors matching Mushaf
    const backgroundColor = Color(0xFFFFF8E1); // Cream
    const textColor = Color(0xFF4E342E); // Dark Brown
    const accentColor = Color(0xFF1B5E20); // Dark Green

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: BackButton(color: textColor),
        title: BlocBuilder<SearchBloc, SearchState>(
          builder: (context, state) {
            String title = "Search Results";
            if (state is SearchLoaded) {
              title = AppLocalizations.of(
                context,
              )!.searchResultsFor(state.query);
            }
            return Text(
              title,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
                fontFamily: GoogleFonts.outfit().fontFamily,
              ),
            );
          },
        ),
        iconTheme: IconThemeData(color: textColor),
      ),
      body: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) {
          if (state is SearchInitial ||
              (state is SearchLoading && state.isFirstFetch)) {
            return Center(child: CircularProgressIndicator(color: accentColor));
          } else if (state is SearchError) {
            return Center(
              child: Text(
                state.message,
                style: TextStyle(color: textColor.withOpacity(0.7)),
              ),
            );
          } else if (state is SearchLoaded) {
            if (state.results.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64.sp,
                      color: textColor.withOpacity(0.3),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      "No results found for\n'${state.query}'",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textColor.withOpacity(0.7),
                        fontSize: 16.sp,
                        fontFamily: GoogleFonts.outfit().fontFamily,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
                  child: Text(
                    AppLocalizations.of(context)!.searchSortedByRelevance,
                    style: GoogleFonts.outfit(
                      fontSize: 10.sp,
                      color: textColor.withOpacity(0.5),
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    controller: _scrollController,
                    padding: EdgeInsets.all(16.w),
                    itemCount: state.hasReachedMax
                        ? state.results.length
                        : state.results.length + 1,
                    separatorBuilder: (_, __) => SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      if (index >= state.results.length) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(
                              color: accentColor,
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      }

                      return _SearchResultCard(
                        item: state.results[index],
                        textColor: textColor,
                        accentColor: accentColor,
                      );
                    },
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  final SearchResult item;
  final Color textColor;
  final Color accentColor;

  const _SearchResultCard({
    required this.item,
    required this.textColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final surahName = SurahNames.englishNames[item.surahNumber - 1];

    return InkWell(
      onTap: () {
        final surah = Surah(
          number: item.surahNumber,
          name: '',
          englishName: surahName,
          englishNameTranslation: '',
          indonesianNameTranslation: '',
          revelationType: '',
          numberOfAyahs: 0,
        );

        context.push(
          '/quran/${item.surahNumber}',
          extra: {'surah': surah, 'initialAyah': item.ayahNumber},
        );
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: const Color(0xFFEEE8D5), // Subtle border
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    "$surahName : ${item.ayahNumber}",
                    style: TextStyle(
                      color: accentColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                      fontFamily: GoogleFonts.outfit().fontFamily,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            if (item.text.isNotEmpty)
              Text(
                item.text,
                textDirection: TextDirection.rtl,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.amiriQuran(
                  color: Colors.black87,
                  fontSize: 22.sp,
                  height: 1.8,
                ),
              ),
            SizedBox(height: 12.h),
            _buildHighlightedTranslation(item.translation),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightedTranslation(String text) {
    final List<TextSpan> spans = [];
    final RegExp exp = RegExp(r'<em>(.*?)<\/em>');
    int start = 0;

    for (final Match m in exp.allMatches(text)) {
      if (m.start > start) {
        spans.add(TextSpan(text: text.substring(start, m.start)));
      }
      spans.add(
        TextSpan(
          text: m.group(1),
          style: TextStyle(
            color: const Color(0xFF2E7D32), // Darker Green for text on light bg
            backgroundColor: const Color(
              0xFFA5D6A7,
            ).withOpacity(0.3), // Light Green highlight
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      start = m.end;
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return RichText(
      text: TextSpan(
        style: TextStyle(
          color: textColor.withOpacity(0.8),
          fontSize: 14.sp,
          height: 1.5,
          fontFamily: GoogleFonts.outfit().fontFamily,
        ),
        children: spans,
      ),
    );
  }
}

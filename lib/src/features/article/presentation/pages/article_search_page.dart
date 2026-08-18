import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../bloc/article_bloc.dart';
import '../../domain/entities/article.dart';
import '../../../../core/di/di_container.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';

class ArticleSearchPage extends StatelessWidget {
  const ArticleSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ArticleBloc>(),
      child: const _ArticleSearchView(),
    );
  }
}

class _ArticleSearchView extends StatefulWidget {
  const _ArticleSearchView();

  @override
  State<_ArticleSearchView> createState() => _ArticleSearchViewState();
}

class _ArticleSearchViewState extends State<_ArticleSearchView> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String? _currentLang;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _currentLang = Localizations.localeOf(context).languageCode;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        context.read<ArticleBloc>().add(
          SearchArticles(query: query, lang: _currentLang),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGradientStart,
      appBar: AppBar(
        backgroundColor: AppColors.bgGradientStart,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Container(
          height: 40.h,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            autofocus: true,
            style: GoogleFonts.inter(color: Colors.white),
            cursorColor: AppColors.accentDark,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.articleSearchHint,
              hintStyle: GoogleFonts.inter(color: Colors.white54),
              border: InputBorder.none,
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 8.h,
              ),
            ),
          ),
        ),
      ),
      body: BlocBuilder<ArticleBloc, ArticleState>(
        builder: (context, state) {
          if (state is ArticleLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accentDark),
            );
          } else if (state is ArticleLoaded) {
            final articles = state.articles;
            if (articles.isEmpty) {
              return Center(
                child: Text(
                  AppLocalizations.of(context)!.articleNoData,
                  style: GoogleFonts.inter(color: Colors.white54),
                ),
              );
            }

            return ListView.separated(
              padding: EdgeInsets.all(16.w),
              itemCount: articles.length,
              separatorBuilder: (context, index) => SizedBox(height: 16.h),
              itemBuilder: (context, index) {
                final article = articles[index];
                return _ArticleListItem(article: article);
              },
            );
          } else if (state is ArticleError) {
            final errorKey = state.message;
            String errorMessage = errorKey;

            // Simple key mapping
            if (errorKey == 'articleErrorLoad') {
              errorMessage = AppLocalizations.of(context)!.articleErrorLoad;
            } else if (errorKey == 'articleErrorSearch') {
              errorMessage = AppLocalizations.of(context)!.articleErrorSearch;
            }

            return Center(
              child: Text(
                errorMessage,
                style: GoogleFonts.inter(color: Colors.redAccent),
              ),
            );
          }

          // Initial State (Before typing/searching)
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_rounded, size: 64.sp, color: Colors.white24),
                SizedBox(height: 16.h),
                Text(
                  AppLocalizations.of(context)!.articleSearchStart,
                  style: GoogleFonts.inter(color: Colors.white54),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ArticleListItem extends StatelessWidget {
  final Article article;

  const _ArticleListItem({required this.article});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('d MMM yyyy').format(article.publishedAt);
    final categoryColor = const Color(
      0xFF00E676,
    ); // Matches BottomNavigationBar

    return GestureDetector(
      onTap: () {
        context.push('/article-detail', extra: article);
      },
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Icon Placeholder
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                _getCategoryIcon(article.category),
                color: categoryColor,
                size: 32.sp,
              ),
            ),
            SizedBox(width: 12.w),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category & Date
                  Row(
                    children: [
                      Text(
                        article.category.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          color: categoryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        dateStr,
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: 16.sp,
                      color: AppColors.gold, // Gold to match Carousel
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    article.summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'kajian':
        return Icons.menu_book_rounded;
      case 'news':
        return Icons.newspaper_rounded;
      case 'tips':
        return Icons.health_and_safety_rounded;
      case 'doa':
        return Icons.volunteer_activism_rounded;
      default:
        return Icons.article_rounded;
    }
  }
}

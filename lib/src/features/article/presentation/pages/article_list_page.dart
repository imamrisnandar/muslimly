import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../l10n/generated/app_localizations.dart';

import '../bloc/article_bloc.dart';
import '../../domain/entities/article.dart';

class ArticleListPage extends StatefulWidget {
  const ArticleListPage({super.key});

  @override
  State<ArticleListPage> createState() => _ArticleListPageState();
}

class _ArticleListPageState extends State<ArticleListPage> {
  String? _currentLang;
  final ScrollController _scrollController = ScrollController();

  // Pagination constants
  static const int _limit = 10;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      final bloc = context.read<ArticleBloc>();
      final state = bloc.state;
      if (state is ArticleLoaded && !state.hasReachedMax) {
        bloc.add(
          LoadArticles(
            lang: _currentLang,
            limit: _limit,
            offset: state.articles.length,
          ),
        );
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9); // Load when 90% scrolled
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newLang = Localizations.localeOf(context).languageCode;
    if (_currentLang != newLang) {
      _currentLang = newLang;
      // Load initial batch
      context.read<ArticleBloc>().add(
        LoadArticles(lang: newLang, limit: _limit, offset: 0),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F2027),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          AppLocalizations.of(context)!.articleListTitle, // "Artikel Islami"
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () => context.push('/article-search'),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: BlocBuilder<ArticleBloc, ArticleState>(
        builder: (context, state) {
          if (state is ArticleLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF1DE9B6)),
            );
          } else if (state is ArticleLoaded) {
            final articles = state.articles;
            if (articles.isEmpty) {
              return Center(
                child: Text(
                  AppLocalizations.of(
                    context,
                  )!.articleListEmpty, // "Belum ada artikel."
                  style: GoogleFonts.inter(color: Colors.white54),
                ),
              );
            }

            return ListView.separated(
              controller: _scrollController,
              padding: EdgeInsets.all(16.w),
              itemCount: state.hasReachedMax
                  ? articles.length
                  : articles.length + 1, // +1 for Loading Indicator
              separatorBuilder: (context, index) => SizedBox(height: 16.h),
              itemBuilder: (context, index) {
                if (index >= articles.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(
                        color: Color(0xFF1DE9B6),
                      ),
                    ),
                  );
                }
                final article = articles[index];
                return _ArticleListItem(article: article);
              },
            );
          } else if (state is ArticleError) {
            // ... existing error logic ...
            final errorKey = state.message;
            String errorMessage = errorKey;
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
          return const SizedBox.shrink();
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
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Icon Placeholder (Or Thumbnail if available)
            // Category Icon with Aesthetic Style
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                gradient: LinearGradient(
                  colors: [
                    categoryColor.withOpacity(0.2),
                    Colors.black.withOpacity(0.4),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: categoryColor.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: categoryColor.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Subtle large icon in background
                  Positioned(
                    right: -10,
                    bottom: -10,
                    child: Transform.rotate(
                      angle: -0.2,
                      child: Icon(
                        _getCategoryIcon(article.category),
                        size: 60.sp,
                        color: categoryColor.withOpacity(0.1),
                      ),
                    ),
                  ),
                  // Main Icon
                  Center(
                    child: Icon(
                      _getCategoryIcon(article.category),
                      color: categoryColor,
                      size: 32.sp,
                    ),
                  ),
                ],
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
                      color: const Color(0xFFFFC107), // Gold to match Carousel
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

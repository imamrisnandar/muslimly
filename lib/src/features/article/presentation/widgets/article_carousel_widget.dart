import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/generated/app_localizations.dart';

import '../../domain/entities/article.dart';
import '../bloc/article_bloc.dart';

class ArticleCarouselWidget extends StatefulWidget {
  const ArticleCarouselWidget({super.key});

  @override
  State<ArticleCarouselWidget> createState() => _ArticleCarouselWidgetState();
}

class _ArticleCarouselWidgetState extends State<ArticleCarouselWidget> {
  String? _currentLang;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newLang = Localizations.localeOf(context).languageCode;
    if (_currentLang != newLang) {
      _currentLang = newLang;
      // Fetch articles when language changes (or first load)
      // Limit to 5 for carousel as requested
      context.read<ArticleBloc>().add(LoadArticles(lang: newLang, limit: 5));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Force a taller height in landscape to prevent overflow
    // In landscape (e.g. 375 height), 260 is about 70% of screen.
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return BlocBuilder<ArticleBloc, ArticleState>(
      builder: (context, state) {
        if (state is ArticleLoaded && state.articles.isNotEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(
                        context,
                      )!.articleTitle, // 'Kabar & Ilmiah'
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white54,
                      ),
                    ),
                    Row(
                      children: [
                        InkWell(
                          onTap: () => context.push('/article-search'),
                          child: Padding(
                            padding: EdgeInsets.all(4.w),
                            child: Icon(
                              Icons.search,
                              color: Colors.white54,
                              size: 20.sp,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        InkWell(
                          onTap: () => context.push('/article-list'),
                          child: Padding(
                            padding: EdgeInsets.all(4.w),
                            child: Text(
                              AppLocalizations.of(
                                context,
                              )!.articleSeeAll, // 'Lihat Semua'
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(
                                  0xFFFFC107,
                                ), // Gold for Action
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
              CarouselSlider(
                options: CarouselOptions(
                  // Robust height calculation
                  height: isLandscape ? 260 : 190.h,
                  viewportFraction: isLandscape
                      ? 0.7
                      : 0.85, // Wider cards in landscape
                  enableInfiniteScroll: false,
                  enlargeCenterPage: true,
                  padEnds: false,
                ),
                items: state.articles.map((article) {
                  return Builder(
                    builder: (BuildContext context) {
                      return _ArticleCard(article: article);
                    },
                  );
                }).toList(),
              ),
            ],
          );
        }
        return const SizedBox.shrink(); // Hide if empty or error for now
      },
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final Article article;

  const _ArticleCard({required this.article});

  @override
  Widget build(BuildContext context) {
    final iconData = _getCategoryIcon(article.category);
    final categoryColor = _getCategoryColor(article.category);
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return GestureDetector(
      onTap: () => context.push('/article-detail', extra: article),
      child: Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          gradient: _getCategoryGradient(article.category), // Custom Gradient
          border: Border.all(
            color: categoryColor.withOpacity(0.3), // Colored Border
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: categoryColor.withOpacity(0.05), // Richer Shadow Glow
              blurRadius: 20,
              spreadRadius: -5,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.r),
          child: Stack(
            children: [
              // Background Icon - Category Tint
              Positioned(
                right: -16.w,
                bottom: -16.w,
                child: Transform.rotate(
                  angle: -0.2,
                  child: Icon(
                    iconData,
                    size: 120.sp,
                    color: categoryColor.withOpacity(0.1),
                  ),
                ),
              ),

              // Content with LayoutBuilder for safety
              LayoutBuilder(
                builder: (context, constraints) {
                  final height = constraints.maxHeight;
                  // If height is surprisingly constrained (< 160), hide summary
                  final showSummary = height > 160;
                  final compactMode = height < 200;

                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: compactMode
                          ? 12.h
                          : 16.h, // Reduce vertical padding
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween, // Use available space
                      children: [
                        // Header
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: categoryColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: categoryColor.withOpacity(0.5),
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                article.category.toUpperCase(),
                                style: GoogleFonts.inter(
                                  fontSize: isLandscape ? 8.sp : 10.sp,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                  color: categoryColor, // Category Text
                                ),
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.calendar_today_rounded,
                              size: isLandscape ? 10.sp : 12.sp,
                              color: Colors.white54,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              "${article.publishedAt.day}/${article.publishedAt.month}/${article.publishedAt.year}",
                              style: GoogleFonts.inter(
                                fontSize: isLandscape ? 10.sp : 12.sp,
                                color: Colors.white54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        // Title (Flexible to avoid overflow)
                        Flexible(
                          child: Text(
                            article.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontSize: isLandscape ? 16.sp : 18.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFFFC107), // Gold Title
                              height: 1.2,
                              letterSpacing: 0.2,
                              shadows: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),

                        if (showSummary) ...[
                          Flexible(
                            child: Text(
                              article.summary,
                              maxLines: compactMode ? 2 : 3,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: isLandscape ? 11.sp : 12.sp,
                                color: Colors.white70,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],

                        // Footer
                        Row(
                          children: [
                            Text(
                              AppLocalizations.of(
                                context,
                              )!.articleReadMore, // "Baca Selengkapnya"
                              style: GoogleFonts.inter(
                                fontSize: isLandscape ? 10.sp : 12.sp,
                                color: categoryColor, // Category Link
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 16.sp,
                              color: categoryColor, // Category Icon
                            ),
                          ],
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
    );
  }

  Color _getCategoryColor(String category) {
    // All categories use "Fresh Teal" (0xFF1DE9B6) as requested
    return const Color(0xFF1DE9B6);
  }

  LinearGradient _getCategoryGradient(String category) {
    final color = _getCategoryColor(category);
    return LinearGradient(
      colors: [
        color.withOpacity(0.15), // Reduced from 0.25 (Subtler Glow)
        Colors.black.withOpacity(0.9), // Increased from 0.3 (Darker Background)
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
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

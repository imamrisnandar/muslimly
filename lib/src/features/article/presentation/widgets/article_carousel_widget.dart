import 'dart:ui' as dart_ui;
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
    final categoryColor = const Color(0xFF1DE9B6); // Fresh Teal
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return GestureDetector(
      onTap: () => context.push('/article-detail', extra: article),
      child: Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            20.r,
          ), // Flyer-like slightly sharper corners
          boxShadow: [
            BoxShadow(
              color: categoryColor.withOpacity(0.1),
              blurRadius: 30,
              spreadRadius: -5,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: Stack(
            children: [
              // 1. Frosted Glass Base Layer
              Positioned.fill(
                child: BackdropFilter(
                  // Increased blur for a thicker glass feel
                  filter: dart_ui.ImageFilter.blur(sigmaX: 25.0, sigmaY: 25.0),
                  child: Container(
                    // Lighter tint so more background colors bleed through
                    color: const Color(0xFF0F2027).withOpacity(0.35),
                  ),
                ),
              ),

              // 2. Glass Surface Reflections & Border
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.r),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        categoryColor.withOpacity(
                          0.25,
                        ), // Stronger Teal highlight on top-left edge
                        Colors.white.withOpacity(
                          0.12,
                        ), // Stronger white reflection
                        Colors.black.withOpacity(0.1),
                      ],
                      stops: const [0.0, 0.35, 1.0],
                    ),
                    border: Border.all(
                      // Stronger white border to emphasize the glass edge
                      color: Colors.white.withOpacity(0.3),
                      width: 1.2,
                    ),
                  ),
                ),
              ),

              // 3. Artistic Watermark (Moved to top-right like a flyer graphic)
              Positioned(
                right: -30.w,
                top: -20.h,
                child: Transform.rotate(
                  angle: 0.15,
                  child: Icon(
                    iconData,
                    size: 150.sp,
                    color: categoryColor.withOpacity(
                      0.05,
                    ), // Very subtle embedded graphic
                  ),
                ),
              ),

              // 4. Content Layout (Poster/Flyer style)
              LayoutBuilder(
                builder: (context, constraints) {
                  final height = constraints.maxHeight;
                  final compactMode = height < 200 || isLandscape;

                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- TOP ROW: Category Ribbon & Date ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Flyer Category Ribbon (Solid frosted glass)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    categoryColor.withOpacity(0.3),
                                    categoryColor.withOpacity(0.1),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(6.r),
                                border: Border.all(
                                  color: categoryColor.withOpacity(0.4),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                article.category.toUpperCase(),
                                style: GoogleFonts.inter(
                                  fontSize: isLandscape ? 8.sp : 10.sp,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.0,
                                  color: categoryColor,
                                ),
                              ),
                            ),

                            // Date Tag (Hidden for now)
                            // Container(
                            //   padding: EdgeInsets.symmetric(
                            //     horizontal: 8.w,
                            //     vertical: 4.h,
                            //   ),
                            //   decoration: BoxDecoration(
                            //     color: Colors.white.withOpacity(0.1),
                            //     borderRadius: BorderRadius.circular(10.r),
                            //   ),
                            //   child: Text(
                            //     "${article.publishedAt.day} ${_getMonthName(article.publishedAt.month)} ${article.publishedAt.year}",
                            //     style: GoogleFonts.inter(
                            //       fontSize: isLandscape ? 8.sp : 9.sp,
                            //       color: Colors.white.withOpacity(0.9),
                            //       fontWeight: FontWeight.w600,
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),

                        // --- MAIN CONTENT: Flyer Typography ---
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Flyer Title (Big, Bold, Gold)
                                Text(
                                  article.title,
                                  maxLines: compactMode ? 2 : 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.outfit(
                                    fontSize: isLandscape ? 15.sp : 18.sp,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFFFFC107), // Pop Gold
                                    height: 1.15,
                                    letterSpacing: 0.5,
                                    shadows: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.8),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                ),

                                if (!compactMode && height > 180) ...[
                                  SizedBox(height: 8.h),
                                  // Subtitle / Summary
                                  Flexible(
                                    child: Text(
                                      article.summary,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(
                                        fontSize: 12.sp,
                                        color: Colors.white.withOpacity(0.75),
                                        height: 1.4,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),

                        // --- BOTTOM ROW: Call to Action Pill ---
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(
                                0.1,
                              ), // Glass Pill
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 0.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.articleReadMore.toUpperCase(),
                                  style: GoogleFonts.inter(
                                    fontSize: isLandscape ? 8.sp : 9.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 13.sp,
                                  color: const Color(0xFFFFC107), // Gold arrow
                                ),
                              ],
                            ),
                          ),
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

  // String _getMonthName(int month) {
  //   const months = [
  //     'Jan',
  //     'Feb',
  //     'Mar',
  //     'Apr',
  //     'May',
  //     'Jun',
  //     'Jul',
  //     'Aug',
  //     'Sep',
  //     'Oct',
  //     'Nov',
  //     'Dec',
  //   ];
  //   if (month >= 1 && month <= 12) return months[month - 1];
  //   return '';
  // }

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

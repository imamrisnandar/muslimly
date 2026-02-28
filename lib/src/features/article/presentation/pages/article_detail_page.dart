import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/article.dart';

class ArticleDetailPage extends StatelessWidget {
  final Article article;

  const ArticleDetailPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('d MMMM yyyy').format(article.publishedAt);
    final categoryColor = const Color(0xFF1DE9B6);

    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.h,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF0F2027),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Gradient Background
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          categoryColor.withOpacity(0.3),
                          const Color(0xFF0F2027),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  // Background Pattern Icon
                  Positioned(
                    right: -40,
                    top: -40,
                    child: Icon(
                      _getCategoryIcon(article.category),
                      size: 250.sp,
                      color: categoryColor.withOpacity(0.05),
                    ),
                  ),
                  // Bottom Fade
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 100.h,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, const Color(0xFF0F2027)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: categoryColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      article.category.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: categoryColor,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Title
                  Text(
                    article.title,
                    style: GoogleFonts.outfit(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFFC107), // Gold
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Metadata (Author & Date)
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16.r,
                        backgroundColor: Colors.white10,
                        child: Icon(
                          Icons.person,
                          color: Colors.white70,
                          size: 16.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            article.author,
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            dateStr,
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),

                  // Divider
                  Divider(color: Colors.white10),
                  SizedBox(height: 24.h),

                  // HTML Content
                  HtmlWidget(
                    article.content,
                    textStyle: GoogleFonts.inter(
                      fontSize: 16.sp,
                      color: Colors.white.withOpacity(
                        0.9,
                      ), // Slightly reduced white for reading comfort
                      height: 1.6,
                    ),
                    customStylesBuilder: (element) {
                      if (element.localName == 'h3') {
                        return {
                          'color': '#1DE9B6', // Teal headings
                          'font-family': 'Outfit',
                          'font-weight': 'bold',
                          'margin-top': '24px',
                          'margin-bottom': '12px',
                        };
                      }
                      if (element.localName == 'blockquote') {
                        return {
                          'background-color':
                              'rgba(255, 193, 7, 0.1)', // Gold tint
                          'border-left': '4px solid #FFC107',
                          'padding': '12px',
                          'margin': '16px 0',
                          'font-style': 'italic',
                          'color': '#FFFFFF',
                        };
                      }
                      if (element.localName == 'li') {
                        return {'margin-bottom': '8px'};
                      }
                      // Arabic text styling class
                      if (element.classes.contains('arabic')) {
                        return {
                          'font-family':
                              'UthmanicHafs13', // Use app's Arabic font
                          'font-size': '24px',
                          'text-align': 'right',
                          'color': '#FFC107',
                          'margin': '16px 0',
                          'line-height': '2.0',
                        };
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 48.h),
                ],
              ),
            ),
          ),
        ],
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

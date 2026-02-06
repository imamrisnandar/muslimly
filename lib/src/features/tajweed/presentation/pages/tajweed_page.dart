import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/di_container.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../data/models/tajweed_model.dart';
import '../../data/repositories/tajweed_repository.dart';
import 'tajweed_lesson_page.dart';

class TajweedPage extends StatefulWidget {
  const TajweedPage({super.key});

  @override
  State<TajweedPage> createState() => _TajweedPageState();
}

class _TajweedPageState extends State<TajweedPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: const Color(0xFF1C2A30), // Dark Theme Background
      appBar: AppBar(
        title: Text(
          l10n.ibadahTajweedTitle,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: GoogleFonts.outfit().fontFamily,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: FutureBuilder<List<TajweedCategory>>(
        future: getIt<TajweedRepository>().getTajweedContent(l10n.localeName),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No Data', style: TextStyle(color: Colors.white)),
            );
          }

          final categories = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 16.h),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return _buildCategorySection(context, category, isLandscape);
            },
          );
        },
      ),
    );
  }

  Widget _buildCategorySection(
    BuildContext context,
    TajweedCategory category,
    bool isLandscape,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2A30), // Match Scaffold
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          collapsedBackgroundColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          iconColor: const Color(0xFF00E676),
          collapsedIconColor: Colors.white54,
          title: Text(
            category.title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF00E676), // Green Accent
              fontFamily: GoogleFonts.outfit().fontFamily,
            ),
          ),
          subtitle: Text(
            category.description,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.white70,
              fontFamily: GoogleFonts.outfit().fontFamily,
            ),
          ),
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              child: Column(
                children: category.lessons.asMap().entries.map((entry) {
                  final index = entry.key;
                  final lesson = entry.value;
                  return _buildLessonCard(
                    context,
                    lesson,
                    index + 1,
                    isLandscape,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonCard(
    BuildContext context,
    TajweedLesson lesson,
    int index,
    bool isLandscape,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h), // Reduced margin inside expansion
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.08), // Slightly lighter for contrast
            Colors.white.withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TajweedLessonPage(lesson: lesson),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            child: Row(
              children: [
                // Decorative Badge
                Container(
                  width: 32.w, // Slightly smaller
                  height: 32.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E676).withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF00E676).withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "$index", // Lesson Index
                      style: TextStyle(
                        color: const Color(0xFF00E676),
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                        fontFamily: GoogleFonts.outfit().fontFamily,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lesson.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: GoogleFonts.outfit().fontFamily,
                        ),
                      ),
                      if (lesson.definition.isNotEmpty) ...[
                        SizedBox(height: 2.h),
                        Text(
                          lesson.definition,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 11.sp,
                            fontFamily: GoogleFonts.outfit().fontFamily,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Action Icon
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white70,
                  size: 14.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

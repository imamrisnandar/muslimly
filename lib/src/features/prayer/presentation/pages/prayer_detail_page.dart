import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../data/models/prayer_guide_model.dart';

class PrayerDetailPage extends StatelessWidget {
  final PrayerGuideItem prayerModel;
  final List<PrayerGuideItem> allContent;

  const PrayerDetailPage({
    super.key,
    required this.prayerModel,
    required this.allContent,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Theme Colors matching Fasting and Wudhu Guides
    const backgroundColor = Color(0xFFFFF8E1); // Cream Theme
    const textColor = Color(0xFF4E342E); // Dark Brown
    const accentColor = Color(0xFF1B5E20); // Dark Green

    // Map to store keys for headings
    final Map<String, GlobalKey> headingKeys = {};

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          prayerModel.title,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontFamily: GoogleFonts.outfit().fontFamily,
            fontSize: 18.sp,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: textColor),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Content Container
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, backgroundColor],
                  ),
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: accentColor.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: MarkdownBody(
                  data: prayerModel.contentMarkdown ?? '',
                  selectable: true,
                  onTapLink: (text, href, title) {
                    if (href != null && href.startsWith('#')) {
                      final key = headingKeys[href.substring(1)];
                      if (key != null && key.currentContext != null) {
                        Scrollable.ensureVisible(
                          key.currentContext!,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          alignment: 0.1, // Offset slightly from top
                        );
                      }
                    }
                  },
                  builders: {
                    'h1': _HeadingBuilder(headingKeys),
                    'h2': _HeadingBuilder(headingKeys),
                    'h3': _HeadingBuilder(headingKeys),
                    'h4': _HeadingBuilder(headingKeys),
                    'h5': _HeadingBuilder(headingKeys),
                    'h6': _HeadingBuilder(headingKeys),
                    'blockquote': _BlockquoteBuilder(textColor, accentColor),
                  },
                  styleSheet: MarkdownStyleSheet(
                    p: TextStyle(
                      color: textColor,
                      fontSize: 16.sp,
                      height: 1.6,
                      fontFamily: GoogleFonts.outfit().fontFamily,
                    ),
                    h1: TextStyle(
                      color: accentColor,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: GoogleFonts.outfit().fontFamily,
                    ),
                    h2: TextStyle(
                      color: accentColor,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: GoogleFonts.outfit().fontFamily,
                      height: 2.0,
                    ),
                    h3: TextStyle(
                      color: textColor,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: GoogleFonts.outfit().fontFamily,
                    ),
                    blockquote: TextStyle(
                      color: textColor.withOpacity(0.8),
                      fontSize: 15.sp,
                      fontStyle: FontStyle.italic,
                      fontFamily: GoogleFonts.outfit().fontFamily,
                    ),
                    blockquoteDecoration: BoxDecoration(
                      color: textColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border(
                        left: BorderSide(color: accentColor, width: 4.w),
                      ),
                    ),
                    listBullet: TextStyle(color: accentColor, fontSize: 16.sp),
                    horizontalRuleDecoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: textColor.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // Navigation Buttons
              if (allContent.isNotEmpty) _buildNavigationSection(context, l10n),

              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationSection(BuildContext context, AppLocalizations l10n) {
    if (allContent.isEmpty) return const SizedBox.shrink();

    final currentIndex = allContent.indexWhere(
      (element) => element.id == prayerModel.id,
    );
    if (currentIndex == -1) return const SizedBox.shrink();

    final prevItem = currentIndex > 0 ? allContent[currentIndex - 1] : null;
    final nextItem = currentIndex < allContent.length - 1
        ? allContent[currentIndex + 1]
        : null;

    return Column(
      children: [
        Divider(color: Colors.brown.withOpacity(0.2)),
        SizedBox(height: 16.h),
        Row(
          children: [
            // Previous Button
            if (prevItem != null)
              Expanded(
                child: _buildNavButton(
                  context,
                  title: prevItem.title,
                  isNext: false,
                  l10n: l10n,
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PrayerDetailPage(
                          prayerModel: prevItem,
                          allContent: allContent,
                        ),
                      ),
                    );
                  },
                ),
              )
            else
              const Spacer(),

            if (prevItem != null && nextItem != null) SizedBox(width: 16.w),

            // Next Button
            if (nextItem != null)
              Expanded(
                child: _buildNavButton(
                  context,
                  title: nextItem.title,
                  isNext: true,
                  l10n: l10n,
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PrayerDetailPage(
                          prayerModel: nextItem,
                          allContent: allContent,
                        ),
                      ),
                    );
                  },
                ),
              )
            else
              const Spacer(),
          ],
        ),
      ],
    );
  }

  Widget _buildNavButton(
    BuildContext context, {
    required String title,
    required bool isNext,
    required AppLocalizations l10n,
    required VoidCallback onTap,
  }) {
    const accentColor = Color(0xFF1B5E20); // Dark Green
    const textColor = Color(0xFF4E342E); // Dark Brown

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: accentColor.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.blueGrey.withOpacity(0.05),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isNext
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: isNext
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                if (!isNext) ...[
                  Icon(
                    Icons.arrow_back_rounded,
                    size: 16.sp,
                    color: accentColor,
                  ),
                  SizedBox(width: 4.w),
                ],
                Text(
                  isNext ? l10n.lblNext : l10n.lblPrevious,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isNext) ...[
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16.sp,
                    color: accentColor,
                  ),
                ],
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              title,
              textAlign: isNext ? TextAlign.right : TextAlign.left,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.sp,
                color: textColor,
                fontWeight: FontWeight.bold,
                fontFamily: GoogleFonts.outfit().fontFamily,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeadingBuilder extends MarkdownElementBuilder {
  final Map<String, GlobalKey> headingKeys;

  _HeadingBuilder(this.headingKeys);

  @override
  Widget? visitText(org_text, TextStyle? preferredStyle) {
    String id = org_text.text.toLowerCase().trim().replaceAll(
      RegExp(r'[^a-z0-9]+'),
      '-',
    );
    // Remove leading/trailing hyphens
    id = id.replaceAll(RegExp(r'^-+|-+$'), '');

    // Assign a GlobalKey to this heading ID if not already present
    // We create a new key every build to ensure context freshness, or reuse if feasible.
    // However, since visitText is called during build...

    // Better strategy: create unique key based on ID, store in map.
    // If map already has it, reuse (to keep state matching).
    GlobalKey key;
    if (headingKeys.containsKey(id)) {
      key = headingKeys[id]!;
    } else {
      key = GlobalKey();
      headingKeys[id] = key;
    }

    return Container(
      key: key,
      child: Text(org_text.text, style: preferredStyle),
    );
  }
}

class _BlockquoteBuilder extends MarkdownElementBuilder {
  final Color textColor;
  final Color accentColor;

  _BlockquoteBuilder(this.textColor, this.accentColor);

  bool _hasArabicText(String text) {
    // Check if text contains Arabic characters (Unicode range 0600-06FF)
    return text.runes.any((rune) => rune >= 0x0600 && rune <= 0x06FF);
  }

  @override
  Widget visitElementAfter(element, preferredStyle) {
    final String text = element.textContent;
    final bool hasArabic = _hasArabicText(text);

    // Smart segmentation: detect Arabic ↔ Latin transitions
    List<Widget> segments = [];
    StringBuffer currentSegment = StringBuffer();
    bool? currentIsArabic;

    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      final charCode = char.codeUnitAt(0);
      final isArabicChar = charCode >= 0x0600 && charCode <= 0x06FF;

      // Neutral characters (punctuation, spaces) don't trigger transitions
      final isNeutral =
          char == ' ' ||
          char == '.' ||
          char == ',' ||
          char == '!' ||
          char == '?' ||
          char == ':' ||
          char == ';' ||
          char == '"' ||
          char == '\'' ||
          char == '(' ||
          char == ')' ||
          char == '*';

      if (currentIsArabic == null) {
        currentIsArabic = isArabicChar;
        currentSegment.write(char);
      } else if (isNeutral) {
        currentSegment.write(char);
      } else if (isArabicChar != currentIsArabic) {
        // Script transition! Save current segment
        if (currentSegment.isNotEmpty) {
          final segmentText = currentSegment.toString().trim();
          if (segmentText.isNotEmpty) {
            segments.add(
              Text(
                segmentText,
                style: currentIsArabic
                    ? GoogleFonts.amiriQuran(
                        color: textColor.withOpacity(0.9),
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w500,
                        height: 1.8,
                      )
                    : TextStyle(
                        color: textColor.withOpacity(0.8),
                        fontSize: 15.sp,
                        fontStyle: FontStyle.italic,
                        fontFamily: GoogleFonts.outfit().fontFamily,
                        height: 1.6,
                      ),
                textAlign: currentIsArabic ? TextAlign.right : TextAlign.left,
                textDirection: currentIsArabic
                    ? TextDirection.rtl
                    : TextDirection.ltr,
              ),
            );
            segments.add(SizedBox(height: 8.h));
          }
        }
        currentSegment.clear();
        currentSegment.write(char);
        currentIsArabic = isArabicChar;
      } else {
        currentSegment.write(char);
      }
    }

    // Add remaining segment
    if (currentSegment.isNotEmpty && currentIsArabic != null) {
      final segmentText = currentSegment.toString().trim();
      if (segmentText.isNotEmpty) {
        segments.add(
          Text(
            segmentText,
            style: currentIsArabic
                ? GoogleFonts.amiriQuran(
                    color: textColor.withOpacity(0.9),
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.8,
                  )
                : TextStyle(
                    color: textColor.withOpacity(0.8),
                    fontSize: 15.sp,
                    fontStyle: FontStyle.italic,
                    fontFamily: GoogleFonts.outfit().fontFamily,
                    height: 1.6,
                  ),
            textAlign: currentIsArabic ? TextAlign.right : TextAlign.left,
            textDirection: currentIsArabic
                ? TextDirection.rtl
                : TextDirection.ltr,
          ),
        );
      }
    }

    return Container(
      padding: EdgeInsets.only(
        right: hasArabic ? 16.w : 8.w,
        left: hasArabic ? 8.w : 16.w,
        top: 12.h,
        bottom: 12.h,
      ),
      decoration: BoxDecoration(
        color: textColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8.r),
        border: Border(
          right: hasArabic
              ? BorderSide(color: accentColor, width: 4.w)
              : BorderSide.none,
          left: !hasArabic
              ? BorderSide(color: accentColor, width: 4.w)
              : BorderSide.none,
        ),
      ),
      child: Column(
        crossAxisAlignment: hasArabic
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: segments,
      ),
    );
  }
}

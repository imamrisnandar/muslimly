import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/tajweed_parser.dart';
import '../../domain/entities/ayah.dart';
import '../../domain/entities/surah.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../core/presentation/widgets/premium_showcase.dart';

class SurahBismillahHeaderWidget extends StatelessWidget {
  const SurahBismillahHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h, top: 8.h),
      child: ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          colors: [
            Color(0xFF1B5E20), // Dark Green
            Color(0xFF43A047), // Rich Green
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds),
        blendMode: BlendMode.srcIn,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 24.w),
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Column(
            children: [
              // Top Decoration
              Row(
                children: [
                  const Expanded(
                    child: Divider(color: Colors.white, thickness: 1),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Icon(
                      Icons.star_outline_rounded,
                      size: 16.sp,
                      color: Colors.white,
                    ),
                  ),
                  const Expanded(
                    child: Divider(color: Colors.white, thickness: 1),
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              // Bismillah Calligraphy
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '﷽', // U+FDFD Calligraphy
                  textAlign: TextAlign.center,
                  style: GoogleFonts.amiri(
                    fontSize: 42.sp,
                    color: Colors.white,
                    height: 1.2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              SizedBox(height: 12.h),

              // Bottom Decoration (Mirrored)
              Row(
                children: [
                  const Expanded(
                    child: Divider(color: Colors.white, thickness: 1),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Icon(
                      Icons.star_outline_rounded,
                      size: 16.sp,
                      color: Colors.white,
                    ),
                  ),
                  const Expanded(
                    child: Divider(color: Colors.white, thickness: 1),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SurahAyahListCardWidget extends StatelessWidget {
  final Ayah ayah;
  final int index;
  final String surahName;
  final Surah surah;
  final int? initialAyah;
  final bool isPlaying;
  final bool isHighlighted;
  final bool showBismillah;
  final String ayahText;
  final String? translation;
  final bool isBookmarked;

  final VoidCallback onMarkAsRead;
  final VoidCallback onShare;
  final VoidCallback onTafsir;
  final VoidCallback onPlay;
  final VoidCallback onBookmark;

  final GlobalKey markReadKey;
  final GlobalKey shareKey;
  final GlobalKey tafsirKey;
  final GlobalKey playKey;
  final GlobalKey bookmarkKey;
  final String showcaseScope;

  const SurahAyahListCardWidget({
    super.key,
    required this.ayah,
    required this.index,
    required this.surahName,
    required this.surah,
    required this.initialAyah,
    required this.isPlaying,
    required this.isHighlighted,
    required this.showBismillah,
    required this.ayahText,
    required this.translation,
    required this.isBookmarked,
    required this.onMarkAsRead,
    required this.onShare,
    required this.onTafsir,
    required this.onPlay,
    required this.onBookmark,
    required this.markReadKey,
    required this.shareKey,
    required this.tafsirKey,
    required this.playKey,
    required this.bookmarkKey,
    required this.showcaseScope,
  });

  Widget _buildActionButton({
    Key? key,
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
    GlobalKey? showcaseKey,
    String? showcaseTitle,
    String? showcaseDesc,
    bool enableShowcase = false,
  }) {
    Widget button = InkWell(
      key: key,
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.all(6.w),
        child: Icon(icon, color: color ?? Colors.grey[600], size: 20.sp),
      ),
    );

    if (enableShowcase && showcaseKey != null) {
      return PremiumShowcase(
        globalKey: showcaseKey,
        scope: showcaseScope,
        title: showcaseTitle ?? '',
        description: showcaseDesc ?? '',
        child: button,
      );
    }

    return button;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showBismillah) const SurahBismillahHeaderWidget(),
        Container(
          decoration: BoxDecoration(
            color: isPlaying || isHighlighted
                ? const Color(0xFFE8F5E9) // Light Green Highlight
                : const Color(0xFFFFFCF2), // Soft Cream
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
            border: isPlaying || isHighlighted
                ? Border.all(color: const Color(0xFF00E676), width: 1.5)
                : Border.all(color: Colors.transparent),
          ),
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Arabic Text
              if (ayah.textTajweed != null && ayah.textTajweed!.isNotEmpty)
                RichText(
                  textAlign: TextAlign.right,
                  text: TajweedParser.parse(
                    ayah.textTajweed!,
                    style: GoogleFonts.amiriQuran(
                      color: Colors.black, // Dark Text
                      fontSize: 26.sp,
                      height: 2.2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              else
                Text(
                  ayahText,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.amiriQuran(
                    color: Colors.black,
                    fontSize: 26.sp,
                    height: 2.2,
                    fontWeight: FontWeight.w500,
                  ),
                ),

              SizedBox(height: 16.h),

              // Translation
              if (translation != null)
                Text(
                  translation!,
                  textAlign: TextAlign.left,
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF424242), // Dark Grey
                    fontSize: 15.sp,
                    height: 1.5,
                  ),
                ),

              if (translation != null) ...[
                SizedBox(height: 16.h),
                Divider(color: Colors.grey.withValues(alpha: 0.1), height: 1),
                SizedBox(height: 12.h),
              ],

              // Compact Action Bar
              Row(
                children: [
                  // Number Badge
                  Container(
                    width: 28.w,
                    height: 28.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E676).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${ayah.numberInSurah}',
                      style: TextStyle(
                        color: const Color(0xFF1B5E20),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  _buildActionButton(
                    key: (index == ((initialAyah ?? 1) - 1))
                        ? markReadKey
                        : null,
                    icon: Icons.check_circle_outline,
                    color: const Color(0xFF00E676), // Use Green
                    onTap: onMarkAsRead,
                  ),
                  SizedBox(width: 8.w),
                  _buildActionButton(
                    icon: Icons.share,
                    onTap: onShare,
                    showcaseKey: shareKey,
                    showcaseTitle: AppLocalizations.of(context)!.share,
                    showcaseDesc: AppLocalizations.of(
                      context,
                    )!.showcaseAyahShare,
                    enableShowcase: index == ((initialAyah ?? 1) - 1),
                  ),
                  SizedBox(width: 8.w),
                  _buildActionButton(
                    icon: Icons.library_books, // Tafsir Icon
                    onTap: onTafsir,
                    showcaseKey: tafsirKey,
                    showcaseTitle: AppLocalizations.of(context)!.menuTafsir,
                    showcaseDesc: AppLocalizations.of(context)!.showcaseTafsir,
                    enableShowcase: index == ((initialAyah ?? 1) - 1),
                  ),
                  SizedBox(width: 8.w),
                  _buildActionButton(
                    icon: Icons.play_circle_outline,
                    onTap: onPlay,
                    showcaseKey: playKey,
                    showcaseTitle: AppLocalizations.of(context)!.menuPlay,
                    showcaseDesc: AppLocalizations.of(
                      context,
                    )!.showcasePlayAyah,
                    enableShowcase: index == ((initialAyah ?? 1) - 1),
                  ),
                  SizedBox(width: 8.w),
                  _buildActionButton(
                    key: (index == ((initialAyah ?? 1) - 1))
                        ? bookmarkKey
                        : null,
                    icon: isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: isBookmarked ? const Color(0xFF00E676) : null,
                    onTap: onBookmark,
                    showcaseKey: bookmarkKey,
                    showcaseTitle: AppLocalizations.of(context)!.menuBookmark,
                    showcaseDesc: AppLocalizations.of(
                      context,
                    )!.showcaseAyahBookmark,
                    enableShowcase: index == ((initialAyah ?? 1) - 1),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

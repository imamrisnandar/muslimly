import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' show DateFormat;
import '../../../../core/presentation/widgets/gradient_page.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/dhikr_content.dart';

class HadithPage extends StatefulWidget {
  const HadithPage({super.key});

  @override
  State<HadithPage> createState() => _HadithPageState();
}

class _HadithPageState extends State<HadithPage> {
  List<Hadith> _all = [];

  @override
  void initState() {
    super.initState();
    DhikrContentRepository().hadiths().then((v) {
      if (mounted) setState(() => _all = v);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final now = DateTime.now();
    final today = _all.isEmpty ? null : hadithOfDay(_all, now);
    return GradientPage(
      title: l10n.hadithTitle,
      child: _all.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
              children: [
                _HeroHadith(
                  h: today!,
                  lang: lang,
                  dateLabel: DateFormat.yMMMMEEEEd(lang).format(now),
                ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Container(
                      width: 4.w,
                      height: 18.h,
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      l10n.hadithAll,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                for (var i = 0; i < _all.length; i++) ...[
                  _HadithTile(index: i + 1, h: _all[i], lang: lang),
                  SizedBox(height: 10.h),
                ],
                SizedBox(height: 4.h),
                Text(
                  l10n.hadithReviewNote,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white38, fontSize: 11.sp),
                ),
              ],
            ),
    );
  }
}

/// Arabic is right-aligned (RTL), the translation left-aligned (LTR).
class _ArabicText extends StatelessWidget {
  final String text;
  final double size;
  const _ArabicText(this.text, {required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Text(
        text,
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        style: GoogleFonts.amiri(
          color: Colors.white,
          fontSize: size,
          height: 1.9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

Future<void> _copy(BuildContext context, Hadith h, String lang) async {
  final l10n = AppLocalizations.of(context)!;
  final messenger = ScaffoldMessenger.of(context);
  await Clipboard.setData(
    ClipboardData(text: '${h.arabic}\n\n${h.text(lang)}\n\n${h.sourceFor(lang)}'),
  );
  messenger.showSnackBar(SnackBar(content: Text(l10n.hadithCopied)));
}

class _SourceChip extends StatelessWidget {
  final String text;
  const _SourceChip(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(color: AppColors.goldLight, fontSize: 11.sp),
      ),
    );
  }
}

class _Ornament extends StatelessWidget {
  const _Ornament();

  @override
  Widget build(BuildContext context) {
    final line = Expanded(
      child: Container(
        height: 1,
        color: AppColors.gold.withValues(alpha: 0.35),
      ),
    );
    return Row(
      children: [
        line,
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Icon(Icons.auto_awesome, color: AppColors.gold, size: 14.sp),
        ),
        line,
      ],
    );
  }
}

class _HeroHadith extends StatelessWidget {
  final Hadith h;
  final String lang;
  final String dateLabel;
  const _HeroHadith({
    required this.h,
    required this.lang,
    required this.dateLabel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 14.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF14574B), Color(0xFF0C2F33), Color(0xFF08161E)],
        ),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.format_quote_rounded, color: AppColors.gold, size: 28.sp),
              SizedBox(width: 6.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.hadithOfDay.toUpperCase(),
                      style: TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                        letterSpacing: 1.4,
                      ),
                    ),
                    Text(
                      dateLabel,
                      style: TextStyle(color: Colors.white54, fontSize: 11.sp),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: l10n.hadithCopy,
                icon: const Icon(Icons.copy_rounded, color: Colors.white60),
                onPressed: () => _copy(context, h, lang),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _ArabicText(h.arabic, size: 28.sp),
          SizedBox(height: 14.h),
          const _Ornament(),
          SizedBox(height: 14.h),
          SizedBox(
            width: double.infinity,
            child: Text(
              h.text(lang),
              textAlign: TextAlign.left,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.88),
                fontSize: 15.sp,
                height: 1.6,
              ),
            ),
          ),
          SizedBox(height: 14.h),
          Align(
            alignment: Alignment.centerLeft,
            child: _SourceChip(h.sourceFor(lang)),
          ),
        ],
      ),
    );
  }
}

class _HadithTile extends StatelessWidget {
  final int index;
  final Hadith h;
  final String lang;
  const _HadithTile({
    required this.index,
    required this.h,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.all(16.r),
      onTap: () => _copy(context, h, lang),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26.r,
                height: 26.r,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.gold.withValues(alpha: 0.15),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  '$index',
                  style: TextStyle(
                    color: AppColors.goldLight,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(child: _SourceChipLeft(h.sourceFor(lang))),
            ],
          ),
          SizedBox(height: 10.h),
          _ArabicText(h.arabic, size: 21.sp),
          SizedBox(height: 8.h),
          SizedBox(
            width: double.infinity,
            child: Text(
              h.text(lang),
              textAlign: TextAlign.left,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13.5.sp,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceChipLeft extends StatelessWidget {
  final String text;
  const _SourceChipLeft(this.text);

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Text(
      text,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(color: Colors.white38, fontSize: 11.sp),
    ),
  );
}

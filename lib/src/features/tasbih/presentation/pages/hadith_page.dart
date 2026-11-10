import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final today = _all.isEmpty ? null : hadithOfDay(_all, DateTime.now());
    return GradientPage(
      title: l10n.hadithTitle,
      child: _all.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(16.r),
              children: [
                Text(
                  l10n.hadithOfDay,
                  style: TextStyle(
                    color: AppColors.gold,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                _HadithCard(h: today!, lang: lang),
                SizedBox(height: 20.h),
                Text(
                  l10n.hadithAll,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                for (final h in _all) ...[
                  _HadithCard(h: h, lang: lang),
                  SizedBox(height: 8.h),
                ],
                Text(
                  l10n.hadithReviewNote,
                  style: TextStyle(color: Colors.white38, fontSize: 11.sp),
                ),
              ],
            ),
    );
  }
}

class _HadithCard extends StatelessWidget {
  final Hadith h;
  final String lang;
  const _HadithCard({required this.h, required this.lang});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            h.arabic,
            textDirection: TextDirection.rtl,
            style: GoogleFonts.amiri(
              color: Colors.white,
              fontSize: 22.sp,
              height: 1.8,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            h.text(lang),
            style: TextStyle(color: Colors.white70, fontSize: 14.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            h.sourceFor(lang),
            style: TextStyle(color: Colors.white38, fontSize: 12.sp),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/presentation/widgets/gradient_page.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/dhikr_content.dart';

class AsmaulHusnaPage extends StatefulWidget {
  const AsmaulHusnaPage({super.key});

  @override
  State<AsmaulHusnaPage> createState() => _AsmaulHusnaPageState();
}

class _AsmaulHusnaPageState extends State<AsmaulHusnaPage> {
  List<AsmaulHusnaName> _all = [];
  String _q = '';

  @override
  void initState() {
    super.initState();
    DhikrContentRepository().asmaulHusna().then((v) {
      if (mounted) setState(() => _all = v);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final q = _q.trim().toLowerCase();
    final shown = q.isEmpty
        ? _all
        : _all
              .where(
                (n) =>
                    n.transliteration.toLowerCase().contains(q) ||
                    n.meaning(lang).toLowerCase().contains(q) ||
                    n.arabic.contains(q) ||
                    '${n.number}' == q,
              )
              .toList();
    return GradientPage(
      title: l10n.asmaulHusnaTitle,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: TextField(
              onChanged: (v) => setState(() => _q = v),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                hintText: l10n.asmaulHusnaSearch,
                hintStyle: const TextStyle(color: Colors.white38),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.all(16.r),
              itemCount: shown.length,
              separatorBuilder: (_, _) => SizedBox(height: 8.h),
              itemBuilder: (_, i) {
                final n = shown[i];
                return GlassCard(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 32.w,
                        child: Text(
                          '${n.number}',
                          style: TextStyle(
                            color: AppColors.gold,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              n.transliteration,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              n.meaning(lang),
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 13.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        n.arabic,
                        textDirection: TextDirection.rtl,
                        style: GoogleFonts.amiri(
                          color: Colors.white,
                          fontSize: 24.sp,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

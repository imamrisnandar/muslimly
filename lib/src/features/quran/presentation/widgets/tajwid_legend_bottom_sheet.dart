import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../l10n/generated/app_localizations.dart';

class TajwidLegendBottomSheet extends StatelessWidget {
  const TajwidLegendBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: 0.8.sh), // Limit height
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1), // Cream Background (Mushaf Theme)
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 12.h),
          Center(
            child: Container(
              width: 48.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[400], // Visible Handle on Light Bg
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: 24.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Text(
              AppLocalizations.of(context)!.tajwidLegendTitle,
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87, // Dark Text
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 40.h),
              child: Column(
                children: [
                  _buildCard(
                    context,
                    const Color(0xFF169278),
                    AppLocalizations.of(context)!.tajwidGhunnah,
                    AppLocalizations.of(context)!.tajwidGhunnahDesc,
                  ),
                  _buildCard(
                    context,
                    const Color(0xFFFFD54F),
                    AppLocalizations.of(context)!.tajwidIkhfa,
                    AppLocalizations.of(context)!.tajwidIkhfaDesc,
                  ),
                  _buildCard(
                    context,
                    const Color(0xFFD8572A),
                    AppLocalizations.of(context)!.tajwidMadJaiz,
                    AppLocalizations.of(context)!.tajwidMadJaizDesc,
                  ),
                  _buildCard(
                    context,
                    const Color(0xFF3B83BD),
                    AppLocalizations.of(context)!.tajwidQalqalah,
                    AppLocalizations.of(context)!.tajwidQalqalahDesc,
                  ),
                  _buildCard(
                    context,
                    const Color(0xFF26BFFD),
                    AppLocalizations.of(context)!.tajwidIqlab,
                    AppLocalizations.of(context)!.tajwidIqlabDesc,
                  ),
                  _buildCard(
                    context,
                    const Color(0xFFE52C2C),
                    AppLocalizations.of(context)!.tajwidMadWajib,
                    AppLocalizations.of(context)!.tajwidMadWajibDesc,
                  ),
                  _buildCard(
                    context,
                    const Color(0xFFA1A1A1),
                    AppLocalizations.of(context)!.tajwidIdghamBilaghunnah,
                    AppLocalizations.of(context)!.tajwidIdghamBilaghunnahDesc,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    Color color,
    String title,
    String subtitle,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFFCF2), // Soft Cream Card
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: color.withOpacity(0.2), // Subtle colored border hint
              width: 1,
            ),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Colored Indicator Bar
                Container(width: 6.w, color: color),
                // Content
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            height: 1.3,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          subtitle,
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            color: Colors.black54, // Greier text
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

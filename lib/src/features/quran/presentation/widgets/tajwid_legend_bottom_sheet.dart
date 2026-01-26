import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../l10n/generated/app_localizations.dart';

class TajwidLegendBottomSheet extends StatelessWidget {
  const TajwidLegendBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: 0.85.sh),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA), // Clean White/Grey Background
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28.r),
          topRight: Radius.circular(28.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 12.h),
          // Drag Handle
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: 24.h),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E676).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.auto_stories_rounded,
                    color: const Color(0xFF00E676),
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Text(
                  AppLocalizations.of(context)!.tajwidLegendTitle,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Outfit',
                    color: const Color(0xFF2D3436),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24.h),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 40.h),
              child: Column(
                children: [
                  _buildPremiumCard(
                    context,
                    color: const Color(0xFF169278),
                    title: AppLocalizations.of(context)!.tajwidGhunnah,
                    subtitle: AppLocalizations.of(context)!.tajwidGhunnahDesc,
                  ),
                  _buildPremiumCard(
                    context,
                    color: const Color(0xFFFFD54F),
                    title: AppLocalizations.of(context)!.tajwidIkhfa,
                    subtitle: AppLocalizations.of(context)!.tajwidIkhfaDesc,
                  ),
                  _buildPremiumCard(
                    context,
                    color: const Color(0xFFD8572A),
                    title: AppLocalizations.of(context)!.tajwidMadJaiz,
                    subtitle: AppLocalizations.of(context)!.tajwidMadJaizDesc,
                  ),
                  _buildPremiumCard(
                    context,
                    color: const Color(0xFF3B83BD),
                    title: AppLocalizations.of(context)!.tajwidQalqalah,
                    subtitle: AppLocalizations.of(context)!.tajwidQalqalahDesc,
                  ),
                  _buildPremiumCard(
                    context,
                    color: const Color(0xFF26BFFD),
                    title: AppLocalizations.of(context)!.tajwidIqlab,
                    subtitle: AppLocalizations.of(context)!.tajwidIqlabDesc,
                  ),
                  _buildPremiumCard(
                    context,
                    color: const Color(0xFFE52C2C),
                    title: AppLocalizations.of(context)!.tajwidMadWajib,
                    subtitle: AppLocalizations.of(context)!.tajwidMadWajibDesc,
                  ),
                  _buildPremiumCard(
                    context,
                    color: const Color(0xFFA1A1A1),
                    title: AppLocalizations.of(
                      context,
                    )!.tajwidIdghamBilaghunnah,
                    subtitle: AppLocalizations.of(
                      context,
                    )!.tajwidIdghamBilaghunnahDesc,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumCard(
    BuildContext context, {
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Visual Indicator
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Center(
                  child: Container(
                    width: 14.w,
                    height: 14.w,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16.w),

              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 2.h),
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2D3436),
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 13.sp,
                        color: const Color(0xFF636E72), // Softer grey
                        height: 1.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

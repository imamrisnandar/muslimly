import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:muslimly/src/core/theme/app_colors.dart';
import '../../domain/entities/surah.dart';

class SurahDetailHeaderWidget extends StatelessWidget {
  final String surahName;
  final Surah surah;
  final int juzNumber;

  const SurahDetailHeaderWidget({
    super.key,
    required this.surahName,
    required this.surah,
    required this.juzNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.quranGreen, // Dark Green
            AppColors.quranGreenDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.quranGreen.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: Info
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    surahName, // Translation/English
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(
                        Icons.menu_book_rounded,
                        size: 12.sp,
                        color: AppColors.accent,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${surah.numberOfAyahs} Ayah',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11.sp,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(
                        Icons.bookmark_outline,
                        size: 12.sp,
                        color: AppColors.accent,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Juz $juzNumber',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Right: Arabic Name
              Text(
                surah.name,
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Amiri', // Use Arabic font if avail
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

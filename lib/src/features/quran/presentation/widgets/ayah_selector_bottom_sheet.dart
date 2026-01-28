import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/generated/app_localizations.dart';

class AyahSelectorBottomSheet extends StatelessWidget {
  final int totalAyahs;
  final Function(int) onAyahSelected;
  final String surahName;

  const AyahSelectorBottomSheet({
    super.key,
    required this.totalAyahs,
    required this.onAyahSelected,
    required this.surahName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F2027),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      constraints: BoxConstraints(
        maxHeight: 0.7.sh, // Max 70% of screen height
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 16.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(
                        context,
                      )!.jumpToAyah, // Ensure this exists or use fallback
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      surahName,
                      style: TextStyle(color: Colors.white54, fontSize: 14.sp),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.close, color: Colors.white54),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.white.withOpacity(0.1)),

          // Grid
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(24.w),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 12.w,
                crossAxisSpacing: 12.w,
                childAspectRatio: 1.0,
              ),
              itemCount: totalAyahs,
              itemBuilder: (context, index) {
                final ayahNumber = index + 1;
                return InkWell(
                  onTap: () {
                    context.pop(); // Close sheet
                    onAyahSelected(ayahNumber);
                  },
                  borderRadius: BorderRadius.circular(12.r),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$ayahNumber',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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

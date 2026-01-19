import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:muslimly/src/features/quran/presentation/utils/arabic_utils.dart';

class MushafHeaderWidget extends StatelessWidget {
  final int surahNumber;
  final String surahNameArabic;
  final int verseCount;

  const MushafHeaderWidget({
    super.key,
    required this.surahNumber,
    required this.surahNameArabic,
    required this.verseCount,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50.h,
      child: Stack(
        children: [
          Center(
            child: ShaderMask(
              shaderCallback: (Rect bounds) {
                return const LinearGradient(
                  colors: [
                    Color(0xFF00E676), // Green
                    Colors.blue, // Blue
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  tileMode: TileMode.mirror,
                ).createShader(bounds);
              },
              blendMode: BlendMode.srcIn,
              child: Image.asset(
                "assets/quran/images/888-02.png",
                width: double.infinity,
                height: 50.h,
                fit: BoxFit.fill,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal:
                  24.w, // Reduced from 64 to push sides outward into boxes
              vertical: 0.h,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Ensure vertical centering
              children: [
                // Ayah Count Label (Right Side in RTL)
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.w),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "اياتها",
                              style: TextStyle(
                                fontSize: 9.sp,
                                fontFamily: "UthmanicHafs13",
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              ArabicUtils.toArabicDigits(verseCount),
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                                fontFamily: "UthmanicHafs13",
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Surah Name (Center)
                Expanded(
                  flex: 6,
                  child: Center(
                    child: Padding(
                      // Add padding to force FittedBox to scale down text
                      // preventing it from touching top/bottom/sides of the frame
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 8.h,
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          surahNameArabic,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: "UthmanicHafs13",
                            fontSize:
                                22.sp, // Keep base large, let FittedBox scale
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Surah Order Label (Left Side in RTL)
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.w),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "ترتيبها",
                              style: TextStyle(
                                fontSize: 9.sp,
                                fontFamily: "UthmanicHafs13",
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              ArabicUtils.toArabicDigits(surahNumber),
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                                fontFamily: "UthmanicHafs13",
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

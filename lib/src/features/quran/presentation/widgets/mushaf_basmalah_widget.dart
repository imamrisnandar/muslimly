import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MushafBasmalahWidget extends StatelessWidget {
  const MushafBasmalahWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Center(
        child: Image.asset(
          "assets/quran/images/Basmala.png",
          color: Colors.black,
          width: 0.5.sw, // 50% of screen width
        ),
      ),
    );
  }
}

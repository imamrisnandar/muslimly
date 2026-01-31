import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum SnackBarType { success, error, info }

void showCustomSnackBar(
  BuildContext context, {
  required String message,
  SnackBarType type = SnackBarType.success,
  Duration duration = const Duration(seconds: 2),
}) {
  Color backgroundColor;
  IconData icon;
  Color iconColor;

  switch (type) {
    case SnackBarType.success:
      backgroundColor = const Color(0xFF00E676); // App Green
      icon = Icons.check_circle_rounded;
      iconColor = Colors.white;
      break;
    case SnackBarType.error:
      backgroundColor = const Color(0xFFFF5252); // Red Accent
      icon = Icons.error_outline_rounded;
      iconColor = Colors.white;
      break;
    case SnackBarType.info:
      backgroundColor = const Color(0xFF263238); // Dark Blue Grey
      icon = Icons.info_outline_rounded;
      iconColor = const Color(0xFF00E676);
      break;
  }

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Outfit',
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.all(16.w),
        elevation: 4,
        duration: duration,
      ),
    );
}

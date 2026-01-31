import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:showcaseview/showcaseview.dart';

class PremiumShowcase extends StatelessWidget {
  final GlobalKey globalKey;
  final String title;
  final String description;
  final Widget child;
  final VoidCallback? onNext;
  final ShapeBorder? targetShapeBorder;

  const PremiumShowcase({
    super.key,
    required this.globalKey,
    required this.title,
    required this.description,
    required this.child,
    this.onNext,
    this.targetShapeBorder,
  });

  @override
  Widget build(BuildContext context) {
    return Showcase.withWidget(
      key: globalKey,
      // height: 200, // Removed invalid param
      // width: 280.w, // Removed invalid param
      targetShapeBorder: targetShapeBorder ?? const CircleBorder(),
      overlayColor: Colors.black.withOpacity(0.85),
      container: _buildTooltip(context),
      child: child,
    );
  }

  Widget _buildTooltip(BuildContext context) {
    return Container(
      width: 280.w,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2C34), // Dark Grey/Blue
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFF00E676).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E676).withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E676).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.info_outline,
                  color: const Color(0xFF00E676),
                  size: 16.sp,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),

          // Body
          Text(
            description,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13.sp,
              height: 1.4,
            ),
          ),

          SizedBox(height: 16.h),

          // Footer (Button)
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                ShowCaseWidget.of(context).next();
                if (onNext != null) onNext!();
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E676),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  "Got it", // Or "Next" / "Lanjut"
                  style: TextStyle(
                    color: Colors.black, // Dark text on Green
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTransparentAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Color titleColor;
  final Color iconColor;
  final VoidCallback? onBack;
  final Widget? leading;

  const AppTransparentAppBar({
    super.key,
    required this.title,
    this.actions,
    this.titleColor = Colors.white,
    this.iconColor = Colors.white,
    this.onBack,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        title,
        style: TextStyle(
          color: titleColor,
          fontWeight: FontWeight.bold,
          fontFamily: GoogleFonts.outfit().fontFamily,
          fontSize: 18.sp,
        ),
      ),
      leading: leading ??
          IconButton(
            icon: Icon(Icons.arrow_back, color: iconColor),
            onPressed: onBack ?? () => context.pop(),
          ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

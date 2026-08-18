import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';

class AuthChoicePage extends StatelessWidget {
  const AuthChoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.bgGradientStart, AppColors.bgGradientMid, AppColors.bgGradientEnd],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                SizedBox(height: 48.h),

                // Logo + App name
                ClipOval(
                  child: Image.asset(
                    'assets/icon/app_icon.png',
                    width: 72.sp,
                    height: 72.sp,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Muslimly',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  l10n.authChoiceSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontSize: 14.sp),
                ),

                const Spacer(),

                // LOGIN
                _AuthOptionCard(
                  icon: Icons.login_rounded,
                  title: l10n.authChoiceLogin,
                  subtitle: l10n.authChoiceLoginSubtitle,
                  isPrimary: true,
                  onTap: () => context.go('/login'),
                ),
                SizedBox(height: 12.h),

                // REGISTER
                _AuthOptionCard(
                  icon: Icons.person_add_outlined,
                  title: l10n.authChoiceRegister,
                  subtitle: l10n.authChoiceRegisterSubtitle,
                  isPrimary: false,
                  onTap: () => context.go('/register'),
                ),

                SizedBox(height: 32.h),

                // OR divider
                Row(
                  children: [
                    const Expanded(child: Divider(color: Colors.white12)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text(
                        l10n.loginOr,
                        style: TextStyle(color: Colors.white38, fontSize: 12.sp),
                      ),
                    ),
                    const Expanded(child: Divider(color: Colors.white12)),
                  ],
                ),

                SizedBox(height: 16.h),

                // GUEST
                TextButton(
                  onPressed: () => context.go('/name-input'),
                  child: Text(
                    l10n.authChoiceGuest,
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white30,
                    ),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  l10n.authChoiceGuestNote,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white30, fontSize: 12.sp),
                ),

                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isPrimary;
  final VoidCallback onTap;

  const _AuthOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const green = AppColors.accent;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
        decoration: BoxDecoration(
          color: isPrimary ? green.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isPrimary ? green : Colors.white24,
            width: isPrimary ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: isPrimary ? green.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isPrimary ? green : Colors.white70,
                size: 22.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isPrimary ? green : Colors.white,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: isPrimary ? green : Colors.white30,
              size: 14.sp,
            ),
          ],
        ),
      ),
    );
  }
}

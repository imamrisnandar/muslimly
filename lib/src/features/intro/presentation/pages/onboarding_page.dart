import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/generated/app_localizations.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../features/settings/presentation/bloc/settings_cubit.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onSkip() {
    context.go('/name-input');
  }

  void _onNext() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _onSkip();
    }
  }

  Widget _buildLanguageOption(BuildContext context, String label, String code) {
    final currentLocale = context.watch<SettingsCubit>().state.locale;
    final selectedCode = currentLocale?.languageCode ?? 'id';
    final isActive = selectedCode == code;

    return GestureDetector(
      onTap: () {
        context.read<SettingsCubit>().updateLanguage(Locale(code));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF00E676) : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
          border: isActive
              ? null
              : Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.black : Colors.white70,
            fontWeight: FontWeight.bold,
            fontSize: 12.sp,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final slides = [
      _OnboardingSlide(
        title: l10n.onboardingTitle1,
        description: l10n.onboardingDesc1,
        icon: Icons.track_changes,
        color: const Color(0xFF00E676),
      ),
      _OnboardingSlide(
        title: l10n.onboardingTitle2,
        description: l10n.onboardingDesc2,
        icon: Icons.mosque_rounded,
        color: const Color(0xFF29B6F6),
      ),
      _OnboardingSlide(
        title: l10n.onboardingTitle3,
        description: l10n.onboardingDesc3,
        icon: Icons.menu_book_rounded,
        color: const Color(0xFFFFCA28),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0F2027),
                  Color(0xFF203A43),
                  Color(0xFF2C5364),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Bar: Language Selector & Skip
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 16.h,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Language Selector (Left)
                      Row(
                        children: [
                          _buildLanguageOption(context, 'ID', 'id'),
                          SizedBox(width: 8.w),
                          _buildLanguageOption(context, 'EN', 'en'),
                        ],
                      ),

                      // Skip Button (Right)
                      TextButton(
                        onPressed: _onSkip,
                        child: Text(
                          "Skip", // Could be localized if needed
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Middle: Carousel
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: slides.length,
                    itemBuilder: (context, index) {
                      return slides[index];
                    },
                  ),
                ),

                // Page Indicator Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(slides.length, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      width: _currentPage == index ? 24.w : 8.w,
                      height: 8.h,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? const Color(0xFF00E676)
                            : Colors.white24,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    );
                  }),
                ),

                SizedBox(height: 32.h),

                // Bottom: Next / Get Started Button
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 24.h,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: ElevatedButton(
                      onPressed: _onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00E676),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentPage == 2
                            ? l10n.getStarted
                            : "Next", // "Next" could be localized
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
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

class _OnboardingSlide extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const _OnboardingSlide({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(32.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.3), width: 2),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(icon, size: 80.sp, color: color),
          ),
          SizedBox(height: 48.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16.sp,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

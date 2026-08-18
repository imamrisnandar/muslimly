import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/zikir_item.dart';
import '../../../../l10n/generated/app_localizations.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/presentation/widgets/app_transparent_app_bar.dart';

class DzikirReadingPage extends StatefulWidget {
  final String title;
  final List<ZikirItem> items;

  final int initialIndex;
  final bool enableCounter;

  const DzikirReadingPage({
    super.key,
    required this.title,
    required this.items,
    this.initialIndex = 0,
    this.enableCounter = true,
  });

  @override
  State<DzikirReadingPage> createState() => _DzikirReadingPageState();
}

class _DzikirReadingPageState extends State<DzikirReadingPage> {
  late PageController _pageController;
  late int _currentIndex;
  int _currentCount = 0; // Counts for the current item

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(
      viewportFraction: 0.9,
      initialPage: _currentIndex,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _incrementCounter() {
    // Add Haptic Feedback
    HapticFeedback.lightImpact();

    final item = widget.items[_currentIndex];
    setState(() {
      _currentCount++;
    });

    if (_currentCount >= item.targetCount) {
      if (_currentIndex < widget.items.length - 1) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            _goToNext();
          }
        });
      } else {
        _showCompletionDialog();
      }
    }
  }

  void _goToPrev() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToNext() {
    if (_currentIndex < widget.items.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _showCompletionDialog();
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
      _currentCount = 0;
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: Text(
          AppLocalizations.of(context)!.dzikirAlhamdulillah,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          AppLocalizations.of(context)!.dzikirDoneMessage,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close Dialog
              context.pop(); // Go Back to Home
            },
            child: Text(
              AppLocalizations.of(context)!.dzikirFinish,
              style: const TextStyle(color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentItem = widget.items[_currentIndex];
    final progress = (_currentIndex + 1) / widget.items.length;
    final l10n = AppLocalizations.of(context)!;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: AppColors.creamBg, // Quran Theme
      appBar: AppTransparentAppBar(
        title: widget.title,
        titleColor: AppColors.quranBrown,
        iconColor: AppColors.quranBrown,
        actions: [
          Center(
            child: Padding(
              padding: EdgeInsets.only(right: 16.w),
              child: Text(
                "${_currentIndex + 1}/${widget.items.length}",
                style: TextStyle(
                  color: AppColors.quranBrown,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(4.h),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.quranGreen.withValues(alpha: 0.1),
            valueColor: const AlwaysStoppedAnimation(AppColors.quranGreen),
            minHeight: 4.h,
          ),
        ),
      ),
      body: isLandscape
          ? Stack(
              children: [
                // Full-screen content
                Column(
                  children: [
                    SizedBox(height: 4.h),
                    // Carousel
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: widget.items.length,
                        onPageChanged: _onPageChanged,
                        physics:
                            const BouncingScrollPhysics(), // Allow manual swipe too
                        itemBuilder: (context, index) {
                          final item = widget.items[index];
                          final isCurrent = index == _currentIndex;

                          return AnimatedScale(
                            scale: isCurrent ? 1.0 : 0.9,
                            duration: const Duration(milliseconds: 300),
                            child: Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: 4.w,
                                vertical: 4.h,
                              ),
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white,
                                    AppColors.creamBg,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(24.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF1B5E20,
                                    ).withValues(alpha: 0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                border: isCurrent
                                    ? Border.all(
                                        color: AppColors.quranGreen,
                                        width: 1.5,
                                      )
                                    : null,
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      item.title,
                                      style: TextStyle(
                                        color: AppColors.quranGreen,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        fontFamily:
                                            GoogleFonts.outfit().fontFamily,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 12.h),
                                    Text(
                                      item.arabic,
                                      style: GoogleFonts.amiriQuran(
                                        color: Colors.black87,
                                        fontSize: 20.sp,
                                        height: 1.8,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    if (item.transliteration.isNotEmpty) ...[
                                      SizedBox(height: 8.h),
                                      Text(
                                        item.transliteration,
                                        style: TextStyle(
                                          color: const Color(
                                            0xFF6D4C41,
                                          ), // Medium Brown
                                          fontSize: 11.sp,
                                          fontStyle: FontStyle.italic,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                    SizedBox(height: 12.h),
                                    Text(
                                      item.translation,
                                      style: TextStyle(
                                        color: AppColors.quranBrown,
                                        fontSize: 11.sp,
                                        fontFamily:
                                            GoogleFonts.outfit().fontFamily,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    if (item.source.isNotEmpty) ...[
                                      SizedBox(height: 6.h),
                                      Text(
                                        item.source,
                                        style: TextStyle(
                                          color: const Color(
                                            0xFF4E342E,
                                          ).withValues(alpha: 0.5),
                                          fontSize: 8.sp,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                // Floating Navigation Buttons (Left & Right)
                Positioned(
                  left: 16.w,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_rounded,
                          color: _currentIndex > 0
                              ? Colors.white
                              : Colors.transparent,
                          size: 20.sp,
                        ),
                        onPressed: _currentIndex > 0 ? _goToPrev : null,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 16.w,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                        onPressed: _goToNext,
                      ),
                    ),
                  ),
                ),

                // Floating Counter Button (Landscape: Top Left)
                if (widget.enableCounter)
                  Positioned(
                    top: 16.h,
                    left: 16.w,
                    child: GestureDetector(
                      onTap: _incrementCounter,
                      child: Container(
                        height: 56.w, // Slightly larger touch area
                        width: 56.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.quranGreen.withValues(alpha: 
                            isLandscape ? 0.2 : 1.0,
                          ), // Semi-transparent in landscape
                          border: isLandscape
                              ? Border.all(
                                  color: AppColors.quranGreen,
                                  width: 2.w,
                                )
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF1B5E20,
                              ).withValues(alpha: isLandscape ? 0.1 : 0.4),
                              blurRadius: isLandscape ? 0 : 8,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value:
                                  (currentItem.targetCount - _currentCount) /
                                  currentItem.targetCount,
                              valueColor: AlwaysStoppedAnimation(
                                isLandscape
                                    ? AppColors.quranGreen
                                    : Colors.white,
                              ),
                              strokeWidth: 3,
                            ),
                            Text(
                              "${currentItem.targetCount - _currentCount}",
                              style: TextStyle(
                                color: isLandscape
                                    ? AppColors.quranGreen
                                    : Colors.white,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            )
          : Column(
              children: [
                SizedBox(height: 16.h),
                // Carousel
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: widget.items.length,
                    onPageChanged: _onPageChanged,
                    physics:
                        const BouncingScrollPhysics(), // Allow manual swipe too
                    itemBuilder: (context, index) {
                      final item = widget.items[index];
                      final isCurrent = index == _currentIndex;

                      return AnimatedScale(
                        scale: isCurrent ? 1.0 : 0.9,
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 8.h,
                          ),
                          padding: EdgeInsets.all(20.w),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Colors.white, AppColors.creamBg],
                            ),
                            borderRadius: BorderRadius.circular(24.r),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.quranGreen.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: isCurrent
                                ? Border.all(
                                    color: AppColors.quranGreen,
                                    width: 1.5,
                                  )
                                : null,
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  item.title,
                                  style: TextStyle(
                                    color: AppColors.quranGreen,
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: GoogleFonts.outfit().fontFamily,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 24.h),
                                Text(
                                  item.arabic,
                                  style: GoogleFonts.amiriQuran(
                                    color: Colors.black87,
                                    fontSize: 28.sp,
                                    height: 2.2,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                if (item.transliteration.isNotEmpty) ...[
                                  SizedBox(height: 16.h),
                                  Text(
                                    item.transliteration,
                                    style: TextStyle(
                                      color: const Color(0xFF6D4C41),
                                      fontSize: 14.sp,
                                      fontStyle: FontStyle.italic,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                                SizedBox(height: 24.h),
                                Text(
                                  item.translation,
                                  style: TextStyle(
                                    color: AppColors.quranBrown,
                                    fontSize: 14.sp,
                                    fontFamily: GoogleFonts.outfit().fontFamily,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                if (item.source.isNotEmpty) ...[
                                  SizedBox(height: 12.h),
                                  Text(
                                    item.source,
                                    style: TextStyle(
                                      color: const Color(
                                        0xFF4E342E,
                                      ).withValues(alpha: 0.5),
                                      fontSize: 10.sp,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Counter Button Area
                if (widget.enableCounter)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 24.h,
                    ),
                    child: Column(
                      children: [
                        Text(
                          l10n.dzikirReadCount(currentItem.targetCount),
                          style: TextStyle(
                            color: AppColors.quranBrown.withValues(alpha: 0.6),
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Prev Button
                            IconButton(
                              icon: Icon(
                                Icons.arrow_back_ios_rounded,
                                color: _currentIndex > 0
                                    ? AppColors.quranBrown
                                    : Colors.transparent,
                                size: 32.sp,
                              ),
                              onPressed: _currentIndex > 0 ? _goToPrev : null,
                            ),
                            SizedBox(width: 24.w),

                            // Counter
                            GestureDetector(
                              onTap: _incrementCounter,
                              child: Container(
                                height: 80.h,
                                width: 80.h,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.quranGreen,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF1B5E20,
                                      ).withValues(alpha: 0.4),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    "${currentItem.targetCount - _currentCount}",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 32.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(width: 24.w),

                            // Next Button
                            IconButton(
                              icon: Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: const Color(
                                  0xFF4E342E,
                                ), // Always visible (Next or Finish)
                                size: 32.sp,
                              ),
                              onPressed: _goToNext,
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          l10n.dzikirTapToCount,
                          style: TextStyle(
                            color: AppColors.quranBrown.withValues(alpha: 0.5),
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  // Simple Navigation for Reading Mode
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios_rounded,
                            color: _currentIndex > 0
                                ? AppColors.quranBrown
                                : Colors.transparent,
                            size: 32.sp,
                          ),
                          onPressed: _currentIndex > 0 ? _goToPrev : null,
                        ),
                        SizedBox(width: 48.w),
                        Text(
                          "${_currentIndex + 1} / ${widget.items.length}",
                          style: TextStyle(
                            color: AppColors.quranBrown,
                            fontSize: 16.sp,
                          ),
                        ),
                        SizedBox(width: 48.w),
                        IconButton(
                          icon: Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: _currentIndex < widget.items.length - 1
                                ? AppColors.quranBrown
                                : Colors.transparent,
                            size: 32.sp,
                          ),
                          onPressed: _currentIndex < widget.items.length - 1
                              ? _goToNext
                              : null,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/inspiration_data.dart';

class DailyInspirationPage extends StatefulWidget {
  const DailyInspirationPage({super.key});

  @override
  State<DailyInspirationPage> createState() => _DailyInspirationPageState();
}

class _DailyInspirationPageState extends State<DailyInspirationPage> {
  late InspirationQuote _currentQuote;

  @override
  void initState() {
    super.initState();
    _randomizeQuote();
  }

  void _randomizeQuote() {
    setState(() {
      _currentQuote = InspirationData
          .quotes[Random().nextInt(InspirationData.quotes.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.black26,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_back, color: Colors.white),
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE65100), Color(0xFFFB8C00), Color(0xFFFF9800)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.format_quote_rounded,
                    size: 64.sp,
                    color: Colors.white70,
                  ),
                  SizedBox(height: 24.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.w),
                    child: Text(
                      _currentQuote.arabic,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.amiriQuran(
                        fontSize: 28.sp,
                        color: Colors.white,
                        height: 2.2,
                      ),
                    ),
                  ),
                  SizedBox(height: 32.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.w),
                    child: Text(
                      "\"${_currentQuote.translation}\"",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    _currentQuote.source,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 64.h),

                  // Actions
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 48.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildActionButton(
                          icon: Icons.refresh,
                          label: "New Quote",
                          onTap: _randomizeQuote,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: const Color(0xFFE65100), size: 28.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

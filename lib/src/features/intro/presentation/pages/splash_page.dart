import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/di_container.dart';
import '../../data/repositories/name_repository.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _navigateToHome();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      final repo = getIt<NameRepository>();
      final name = await repo.getName();

      if (mounted) {
        if (name == null || name.isEmpty) {
          context.go('/onboarding');
        } else {
          context.go('/dashboard');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: isLandscape
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildLogo(isLandscape),
                        SizedBox(width: 24.w),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildTitle(isLandscape),
                              SizedBox(height: 8.h),
                              _buildSubtitle(isLandscape, TextAlign.left),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildLogo(isLandscape),
                        SizedBox(height: 24.h),
                        _buildTitle(isLandscape),
                        SizedBox(height: 8.h),
                        _buildSubtitle(isLandscape, TextAlign.center),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(bool isLandscape) {
    return ScaleTransition(
      scale: _animation,
      child: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF101820),
          border: Border.all(color: const Color(0xFFD4AF37), width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00E676).withOpacity(0.3),
              blurRadius: 40,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipOval(
          child: Image.asset(
            'assets/icon/app_icon.png',
            width: isLandscape ? 80.sp : 100.sp,
            height: isLandscape ? 80.sp : 100.sp,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(bool isLandscape) {
    return Text(
      'Muslimly',
      style: TextStyle(
        color: Colors.white,
        fontSize: isLandscape ? 28.sp : 32.sp,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildSubtitle(bool isLandscape, TextAlign align) {
    return Text(
      'Your Daily Muslim Companion',
      textAlign: align,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: Colors.white70,
        fontSize: 14.sp,
        letterSpacing: 1,
      ),
    );
  }
}

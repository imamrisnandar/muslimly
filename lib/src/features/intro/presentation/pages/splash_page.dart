import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/di_container.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../settings/data/repositories/settings_repository.dart';
import '../../../settings/presentation/bloc/settings_cubit.dart';
import '../../domain/repositories/name_repository.dart';
import '../../../../core/theme/app_colors.dart';

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
      duration: const Duration(milliseconds: 500),
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

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    // Trigger background settings sync on app start
    getIt<SettingsRepository>().syncSettingsFromRemote();

    // Restore AuthBloc state from persisted token (runs in parallel with navigation logic)
    if (mounted) context.read<AuthBloc>().add(AuthStarted());

    final tokenResult = await getIt<AuthRepository>().getToken();
    final token = tokenResult.getOrElse((_) => null);

    if (token != null && token.isNotEmpty) {
      final payload = _decodeJwtPayload(token);
      final exp = payload?['exp'] as int?;
      final isValid = exp != null &&
          DateTime.fromMillisecondsSinceEpoch(exp * 1000).isAfter(DateTime.now());

      if (isValid) {
        final username = payload!['username'] as String?;
        if (username != null && username.isNotEmpty && mounted) {
          context.read<SettingsCubit>().updateName(username);
        }
        if (mounted) context.go('/dashboard');
        return;
      }

      // Token expired — delete and force re-login
      await getIt<AuthRepository>().deleteToken();
      if (mounted) context.go('/login');
      return;
    }

    final name = await getIt<NameRepository>().getName();
    if (mounted) {
      context.go(name == null || name.isEmpty ? '/onboarding' : '/dashboard');
    }
  }

  Map<String, dynamic>? _decodeJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = parts[1];
      final normalized = payload.padRight(
        payload.length + (4 - payload.length % 4) % 4,
        '=',
      );
      final decoded = utf8.decode(base64Url.decode(normalized));
      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (_) {
      return null;
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
            colors: [AppColors.bgGradientStart, AppColors.bgGradientMid, AppColors.bgGradientEnd],
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
              color: AppColors.accent.withValues(alpha: 0.3),
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

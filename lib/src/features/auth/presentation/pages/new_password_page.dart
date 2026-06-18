import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/islamic_loading_indicator.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../core/utils/custom_snackbar.dart';
import '../../../../core/utils/password_validator.dart';
import '../bloc/forgot_password_bloc.dart';

class NewPasswordPage extends StatefulWidget {
  final String resetToken;
  const NewPasswordPage({super.key, required this.resetToken});

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmVisible = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          ),
        ),
        child: BlocConsumer<ForgotPasswordBloc, ForgotPasswordState>(
          listener: (context, state) {
            if (state is ForgotPasswordSuccess) {
              showCustomSnackBar(context, message: l10n.newPasswordSuccess, type: SnackBarType.success);
              context.go('/login');
            } else if (state is ForgotPasswordError) {
              showCustomSnackBar(context, message: state.message, type: SnackBarType.error);
            }
          },
          builder: (context, state) {
            final isLoading = state is ForgotPasswordLoading;

            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Container(
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C2A30).withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock_outline, color: const Color(0xFF00E676), size: 48.sp),
                      SizedBox(height: 16.h),
                      Text(
                        l10n.newPasswordTitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        l10n.newPasswordSubtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14.sp, color: Colors.white70),
                      ),
                      SizedBox(height: 32.h),
                      Text(
                        l10n.newPasswordLabel,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                          letterSpacing: 1.0,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        style: const TextStyle(color: Colors.black87),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: l10n.newPasswordHint,
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          prefixIcon: Icon(Icons.lock_outline, color: Colors.green[200]),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                              color: Colors.green[200],
                            ),
                            onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 16.h),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        l10n.newPasswordConfirmLabel,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                          letterSpacing: 1.0,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextField(
                        controller: _confirmController,
                        obscureText: !_isConfirmVisible,
                        style: const TextStyle(color: Colors.black87),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: l10n.newPasswordConfirmHint,
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          prefixIcon: Icon(Icons.lock_outline, color: Colors.green[200]),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmVisible ? Icons.visibility : Icons.visibility_off,
                              color: Colors.green[200],
                            ),
                            onPressed: () => setState(() => _isConfirmVisible = !_isConfirmVisible),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 16.h),
                        ),
                      ),
                      SizedBox(height: 28.h),
                      if (isLoading)
                        const Center(child: IslamicLoadingIndicator(size: 48))
                      else
                        SizedBox(
                          height: 50.h,
                          child: ElevatedButton(
                            onPressed: () {
                              final password = _passwordController.text;
                              final confirm = _confirmController.text;
                              if (!isPasswordStrong(password)) {
                                showCustomSnackBar(context, message: l10n.passwordTooWeak, type: SnackBarType.error);
                                return;
                              }
                              if (password != confirm) {
                                showCustomSnackBar(
                                  context,
                                  message: l10n.newPasswordMismatch,
                                  type: SnackBarType.error,
                                );
                                return;
                              }
                              context.read<ForgotPasswordBloc>().add(
                                ForgotPasswordResetSubmitted(
                                  resetToken: widget.resetToken,
                                  newPassword: password,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00E676),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              l10n.newPasswordButton,
                              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

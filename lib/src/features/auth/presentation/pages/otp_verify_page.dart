import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/islamic_loading_indicator.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../core/utils/custom_snackbar.dart';
import '../bloc/forgot_password_bloc.dart';

class OtpVerifyPage extends StatefulWidget {
  final String email;
  const OtpVerifyPage({super.key, required this.email});

  @override
  State<OtpVerifyPage> createState() => _OtpVerifyPageState();
}

class _OtpVerifyPageState extends State<OtpVerifyPage> {
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
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
            if (state is ForgotPasswordOTPVerified) {
              context.push('/new-password', extra: {
                'bloc': context.read<ForgotPasswordBloc>(),
                'reset_token': state.resetToken,
              });
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
                      Icon(Icons.mark_email_read_outlined, color: const Color(0xFF00E676), size: 48.sp),
                      SizedBox(height: 16.h),
                      Text(
                        l10n.otpVerifyTitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        l10n.otpVerifySubtitle(widget.email),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14.sp, color: Colors.white70),
                      ),
                      SizedBox(height: 32.h),
                      TextField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 6,
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 8,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: l10n.otpVerifyHint,
                          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14.sp, letterSpacing: 1),
                          counterText: '',
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
                              context.read<ForgotPasswordBloc>().add(
                                ForgotPasswordOTPSubmitted(
                                  email: widget.email,
                                  otp: _otpController.text.trim(),
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
                              l10n.otpVerifyButton,
                              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      SizedBox(height: 16.h),
                      Center(
                        child: TextButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  context.read<ForgotPasswordBloc>().add(
                                    ForgotPasswordEmailSubmitted(widget.email),
                                  );
                                },
                          child: Text(
                            l10n.otpVerifyResend,
                            style: const TextStyle(color: Color(0xFF00E676)),
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

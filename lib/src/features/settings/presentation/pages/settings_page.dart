import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/generated/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../bloc/settings_cubit.dart';
import '../bloc/settings_state.dart';
import '../../../prayer/presentation/bloc/prayer_bloc.dart';
import '../../../prayer/presentation/bloc/prayer_event.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:dio/dio.dart';
import '../../../quran/presentation/pages/help_guide_page.dart';
import '../../../../core/di/di_container.dart';
import '../../../../core/services/showcase_preferences_service.dart';
import '../../../../core/utils/custom_snackbar.dart';
import '../../../../core/utils/password_validator.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/presentation/widgets/app_transparent_app_bar.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _showLanguageBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.cardDarker,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle Bar
                Center(
                  child: Container(
                    margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 32.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.settingsLanguage,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Outfit',
                        ),
                      ),
                      SizedBox(height: 24.h),

                      BlocBuilder<SettingsCubit, SettingsState>(
                        builder: (context, state) {
                          final isIndo = state.locale?.languageCode == 'id';
                          return Column(
                            children: [
                              _buildLanguageOption(
                                context,
                                "English",
                                "US", // Using iso code or emoji
                                "🇺🇸",
                                !isIndo,
                                () {
                                  context.read<SettingsCubit>().updateLanguage(
                                    const Locale('en'),
                                  );
                                  Navigator.pop(context);
                                },
                              ),
                              SizedBox(height: 12.h),
                              _buildLanguageOption(
                                context,
                                "Bahasa Indonesia",
                                "ID",
                                "🇮🇩",
                                isIndo,
                                () {
                                  context.read<SettingsCubit>().updateLanguage(
                                    const Locale('id'),
                                  );
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String label,
    String subLabel,
    String flag,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? AppColors.accent : Colors.white10,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Text(flag, style: TextStyle(fontSize: 24.sp)),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w600,
                      fontFamily: 'Outfit',
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subLabel,
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  color: AppColors.cardDarker,
                  size: 16.sp,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showNameDialog(BuildContext context, String currentName) {
    final TextEditingController controller = TextEditingController(
      text: currentName,
    );
    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return Dialog(
          backgroundColor: AppColors.cardDarker,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.settingsName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: TextField(
                      controller: controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: l10n.nameInputHint,
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 14.h,
                        ),
                        prefixIcon: Icon(
                          Icons.person_outline,
                          color: Colors.white54,
                          size: 20.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 32.h),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                          child: Text(
                            l10n.cancel,
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 16.sp,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (controller.text.isNotEmpty) {
                              context.read<SettingsCubit>().updateName(
                                controller.text,
                              );
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                          child: Text(
                            l10n.settingsSave,
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).then((_) => controller.dispose());
  }

  void _showEditUsernameSheet(BuildContext context, String userId, String currentUsername, String token) {
    final controller = TextEditingController(text: currentUsername);
    showDialog(
      context: context,
      builder: (dialogContext) {
        final l10n = AppLocalizations.of(dialogContext)!;
        bool isLoading = false;
        return StatefulBuilder(
          builder: (ctx, setState) => Dialog(
            backgroundColor: AppColors.cardDarker,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.settingsEditUsername, style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 24.h),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: TextField(
                      controller: controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: l10n.settingsUsernameHint,
                        hintStyle: TextStyle(color: Colors.white30),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                        prefixIcon: Icon(Icons.person_outline, color: Colors.white54, size: 20.sp),
                      ),
                    ),
                  ),
                  SizedBox(height: 32.h),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: Text(l10n.cancel, style: TextStyle(color: Colors.white54, fontSize: 16.sp)),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isLoading ? null : () async {
                            final newUsername = controller.text.trim();
                            if (newUsername.isEmpty || newUsername == currentUsername) return;
                            setState(() => isLoading = true);
                            try {
                              final dio = getIt<Dio>();
                              await dio.put(
                                '/users/update',
                                data: {'id': userId, 'username': newUsername},
                                options: Options(headers: {'Authorization': 'Bearer $token'}),
                              );
                              if (dialogContext.mounted) {
                                Navigator.pop(dialogContext);
                                showCustomSnackBar(context, message: l10n.settingsUsernameUpdated, type: SnackBarType.success);
                              }
                            } on DioException catch (e) {
                              final msg = e.response?.data?['message'] ?? l10n.commonError;
                              if (dialogContext.mounted) showCustomSnackBar(dialogContext, message: msg.toString(), type: SnackBarType.error);
                            } finally {
                              if (dialogContext.mounted) setState(() => isLoading = false);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                          ),
                          child: isLoading
                              ? SizedBox(width: 20.w, height: 20.h, child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.black54))
                              : Text(l10n.settingsSave, style: TextStyle(color: Colors.black87, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).then((_) => controller.dispose());
  }

  void _showChangePasswordSheet(BuildContext context, String token) {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
        final l10n = AppLocalizations.of(dialogContext)!;
        bool isLoading = false;
        bool showCurrent = false;
        bool showNew = false;
        bool showConfirm = false;
        return StatefulBuilder(
          builder: (ctx, setState) => Dialog(
            backgroundColor: AppColors.cardDarker,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.settingsChangePassword, style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 24.h),
                  _passwordField(l10n.settingsCurrentPassword, l10n.settingsCurrentPasswordHint, currentCtrl, showCurrent, () => setState(() => showCurrent = !showCurrent)),
                  SizedBox(height: 16.h),
                  _passwordField(l10n.newPasswordLabel, l10n.newPasswordHint, newCtrl, showNew, () => setState(() => showNew = !showNew)),
                  SizedBox(height: 4.h),
                  Padding(
                    padding: EdgeInsets.only(left: 4.w),
                    child: Text(
                      l10n.passwordComplexityHint,
                      style: TextStyle(color: Colors.white38, fontSize: 11.sp),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  _passwordField(l10n.newPasswordConfirmLabel, l10n.newPasswordConfirmHint, confirmCtrl, showConfirm, () => setState(() => showConfirm = !showConfirm)),
                  SizedBox(height: 32.h),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: Text(l10n.cancel, style: TextStyle(color: Colors.white54, fontSize: 16.sp)),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isLoading ? null : () async {
                            final pw = newCtrl.text;
                            if (!isPasswordStrong(pw)) {
                              showCustomSnackBar(dialogContext, message: l10n.passwordTooWeak, type: SnackBarType.error);
                              return;
                            }
                            if (pw != confirmCtrl.text) {
                              showCustomSnackBar(dialogContext, message: l10n.newPasswordMismatch, type: SnackBarType.error);
                              return;
                            }
                            setState(() => isLoading = true);
                            try {
                              final dio = getIt<Dio>();
                              await dio.put(
                                '/users/change-password',
                                data: {'current_password': currentCtrl.text, 'new_password': newCtrl.text},
                                options: Options(headers: {'Authorization': 'Bearer $token'}),
                              );
                              if (dialogContext.mounted) {
                                Navigator.pop(dialogContext);
                                showCustomSnackBar(context, message: l10n.settingsPasswordChanged, type: SnackBarType.success);
                              }
                            } on DioException catch (e) {
                              final msg = e.response?.data?['message'] ?? l10n.commonError;
                              if (dialogContext.mounted) showCustomSnackBar(dialogContext, message: msg.toString(), type: SnackBarType.error);
                            } finally {
                              if (dialogContext.mounted) setState(() => isLoading = false);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                          ),
                          child: isLoading
                              ? SizedBox(width: 20.w, height: 20.h, child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.black54))
                              : Text(l10n.settingsSave, style: TextStyle(color: Colors.black87, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).then((_) {
      currentCtrl.dispose();
      newCtrl.dispose();
      confirmCtrl.dispose();
    });
  }

  Widget _passwordField(String label, String hint, TextEditingController ctrl, bool visible, VoidCallback onToggle) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white10),
      ),
      child: TextField(
        controller: ctrl,
        obscureText: !visible,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white54, fontSize: 12.sp),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white30),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          prefixIcon: Icon(Icons.lock_outline, color: Colors.white54, size: 20.sp),
          suffixIcon: IconButton(
            icon: Icon(visible ? Icons.visibility : Icons.visibility_off, color: Colors.white38, size: 20.sp),
            onPressed: onToggle,
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountSheet(BuildContext context, String token) {
    final otherReasonCtrl = TextEditingController();
    String? selectedReason;
    bool isLoading = false;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        final l10n = AppLocalizations.of(sheetContext)!;

        final reasons = [
          l10n.settingsDeleteReasonNoLongerNeed,
          l10n.settingsDeleteReasonPrivacy,
          l10n.settingsDeleteReasonNotifications,
          l10n.settingsDeleteReasonBetterApp,
          l10n.settingsDeleteReasonOther,
        ];

        bool isOther(String? r) => r == l10n.settingsDeleteReasonOther;
        bool otherValid() => otherReasonCtrl.text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length >= 3;
        bool canSubmit() => selectedReason != null && (!isOther(selectedReason) || otherValid());

        return StatefulBuilder(
          builder: (ctx, setState) => Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: Container(
            decoration: BoxDecoration(
              color: AppColors.cardDarker,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 32.h),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40.w, height: 4.h,
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2.r)),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    children: [
                      const Icon(Icons.delete_forever_outlined, color: Colors.redAccent, size: 24),
                      SizedBox(width: 10.w),
                      Text(l10n.settingsDeleteAccountTitle, style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_outlined, color: Colors.redAccent, size: 18),
                        SizedBox(width: 8.w),
                        Expanded(child: Text(l10n.settingsDeleteAccountWarning, style: TextStyle(color: Colors.redAccent, fontSize: 12.sp))),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Text(l10n.settingsDeleteAccountReason, style: TextStyle(color: Colors.white70, fontSize: 14.sp, fontWeight: FontWeight.w600)),
                  SizedBox(height: 12.h),
                  ...reasons.map((reason) {
                    final selected = selectedReason == reason;
                    return InkWell(
                      onTap: () => setState(() => selectedReason = reason),
                      borderRadius: BorderRadius.circular(8.r),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        child: Row(
                          children: [
                            Container(
                              width: 20.w,
                              height: 20.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selected ? AppColors.accent : Colors.white38,
                                  width: 2,
                                ),
                              ),
                              child: selected
                                  ? Center(
                                      child: Container(
                                        width: 10.w,
                                        height: 10.w,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.accent,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(child: Text(reason, style: TextStyle(color: Colors.white, fontSize: 13.sp))),
                          ],
                        ),
                      ),
                    );
                  }),
                  if (isOther(selectedReason)) ...[
                    SizedBox(height: 12.h),
                    TextField(
                      controller: otherReasonCtrl,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 3,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: l10n.settingsDeleteReasonOtherHint,
                        hintStyle: TextStyle(color: Colors.white38, fontSize: 13.sp),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.07),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide(color: Colors.white24),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: const BorderSide(color: AppColors.accent),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                      ),
                    ),
                    if (!otherValid() && otherReasonCtrl.text.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 6.h),
                        child: Text(
                          l10n.settingsDeleteOtherTooShort,
                          style: TextStyle(color: Colors.redAccent, fontSize: 12.sp),
                        ),
                      ),
                  ],
                  SizedBox(height: 24.h),
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: (!canSubmit() || isLoading) ? null : () async {
                        final confirmed = await showDialog<bool>(
                          context: ctx,
                          builder: (dialogContext) => AlertDialog(
                            backgroundColor: AppColors.cardDarker,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                            title: Text(
                              l10n.settingsDeleteConfirmTitle,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            content: Text(
                              l10n.settingsDeleteConfirmMessage,
                              style: const TextStyle(color: Colors.white70),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialogContext, false),
                                child: Text(l10n.settingsDeleteConfirmNo, style: const TextStyle(color: Colors.white54)),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(dialogContext, true),
                                child: Text(l10n.settingsDeleteConfirmYes, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        );
                        if (confirmed != true) return;
                        setState(() => isLoading = true);
                        final reason = isOther(selectedReason) ? otherReasonCtrl.text.trim() : selectedReason!;
                        try {
                          final dio = getIt<Dio>();
                          await dio.delete(
                            '/users/me',
                            data: {'reason': reason},
                            options: Options(headers: {'Authorization': 'Bearer $token'}),
                          );
                          if (sheetContext.mounted) Navigator.pop(sheetContext);
                          if (context.mounted) {
                            showCustomSnackBar(context, message: l10n.settingsDeleteSuccess, type: SnackBarType.success);
                            context.read<AuthBloc>().add(AuthLogoutRequested());
                          }
                        } on DioException catch (e) {
                          final msg = e.response?.data?['message'] ?? l10n.commonError;
                          if (sheetContext.mounted) showCustomSnackBar(sheetContext, message: msg.toString(), type: SnackBarType.error);
                        } finally {
                          if (sheetContext.mounted) setState(() => isLoading = false);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: !canSubmit() ? Colors.grey.withValues(alpha: 0.3) : Colors.redAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? SizedBox(width: 20.w, height: 20.h, child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(l10n.settingsDeleteConfirmButton, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ),
        );
      },
    ).then((_) => otherReasonCtrl.dispose());
  }

  void _showTargetBottomSheet(
    BuildContext context,
    SettingsState initialState,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardDarker,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            final l10n = AppLocalizations.of(context)!;
            final isAyahMode = state.targetUnit == 'ayah';
            final currentTarget = isAyahMode
                ? state.dailyAyahTarget
                : state.dailyTarget;

            return SizedBox(
              height: 600.h,
              child: Column(
                children: [
                  Center(
                    child: Container(
                      margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.targetSelectTitle,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20.h),

                          // MODE SELECTOR
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            padding: EdgeInsets.all(4.w),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildModeButton(
                                    context,
                                    l10n.lblPages ?? 'Pages',
                                    'page',
                                    !isAyahMode,
                                  ),
                                ),
                                Expanded(
                                  child: _buildModeButton(
                                    context,
                                    l10n.lblAyah ?? 'Ayahs',
                                    'ayah',
                                    isAyahMode,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16.h),

                          // EXPLANATION
                          Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0D47A1).withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: Colors.blueAccent.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.blueAccent,
                                  size: 20.sp,
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Text(
                                    isAyahMode
                                        ? (l10n.targetAyahExplanation ??
                                              "Ayah target tracked in List Mode")
                                        : (l10n.targetPageExplanation ??
                                              "Page target tracked in Mushaf Tab"),
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontSize: 13.sp,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 24.h),

                          Text(
                            l10n.targetChooseTarget,
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                            ),
                          ),
                          SizedBox(height: 12.h),

                          if (isAyahMode) ...[
                            _buildTargetOption(
                              context,
                              10,
                              "10 ${l10n.lblAyah}",
                              currentTarget,
                              true,
                            ),
                            _buildTargetOption(
                              context,
                              20,
                              "20 ${l10n.lblAyah}",
                              currentTarget,
                              true,
                            ),
                            _buildTargetOption(
                              context,
                              50,
                              "50 ${l10n.lblAyah}",
                              currentTarget,
                              true,
                            ),
                            _buildTargetOption(
                              context,
                              100,
                              "100 ${l10n.lblAyah}",
                              currentTarget,
                              true,
                            ),
                          ] else ...[
                            _buildTargetOption(
                              context,
                              2,
                              l10n.targetBeginner,
                              currentTarget,
                              false,
                            ),
                            _buildTargetOption(
                              context,
                              4,
                              l10n.targetRoutine,
                              currentTarget,
                              false,
                            ),
                            _buildTargetOption(
                              context,
                              10,
                              l10n.targetHalfJuz,
                              currentTarget,
                              false,
                            ),
                            _buildTargetOption(
                              context,
                              20,
                              l10n.targetOneJuz,
                              currentTarget,
                              false,
                            ),
                          ],

                          SizedBox(height: 8.h),
                          Container(
                            margin: EdgeInsets.only(top: 8.h),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white24),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: ListTile(
                              leading: const Icon(
                                Icons.edit,
                                color: Colors.white70,
                              ),
                              title: Text(
                                l10n.targetCustom,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              trailing: const Icon(
                                Icons.chevron_right,
                                color: Colors.white54,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                _showCustomTargetDialog(
                                  context,
                                  currentTarget,
                                  isAyahMode,
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 32.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _getAdjustmentText(int adjustment, AppLocalizations l10n) {
    if (adjustment == 0) return "0 ${l10n.days ?? 'Days'}";
    final sign = adjustment > 0 ? "+" : "";
    return "$sign$adjustment ${l10n.days ?? 'Days'}";
  }

  void _showCalculationMethodBottomSheet(
    BuildContext context,
    SettingsState state,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardDarker,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (sheetContext) {
        final l10n = AppLocalizations.of(sheetContext)!;
        final options = <String, String>{
          'singapore': l10n.prayerCalculationMethodSingapore,
          'kemenag_ri': l10n.prayerCalculationMethodKemenagRI,
        };

        return Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.prayerCalculationMethod,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.h),
              ...options.entries.map((entry) {
                final selected = state.calculationMethod == entry.key;
                return RadioListTile<String>(
                  value: entry.key,
                  groupValue: state.calculationMethod,
                  activeColor: AppColors.accent,
                  title: Text(
                    entry.value,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: selected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  onChanged: (value) {
                    if (value == null) return;
                    context.read<SettingsCubit>().updateCalculationMethod(
                      value,
                    );
                    // PrayerBloc is only provided under the /dashboard route
                    // (shared with the Jadwal tab); Settings can also be
                    // reached via the standalone /settings route, where it
                    // isn't available, so this refetch is best-effort.
                    try {
                      final prayerBloc = context.read<PrayerBloc>();
                      prayerBloc.add(
                        FetchPrayerTime(
                          latitude: prayerBloc.state.currentCity.latitude,
                          longitude: prayerBloc.state.currentCity.longitude,
                          date: DateTime.now(),
                        ),
                      );
                    } catch (_) {}
                    Navigator.pop(sheetContext);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showHijriAdjustmentBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardDarker,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        // Helper to get month name
        String getMonthName(int i) {
          return _getHijriMonthName(context, i);
        }

        return Container(
          height: 600.h,
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
          child: Column(
            children: [
              Text(
                l10n.hijriAdjustment ?? 'Hijri Adjustment',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                l10n.hijriAdjustmentSubtitle ??
                    'Adjust date per month if sighting varies',
                style: TextStyle(color: Colors.white54, fontSize: 14.sp),
              ),
              SizedBox(height: 24.h),
              Expanded(
                child: BlocBuilder<SettingsCubit, SettingsState>(
                  builder: (context, state) {
                    return ListView.separated(
                      itemCount: 12,
                      separatorBuilder: (c, i) =>
                          Divider(color: Colors.white.withValues(alpha: 0.05)),
                      itemBuilder: (context, index) {
                        final monthIndex = index + 1;
                        final monthName = getMonthName(monthIndex);

                        final adjMap = state.hijriAdjustments.firstWhere(
                          (e) => e['hijri_month'] == monthIndex,
                          orElse: () => {'adjustment': 0},
                        );
                        final currentVal = adjMap['adjustment'] as int? ?? 0;

                        return ListTile(
                          title: Text(
                            monthName,
                            style: const TextStyle(color: Colors.white),
                          ),
                          trailing: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: currentVal != 0
                                  ? AppColors.accent.withValues(alpha: 0.2)
                                  : Colors.white10,
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                color: currentVal != 0
                                    ? AppColors.accent
                                    : Colors.transparent,
                              ),
                            ),
                            child: Text(
                              _getAdjustmentText(currentVal, l10n),
                              style: TextStyle(
                                color: currentVal != 0
                                    ? AppColors.accent
                                    : Colors.white70,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          onTap: () => _showAdjustmentSelector(
                            context,
                            monthIndex,
                            currentVal,
                            monthName,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getHijriMonthName(BuildContext context, int month) {
    final locale = Localizations.localeOf(context).languageCode;
    if (locale == 'id') {
      const months = [
        "Muharram",
        "Safar",
        "Rabiul Awal",
        "Rabiul Akhir",
        "Jumadil Awal",
        "Jumadil Akhir",
        "Rajab",
        "Sya'ban",
        "Ramadhan",
        "Syawal",
        "Dzulqa'idah",
        "Dzulhijjah",
      ];
      if (month >= 1 && month <= 12) return months[month - 1];
    } else {
      const months = [
        "Muharram",
        "Safar",
        "Rabi' al-awwal",
        "Rabi' al-thani",
        "Jumada al-awwal",
        "Jumada al-thani",
        "Rajab",
        "Sha'ban",
        "Ramadan",
        "Shawwal",
        "Dhu al-Qi'dah",
        "Dhu al-Hijjah",
      ];
      if (month >= 1 && month <= 12) return months[month - 1];
    }
    return "Month $month";
  }

  void _showAdjustmentSelector(
    BuildContext context,
    int monthIndex,
    int currentAdjustment,
    String monthName,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardDarker,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.settingsMonthAdjustment(monthName),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (int i = -2; i <= 2; i++)
                    _buildAdjustmentOption(
                      context,
                      monthIndex,
                      i,
                      currentAdjustment,
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAdjustmentOption(
    BuildContext context,
    int monthIndex,
    int value,
    int groupValue,
  ) {
    final isSelected = value == groupValue;
    return GestureDetector(
      onTap: () {
        context.read<SettingsCubit>().updateHijriAdjustment(monthIndex, value);
        Navigator.pop(context);
      },
      child: Container(
        width: 50.w,
        height: 50.w,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : Colors.white10,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          value > 0 ? "+$value" : "$value",
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildModeButton(
    BuildContext context,
    String label,
    String value,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () {
        context.read<SettingsCubit>().updateTargetUnit(value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black87 : Colors.white54,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }

  void _showCustomTargetDialog(
    BuildContext context,
    int currentTarget,
    bool isAyahMode,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final TextEditingController controller = TextEditingController(
      text: currentTarget.toString(),
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.cardDarker,
          title: Text(
            l10n.targetCustomTitle,
            style: const TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: l10n.targetCustomHint,
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white54),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.accent),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                final value = int.tryParse(controller.text);
                if (value != null && value > 0) {
                  if (isAyahMode) {
                    context.read<SettingsCubit>().updateDailyAyahTarget(value);
                  } else {
                    context.read<SettingsCubit>().updateDailyTarget(value);
                  }
                  Navigator.pop(context);
                }
              },
              child: Text(
                l10n.settingsSave,
                style: const TextStyle(color: AppColors.accent),
              ),
            ),
          ],
        );
      },
    ).then((_) => controller.dispose());
  }

  Widget _buildTargetOption(
    BuildContext context,
    int value,
    String label,
    int currentValue,
    bool isAyahMode,
  ) {
    final isSelected = value == currentValue;
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.accent.withValues(alpha: 0.1)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: isSelected
            ? Border.all(color: AppColors.accent)
            : Border.all(color: Colors.transparent),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        leading: Icon(
          isSelected ? Icons.check_circle : Icons.circle_outlined,
          color: isSelected ? AppColors.accent : Colors.white54,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () {
          if (isAyahMode) {
            context.read<SettingsCubit>().updateDailyAyahTarget(value);
          } else {
            context.read<SettingsCubit>().updateDailyTarget(value);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGradientStart,
      appBar: AppTransparentAppBar(
        title: AppLocalizations.of(context)!.settingsTitle,
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          final l10n = AppLocalizations.of(context)!;
          return ListView(
            padding: EdgeInsets.all(16.w),
            children: [
              _buildSectionHeader(context, l10n.settingsProfile),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, authState) {
                  if (authState is AuthAuthenticated) {
                    return _buildListTile(
                      icon: Icons.person_outline,
                      title: l10n.settingsName,
                      subtitle: authState.user.name,
                      onTap: () => _showEditUsernameSheet(context, authState.user.id, authState.user.name, authState.user.token ?? ''),
                    );
                  }
                  return _buildListTile(
                    icon: Icons.person_outline,
                    title: l10n.settingsName,
                    subtitle: state.userName.isEmpty ? 'Friend' : state.userName,
                    onTap: () => _showNameDialog(context, state.userName),
                  );
                },
              ),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, authState) {
                  if (authState is! AuthAuthenticated) return const SizedBox.shrink();
                  final email = authState.user.email;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 8.h),
                      Material(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12.r),
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          leading: const Icon(
                            Icons.email_outlined,
                            color: AppColors.accent,
                          ),
                          title: Text(
                            l10n.settingsEmail,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            email,
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12.sp,
                            ),
                          ),
                          trailing: Icon(
                            Icons.copy,
                            color: Colors.white24,
                            size: 18.sp,
                          ),
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: email));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.settingsEmailCopied),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, authState) {
                  if (authState is! AuthAuthenticated) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 24.h),
                      _buildSectionHeader(context, l10n.settingsSecurity),
                      Material(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12.r),
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          leading: const Icon(Icons.lock_outline, color: AppColors.accent),
                          title: Text(
                            l10n.settingsChangePassword,
                            style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w600),
                          ),
                          trailing: Icon(Icons.chevron_right, color: Colors.white24, size: 20.sp),
                          onTap: () => _showChangePasswordSheet(context, authState.user.token ?? ''),
                        ),
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: 24.h),
              _buildSectionHeader(context, l10n.settingsLanguage),
              _buildListTile(
                icon: Icons.language,
                title: l10n.settingsLanguage,
                subtitle: state.locale?.languageCode == 'id'
                    ? l10n.settingsLanguageIndonesian
                    : l10n.settingsLanguageEnglish,
                onTap: () => _showLanguageBottomSheet(context),
              ),
              SizedBox(height: 12.h),
              _buildSectionHeader(
                context,
                l10n.settingsIbadah ?? 'Ibadah',
              ), // Use fallback if key not generated yet
              _buildListTile(
                icon: Icons.calendar_today,
                title: l10n.hijriAdjustment ?? 'Hijri Adjustment',
                subtitle: l10n.hijriAdjustmentSubtitle,
                onTap: () => _showHijriAdjustmentBottomSheet(context),
              ),
              SizedBox(height: 12.h),
              _buildListTile(
                icon: Icons.access_time,
                title: l10n.prayerCalculationMethod,
                subtitle: state.calculationMethod == 'kemenag_ri'
                    ? l10n.prayerCalculationMethodKemenagRI
                    : l10n.prayerCalculationMethodSingapore,
                onTap: () => _showCalculationMethodBottomSheet(context, state),
              ),
              SizedBox(height: 24.h),
              _buildSectionHeader(context, l10n.settingsQuran),
              _buildListTile(
                icon: Icons.menu_book,
                title: l10n.settingsDailyTarget,
                subtitle: state.targetUnit == 'ayah'
                    ? "${state.dailyAyahTarget} ${l10n.lblAyah}"
                    : l10n.settingsTargetPages(state.dailyTarget),
                onTap: () => _showTargetBottomSheet(context, state),
              ),
              SizedBox(height: 12.h),
              _buildListTile(
                icon: Icons.help_outline,
                title: l10n.guideTitle,
                subtitle: l10n.guideSubtitle,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HelpGuidePage(),
                    ),
                  );
                },
              ),
              SizedBox(height: 24.h),
              BlocConsumer<AuthBloc, AuthState>(
                listener: (context, authState) {
                  if (authState is AuthLoggedOut) {
                    context.go('/login');
                  }
                },
                builder: (context, authState) {
                  if (authState is AuthAuthenticated) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildSectionHeader(context, l10n.settingsAccount),
                        SizedBox(
                          height: 50.h,
                          child: ElevatedButton.icon(
                            onPressed: () => showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: AppColors.cardDarker,
                                title: Text(
                                  l10n.settingsLogout,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                content: Text(
                                  l10n.settingsLogoutConfirm,
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: Text(
                                      l10n.cancel,
                                      style: const TextStyle(color: Colors.white54),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      context.read<AuthBloc>().add(AuthLogoutRequested());
                                    },
                                    child: Text(
                                      l10n.settingsLogout,
                                      style: const TextStyle(color: Colors.redAccent),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            icon: const Icon(Icons.logout, color: Colors.white),
                            label: Text(
                              l10n.settingsLogout,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent.withValues(alpha: 0.8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Center(
                          child: TextButton(
                            onPressed: () => _showDeleteAccountSheet(context, authState.user.token ?? ''),
                            child: Text(
                              l10n.settingsDeleteAccount,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.redAccent.withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                      ],
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSectionHeader(context, l10n.settingsAccount),
                      _buildListTile(
                        icon: Icons.login,
                        title: l10n.settingsLogin,
                        subtitle: l10n.settingsLoginSubtitle,
                        onTap: () => context.go('/login'),
                        iconColor: AppColors.accent,
                      ),
                      SizedBox(height: 8.h),
                      _buildListTile(
                        icon: Icons.person_add_outlined,
                        title: l10n.settingsCreateAccount,
                        subtitle: l10n.settingsCreateAccountSubtitle,
                        onTap: () => context.go('/register'),
                        iconColor: AppColors.accent,
                      ),
                      SizedBox(height: 16.h),
                    ],
                  );
                },
              ),
              SizedBox(height: 24.h),
              _buildSectionHeader(context, l10n.aboutTitle),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.aboutSummary,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14.sp,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    InkWell(
                      onTap: () async {
                        final Uri emailLaunchUri = Uri(
                          scheme: 'mailto',
                          path: 'imam.risnandar@gmail.com',
                          query: 'subject=Muslimly App Feedback',
                        );
                        if (!await launchUrl(emailLaunchUri)) {
                          // no email app available
                        }
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.mail_outline,
                            color: AppColors.accent,
                            size: 20.sp,
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            l10n.contactTitle,
                            style: TextStyle(
                              color: AppColors.accent,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (!kReleaseMode) ...[
                SizedBox(height: 24.h),
                _buildSectionHeader(context, "Developer Mode"),
                _buildListTile(
                  icon: Icons.restore_page_outlined,
                  title: "Reset Tutorials",
                  subtitle: "Clear showcase history for testing",
                  iconColor: Colors.orangeAccent,
                  onTap: () async {
                    await getIt<ShowcasePreferencesService>().clearAll();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "All tutorials reset! Restart app or revisit pages.",
                          ),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  },
                ),
                SizedBox(height: 8.h),
                _buildListTile(
                  icon: Icons.bug_report_outlined,
                  title: "Test Crashlytics",
                  subtitle: "Force crash to verify Firebase reporting",
                  iconColor: Colors.redAccent,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: AppColors.cardDark,
                        title: const Text(
                          'Test Crashlytics',
                          style: TextStyle(color: Colors.white),
                        ),
                        content: const Text(
                          'App akan crash sekarang. Buka ulang app, lalu cek Firebase Console dalam 1-2 menit.',
                          style: TextStyle(color: Colors.white70),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Batal', style: TextStyle(color: Colors.white54)),
                          ),
                          TextButton(
                            onPressed: () => FirebaseCrashlytics.instance.crash(),
                            child: const Text('Crash Sekarang', style: TextStyle(color: Colors.redAccent)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
              FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Center(
                      child: Text(
                        "v${snapshot.data!.version} (${snapshot.data!.buildNumber})",
                        style: TextStyle(
                          color: Colors.white24,
                          fontSize: 12.sp,
                          fontFamily: 'Outfit',
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              SizedBox(height: 100.h),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h, left: 4.w),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.accent,
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return Material(
      color: Colors.white.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(12.r),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        leading: Icon(icon, color: iconColor ?? AppColors.accent),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.white54, fontSize: 12.sp),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white54),
        onTap: onTap,
      ),
    );
  }
}

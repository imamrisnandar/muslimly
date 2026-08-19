import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/generated/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../bloc/settings_cubit.dart';
import '../bloc/settings_state.dart';
import 'package:dio/dio.dart';
import '../../../../core/di/di_container.dart';
import '../../../../core/utils/custom_snackbar.dart';
import '../../../../core/utils/password_validator.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../core/theme/app_colors.dart';

void showLanguageBottomSheet(BuildContext context) {
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
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
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

void showNameDialog(BuildContext context, String currentName) {
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

void showEditUsernameSheet(
  BuildContext context,
  String userId,
  String currentUsername,
  String token,
) {
  final controller = TextEditingController(text: currentUsername);
  showDialog(
    context: context,
    builder: (dialogContext) {
      final l10n = AppLocalizations.of(dialogContext)!;
      bool isLoading = false;
      return StatefulBuilder(
        builder: (ctx, setState) => Dialog(
          backgroundColor: AppColors.cardDarker,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.settingsEditUsername,
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
                      hintText: l10n.settingsUsernameHint,
                      hintStyle: TextStyle(color: Colors.white30),
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
                        onPressed: () => Navigator.pop(dialogContext),
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
                        onPressed: isLoading
                            ? null
                            : () async {
                                final newUsername = controller.text.trim();
                                if (newUsername.isEmpty ||
                                    newUsername == currentUsername)
                                  return;
                                setState(() => isLoading = true);
                                try {
                                  final dio = getIt<Dio>();
                                  await dio.put(
                                    '/users/update',
                                    data: {
                                      'id': userId,
                                      'username': newUsername,
                                    },
                                    options: Options(
                                      headers: {
                                        'Authorization': 'Bearer $token',
                                      },
                                    ),
                                  );
                                  if (dialogContext.mounted) {
                                    Navigator.pop(dialogContext);
                                    showCustomSnackBar(
                                      context,
                                      message: l10n.settingsUsernameUpdated,
                                      type: SnackBarType.success,
                                    );
                                  }
                                } on DioException catch (e) {
                                  final msg =
                                      e.response?.data?['message'] ??
                                      l10n.commonError;
                                  if (dialogContext.mounted)
                                    showCustomSnackBar(
                                      dialogContext,
                                      message: msg.toString(),
                                      type: SnackBarType.error,
                                    );
                                } finally {
                                  if (dialogContext.mounted)
                                    setState(() => isLoading = false);
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
                        child: isLoading
                            ? SizedBox(
                                width: 20.w,
                                height: 20.h,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black54,
                                ),
                              )
                            : Text(
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

void showChangePasswordSheet(BuildContext context, String token) {
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.settingsChangePassword,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 24.h),
                _passwordField(
                  l10n.settingsCurrentPassword,
                  l10n.settingsCurrentPasswordHint,
                  currentCtrl,
                  showCurrent,
                  () => setState(() => showCurrent = !showCurrent),
                ),
                SizedBox(height: 16.h),
                _passwordField(
                  l10n.newPasswordLabel,
                  l10n.newPasswordHint,
                  newCtrl,
                  showNew,
                  () => setState(() => showNew = !showNew),
                ),
                SizedBox(height: 4.h),
                Padding(
                  padding: EdgeInsets.only(left: 4.w),
                  child: Text(
                    l10n.passwordComplexityHint,
                    style: TextStyle(color: Colors.white38, fontSize: 11.sp),
                  ),
                ),
                SizedBox(height: 12.h),
                _passwordField(
                  l10n.newPasswordConfirmLabel,
                  l10n.newPasswordConfirmHint,
                  confirmCtrl,
                  showConfirm,
                  () => setState(() => showConfirm = !showConfirm),
                ),
                SizedBox(height: 32.h),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
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
                        onPressed: isLoading
                            ? null
                            : () async {
                                final pw = newCtrl.text;
                                if (!isPasswordStrong(pw)) {
                                  showCustomSnackBar(
                                    dialogContext,
                                    message: l10n.passwordTooWeak,
                                    type: SnackBarType.error,
                                  );
                                  return;
                                }
                                if (pw != confirmCtrl.text) {
                                  showCustomSnackBar(
                                    dialogContext,
                                    message: l10n.newPasswordMismatch,
                                    type: SnackBarType.error,
                                  );
                                  return;
                                }
                                setState(() => isLoading = true);
                                try {
                                  final dio = getIt<Dio>();
                                  await dio.put(
                                    '/users/change-password',
                                    data: {
                                      'current_password': currentCtrl.text,
                                      'new_password': newCtrl.text,
                                    },
                                    options: Options(
                                      headers: {
                                        'Authorization': 'Bearer $token',
                                      },
                                    ),
                                  );
                                  if (dialogContext.mounted) {
                                    Navigator.pop(dialogContext);
                                    showCustomSnackBar(
                                      context,
                                      message: l10n.settingsPasswordChanged,
                                      type: SnackBarType.success,
                                    );
                                  }
                                } on DioException catch (e) {
                                  final msg =
                                      e.response?.data?['message'] ??
                                      l10n.commonError;
                                  if (dialogContext.mounted)
                                    showCustomSnackBar(
                                      dialogContext,
                                      message: msg.toString(),
                                      type: SnackBarType.error,
                                    );
                                } finally {
                                  if (dialogContext.mounted)
                                    setState(() => isLoading = false);
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
                        child: isLoading
                            ? SizedBox(
                                width: 20.w,
                                height: 20.h,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black54,
                                ),
                              )
                            : Text(
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
  ).then((_) {
    currentCtrl.dispose();
    newCtrl.dispose();
    confirmCtrl.dispose();
  });
}

Widget _passwordField(
  String label,
  String hint,
  TextEditingController ctrl,
  bool visible,
  VoidCallback onToggle,
) {
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
        prefixIcon: Icon(
          Icons.lock_outline,
          color: Colors.white54,
          size: 20.sp,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            visible ? Icons.visibility : Icons.visibility_off,
            color: Colors.white38,
            size: 20.sp,
          ),
          onPressed: onToggle,
        ),
      ),
    ),
  );
}

void showDeleteAccountSheet(BuildContext context, String token) {
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
      bool otherValid() =>
          otherReasonCtrl.text
              .trim()
              .split(RegExp(r'\s+'))
              .where((w) => w.isNotEmpty)
              .length >=
          3;
      bool canSubmit() =>
          selectedReason != null && (!isOther(selectedReason) || otherValid());

      return StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
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
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    children: [
                      const Icon(
                        Icons.delete_forever_outlined,
                        color: Colors.redAccent,
                        size: 24,
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        l10n.settingsDeleteAccountTitle,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: Colors.redAccent.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_outlined,
                          color: Colors.redAccent,
                          size: 18,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            l10n.settingsDeleteAccountWarning,
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    l10n.settingsDeleteAccountReason,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
                                  color: selected
                                      ? AppColors.accent
                                      : Colors.white38,
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
                            Expanded(
                              child: Text(
                                reason,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.sp,
                                ),
                              ),
                            ),
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
                        hintStyle: TextStyle(
                          color: Colors.white38,
                          fontSize: 13.sp,
                        ),
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
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 12.h,
                        ),
                      ),
                    ),
                    if (!otherValid() && otherReasonCtrl.text.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 6.h),
                        child: Text(
                          l10n.settingsDeleteOtherTooShort,
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                  ],
                  SizedBox(height: 24.h),
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: (!canSubmit() || isLoading)
                          ? null
                          : () async {
                              final confirmed = await showDialog<bool>(
                                context: ctx,
                                builder: (dialogContext) => AlertDialog(
                                  backgroundColor: AppColors.cardDarker,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                  title: Text(
                                    l10n.settingsDeleteConfirmTitle,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  content: Text(
                                    l10n.settingsDeleteConfirmMessage,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(dialogContext, false),
                                      child: Text(
                                        l10n.settingsDeleteConfirmNo,
                                        style: const TextStyle(
                                          color: Colors.white54,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(dialogContext, true),
                                      child: Text(
                                        l10n.settingsDeleteConfirmYes,
                                        style: const TextStyle(
                                          color: Colors.redAccent,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                              if (confirmed != true) return;
                              setState(() => isLoading = true);
                              final reason = isOther(selectedReason)
                                  ? otherReasonCtrl.text.trim()
                                  : selectedReason!;
                              try {
                                final dio = getIt<Dio>();
                                await dio.delete(
                                  '/users/me',
                                  data: {'reason': reason},
                                  options: Options(
                                    headers: {'Authorization': 'Bearer $token'},
                                  ),
                                );
                                if (sheetContext.mounted)
                                  Navigator.pop(sheetContext);
                                if (context.mounted) {
                                  showCustomSnackBar(
                                    context,
                                    message: l10n.settingsDeleteSuccess,
                                    type: SnackBarType.success,
                                  );
                                  context.read<AuthBloc>().add(
                                    AuthLogoutRequested(),
                                  );
                                }
                              } on DioException catch (e) {
                                final msg =
                                    e.response?.data?['message'] ??
                                    l10n.commonError;
                                if (sheetContext.mounted)
                                  showCustomSnackBar(
                                    sheetContext,
                                    message: msg.toString(),
                                    type: SnackBarType.error,
                                  );
                              } finally {
                                if (sheetContext.mounted)
                                  setState(() => isLoading = false);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: !canSubmit()
                            ? Colors.grey.withValues(alpha: 0.3)
                            : Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? SizedBox(
                              width: 20.w,
                              height: 20.h,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              l10n.settingsDeleteConfirmButton,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
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

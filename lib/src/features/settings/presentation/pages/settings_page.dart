import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/generated/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:url_launcher/url_launcher.dart';
import '../bloc/settings_cubit.dart';
import '../bloc/settings_state.dart';
import '../../../../core/di/di_container.dart';
import '../../../../core/utils/custom_snackbar.dart'; // Import Custom SnackBar
import '../../../../core/services/background_service.dart'; // Correct import
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _showLanguageBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            final l10n = AppLocalizations.of(context)!;
            final isIndo = state.locale.languageCode == 'id';

            return Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 24.h),
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  Text(
                    l10n.settingsLanguage,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  _buildLanguageOption(
                    context,
                    l10n.settingsLanguageEnglish,
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
                    l10n.settingsLanguageIndonesian,
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
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String label,
    String flag,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF00E676).withOpacity(0.1)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? const Color(0xFF00E676) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: TextStyle(fontSize: 24.sp)),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF00E676)),
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
          backgroundColor: const Color(0xFF1E1E1E),
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
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: TextField(
                    controller: controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: l10n.nameInputHint,
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.3),
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
                          backgroundColor: const Color(0xFF00E676),
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
        );
      },
    );
  }

  void _showTargetBottomSheet(
    BuildContext context,
    SettingsState initialState,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
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
                              color: const Color(0xFF0D47A1).withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: Colors.blueAccent.withOpacity(0.3),
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
                                      color: Colors.white.withOpacity(0.9),
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
                            "Choose Target",
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
          color: isSelected ? const Color(0xFF00E676) : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF00E676).withOpacity(0.3),
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
          backgroundColor: const Color(0xFF1E1E1E),
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
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white54),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF00E676)),
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
                style: const TextStyle(color: Color(0xFF00E676)),
              ),
            ),
          ],
        );
      },
    );
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
            ? const Color(0xFF00E676).withOpacity(0.1)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: isSelected
            ? Border.all(color: const Color(0xFF00E676))
            : Border.all(color: Colors.transparent),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        leading: Icon(
          isSelected ? Icons.check_circle : Icons.circle_outlined,
          color: isSelected ? const Color(0xFF00E676) : Colors.white54,
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
      backgroundColor: const Color(0xFF0F2027),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)!.settingsTitle,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          final l10n = AppLocalizations.of(context)!;
          return ListView(
            padding: EdgeInsets.all(16.w),
            children: [
              _buildSectionHeader(context, l10n.settingsProfile),
              _buildListTile(
                icon: Icons.person_outline,
                title: l10n.settingsName,
                subtitle: state.userName ?? 'Friend',
                onTap: () => _showNameDialog(context, state.userName ?? ''),
              ),
              SizedBox(height: 24.h),
              _buildSectionHeader(context, l10n.settingsLanguage),
              _buildListTile(
                icon: Icons.language,
                title: l10n.settingsLanguage,
                subtitle: state.locale.languageCode == 'id'
                    ? l10n.settingsLanguageIndonesian
                    : l10n.settingsLanguageEnglish,
                onTap: () => _showLanguageBottomSheet(context),
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
              SizedBox(height: 24.h),
              _buildSectionHeader(context, l10n.aboutTitle),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
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
                          query:
                              'subject=Muslimly App Feedback', // add subject and body here
                        );
                        if (!await launchUrl(emailLaunchUri)) {
                          // Handle error or just ignore if no email app
                        }
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.mail_outline,
                            color: const Color(0xFF00E676),
                            size: 20.sp,
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            l10n.contactTitle,
                            style: TextStyle(
                              color: const Color(0xFF00E676),
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
              SizedBox(height: 24.h),
              _buildSectionHeader(
                context,
                l10n.settingsDeveloper,
              ), // "Developer Options"
              _buildListTile(
                icon: Icons.sync,
                title: l10n.settingsTestBackground,
                subtitle: l10n.settingsTestBackgroundSubtitle,
                onTap: () {
                  // Trigger Background Sync
                  getIt<BackgroundService>().triggerImmediateSync();
                  showCustomSnackBar(
                    context,
                    message: 'Background Sync Triggered!',
                    type: SnackBarType.success,
                  );
                },
              ),
              SizedBox(height: 12.h),
              _buildListTile(
                icon: Icons.restore,
                title: l10n.settingsResetShowcase, // "Reset Showcase"
                subtitle: l10n.settingsResetShowcaseSubtitle,
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('hasShownQuranListShowcase');
                  await prefs.remove('hasShownSurahDetailShowcase');
                  await prefs.remove('hasShownDashboardShowcase');
                  await prefs.remove('hasShownMushafShowcase');
                  if (context.mounted) {
                    showCustomSnackBar(
                      context,
                      message:
                          'Showcase flags reset! Restart feature to see tutorials.',
                      type: SnackBarType.success,
                    );
                  }
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
          color: const Color(0xFF00E676),
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
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.white70, fontSize: 14.sp),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.white54, size: 20.sp),
        onTap: onTap,
      ),
    );
  }
}

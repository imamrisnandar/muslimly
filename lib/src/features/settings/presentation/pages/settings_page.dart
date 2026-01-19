import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/generated/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../bloc/settings_cubit.dart';
import '../bloc/settings_state.dart';

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
        return Wrap(
          children: [
            ListTile(
              leading: const Text("🇺🇸", style: TextStyle(fontSize: 24)),
              title: Text(
                AppLocalizations.of(context)!.settingsLanguageEnglish,
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                context.read<SettingsCubit>().updateLanguage(
                  const Locale('en'),
                );
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Text("🇮🇩", style: TextStyle(fontSize: 24)),
              title: Text(
                AppLocalizations.of(context)!.settingsLanguageIndonesian,
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                context.read<SettingsCubit>().updateLanguage(
                  const Locale('id'),
                );
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showNameDialog(BuildContext context, String currentName) {
    // ... existing code ...
    final TextEditingController controller = TextEditingController(
      text: currentName,
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: Text(
            AppLocalizations.of(context)!.settingsName,
            style: const TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.nameInputHint,
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
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                context.read<SettingsCubit>().updateName(controller.text);
                Navigator.pop(context);
              },
              child: Text(
                AppLocalizations.of(context)!.settingsSave,
                style: const TextStyle(color: Color(0xFF00E676)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showTargetBottomSheet(BuildContext context, int currentTarget) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              SizedBox(height: 16.h),
              _buildTargetOption(
                context,
                2,
                l10n.targetBeginner,
                currentTarget,
              ),
              _buildTargetOption(context, 4, l10n.targetRoutine, currentTarget),
              _buildTargetOption(
                context,
                10,
                l10n.targetHalfJuz,
                currentTarget,
              ),
              _buildTargetOption(context, 20, l10n.targetOneJuz, currentTarget),
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.white54),
                title: Text(
                  l10n.targetCustom,
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showCustomTargetDialog(context, currentTarget);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCustomTargetDialog(BuildContext context, int currentTarget) {
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
                  context.read<SettingsCubit>().updateDailyTarget(value);
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
  ) {
    final isSelected = value == currentValue;
    return ListTile(
      leading: Icon(
        isSelected ? Icons.check_circle : Icons.circle_outlined,
        color: isSelected ? const Color(0xFF00E676) : Colors.white54,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? const Color(0xFF00E676) : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        context.read<SettingsCubit>().updateDailyTarget(value);
        Navigator.pop(context);
      },
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
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
                subtitle: l10n.settingsTargetPages(state.dailyTarget),
                onTap: () => _showTargetBottomSheet(context, state.dailyTarget),
              ),
              Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: _buildListTile(
                  icon: Icons.history,
                  title: l10n.settingsReadingHistory,
                  subtitle: l10n.settingsHistorySubtitle,
                  onTap: () => context.push('/quran/history'),
                ),
              ),
              SizedBox(height: 24.h),
              _buildSectionHeader(context, l10n.settingsDeveloper),
              _buildListTile(
                icon: Icons.notifications_active,
                title: l10n.settingsTestAdhan,
                subtitle: l10n.settingsTestAdhanSubtitle,
                onTap: () async {
                  await context.read<SettingsCubit>().testNotification();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.settingsTestAdhanTriggered),
                        backgroundColor: const Color(0xFF00E676),
                      ),
                    );
                  }
                },
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

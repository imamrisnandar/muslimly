import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/generated/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../bloc/settings_cubit.dart';
import '../bloc/settings_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../../../quran/presentation/pages/help_guide_page.dart';
import '../../../../core/di/di_container.dart';
import '../../../../core/services/showcase_preferences_service.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/presentation/widgets/app_transparent_app_bar.dart';
import '../widgets/settings_profile_sheets.dart';
import '../widgets/settings_quran_ibadah_sheets.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
                      onTap: () => showEditUsernameSheet(
                        context,
                        authState.user.id,
                        authState.user.name,
                        authState.user.token ?? '',
                      ),
                    );
                  }
                  return _buildListTile(
                    icon: Icons.person_outline,
                    title: l10n.settingsName,
                    subtitle: state.userName.isEmpty
                        ? 'Friend'
                        : state.userName,
                    onTap: () => showNameDialog(context, state.userName),
                  );
                },
              ),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, authState) {
                  if (authState is! AuthAuthenticated)
                    return const SizedBox.shrink();
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
                  if (authState is! AuthAuthenticated)
                    return const SizedBox.shrink();
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
                          leading: const Icon(
                            Icons.lock_outline,
                            color: AppColors.accent,
                          ),
                          title: Text(
                            l10n.settingsChangePassword,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          trailing: Icon(
                            Icons.chevron_right,
                            color: Colors.white24,
                            size: 20.sp,
                          ),
                          onTap: () => showChangePasswordSheet(
                            context,
                            authState.user.token ?? '',
                          ),
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
                onTap: () => showLanguageBottomSheet(context),
              ),
              SizedBox(height: 12.h),
              _buildSectionHeader(
                context,
                l10n.settingsIbadah,
              ),
              _buildListTile(
                icon: Icons.calendar_today,
                title: l10n.hijriAdjustment,
                subtitle: l10n.hijriAdjustmentSubtitle,
                onTap: () => showHijriAdjustmentBottomSheet(context),
              ),
              SizedBox(height: 12.h),
              _buildListTile(
                icon: Icons.access_time,
                title: l10n.prayerCalculationMethod,
                subtitle: state.calculationMethod == 'kemenag_ri'
                    ? l10n.prayerCalculationMethodKemenagRI
                    : l10n.prayerCalculationMethodSingapore,
                onTap: () => showCalculationMethodBottomSheet(context, state),
              ),
              SizedBox(height: 24.h),
              _buildSectionHeader(context, l10n.settingsQuran),
              _buildListTile(
                icon: Icons.menu_book,
                title: l10n.settingsDailyTarget,
                subtitle: state.targetUnit == 'ayah'
                    ? "${state.dailyAyahTarget} ${l10n.lblAyah}"
                    : l10n.settingsTargetPages(state.dailyTarget),
                onTap: () => showTargetBottomSheet(context, state),
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
                                      style: const TextStyle(
                                        color: Colors.white54,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      context.read<AuthBloc>().add(
                                        AuthLogoutRequested(),
                                      );
                                    },
                                    child: Text(
                                      l10n.settingsLogout,
                                      style: const TextStyle(
                                        color: Colors.redAccent,
                                      ),
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
                              backgroundColor: Colors.redAccent.withValues(
                                alpha: 0.8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Center(
                          child: TextButton(
                            onPressed: () => showDeleteAccountSheet(
                              context,
                              authState.user.token ?? '',
                            ),
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
                            child: const Text(
                              'Batal',
                              style: TextStyle(color: Colors.white54),
                            ),
                          ),
                          TextButton(
                            onPressed: () =>
                                FirebaseCrashlytics.instance.crash(),
                            child: const Text(
                              'Crash Sekarang',
                              style: TextStyle(color: Colors.redAccent),
                            ),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
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

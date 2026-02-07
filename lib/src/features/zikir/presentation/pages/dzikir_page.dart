import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../core/di/di_container.dart';
import '../../../tajweed/presentation/pages/tajweed_page.dart';
import '../../data/repositories/zikir_local_repository.dart';
import 'dzikir_reading_page.dart';
import 'doa_harian_list_page.dart';
import '../../../../features/fasting/presentation/pages/fasting_guide_page.dart';

class DzikirPage extends StatelessWidget {
  const DzikirPage({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    // Detect orientation for responsive layout
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    // Get Localizations
    final l10n = AppLocalizations.of(context)!;

    // 1. Amalan Data (Existing Dzikir & Dua) - Grid Items
    final practiceItems = [
      _IbadahItem(
        title: l10n.dzikirMorningTitle,
        subtitle: l10n.dzikirMorningSubtitle,
        icon: Icons.wb_sunny_outlined,
        color: Colors.orangeAccent,
        onTap: () async {
          final locale = Localizations.localeOf(context);
          final items = await getIt<ZikirLocalRepository>().getMorningZikir(
            locale,
          );
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DzikirReadingPage(
                  title: l10n.dzikirMorningTitle,
                  items: items,
                ),
              ),
            );
          }
        },
      ),
      _IbadahItem(
        title: l10n.dzikirEveningTitle,
        subtitle: l10n.dzikirEveningSubtitle,
        icon: Icons.nightlight_round,
        color: Colors.indigoAccent,
        onTap: () async {
          final locale = Localizations.localeOf(context);
          final items = await getIt<ZikirLocalRepository>().getEveningZikir(
            locale,
          );
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DzikirReadingPage(
                  title: l10n.dzikirEveningTitle,
                  items: items,
                ),
              ),
            );
          }
        },
      ),
      _IbadahItem(
        title: l10n.dzikirPrayerTitle,
        subtitle: l10n.dzikirPrayerSubtitle,
        icon: Icons.mosque_outlined,
        color: const Color(0xFF00E676),
        onTap: () async {
          final locale = Localizations.localeOf(context);
          final items = await getIt<ZikirLocalRepository>().getPrayerZikir(
            locale,
          );
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DzikirReadingPage(
                  title: l10n.dzikirPrayerTitle,
                  items: items,
                ),
              ),
            );
          }
        },
      ),
      _IbadahItem(
        title: l10n.dzikirDailyTitle,
        subtitle: l10n.dzikirDailySubtitle,
        icon: Icons.book_outlined,
        color: Colors.tealAccent,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DoaHarianListPage()),
          );
        },
      ),
    ];

    // 2. Learning Data (Tajweed, etc) - List Items
    final learningItems = [
      _IbadahItem(
        title: l10n.ibadahTajweedTitle,
        subtitle: l10n.ibadahTajweedSubtitle,
        icon: Icons.graphic_eq,
        color: const Color(
          0xFF00E676,
        ), // Green Accent matching TajweedPage Theme
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TajweedPage()),
          );
        },
      ),
      _IbadahItem(
        title: l10n.ibadahFastingTitle,
        subtitle: l10n.fastingGuideSubtitle,
        icon: Icons.volunteer_activism_outlined,
        color: const Color(0xFFFFA000), // Amber/Orange for Fasting
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FastingGuidePage()),
          );
        },
      ),
      _IbadahItem(
        title: l10n.ibadahWudhuTitle,
        subtitle: l10n.comingSoon,
        icon: Icons.water_drop_outlined,
        color: Colors.blueGrey,
        onTap: null, // Disabled
      ),
      _IbadahItem(
        title: l10n.ibadahPrayerTitle,
        subtitle:
            l10n.comingSoon, // Placeholder subtitle until content is ready
        icon: Icons.accessibility_new_rounded, // Best fit for prayer movements
        color: Colors.blueGrey,
        onTap: null, // Disabled
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          l10n.bottomNavDzikir, // "Ibadah"
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- SECTION 1: AMALAN (GRID) ---
              _buildSectionHeader(context, l10n.ibadahPracticesSection),
              SizedBox(height: 12.h),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isLandscape ? 4 : 2,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                  childAspectRatio: isLandscape
                      ? 0.9
                      : 1.1, // Slightly taller for content
                ),
                itemCount: practiceItems.length,
                itemBuilder: (context, index) {
                  return _buildPracticeCard(
                    context,
                    practiceItems[index],
                    isLandscape,
                  );
                },
              ),

              SizedBox(height: 24.h),

              // --- SECTION 2: LEARNING (LIST) ---
              _buildSectionHeader(context, l10n.ibadahLearningSection),
              SizedBox(height: 12.h),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: learningItems.length,
                separatorBuilder: (context, index) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  return _buildLearningCard(context, learningItems[index]);
                },
              ),

              // Bottom padding
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.white,
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildPracticeCard(
    BuildContext context,
    _IbadahItem item,
    bool isLandscape,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, color: item.color, size: 28.sp),
              ),
              SizedBox(height: 12.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Text(
                  item.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (!isLandscape) ...[
                SizedBox(height: 4.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Text(
                    item.subtitle,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white54, fontSize: 11.sp),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLearningCard(BuildContext context, _IbadahItem item) {
    final isDisabled = item.onTap == null;

    // Matches Dzikir Pagi Button Style (Glassmorphism)
    final cardColor = isDisabled
        ? Colors.white.withOpacity(0.02)
        : Colors.white.withOpacity(0.05);

    final borderColor = isDisabled
        ? Colors.white.withOpacity(0.05)
        : Colors.white.withOpacity(0.1);

    final titleColor = isDisabled ? Colors.white38 : Colors.white;
    final subtitleColor = isDisabled ? Colors.white24 : Colors.white54;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: isDisabled
                      ? Colors.grey.withOpacity(0.1)
                      : item.color.withOpacity(0.2), // Increased opacity
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  item.icon,
                  color: isDisabled ? Colors.grey : item.color,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      item.subtitle,
                      style: TextStyle(color: subtitleColor, fontSize: 12.sp),
                    ),
                  ],
                ),
              ),
              if (!isDisabled)
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white30,
                  size: 16.sp,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IbadahItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  _IbadahItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

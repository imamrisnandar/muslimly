import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../core/di/di_container.dart';
import '../../data/repositories/zikir_local_repository.dart';
import 'dzikir_reading_page.dart';
import 'doa_harian_list_page.dart';

class DzikirPage extends StatelessWidget {
  const DzikirPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Detect orientation for responsive layout
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    // Menu Items Data
    final l10n = AppLocalizations.of(context)!;
    final menuItems = [
      _ZikirMenuItem(
        title: l10n.dzikirMorningTitle,
        subtitle: l10n.dzikirMorningSubtitle,
        icon: Icons.wb_sunny_outlined,
        color: Colors.orangeAccent,
        onTap: () {
          final items = getIt<ZikirLocalRepository>().getMorningZikir();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DzikirReadingPage(
                title: l10n.dzikirMorningTitle,
                items: items,
              ),
            ),
          );
        },
      ),
      _ZikirMenuItem(
        title: l10n.dzikirEveningTitle,
        subtitle: l10n.dzikirEveningSubtitle,
        icon: Icons.nightlight_round,
        color: Colors.indigoAccent,
        onTap: () {
          final items = getIt<ZikirLocalRepository>().getEveningZikir();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DzikirReadingPage(
                title: l10n.dzikirEveningTitle,
                items: items,
              ),
            ),
          );
        },
      ),
      _ZikirMenuItem(
        title: l10n.dzikirPrayerTitle,
        subtitle: l10n.dzikirPrayerSubtitle,
        icon: Icons.mosque_outlined,
        color: const Color(0xFF00E676),
        onTap: () {
          final items = getIt<ZikirLocalRepository>().getPrayerZikir();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DzikirReadingPage(
                title: l10n.dzikirPrayerTitle,
                items: items,
              ),
            ),
          );
        },
      ),
      _ZikirMenuItem(
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

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.bottomNavDzikir,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: isLandscape ? 8.h : 16.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.dzikirSelectCategory,
              style: TextStyle(
                color: Colors.white,
                fontSize: isLandscape ? 14.sp : 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isLandscape ? 8.h : 16.h),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isLandscape ? 4 : 2,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                  childAspectRatio: isLandscape ? 0.85 : 1.0,
                ),
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  final item = menuItems[index];
                  return _buildMenuCard(context, item);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, _ZikirMenuItem item) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(isLandscape ? 16.r : 20.r),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(isLandscape ? 16.r : 20.r),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(isLandscape ? 10.w : 16.w),
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.icon,
                  color: item.color,
                  size: isLandscape ? 24.sp : 32.sp,
                ),
              ),
              SizedBox(height: isLandscape ? 5.h : 16.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Text(
                  item.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isLandscape ? 12.sp : 16.sp,
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
                    style: TextStyle(color: Colors.white54, fontSize: 12.sp),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ZikirMenuItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  _ZikirMenuItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

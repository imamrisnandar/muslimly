import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../l10n/generated/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/di_container.dart';
import '../bloc/doa_harian_list_cubit.dart';
import '../bloc/doa_harian_list_state.dart';
import 'dzikir_reading_page.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/presentation/widgets/app_transparent_app_bar.dart';

class DoaHarianListPage extends StatelessWidget {
  const DoaHarianListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Resolved here (a normal build context), not inside BlocProvider's
    // create callback — that callback's context doesn't support listening
    // to inherited widgets like Localizations.
    final locale = Localizations.localeOf(context);
    return BlocProvider(
      create: (context) => getIt<DoaHarianListCubit>()..loadContent(locale),
      child: const _DoaHarianListView(),
    );
  }
}

class _DoaHarianListView extends StatefulWidget {
  const _DoaHarianListView();

  @override
  State<_DoaHarianListView> createState() => _DoaHarianListViewState();
}

class _DoaHarianListViewState extends State<_DoaHarianListView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      context.read<DoaHarianListCubit>().search(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: AppColors.cardDark, // Dark Theme Background
      appBar: AppTransparentAppBar(title: l10n.dzikirDailyTitle),
      body: BlocBuilder<DoaHarianListCubit, DoaHarianListState>(
        builder: (context, state) {
          final allItems = state.allItems;
          final filteredItems = state.filteredItems;

          return Column(
            children: [
              // Search Field
              Padding(
                padding: EdgeInsets.fromLTRB(
                  16.w,
                  isLandscape ? 4.h : 8.h,
                  16.w,
                  isLandscape ? 8.h : 16.h,
                ),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isLandscape ? 12.sp : 14.sp,
                  ),
                  decoration: InputDecoration(
                    hintText: l10n.searchDoa,
                    hintStyle: TextStyle(
                      color: Colors.white54,
                      fontSize: isLandscape ? 12.sp : 14.sp,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.white54,
                      size: isLandscape ? 18.sp : 20.sp,
                    ),
                    filled: true,
                    fillColor: Colors.black.withValues(alpha: 0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: isLandscape ? 8.h : 12.h,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(
                        color: AppColors.accent,
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),

              // List Items
              Expanded(
                child: filteredItems.isEmpty
                    ? Center(
                        child: Text(
                          l10n.msgNoDoaFound,
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: isLandscape ? 12.sp : 14.sp,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: isLandscape ? 4.h : 8.h,
                        ),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];

                          // Find original index to pass correct initialIndex to Reader
                          final originalIndex = allItems.indexOf(item);

                          return Container(
                            margin: EdgeInsets.only(
                              bottom: isLandscape ? 8.h : 12.h,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withValues(alpha: 0.05),
                                  Colors.white.withValues(alpha: 0.02),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.05),
                                width: 1,
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16.r),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DzikirReadingPage(
                                        title: l10n.dzikirDailyTitle,
                                        items: allItems,
                                        initialIndex: originalIndex,
                                        enableCounter: false,
                                      ),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 16.h,
                                  ),
                                  child: Row(
                                    children: [
                                      // Decorative Number Badge
                                      Container(
                                        width: 40.w,
                                        height: 40.w,
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFF00E676,
                                          ).withValues(alpha: 0.1),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: const Color(
                                              0xFF00E676,
                                            ).withValues(alpha: 0.3),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "${originalIndex + 1}",
                                            style: TextStyle(
                                              color: AppColors.accent,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14.sp,
                                              fontFamily: GoogleFonts.outfit()
                                                  .fontFamily,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 16.w),

                                      // Title
                                      Expanded(
                                        child: Text(
                                          item.title,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w600,
                                            fontFamily:
                                                GoogleFonts.outfit().fontFamily,
                                          ),
                                        ),
                                      ),

                                      // Action Icon
                                      Container(
                                        padding: EdgeInsets.all(8.w),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.05,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8.r,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          color: Colors.white70,
                                          size: 16.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

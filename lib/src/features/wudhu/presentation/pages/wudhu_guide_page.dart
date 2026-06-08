import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/di_container.dart';
import '../../../../core/presentation/widgets/app_transparent_app_bar.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../data/models/wudhu_model.dart';
import '../bloc/wudhu_cubit.dart';
import '../bloc/wudhu_state.dart';
import 'wudhu_detail_page.dart';

class WudhuGuidePage extends StatelessWidget {
  const WudhuGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<WudhuCubit>()
        ..loadContent(AppLocalizations.of(context)!.localeName),
      child: const _WudhuGuideView(),
    );
  }
}

class _WudhuGuideView extends StatefulWidget {
  const _WudhuGuideView();

  @override
  State<_WudhuGuideView> createState() => _WudhuGuideViewState();
}

class _WudhuGuideViewState extends State<_WudhuGuideView> {
  final TextEditingController _searchController = TextEditingController();
  String? _currentLocale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = AppLocalizations.of(context)!.localeName;
    if (_currentLocale != locale) {
      _currentLocale = locale;
      context.read<WudhuCubit>().loadContent(locale);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF1C2A30),
      appBar: AppTransparentAppBar(title: l10n.wudhuGuideTitle),
      body: BlocBuilder<WudhuCubit, WudhuState>(
        builder: (context, state) {
          if (state.status == WudhuStatus.loading ||
              state.status == WudhuStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == WudhuStatus.error) {
            return Center(
              child: Text(
                'Error: ${state.errorMessage}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }
          if (state.items.isEmpty) {
            return Center(
              child: Text(l10n.msgNoData, style: const TextStyle(color: Colors.white)),
            );
          }

          final filteredData = state.filteredItems;

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                child: TextField(
                  controller: _searchController,
                  onChanged: context.read<WudhuCubit>().onSearchChanged,
                  style: TextStyle(color: Colors.white, fontSize: 14.sp),
                  decoration: InputDecoration(
                    hintText: l10n.searchWudhuGuide,
                    hintStyle: TextStyle(color: Colors.white38, fontSize: 14.sp),
                    prefixIcon: const Icon(Icons.search, color: Colors.white54),
                    suffixIcon: state.query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.white54),
                            onPressed: () {
                              _searchController.clear();
                              context.read<WudhuCubit>().onSearchChanged('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: filteredData.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 48.sp, color: Colors.white24),
                            SizedBox(height: 16.h),
                            Text(
                              l10n.msgNoResults,
                              style: TextStyle(
                                color: Colors.white54,
                                fontFamily: GoogleFonts.outfit().fontFamily,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        key: const PageStorageKey('wudhu_guide_list'),
                        padding: EdgeInsets.all(16.w),
                        itemCount: filteredData.length,
                        separatorBuilder: (_, __) => SizedBox(height: 12.h),
                        itemBuilder: (context, index) {
                          return _buildChapterCard(context, filteredData[index], state.items);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChapterCard(BuildContext context, WudhuModel item, List<WudhuModel> allItems) {
    const accentColor = Color(0xFF00E676);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => WudhuDetailPage(item: item, allItems: allItems),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: accentColor.withOpacity(0.3)),
                  ),
                  child: Center(
                    child: Text(
                      "${item.order}",
                      style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                        fontFamily: GoogleFonts.outfit().fontFamily,
                      ),
                    ),
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
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: GoogleFonts.outfit().fontFamily,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        item.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12.sp,
                          fontFamily: GoogleFonts.outfit().fontFamily,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(Icons.arrow_forward_ios_rounded, color: Colors.white38, size: 16.sp),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

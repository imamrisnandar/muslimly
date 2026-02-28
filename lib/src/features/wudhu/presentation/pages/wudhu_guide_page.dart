import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/di_container.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../data/models/wudhu_model.dart';
import '../../data/repositories/wudhu_repository.dart';
import 'wudhu_detail_page.dart';

class WudhuGuidePage extends StatefulWidget {
  const WudhuGuidePage({super.key});

  @override
  State<WudhuGuidePage> createState() => _WudhuGuidePageState();
}

class _WudhuGuidePageState extends State<WudhuGuidePage> {
  late Future<List<WudhuModel>> _dataFuture;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _currentLocale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context)!;
    if (_currentLocale != l10n.localeName) {
      _currentLocale = l10n.localeName;
      _dataFuture = getIt<WudhuRepository>().getWudhuContent(l10n.localeName);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<WudhuModel> _filterData(List<WudhuModel> data) {
    if (_searchQuery.isEmpty) {
      return data;
    }
    return data.where((item) {
      final titleMatch = item.title.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      final descMatch = item.description.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      return titleMatch || descMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(
        0xFF1C2A30,
      ), // Dark Theme matching Fasting Guide
      appBar: AppBar(
        title: Text(
          l10n.wudhuGuideTitle,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: GoogleFonts.outfit().fontFamily,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: FutureBuilder<List<WudhuModel>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                l10n.msgNoData,
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          final allData = List<WudhuModel>.from(snapshot.data!);
          // Sort by order first
          allData.sort((a, b) => a.order.compareTo(b.order));

          final filteredData = _filterData(allData);

          return Column(
            children: [
              // Search Bar
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  style: TextStyle(color: Colors.white, fontSize: 14.sp),
                  decoration: InputDecoration(
                    hintText: l10n.searchWudhuGuide,
                    hintStyle: TextStyle(
                      color: Colors.white38,
                      fontSize: 14.sp,
                    ),
                    prefixIcon: const Icon(Icons.search, color: Colors.white54),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear,
                              color: Colors.white54,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // Content List
              Expanded(
                child: filteredData.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 48.sp,
                              color: Colors.white24,
                            ),
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
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 12.h),
                        itemBuilder: (context, index) {
                          final item = filteredData[index];
                          return _buildChapterCard(context, item, allData);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChapterCard(
    BuildContext context,
    WudhuModel item,
    List<WudhuModel> allItems,
  ) {
    const accentColor = Color(0xFF00E676); // Green Accent (Matching Fasting)

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
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    WudhuDetailPage(item: item, allItems: allItems),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                // Number Badge
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

                // Content
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
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white38,
                  size: 16.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

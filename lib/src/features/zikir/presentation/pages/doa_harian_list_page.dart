import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../data/repositories/zikir_local_repository.dart';
import '../../domain/entities/zikir_item.dart';
import '../../../../core/di/di_container.dart';
import 'dzikir_reading_page.dart';

class DoaHarianListPage extends StatefulWidget {
  const DoaHarianListPage({super.key});

  @override
  State<DoaHarianListPage> createState() => _DoaHarianListPageState();
}

class _DoaHarianListPageState extends State<DoaHarianListPage> {
  late List<ZikirItem> _allItems;
  List<ZikirItem> _filteredItems = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _allItems = getIt<ZikirLocalRepository>().getDailyDzikir();
    _filteredItems = _allItems;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = _allItems
          .where(
            (item) =>
                item.title.toLowerCase().contains(query) ||
                item.translation.toLowerCase().contains(query),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      appBar: AppBar(
        title: Text(
          l10n.dzikirDailyTitle,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
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
                hintText: 'Cari doa...',
                hintStyle: TextStyle(
                  color: Colors.white38,
                  fontSize: isLandscape ? 12.sp : 14.sp,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.white38,
                  size: isLandscape ? 18.sp : 20.sp,
                ),
                filled: true,
                fillColor: const Color(0xFF1A2C33),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: isLandscape ? 8.h : 12.h,
                ),
              ),
            ),
          ),

          // List Items
          Expanded(
            child: _filteredItems.isEmpty
                ? Center(
                    child: Text(
                      "Tidak ditemukan doa",
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: isLandscape ? 12.sp : 14.sp,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: isLandscape ? 4.h : 8.h,
                    ),
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];

                      // Find original index to pass correct initialIndex to Reader
                      final originalIndex = _allItems.indexOf(item);

                      return Container(
                        margin: EdgeInsets.only(
                          bottom: isLandscape ? 8.h : 12.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A2C33),
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
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
                                    items:
                                        _allItems, // Pass _allItems to allow full swipe
                                    initialIndex: originalIndex,
                                    enableCounter:
                                        false, // Disable counter for Daily Doa
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: isLandscape ? 10.h : 16.h,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: isLandscape ? 32.w : 40.w,
                                    height: isLandscape ? 32.w : 40.w,
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF00E676,
                                      ).withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        "${originalIndex + 1}",
                                        style: TextStyle(
                                          color: const Color(0xFF00E676),
                                          fontWeight: FontWeight.bold,
                                          fontSize: isLandscape ? 12.sp : 16.sp,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: isLandscape ? 12.w : 16.w),
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isLandscape ? 13.sp : 16.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right,
                                    color: Colors.white54,
                                    size: isLandscape ? 20.sp : 24.sp,
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
      ),
    );
  }
}

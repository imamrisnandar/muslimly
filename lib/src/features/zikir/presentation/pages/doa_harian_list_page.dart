import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../data/repositories/zikir_local_repository.dart';
import '../../domain/entities/zikir_item.dart';
import 'package:google_fonts/google_fonts.dart';
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
      backgroundColor: const Color(0xFFFFF8E1), // Quran Theme
      appBar: AppBar(
        title: Text(
          l10n.dzikirDailyTitle,
          style: TextStyle(
            color: const Color(0xFF4E342E),
            fontWeight: FontWeight.bold,
            fontFamily: GoogleFonts.outfit().fontFamily,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4E342E)),
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
                color: const Color(0xFF4E342E),
                fontSize: isLandscape ? 12.sp : 14.sp,
              ),
              decoration: InputDecoration(
                hintText: 'Cari doa...',
                hintStyle: TextStyle(
                  color: const Color(0xFF4E342E).withOpacity(0.5),
                  fontSize: isLandscape ? 12.sp : 14.sp,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: const Color(0xFF4E342E).withOpacity(0.5),
                  size: isLandscape ? 18.sp : 20.sp,
                ),
                filled: true,
                fillColor: Colors.white,
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
                    color: Color(0xFF1B5E20),
                    width: 1,
                  ),
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
                        color: const Color(0xFF4E342E).withOpacity(0.5),
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
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Colors.white, const Color(0xFFFFF8E1)],
                          ),
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1B5E20).withOpacity(0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: const Color(0xFF1B5E20).withOpacity(0.1),
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
                                    items: _allItems,
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
                                      color: const Color(0xFFFFF8E1),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(
                                          0xFF1B5E20,
                                        ).withOpacity(0.2),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "${originalIndex + 1}",
                                        style: TextStyle(
                                          color: const Color(0xFF1B5E20),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.sp,
                                          fontFamily:
                                              GoogleFonts.outfit().fontFamily,
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
                                        color: const Color(0xFF4E342E),
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
                                      color: const Color(
                                        0xFF1B5E20,
                                      ).withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: const Color(0xFF1B5E20),
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
      ),
    );
  }
}

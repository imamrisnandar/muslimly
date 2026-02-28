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
  List<ZikirItem> _allItems = []; // Initialize as empty
  List<ZikirItem> _filteredItems = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  Future<void> _loadData() async {
    final locale = Localizations.localeOf(context);
    final items = await getIt<ZikirLocalRepository>().getDailyDzikir(locale);
    if (mounted) {
      setState(() {
        _allItems = items;
        // Re-apply search if exists
        if (_searchController.text.isNotEmpty) {
          _onSearchChanged();
        } else {
          _filteredItems = items;
        }
      });
    }
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
      backgroundColor: const Color(0xFF1C2A30), // Dark Theme Background
      appBar: AppBar(
        title: Text(
          l10n.dzikirDailyTitle,
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
                fillColor: Colors.black.withOpacity(0.3),
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
                    color: Color(0xFF00E676),
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
                            colors: [
                              Colors.white.withOpacity(0.05),
                              Colors.white.withOpacity(0.02),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.05),
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
                                      color: const Color(
                                        0xFF00E676,
                                      ).withOpacity(0.1),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(
                                          0xFF00E676,
                                        ).withOpacity(0.3),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "${originalIndex + 1}",
                                        style: TextStyle(
                                          color: const Color(0xFF00E676),
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
                                      color: Colors.white.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(8.r),
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
      ),
    );
  }
}

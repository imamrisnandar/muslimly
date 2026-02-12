import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/di_container.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../data/models/prayer_guide_model.dart';
import '../../data/repositories/prayer_guide_repository.dart';
import 'prayer_detail_page.dart';

class PrayerGuidePage extends StatefulWidget {
  const PrayerGuidePage({super.key});

  @override
  State<PrayerGuidePage> createState() => _PrayerGuidePageState();
}

class _PrayerGuidePageState extends State<PrayerGuidePage> {
  late Future<List<PrayerGuideCategory>> _prayerContentFuture;
  final TextEditingController _searchController = TextEditingController();
  List<PrayerGuideCategory> _allCategories = [];
  List<PrayerGuideCategory> _filteredCategories = [];
  List<PrayerGuideItem> _allItems = []; // Flattened list for navigation
  String _searchQuery = '';
  String? _currentLocale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context).languageCode;
    if (_currentLocale != locale) {
      _currentLocale = locale;
      _prayerContentFuture = getIt<PrayerGuideRepository>().getPrayerContent(
        locale,
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterContent(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredCategories = List.from(_allCategories);
      } else {
        _filteredCategories = _allCategories
            .map((category) {
              // Check if category matches or any item matches
              final categoryMatches = category.title.toLowerCase().contains(
                query.toLowerCase(),
              );

              // Filter items
              final matchingItems = category.items.where((item) {
                return categoryMatches ||
                    item.title.toLowerCase().contains(query.toLowerCase()) ||
                    item.description.toLowerCase().contains(
                      query.toLowerCase(),
                    );
              }).toList();

              // Return new category with filtered items (only if there are matches)
              if (matchingItems.isEmpty) return null;

              return PrayerGuideCategory(
                id: category.id,
                title: category.title,
                description: category.description,
                items: matchingItems,
              );
            })
            .whereType<PrayerGuideCategory>()
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(
        0xFF1C2A30,
      ), // Dark Theme matching Wudhu Guide
      appBar: AppBar(
        title: Text(
          l10n.ibadahPrayerTitle,
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
      body: FutureBuilder<List<PrayerGuideCategory>>(
        future: _prayerContentFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No content available',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          if (_allCategories.isEmpty) {
            _allCategories = snapshot.data!;
            _filteredCategories = List.from(_allCategories);
            // Flatten items for navigation
            _allItems = _allCategories.expand((c) => c.items).toList();
          }

          return Column(
            children: [
              // Search Bar
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterContent,
                  style: TextStyle(color: Colors.white, fontSize: 14.sp),
                  decoration: InputDecoration(
                    hintText: l10n.searchPrayerGuide,
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
                              _filterContent('');
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
              Expanded(
                child: ListView.builder(
                  // Key is vital for proper keeping state
                  key: const PageStorageKey('prayer_guide_list'),
                  itemCount: _filteredCategories.length,
                  padding: EdgeInsets.only(
                    bottom: 20.h,
                    left: 16.w,
                    right: 16.w,
                  ),
                  itemBuilder: (context, index) {
                    final category = _filteredCategories[index];
                    // Auto-expand if searching
                    final forceExpand = _searchQuery.isNotEmpty;

                    return _buildCategorySection(
                      context,
                      category,
                      forceExpand,
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

  Widget _buildCategorySection(
    BuildContext context,
    PrayerGuideCategory category,
    bool forceExpand,
  ) {
    const accentColor = Color(0xFF00E676); // Green Accent (Tajweed Style)

    // Key to handle expansion state based on search
    final key = PageStorageKey('${category.id}_$forceExpand');

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2A30), // Match Scaffold or slightly lighter
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: key,
          initiallyExpanded: forceExpand,
          collapsedBackgroundColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          iconColor: accentColor,
          collapsedIconColor: Colors.white54,
          title: Text(
            category.title.toUpperCase(),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: accentColor,
              fontFamily: GoogleFonts.outfit().fontFamily,
            ),
          ),
          subtitle: Text(
            category.description,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.white70,
              fontFamily: GoogleFonts.outfit().fontFamily,
            ),
          ),
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              child: Column(
                children: category.items.asMap().entries.map((entry) {
                  // Local index for numbering (Resets per category)
                  final index = entry.key + 1;
                  final item = entry.value;
                  return _buildItemCard(context, item, index);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, PrayerGuideItem item, int order) {
    const accentColor = Color(0xFF00E676); // Green Accent (Tajweed Style)

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.04),
          ],
        ),
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
                    PrayerDetailPage(prayerModel: item, allContent: _allItems),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              children: [
                // Number Badge
                Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: accentColor.withOpacity(0.3)),
                  ),
                  child: Center(
                    child: Text(
                      '$order',
                      style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                        fontFamily: GoogleFonts.outfit().fontFamily,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: GoogleFonts.outfit().fontFamily,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        item.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 11.sp,
                          fontFamily: GoogleFonts.outfit().fontFamily,
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white70,
                  size: 14.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

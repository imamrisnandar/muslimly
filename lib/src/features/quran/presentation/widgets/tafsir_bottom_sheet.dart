import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/di_container.dart';
import '../../../../core/widgets/islamic_loading_indicator.dart';
import '../../domain/entities/word.dart';
import '../bloc/translation/translation_bloc.dart';
import '../bloc/translation/translation_event.dart';
import '../bloc/translation/translation_state.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';

class TafsirBottomSheet extends StatefulWidget {
  final int surahId;
  final String surahName;
  final int ayahNumber;
  final int initialTabIndex;
  final String arabicText;
  final String languageCode;

  const TafsirBottomSheet({
    super.key,
    required this.surahId,
    required this.surahName,
    required this.ayahNumber,
    this.initialTabIndex = 0,
    this.arabicText = '',
    this.languageCode = 'id',
  });

  @override
  State<TafsirBottomSheet> createState() => _TafsirBottomSheetState();
}

class _TafsirBottomSheetState extends State<TafsirBottomSheet>
    with TickerProviderStateMixin {
  late TabController _mainTabController;

  // Translation Sub-Tab (0=Indo, 1=Eng)
  int _transSubTabIndex = 0;

  // Tafsir Sub-Tab (0=Jalalayn, 1=Ibn Kathir)
  int _tafsirSubTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    // Set default tabs based on language
    if (widget.languageCode == 'id') {
      _transSubTabIndex = 0; // Indo
      _tafsirSubTabIndex = 0; // Jalalayn
    } else {
      _transSubTabIndex = 1; // Eng
      _tafsirSubTabIndex = 1; // Ibn Kathir
    }
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return BlocProvider(
      create: (context) => getIt<TranslationBloc>()
        ..add(
          LoadAyahDetail(
            surahId: widget.surahId,
            ayahId: widget.ayahNumber,
            languageCode: widget.languageCode,
          ),
        ),
      child: Container(
        height: isLandscape ? 0.95.sh : 0.85.sh, // More height in landscape
        decoration: BoxDecoration(
          color: const Color(0xFFF1EEE5), // Cream Background (Quran Theme)
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2), // Lighter shadow
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          children: [
            // 1. Drag Handle
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
                width: 48.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.black12, // Darker handle for light bg
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),

            // 2. Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.surahName} : ${widget.ayahNumber}',
                        style: GoogleFonts.outfit(
                          color: AppColors.surfaceDark, // Dark Text
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'QS. ${widget.surahId}:${widget.ayahNumber}',
                        style: GoogleFonts.outfit(
                          color: AppColors.textDisabled, // Grey Subtitle
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.black54),
                  ),
                ],
              ),
            ),

            // 3. Divider
            Container(height: 1, color: Colors.black12),

            // 4. Content (BlocBuilder)
            Expanded(
              child: BlocBuilder<TranslationBloc, TranslationState>(
                builder: (context, state) {
                  if (state is TranslationLoading) {
                    return const Center(
                      child: IslamicLoadingIndicator(size: 64, isDark: false),
                    );
                  } else if (state is TranslationError) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.redAccent,
                              size: 48.sp,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              state.message,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                color: AppColors.surfaceDark,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            ElevatedButton(
                              onPressed: () {
                                context.read<TranslationBloc>().add(
                                  LoadAyahDetail(
                                    surahId: widget.surahId,
                                    ayahId: widget.ayahNumber,
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.quranTeal,
                                foregroundColor: Colors.white,
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.tryAgain,
                                style: GoogleFonts.outfit(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else if (state is TranslationLoaded) {
                    return TabBarView(
                      controller: _mainTabController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildTranslationTab(context, state),
                        _buildTafsirTab(context, state),
                      ],
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTranslationTab(BuildContext context, TranslationLoaded state) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Arabic Text
          Center(
            child: Text(
              widget.arabicText.isNotEmpty
                  ? widget.arabicText
                  : 'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'UthmanicHafs13',
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black, // Stark Black for Arabic
                height: 1.6,
              ),
            ),
          ),
          SizedBox(height: 32.h),

          // Word-by-Word Section
          if (state.words.isNotEmpty) ...[
            Text(
              AppLocalizations.of(context)!.wordByWord,
              style: GoogleFonts.outfit(
                color: AppColors.quranTeal, // Teal
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 16.h),
            SizedBox(height: 16.h),
            Directionality(
              textDirection: TextDirection.rtl,
              child: Wrap(
                spacing: 8.w,
                runSpacing: 16.h,
                alignment: WrapAlignment.start, // Start from Right in RTL
                children: state.words.map((w) => _buildWordItem(w)).toList(),
              ),
            ),
            SizedBox(height: 32.h),
            const Divider(color: Colors.black12, height: 1),
            SizedBox(height: 24.h),
          ],

          // Translation Header with Tabs
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.translation,
                style: GoogleFonts.outfit(
                  color: AppColors.quranTeal,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              // Mini Tabs for Translation
              Container(
                height: 30.h,
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTransSubTab("Indo", 0),
                    _buildTransSubTab("Eng", 1),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Translation Content
          if (_transSubTabIndex == 0) ...[
            Text(
              state.translationIndo,
              style: GoogleFonts.outfit(
                color: AppColors.surfaceDark,
                fontSize: 16.sp,
                height: 1.6,
              ),
            ),
          ] else ...[
            Text(
              state.translationEng,
              style: GoogleFonts.outfit(
                color: AppColors.surfaceDark,
                fontSize: 16.sp,
                height: 1.6,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],

          SizedBox(height: 48.h),

          // Read Tafsir Button
          Center(
            child: InkWell(
              onTap: () {
                _mainTabController.animateTo(1);
              },
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.quranTeal),
                  borderRadius: BorderRadius.circular(12.r),
                  color: AppColors.quranTeal.withValues(alpha: 0.1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.menu_book_rounded,
                      color: AppColors.quranTeal,
                      size: 20.sp,
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      AppLocalizations.of(context)!.readTafsirButton,
                      style: GoogleFonts.outfit(
                        color: AppColors.quranTeal,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildWordItem(Word word) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white, // Card look
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Arabic
          Text(
            word.arabic,
            style: TextStyle(
              fontFamily: 'UthmanicHafs13',
              fontSize: 18.sp,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 4.h),
          // Translation
          Text(
            word.translation,
            style: GoogleFonts.outfit(
              fontSize: 10.sp,
              color: AppColors.quranTeal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTransSubTab(String title, int index) {
    final bool isSelected = _transSubTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _transSubTabIndex = index;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(15.r),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          title,
          style: GoogleFonts.outfit(
            color: isSelected
                ? AppColors.quranTeal
                : AppColors.textDisabled,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildTafsirTab(BuildContext context, TranslationLoaded state) {
    return Column(
      children: [
        // Content
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 40.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Arabic Context Header
                Center(
                  child: Text(
                    widget.arabicText.isNotEmpty
                        ? widget.arabicText
                        : 'Loading Arabic...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'UthmanicHafs13',
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      height: 1.6,
                    ),
                  ),
                ),
                SizedBox(height: 24.h),

                // Tafsir Switcher
                Center(
                  child: Container(
                    height: 40.h,
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildTafsirSubTabItem("Jalalayn (Indo)", 0),
                          _buildTafsirSubTabItem("Ibn Kathir (Eng)", 1),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),

                if (_tafsirSubTabIndex == 0) ...[
                  Text(
                    "Tafsir Jalalayn",
                    style: GoogleFonts.outfit(
                      color: AppColors.surfaceDark,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    AppLocalizations.of(context)!.tafsirSourceJalalayn,
                    style: GoogleFonts.outfit(
                      color: AppColors.quranTeal,
                      fontSize: 10.sp,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  SelectableText(
                    state.tafsirJalalayn.isNotEmpty
                        ? state.tafsirJalalayn
                        : AppLocalizations.of(context)!.tafsirNotAvailable,
                    style: GoogleFonts.outfit(
                      color: AppColors.surfaceDark.withValues(alpha: 0.9),
                      fontSize: 16.sp,
                      height: 1.8,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ] else ...[
                  Text(
                    "Tafsir Ibn Kathir",
                    style: GoogleFonts.outfit(
                      color: AppColors.surfaceDark,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    AppLocalizations.of(context)!.tafsirSourceIbnKathir,
                    style: GoogleFonts.outfit(
                      color: AppColors.quranTeal,
                      fontSize: 10.sp,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  SelectableText(
                    state.tafsirIbnKathir.isNotEmpty
                        ? state.tafsirIbnKathir
                        : AppLocalizations.of(context)!.tafsirNotAvailable,
                    style: GoogleFonts.outfit(
                      color: AppColors.surfaceDark.withValues(alpha: 0.9),
                      fontSize: 16.sp,
                      height: 1.8,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ],
            ),
          ),
        ),

        // Navigation (Back)
        Container(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Colors.black12)),
            color: Color(0xFFF1EEE5), // Ensure bg color covers bottom
          ),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: InkWell(
            onTap: () => _mainTabController.animateTo(0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.arrow_back_ios,
                  size: 14.sp,
                  color: AppColors.quranTeal,
                ),
                SizedBox(width: 8.w),
                Text(
                  AppLocalizations.of(context)!.backToTranslation,
                  style: GoogleFonts.outfit(
                    color: AppColors.quranTeal,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTafsirSubTabItem(String title, int index) {
    final bool isSelected = _tafsirSubTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _tafsirSubTabIndex = index;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: GoogleFonts.outfit(
            color: isSelected
                ? AppColors.quranTeal
                : AppColors.textDisabled,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12.sp,
          ),
        ),
      ),
    );
  }
}

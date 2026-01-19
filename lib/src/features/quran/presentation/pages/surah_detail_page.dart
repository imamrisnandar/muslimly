import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/surah_names.dart';
import '../../../../core/di/di_container.dart';
import '../../domain/entities/surah.dart';
import '../bloc/quran_bloc.dart';
import '../bloc/quran_event.dart';
import '../bloc/quran_state.dart';

class SurahDetailPage extends StatelessWidget {
  final Surah surah;

  const SurahDetailPage({super.key, required this.surah});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final surahName = SurahNames.getName(
      surah.number,
      locale,
      surah.englishName,
    );

    return BlocProvider(
      create: (context) =>
          getIt<QuranBloc>()..add(QuranFetchAyahs(surah.number)),
      child: Scaffold(
        backgroundColor: const Color(0xFF0F2027), // Dark Background
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          title: Text(surahName, style: const TextStyle(color: Colors.white)),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // Bismillah Header
            Container(
              margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    surah.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    surahName, // Also update subtitle in header
                    style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                  ),
                  SizedBox(height: 16.h),
                  const Divider(color: Colors.white24),
                  if (surah.number != 1) ...[
                    SizedBox(height: 8.h),
                    const Text(
                      'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            Expanded(
              child: BlocBuilder<QuranBloc, QuranState>(
                builder: (context, state) {
                  if (state is QuranLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is QuranError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  } else if (state is QuranAyahsLoaded) {
                    return ListView.separated(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 8.h,
                      ),
                      itemCount: state.ayahs.length,
                      separatorBuilder: (context, index) =>
                          Divider(color: Colors.white.withOpacity(0.05)),
                      itemBuilder: (context, index) {
                        final ayah = state.ayahs[index];
                        String ayahText = ayah.text;

                        // Define variations of Bismillah to handle different API encodings/harakat
                        const bismillahVariations = [
                          'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ', // Exact text from API (Surah 2:1)
                          'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ', // Uthmani 1
                          'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ', // Simple Alef
                          'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ', // Another var
                        ];

                        // Strip logic: Only if NOT Surah 1 (Al-Fatihah)
                        if (index == 0 && surah.number != 1) {
                          // Clean potential BOM or invisible chars
                          ayahText = ayahText.replaceAll('\uFEFF', '').trim();

                          bool stripped = false;
                          for (final bismillah in bismillahVariations) {
                            if (ayahText.startsWith(bismillah)) {
                              ayahText = ayahText
                                  .substring(bismillah.length)
                                  .trim();
                              stripped = true;
                              break; // Stop after first match
                            }
                          }

                          // Fallback: Regex if exact match failed (matches skeletal Bismillah)
                          if (!stripped) {
                            final bismillahRegex = RegExp(
                              r'^بِسْمِ\s+ٱلل.+?ٱلر.+?حِيمِ',
                            );
                            final match = bismillahRegex.firstMatch(ayahText);
                            if (match != null) {
                              ayahText = ayahText.substring(match.end).trim();
                            }
                          }
                        }

                        // Special case for Al-Fatihah (Surah 1) where Verse 1 IS Bismillah
                        // We likely want to Show it if it's the ONLY text, OR user said "stored in header only"
                        // If we strip it and it's empty, and it is Surah 1...
                        // Actually user said "Bismillah bukan merupakan ayah pertama".
                        // Meaning for Al-Fatihah, Verse 1 (Bismillah) should seemingly be skipped if strictly following this rule.
                        // I will respect the "IsEmpty" check.

                        if (ayahText.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return Container(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Only show Ayah text
                              Container(
                                padding: EdgeInsets.all(12.w),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.02),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    CircleAvatar(
                                      radius: 14.r,
                                      backgroundColor: const Color(0xFF00E676),
                                      child: Text(
                                        '${ayah.numberInSurah}',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    const Icon(
                                      Icons.share_outlined,
                                      color: Colors.white54,
                                      size: 20,
                                    ),
                                    SizedBox(width: 12.w),
                                    const Icon(
                                      Icons.play_circle_outline,
                                      color: Colors.white54,
                                      size: 20,
                                    ),
                                    SizedBox(width: 12.w),
                                    const Icon(
                                      Icons.bookmark_border,
                                      color: Colors.white54,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 16.h),

                              // Arabic Text
                              Text(
                                ayahText,
                                textAlign: TextAlign.right,
                                style: GoogleFonts.amiriQuran(
                                  color: Colors.white,
                                  fontSize: 24.sp,
                                  height:
                                      2.2, // Increased line height for better readability
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              // Translation (Optional - skipped for now as user just wants Mushaf style initially, but API has it if needed later)
                            ],
                          ),
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

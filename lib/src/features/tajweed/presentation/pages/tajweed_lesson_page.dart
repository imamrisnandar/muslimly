import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';
import '../../data/models/tajweed_model.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio_background/just_audio_background.dart';

class TajweedLessonPage extends StatefulWidget {
  final TajweedLesson lesson;

  const TajweedLessonPage({super.key, required this.lesson});

  @override
  State<TajweedLessonPage> createState() => _TajweedLessonPageState();
}

class _TajweedLessonPageState extends State<TajweedLessonPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlayingUrl;
  bool _isPlaying = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playAudio(List<String> urls, String title) async {
    // Added title parameter
    if (urls.isEmpty) return;

    // Determine if we are toggling off the current audio
    if (_currentlyPlayingUrl == urls.first && _isPlaying) {
      await _audioPlayer.stop();
      setState(() {
        _isPlaying = false;
        _currentlyPlayingUrl = null;
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _currentlyPlayingUrl = urls.first;
      });

      // Gapless playback logic
      final playlist = ConcatenatingAudioSource(
        // Use Loop to add all sources
        children: urls.map((url) {
          final uri = Uri.parse(url);
          final fragment = uri.fragment;

          // Check for timestamp fragment #t=startMs,endMs
          if (fragment.startsWith('t=')) {
            final times = fragment.substring(2).split(',');
            if (times.length == 2) {
              final startMs = int.tryParse(times[0]);
              final endMs = int.tryParse(times[1]);

              if (startMs != null && endMs != null) {
                return ClippingAudioSource(
                  start: Duration(milliseconds: startMs),
                  end: Duration(milliseconds: endMs),
                  child: AudioSource.uri(
                    uri.removeFragment(),
                  ), // Use clear URI for source
                  tag: MediaItem(
                    id: url,
                    title: title,
                    artist: 'Mishary Rashid Alafasy',
                  ),
                );
              }
            }
          }

          // Fallback to standard
          return AudioSource.uri(
            uri,
            tag: MediaItem(
              id: url,
              title: title,
              artist: 'Mishary Rashid Alafasy',
            ),
          );
        }).toList(),
      );

      await _audioPlayer.setAudioSource(playlist);
      setState(() {
        _isLoading = false;
        _isPlaying = true;
      });

      await _audioPlayer.play();

      // Reset state when finished
      _audioPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          if (mounted) {
            setState(() {
              _isPlaying = false;
              _currentlyPlayingUrl = null;
            });
          }
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isPlaying = false;
        _currentlyPlayingUrl = null;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to play audio: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1), // Cream Theme
      appBar: AppBar(
        title: Text(
          widget.lesson.title,
          style: TextStyle(
            color: const Color(0xFF4E342E), // Dark Brown
            fontWeight: FontWeight.bold,
            fontFamily: GoogleFonts.outfit().fontFamily,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF4E342E)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Definition Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, const Color(0xFFFFF8E1)],
                ),
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1B5E20).withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: const Color(0xFF1B5E20).withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B5E20).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          Icons.menu_book,
                          color: const Color(0xFF1B5E20),
                          size: 20.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        "Definisi", // Localize later
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1B5E20), // Dark Green
                          fontFamily: GoogleFonts.outfit().fontFamily,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    widget.lesson.definition,
                    style: TextStyle(
                      fontSize: 15.sp,
                      height: 1.6,
                      color: const Color(0xFF4E342E), // Brown
                      fontFamily: GoogleFonts.outfit().fontFamily,
                    ),
                  ),
                  if (widget.lesson.note != null) ...[
                    SizedBox(height: 12.h),
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4E342E).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16.sp,
                            color: const Color(0xFF4E342E).withOpacity(0.6),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              "${widget.lesson.note}", // Localize "Catatan" if needed
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontStyle: FontStyle.italic,
                                color: const Color(0xFF4E342E).withOpacity(0.8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // 2. Letters Section
            if (widget.lesson.letters.isNotEmpty) ...[
              Text(
                "Huruf (${widget.lesson.letters.length})",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4E342E),
                  fontFamily: GoogleFonts.outfit().fontFamily,
                ),
              ),
              SizedBox(height: 12.h),
              Wrap(
                spacing: 12.w,
                runSpacing: 12.h,
                children: widget.lesson.letters.map((letter) {
                  return Container(
                    width: 56.w,
                    height: 56.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.brown.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(
                        color: const Color(0xFF1B5E20).withOpacity(0.2),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        letter,
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: GoogleFonts.amiriQuran().fontFamily,
                          color: const Color(0xFF1B5E20),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 24.h),
            ],

            // 3. Examples Section
            if (widget.lesson.examples.isNotEmpty) ...[
              Text(
                "Contoh Bacaan",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4E342E),
                  fontFamily: GoogleFonts.outfit().fontFamily,
                ),
              ),
              SizedBox(height: 12.h),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.lesson.examples.length,
                itemBuilder: (context, index) {
                  final example = widget.lesson.examples[index];
                  final isPlaying =
                      _currentlyPlayingUrl == example.audioUrls.firstOrNull;
                  final bool hasAudio = example.audioUrls.isNotEmpty;

                  return Container(
                    margin: EdgeInsets.only(bottom: 12.h),
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(
                        color: isPlaying
                            ? const Color(0xFF1B5E20)
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Play Button
                        if (hasAudio)
                          InkWell(
                            onTap: () =>
                                _playAudio(example.audioUrls, example.label),
                            borderRadius: BorderRadius.circular(30),
                            child: Container(
                              padding: EdgeInsets.all(10.r),
                              decoration: BoxDecoration(
                                color: isPlaying
                                    ? const Color(0xFF1B5E20) // Active Green
                                    : const Color(0xFFFFF8E1), // Cream bg
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(
                                    0xFF1B5E20,
                                  ).withOpacity(0.2),
                                ),
                              ),
                              child: _isLoading && isPlaying
                                  ? SizedBox(
                                      width: 20.sp,
                                      height: 20.sp,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Icon(
                                      isPlaying ? Icons.stop : Icons.play_arrow,
                                      color: isPlaying
                                          ? Colors.white
                                          : const Color(0xFF1B5E20),
                                      size: 24.sp,
                                    ),
                            ),
                          )
                        else
                          Container(
                            padding: EdgeInsets.all(10.r),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.volume_off,
                              color: Colors.grey,
                              size: 24.sp,
                            ),
                          ),

                        SizedBox(width: 16.w),

                        // Text Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (example.subCategory != null)
                                Text(
                                  example.subCategory!,
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: const Color(0xFF1B5E20),
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              SizedBox(height: 4.h),
                              // Replaced simple Text with RichText builder
                              _buildHighlightedArabicText(
                                example.highlight,
                                isLandscape: false, // context availability
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                example.label,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: const Color(
                                    0xFF4E342E,
                                  ).withOpacity(0.7),
                                  fontFamily: GoogleFonts.outfit().fontFamily,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightedArabicText(String text, {required bool isLandscape}) {
    // Regex to find content inside curly braces {}
    // and split the string into parts
    List<InlineSpan> spans = [];

    // Split by regex but keep delimiters to identify parts
    // simple parsing: scan string
    final regex = RegExp(r'\{([^}]+)\}');

    int currentIndex = 0;

    // Using matches
    final matches = regex.allMatches(text);

    for (final match in matches) {
      // Add text before match
      if (match.start > currentIndex) {
        spans.add(
          TextSpan(
            text: text.substring(currentIndex, match.start),
            style: TextStyle(color: Colors.black87),
          ),
        );
      }

      // Add highlighted text (group 1 is content inside braces)
      spans.add(
        TextSpan(
          text: match.group(1),
          style: TextStyle(
            color: const Color(
              0xFFD32F2F,
            ), // Red for highlight (Standard TajweedRed)
            // or use 0xFFC62828
          ),
        ),
      );

      currentIndex = match.end;
    }

    // Add remaining text
    if (currentIndex < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(currentIndex),
          style: TextStyle(color: Colors.black87),
        ),
      );
    }

    // Fallback if no brackets found (legacy support)
    if (spans.isEmpty) {
      spans.add(
        TextSpan(
          text: text,
          style: const TextStyle(color: Colors.black87),
        ),
      );
    }

    return RichText(
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
      text: TextSpan(
        children: spans,
        style: TextStyle(
          fontSize: 26.sp,
          fontFamily: GoogleFonts.amiriQuran().fontFamily,
          fontWeight: FontWeight.bold,
          height: 2.0,
        ),
      ),
    );
  }
}

extension ListGetExtension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

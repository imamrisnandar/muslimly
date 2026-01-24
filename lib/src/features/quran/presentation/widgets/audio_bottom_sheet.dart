import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../bloc/audio_bloc.dart';
import '../bloc/audio_event.dart';
import '../bloc/audio_state.dart';
import 'reciter_selector_bottom_sheet.dart';
import '../../domain/entities/reciter.dart';

class AudioBottomSheet extends StatelessWidget {
  const AudioBottomSheet({super.key});

  String _formatDuration(Duration? duration) {
    if (duration == null) return "--:--";
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2C33), // Dark theme
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: BlocBuilder<AudioBloc, AudioState>(
        builder: (context, state) {
          final isPlaying = state.status == AudioStatus.playing;
          final duration = state.duration;
          final position = state.position;
          final progress = (duration.inMilliseconds > 0)
              ? (position.inMilliseconds / duration.inMilliseconds).clamp(
                  0.0,
                  1.0,
                )
              : 0.0;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 24.h),

              // Title and Reciter
              Text(
                state.currentSurahName ?? 'Surah',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              GestureDetector(
                onTap: () {
                  // Open Reciter Selector
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => ReciterSelectorBottomSheet(
                      filterSource: state.selectedReciter?.source,
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person, color: Colors.white70, size: 16.sp),
                      SizedBox(width: 8.w),
                      Text(
                        state.selectedReciter?.name ?? 'Select Reciter',
                        style: TextStyle(
                          color: const Color(0xFF00E676),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      // Source Badge
                      if (state.selectedReciter != null)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color:
                                state.selectedReciter!.source ==
                                    AudioSourceType.quranComChapter
                                ? Colors.blue.withOpacity(0.2)
                                : Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4.r),
                            border: Border.all(
                              color:
                                  state.selectedReciter!.source ==
                                      AudioSourceType.quranComChapter
                                  ? Colors.blue.withOpacity(0.5)
                                  : Colors.orange.withOpacity(0.5),
                            ),
                          ),
                          child: Text(
                            state.selectedReciter!.source ==
                                    AudioSourceType.quranComChapter
                                ? "Full"
                                : "Verse",
                            style: TextStyle(
                              fontSize: 8.sp,
                              color:
                                  state.selectedReciter!.source ==
                                      AudioSourceType.quranComChapter
                                  ? Colors.blue
                                  : Colors.orange,
                            ),
                          ),
                        ),
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white70,
                        size: 16.sp,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 32.h),

              // Progress Slider
              Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      thumbShape: RoundSliderThumbShape(
                        enabledThumbRadius: 6.r,
                      ),
                      overlayShape: RoundSliderOverlayShape(
                        overlayRadius: 14.r,
                      ),
                      trackHeight: 4.h,
                      activeTrackColor: const Color(0xFF00E676),
                      inactiveTrackColor: Colors.white12,
                      thumbColor: Colors.white,
                    ),
                    child: Slider(
                      value: progress,
                      onChanged: (value) {
                        // Seek logic could be implemented here
                        // context.read<AudioBloc>().add(SeekAudio(Duration...));
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(position),
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12.sp,
                          ),
                        ),
                        Text(
                          _formatDuration(duration),
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24.h),

              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Prev (Optional)
                  IconButton(
                    icon: Icon(Icons.skip_previous, size: 32.sp),
                    color: Colors.white54,
                    onPressed: () {},
                  ),
                  SizedBox(width: 24.w),

                  // Play/Pause
                  Container(
                    width: 64.w,
                    height: 64.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E676),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00E676).withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 32.sp,
                      ),
                      onPressed: () {
                        if (isPlaying) {
                          context.read<AudioBloc>().add(PauseAudio());
                        } else {
                          context.read<AudioBloc>().add(ResumeAudio());
                        }
                      },
                    ),
                  ),

                  SizedBox(width: 24.w),
                  // Next (Optional)
                  IconButton(
                    icon: Icon(Icons.skip_next, size: 32.sp),
                    color: Colors.white54,
                    onPressed: () {},
                  ),
                ],
              ),
              SizedBox(height: 16.h),
            ],
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../bloc/audio_bloc.dart';
import '../bloc/audio_event.dart';
import '../bloc/audio_state.dart';

class AudioPlayerWidget extends StatelessWidget {
  const AudioPlayerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioBloc, AudioState>(
      builder: (context, state) {
        if (!state.isMiniPlayerVisible) return const SizedBox.shrink();

        final isPlaying = state.status == AudioStatus.playing;
        final position = state.position.inMilliseconds.toDouble();
        final duration = state.duration.inMilliseconds.toDouble();
        final progress = (duration > 0)
            ? (position / duration).clamp(0.0, 1.0)
            : 0.0;

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: const Color(0xFF1A2C33),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  // Icon or Album Art Placeholder
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E676).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: const Icon(
                      Icons.music_note,
                      color: Color(0xFF00E676),
                    ),
                  ),
                  SizedBox(width: 12.w),

                  // Text Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.currentSurahName ?? 'Surah',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          state.selectedReciter?.name ?? 'Unknown Qori',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Controls
                  if (state.status == AudioStatus.loading)
                    SizedBox(
                      width: 24.w,
                      height: 24.w,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    IconButton(
                      icon: Icon(
                        isPlaying
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_filled,
                      ),
                      color: const Color(0xFF00E676),
                      iconSize: 32.sp,
                      onPressed: () {
                        if (isPlaying) {
                          context.read<AudioBloc>().add(PauseAudio());
                        } else {
                          context.read<AudioBloc>().add(ResumeAudio());
                        }
                      },
                    ),

                  IconButton(
                    icon: const Icon(Icons.close),
                    color: Colors.white54,
                    onPressed: () {
                      context.read<AudioBloc>().add(CloseAudio());
                    },
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withOpacity(0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF00E676),
                ),
                minHeight: 2.h,
              ),
            ],
          ),
        );
      },
    );
  }
}

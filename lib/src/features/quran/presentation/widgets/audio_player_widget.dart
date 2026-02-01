import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../bloc/audio_bloc.dart';
import '../bloc/audio_event.dart';
import '../bloc/audio_state.dart';
import '../../domain/entities/reciter.dart';
import '../../../../core/utils/custom_snackbar.dart';
import 'reciter_selector_bottom_sheet.dart';
import '../../../../core/widgets/islamic_loading_indicator.dart';

class AudioPlayerWidget extends StatelessWidget {
  final GlobalKey? qoriShowcaseKey;
  final GlobalKey? dragShowcaseKey;

  const AudioPlayerWidget({
    super.key,
    this.qoriShowcaseKey,
    this.dragShowcaseKey,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AudioBloc, AudioState>(
      listener: (context, state) {
        if (state.status == AudioStatus.error) {
          showCustomSnackBar(
            context,
            message: state.errorMessage ?? 'Audio Error',
            type: SnackBarType.error,
          );
        }
      },
      builder: (context, state) {
        if (!state.isMiniPlayerVisible) return const SizedBox.shrink();

        final isPlaying = state.status == AudioStatus.playing;
        final position = state.position.inMilliseconds.toDouble();
        final duration = state.duration.inMilliseconds.toDouble();
        final progress = (duration > 0)
            ? (position / duration).clamp(0.0, 1.0)
            : 0.0;

        return Material(
          color: Colors.transparent,
          child: Container(
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
                    _buildIcon(),
                    SizedBox(width: 12.w),

                    // Text Info
                    Expanded(child: _buildQoriInfo(context, state)),

                    // Controls
                    if (state.status == AudioStatus.loading)
                      SizedBox(
                        width: 24.w,
                        height: 24.w,
                        child: const IslamicLoadingIndicator(size: 24),
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
          ),
        );
      },
    );
  }

  Widget _buildQoriInfo(BuildContext context, AudioState state) {
    return GestureDetector(
      onTap: () {
        // Filter Qori based on Context (Ayah vs Surah)
        final filter = state.currentAyahNumber != null
            ? AudioSourceType.alQuranCloudVerse
            : AudioSourceType.quranComChapter;

        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) =>
              ReciterSelectorBottomSheet(filterSource: filter),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            state.currentAyahNumber != null
                ? '${state.currentSurahName} : Ayah ${state.currentAyahNumber}'
                : state.currentSurahName ?? 'Surah',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  state.selectedReciter?.name ?? 'Unknown Qori',
                  style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white70,
                size: 16.sp,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: const Color(0xFF00E676).withOpacity(0.2),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: const Icon(Icons.music_note, color: Color(0xFF00E676)),
    );
  }
}

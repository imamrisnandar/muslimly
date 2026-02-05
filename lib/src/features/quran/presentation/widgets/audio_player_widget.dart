import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';

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

        // Ensure slider value doesn't exceed max
        final sliderValue = position.clamp(0.0, duration > 0 ? duration : 0.0);
        final sliderMax = duration > 0 ? duration : 1.0;

        return Material(
          color: Colors.transparent,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2C33),
              borderRadius: BorderRadius.circular(20.r),
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
                // ROW 1: Header (Icon, Info, Close)
                Row(
                  children: [
                    _buildIcon(),
                    SizedBox(width: 12.w),
                    Expanded(child: _buildQoriInfo(context, state)),
                    IconButton(
                      icon: const Icon(Icons.close),
                      color: Colors.white54,
                      iconSize: 20.sp,
                      onPressed: () {
                        context.read<AudioBloc>().add(CloseAudio());
                      },
                    ),
                  ],
                ),

                SizedBox(height: 8.h),

                // ROW 2: Slider & Time Labels
                Row(
                  children: [
                    Text(
                      _formatDuration(state.position),
                      style: TextStyle(color: Colors.white54, fontSize: 10.sp),
                    ),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 2.h,
                          thumbShape: RoundSliderThumbShape(
                            enabledThumbRadius: 6.r,
                          ),
                          overlayShape: RoundSliderOverlayShape(
                            overlayRadius: 14.r,
                          ),
                          activeTrackColor: const Color(0xFF00E676),
                          inactiveTrackColor: Colors.white10,
                          thumbColor: Colors.white,
                          overlayColor: const Color(
                            0xFF00E676,
                          ).withOpacity(0.2),
                        ),
                        child: Slider(
                          value: sliderValue,
                          min: 0.0,
                          max: sliderMax,
                          onChanged: (value) {
                            context.read<AudioBloc>().add(
                              SeekTo(Duration(milliseconds: value.toInt())),
                            );
                          },
                        ),
                      ),
                    ),
                    Text(
                      _formatDuration(state.duration),
                      style: TextStyle(color: Colors.white54, fontSize: 10.sp),
                    ),
                  ],
                ),

                // ROW 3: Controls (Repeat, Prev, Play, Next, Speed)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Repeat Button
                    IconButton(
                      onPressed: () =>
                          context.read<AudioBloc>().add(ToggleLoopMode()),
                      icon: _buildLoopIcon(state.loopMode),
                      iconSize: 20.sp,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),

                    // Prev Button
                    IconButton(
                      onPressed: () =>
                          context.read<AudioBloc>().add(SkipToPrevious()),
                      icon: const Icon(Icons.skip_previous_rounded),
                      color: Colors.white,
                      iconSize: 28.sp,
                    ),

                    // Play/Pause Button (Center)
                    Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF00E676),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                        ),
                        color: const Color(0xFF1A2C33),
                        iconSize: 32.sp,
                        onPressed: () {
                          if (isPlaying) {
                            context.read<AudioBloc>().add(PauseAudio());
                          } else {
                            context.read<AudioBloc>().add(ResumeAudio());
                          }
                        },
                      ),
                    ),

                    // Next Button
                    IconButton(
                      onPressed: () =>
                          context.read<AudioBloc>().add(SkipToNext()),
                      icon: const Icon(Icons.skip_next_rounded),
                      color: Colors.white,
                      iconSize: 28.sp,
                    ),

                    // Speed Button
                    TextButton(
                      onPressed: () =>
                          context.read<AudioBloc>().add(CyclePlaybackSpeed()),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        "${state.playbackSpeed}x",
                        style: TextStyle(
                          color: const Color(0xFF00E676),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoopIcon(LoopMode mode) {
    switch (mode) {
      case LoopMode.off:
        return Icon(Icons.repeat_rounded, color: Colors.white24);
      case LoopMode.all:
        return Icon(Icons.repeat_rounded, color: const Color(0xFF00E676));
      case LoopMode.one:
        return Icon(Icons.repeat_one_rounded, color: const Color(0xFF00E676));
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    }
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  Widget _buildQoriInfo(BuildContext context, AudioState state) {
    return GestureDetector(
      onTap: () {
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

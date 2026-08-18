import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';

import '../bloc/audio_bloc.dart';
import '../bloc/audio_event.dart';
import '../bloc/audio_state.dart';
import '../../../../core/utils/custom_snackbar.dart';
import 'reciter_selector_bottom_sheet.dart';
import '../../../../core/presentation/widgets/premium_showcase.dart';
import 'package:muslimly/src/l10n/generated/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';

class AudioPlayerWidget extends StatelessWidget {
  final GlobalKey? qoriShowcaseKey;
  final GlobalKey? speedShowcaseKey;
  final GlobalKey? repeatShowcaseKey;
  // Legacy or drag key if needed, keeping constructor clean
  final GlobalKey? dragShowcaseKey;
  final bool isMini;
  final VoidCallback? onMaximize;
  final VoidCallback? onMinimize;

  /// Named ShowcaseView scope of the hosting page (see ShowcaseScopes).
  final String? showcaseScope;

  const AudioPlayerWidget({
    super.key,
    this.qoriShowcaseKey,
    this.speedShowcaseKey,
    this.repeatShowcaseKey,
    this.dragShowcaseKey,
    this.isMini = false,
    this.onMaximize,
    this.onMinimize,
    this.showcaseScope,
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

        // Pass context and state to builders
        if (isMini) {
          return _buildMiniPlayer(context, state);
        } else {
          return _buildFullPlayer(context, state);
        }
      },
    );
  }

  Widget _buildMiniPlayer(BuildContext context, AudioState state) {
    final isPlaying = state.status == AudioStatus.playing;

    return Material(
      color: Colors.transparent,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.cardAlt,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            _buildIcon(),
            SizedBox(width: 12.w),

            // Info (Surah Name)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    state.currentSurahName != null
                        ? "Surah ${state.currentSurahName}"
                        : "Select Surah",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    state.selectedReciter?.name ?? 'Select Reciter',
                    style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Play/Pause
            IconButton(
              icon: Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: AppColors.accent,
              ),
              onPressed: () {
                if (isPlaying) {
                  context.read<AudioBloc>().add(PauseAudio());
                } else {
                  context.read<AudioBloc>().add(ResumeAudio());
                }
              },
            ),

            // Full Mode Button
            IconButton(
              icon: Icon(
                Icons.open_in_full_rounded,
                color: Colors.white70,
                size: 20.sp,
              ),
              onPressed: onMaximize,
              tooltip: 'Full Mode',
            ),

            // Close
            IconButton(
              icon: Icon(Icons.close, color: Colors.white54, size: 20.sp),
              onPressed: () {
                context.read<AudioBloc>().add(CloseAudio());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullPlayer(BuildContext context, AudioState state) {
    final isPlaying = state.status == AudioStatus.playing;
    final position = state.position.inMilliseconds.toDouble();
    final duration = state.duration.inMilliseconds.toDouble();

    // Ensure slider value doesn't exceed max
    final sliderValue = position.clamp(0.0, duration > 0 ? duration : 0.0);
    final sliderMax = duration > 0 ? duration : 1.0;

    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: PremiumShowcase(
          globalKey: dragShowcaseKey ?? GlobalKey(),
          scope: showcaseScope,
          title: AppLocalizations.of(context)!.showcaseMiniPlayerTitle,
          description: AppLocalizations.of(context)!.showcaseMiniPlayerDesc,
          child: Container(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
            decoration: BoxDecoration(
              color: AppColors.cardAlt,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // HEADER: Minimize Button (Center Top)
                GestureDetector(
                  onTap: onMinimize,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(bottom: 8.h),
                    alignment: Alignment.center,
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                ),
                // Optional Chevron Icon for clearer "Minimize" action
                // IconButton(
                //   icon: Icon(Icons.keyboard_arrow_down, color: Colors.white54),
                //   onPressed: onMinimize,
                // ),

                // ROW 1: Header (Icon, Info, Close)
                Row(
                  children: [
                    _buildIcon(),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: PremiumShowcase(
                        globalKey: qoriShowcaseKey ?? GlobalKey(),
                        scope: showcaseScope,
                        title: AppLocalizations.of(
                          context,
                        )!.showcaseChangeQoriTitle,
                        description: AppLocalizations.of(
                          context,
                        )!.showcaseChangeQoriDesc,
                        targetShapeBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: _buildQoriInfo(context, state),
                      ),
                    ),
                    // Minimize visual button (Chevron)
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      color: Colors.white70,
                      iconSize: 28.sp,
                      onPressed: onMinimize,
                      tooltip: 'Minimize',
                    ),
                    // Close Button
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      color: Colors.white54,
                      iconSize: 24.sp,
                      onPressed: () {
                        context.read<AudioBloc>().add(CloseAudio());
                      },
                      tooltip: 'Close',
                    ),
                  ],
                ),

                SizedBox(height: 16.h),

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
                          activeTrackColor: AppColors.accent,
                          inactiveTrackColor: Colors.white10,
                          thumbColor: Colors.white,
                          overlayColor: const Color(
                            0xFF00E676,
                          ).withValues(alpha: 0.2),
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
                    PremiumShowcase(
                      globalKey: repeatShowcaseKey ?? GlobalKey(),
                      scope: showcaseScope,
                      title: AppLocalizations.of(context)!.showcaseRepeatTitle,
                      description: AppLocalizations.of(
                        context,
                      )!.showcaseRepeatDesc,
                      child: IconButton(
                        onPressed: () =>
                            context.read<AudioBloc>().add(ToggleLoopMode()),
                        icon: _buildLoopIcon(state.loopMode),
                        iconSize: 20.sp,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
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
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                        ),
                        color: AppColors.cardAlt,
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
                    PremiumShowcase(
                      globalKey: speedShowcaseKey ?? GlobalKey(),
                      scope: showcaseScope,
                      title: AppLocalizations.of(context)!.showcaseSpeedTitle,
                      description: AppLocalizations.of(
                        context,
                      )!.showcaseSpeedDesc,
                      targetShapeBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: TextButton(
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
                            color: AppColors.accent,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoopIcon(LoopMode mode) {
    IconData icon;
    Color color;

    switch (mode) {
      case LoopMode.off:
        icon = Icons.repeat;
        color = Colors.white54;
        break;
      case LoopMode.all: // Standard Repeat
        icon = Icons.repeat;
        color = AppColors.accent;
        break;
      case LoopMode.one:
        icon = Icons.repeat_one;
        color = AppColors.accent;
        break;
    }

    return Icon(icon, color: color);
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
    // Determine prefix based on context (Ayah Mode vs Surah Mode)
    final isAyahMode = state.currentAyahNumber != null;
    final prefix = isAyahMode ? "Qori Ayat: " : "";
    final reciterName = state.selectedReciter?.name ?? 'Select Reciter';

    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (context) => const ReciterSelectorBottomSheet(),
        );
      },
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$prefix$reciterName",
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
                    state.currentSurahName != null
                        ? "Surah ${state.currentSurahName}"
                        : "Select Surah",
                    style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.white54,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Icon(Icons.music_note, color: Colors.white70, size: 24.sp),
    );
  }
}

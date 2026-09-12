import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/database/database_service.dart';
import '../../../../core/di/di_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// Play/share/save controls for one hafalan session's opt-in recording
/// (HAFALAN_TRACKER_PLAN.md §F). Deliberately a standalone `just_audio`
/// `AudioPlayer` rather than reusing `AudioPlayerWidget` — that widget is
/// tightly coupled to the app's global remote-reciter `AudioBloc` (reciter
/// picker, showcase tours, no path/URL constructor param at all), not a
/// generic local-file player.
class HafalanAudioControls extends StatefulWidget {
  final int sessionId;
  final String audioFilePath;
  final bool isSaved;

  const HafalanAudioControls({
    super.key,
    required this.sessionId,
    required this.audioFilePath,
    required this.isSaved,
  });

  @override
  State<HafalanAudioControls> createState() => _HafalanAudioControlsState();
}

class _HafalanAudioControlsState extends State<HafalanAudioControls> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoading = false;
  late bool _isSaved = widget.isSaved;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _player.pause();
      if (mounted) setState(() => _isPlaying = false);
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _player.setFilePath(widget.audioFilePath);
      _player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed && mounted) {
          setState(() => _isPlaying = false);
        }
      });
      await _player.play();
      if (mounted) setState(() => _isPlaying = true);
    } catch (_) {
      // File likely missing (purged, or the app was reinstalled) — nothing
      // to play, fail silently rather than crashing the progress list.
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _share() async {
    // Resolve the localized text before the await below — context shouldn't
    // be touched after an async gap.
    final shareText = AppLocalizations.of(context)!.hafalanShareText;
    try {
      await SharePlus.instance.share(
        ShareParams(files: [XFile(widget.audioFilePath)], text: shareText),
      );
    } catch (_) {}
  }

  Future<void> _toggleSave() async {
    final newValue = !_isSaved;
    setState(() => _isSaved = newValue);
    try {
      await getIt<DatabaseService>().setHafalanAudioSaved(
        widget.sessionId,
        newValue,
      );
    } catch (_) {
      if (mounted) setState(() => _isSaved = !newValue);
    }
  }

  Widget _iconButton(
    IconData icon,
    VoidCallback? onTap, {
    Color? color,
    String? tooltip,
  }) {
    return IconButton(
      icon: Icon(icon, size: 19.sp, color: color ?? Colors.white70),
      onPressed: onTap,
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      constraints: BoxConstraints(minWidth: 30.w, minHeight: 30.w),
      visualDensity: VisualDensity.compact,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _isLoading
            ? SizedBox(
                width: 19.sp,
                height: 19.sp,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white70,
                ),
              )
            : _iconButton(
                _isPlaying
                    ? Icons.pause_circle_filled_rounded
                    : Icons.play_circle_fill_rounded,
                _togglePlay,
                tooltip: l10n.hafalanTooltipPlay,
              ),
        _iconButton(
          Icons.ios_share_rounded,
          _share,
          tooltip: l10n.hafalanTooltipShare,
        ),
        _iconButton(
          _isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
          _toggleSave,
          color: _isSaved ? AppColors.gold : null,
          tooltip: _isSaved
              ? l10n.hafalanTooltipSaved
              : l10n.hafalanTooltipSave,
        ),
      ],
    );
  }
}

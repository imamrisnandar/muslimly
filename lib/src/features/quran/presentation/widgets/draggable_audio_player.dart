import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:showcaseview/showcaseview.dart';
import '../../../../core/di/di_container.dart';
import '../../../../core/services/showcase_preferences_service.dart';
import '../bloc/audio_bloc.dart';
import '../bloc/audio_state.dart';
import 'audio_player_widget.dart';

class DraggableAudioPlayer extends StatefulWidget {
  final String? showcasePrefsKey;
  final bool enableShowcase;

  /// Named ShowcaseView scope of the hosting page (see ShowcaseScopes).
  /// Null when the host has no registered ShowcaseView (e.g. DashboardPage);
  /// showcases are then skipped.
  final String? showcaseScope;

  const DraggableAudioPlayer({
    super.key,
    this.showcasePrefsKey,
    this.enableShowcase = true,
    this.showcaseScope,
  });

  @override
  State<DraggableAudioPlayer> createState() => _DraggableAudioPlayerState();
}

class _DraggableAudioPlayerState extends State<DraggableAudioPlayer> {
  // Position state (null means default/docked)
  double? _top;
  bool _isDragging = false;

  // Showcase Keys
  final GlobalKey _dragKey = GlobalKey();
  final GlobalKey _qoriKey = GlobalKey();
  final GlobalKey _speedKey = GlobalKey();
  final GlobalKey _repeatKey = GlobalKey();

  @override
  void didUpdateWidget(DraggableAudioPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enableShowcase && !oldWidget.enableShowcase) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkShowcase();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Media Query for bounds
    final size = MediaQuery.of(context).size;

    return BlocListener<AudioBloc, AudioState>(
      listenWhen: (previous, current) =>
          !previous.isMiniPlayerVisible && current.isMiniPlayerVisible,
      listener: (context, state) {
        if (state.isMiniPlayerVisible) {
          // Default to Full Mode (Top) when player appears
          setState(() {
            _top = 50.0;
          });

          // Delay slightly to ensure widget is rendered
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) _checkShowcase();
          });
        }
      },
      child: Positioned(
        top: _top,
        left: 0,
        bottom: (_top == null) ? 0 : null, // Dock bottom if moved to null
        right: 0, // Always dock full width
        child: GestureDetector(
          onVerticalDragStart: (details) {
            setState(() {
              _isDragging = true;
              // If dragging from docked (Mini), start from bottom
              if (_top == null) {
                // Approximate start position from bottom up
                // We actually want to Switch to Full View content immediately to handle the drag?
                // Or just calculate _top based on touch?
                // For simplicity, let's snap to touch position
                final validTop = details.globalPosition.dy - 50;
                _top = validTop.clamp(50.0, size.height - 100.0);
              }
            });
          },
          onVerticalDragUpdate: (details) {
            final screenH = size.height;

            setState(() {
              // Update Top with clamping
              // Ensure we don't drag off screen or too high
              _top = (details.globalPosition.dy - 50).clamp(
                50.0,
                screenH - 80.0, // Allow dragging near bottom
              );
            });
          },
          onVerticalDragEnd: (details) {
            final screenH = size.height;
            final velocity = details.primaryVelocity ?? 0;
            final currentTop = _top ?? 0;

            setState(() {
              _isDragging = false;
              // Snap Logic:
              // Only minimize if flung down fast OR dragged near bottom (e.g. > 80% screen height)
              if (velocity > 1000 || currentTop > screenH * 0.8) {
                _top = null; // Snap to Mini/Docked
              } else {
                // Free Floating: Keep current position
                // Ensure it respects bounds (though clamp in update should handle it)
                _top = currentTop.clamp(50.0, screenH - 150.0);
              }
            });
          },
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return AnimatedContainer(
      duration: _isDragging ? Duration.zero : const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      transform: _isDragging
          ? Matrix4.diagonal3Values(1.0, 1.0, 1.0)
          : Matrix4.identity(),
      child: AudioPlayerWidget(
        showcaseScope: widget.showcaseScope,
        dragShowcaseKey: _dragKey,
        qoriShowcaseKey: _qoriKey,
        speedShowcaseKey: _speedKey,
        repeatShowcaseKey: _repeatKey,
        isMini: _top == null, // Expanded if _top is set (even if dragging)
        onMinimize: () {
          setState(() {
            _top = null; // Dock/Mini
          });
        },
        onMaximize: () {
          setState(() {
            _top = 50.0; // Full/Top
          });
        },
      ),
    );
  }

  Future<void> _checkShowcase() async {
    final showcaseService = getIt<ShowcasePreferencesService>();
    final key = widget.showcasePrefsKey ?? ShowcaseKeys.audioPlayer;
    final hasShown = await showcaseService.hasShown(key);

    // mounted must be checked before touching context: this State may have
    // been disposed while awaiting, and ModalRoute.of on a defunct element
    // crashes in release builds
    if (!mounted) return;
    if (ModalRoute.of(context)?.isCurrent != true) return;

    if (widget.enableShowcase && !hasShown && mounted && _top != null) {
      // No fallback to the current active scope: without an explicit scope
      // (e.g. mini player on DashboardPage) the showcase is skipped entirely.
      // The scope may also already be unregistered if the hosting page was
      // disposed before this delayed check ran.
      if (widget.showcaseScope == null) return;
      final ShowcaseView showcaseView;
      try {
        showcaseView = ShowcaseView.getNamed(widget.showcaseScope!);
      } catch (_) {
        return;
      }
      showcaseView.startShowCase([_dragKey, _qoriKey, _speedKey, _repeatKey]);
      await showcaseService.markShown(key);
    }
  }
}

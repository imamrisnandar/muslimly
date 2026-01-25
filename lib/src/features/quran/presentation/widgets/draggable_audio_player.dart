import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';
import '../../../../l10n/generated/app_localizations.dart';
import 'audio_player_widget.dart';

class DraggableAudioPlayer extends StatefulWidget {
  final GlobalKey? dragShowcaseKey;
  final GlobalKey? qoriShowcaseKey;

  const DraggableAudioPlayer({
    super.key,
    this.dragShowcaseKey,
    this.qoriShowcaseKey,
  });

  @override
  State<DraggableAudioPlayer> createState() => _DraggableAudioPlayerState();
}

class _DraggableAudioPlayerState extends State<DraggableAudioPlayer> {
  // Position state (null means default/docked)
  double? _top;

  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    // Media Query for bounds
    final size = MediaQuery.of(context).size;

    return Positioned(
      top: _top,
      left: 0,
      bottom: (_top == null) ? 0 : null, // Dock bottom if not moved
      right: 0, // Always dock full width
      child: GestureDetector(
        onLongPressStart: (details) {
          setState(() {
            _isDragging = true;
            // Initialization on first drag: Snap to current position
            if (_top == null) {
              final validTop = details.globalPosition.dy - 50;
              _top = validTop;
            }
          });
        },
        onLongPressMoveUpdate: (details) {
          final screenH = size.height;

          setState(() {
            // Update Top with clamping
            _top = (details.globalPosition.dy - 50).clamp(
              50.0,
              screenH - 100.0,
            );
          });
        },
        onLongPressEnd: (details) {
          setState(() {
            _isDragging = false;
          });
        },
        child: widget.dragShowcaseKey != null
            ? Showcase(
                key: widget.dragShowcaseKey!,
                description: AppLocalizations.of(
                  context,
                )!.showcaseDraggableDesc,
                child: _buildBody(),
              )
            : _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      transform: _isDragging
          ? Matrix4.diagonal3Values(1.05, 1.05, 1.0)
          : Matrix4.identity(),
      child: AudioPlayerWidget(qoriShowcaseKey: widget.qoriShowcaseKey),
    );
  }
}

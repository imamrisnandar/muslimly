import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'audio_player_widget.dart';

class DraggableAudioPlayer extends StatefulWidget {
  const DraggableAudioPlayer({super.key});

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

    // If no position set, dock to bottom (Default)
    // We use a safe default if _top/_left is null

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
              // Validating current position from context is hard in Positioned.
              // We calculate "Docked" position relative to global.

              // Assume height is approx 100?
              // Better: Use `details.globalPosition` logic
              // Center the widget on the finger?

              // Let's assume the widget is at the bottom currently.
              // RenderBox box = context.findRenderObject() as RenderBox;
              // Offset pos = box.localToGlobal(Offset.zero);

              // Simplified: Set initial top/left based on drag start
              // But we want to avoid "Jump".

              // Current Widget Geometry:
              // Width: Screen Width
              // Height: Auto (~80-100)
              // Position: Bottom of SafeArea

              final validTop =
                  details.globalPosition.dy -
                  50; // Offset to center vertically?

              _top = validTop;

              // If user wants to move it horizontally, we must shrink width?
              // "AudioPlayerWidget" has internal margins `horizontal: 16.w`.
              // It effectively fills the width.
            }
          });
        },
        onLongPressMoveUpdate: (details) {
          final screenH = size.height;

          setState(() {
            // Update Top
            _top = (details.globalPosition.dy - 50).clamp(
              50.0,
              screenH - 100.0,
            );

            // Optional: If user drags horizontally significantly, enable horizontal move?
            // For now, let's keep it simple: strict vertical move or free move?
            // "Pindah-pindah" implies 2D.
            // But full width widget looks weird moved X.
            // Let's allow X movement by shrinking width?
            // NAH, let's keep it full width (or margined) but moveable Y?
            // Or make it a "Bubble" style on dragging.

            // Let's allow moving Y freely.
            // If I set `left`, I must set `width` if I want to keep size?
            // Standard AudioPlayerWidget usage relies on constraints.
          });
        },
        onLongPressEnd: (details) {
          setState(() {
            _isDragging = false;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          transform: _isDragging
              ? Matrix4.diagonal3Values(1.05, 1.05, 1.0)
              : Matrix4.identity(),
          // Add elevation or shadow indicate drag
          child: const AudioPlayerWidget(),
        ),
      ),
    );
  }
}

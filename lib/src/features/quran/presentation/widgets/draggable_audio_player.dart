import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/audio_bloc.dart';
import '../bloc/audio_state.dart';
import 'audio_player_widget.dart';

class DraggableAudioPlayer extends StatefulWidget {
  // Keys are no longer needed, but if parent widgets still pass them during transition,
  // we can keep optional params or just remove them.
  // To be safe and compatible with current calls (even if clean), we can leave them out
  // since I cleaned the parents. But if I missed one, keeping them as unused optionals is safer
  // to avoid build errors, OR I can just remove them since I am confident I cleaned parents.
  // I cleaned parents in previous steps. I will remove them.

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

    return BlocListener<AudioBloc, AudioState>(
      listener: (context, state) {
        // No showcase logic anymore
      },
      child: Positioned(
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
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      transform: _isDragging
          ? Matrix4.diagonal3Values(1.05, 1.05, 1.0)
          : Matrix4.identity(),
      child: const AudioPlayerWidget(),
    );
  }
}

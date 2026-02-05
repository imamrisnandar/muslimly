import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import '../bloc/audio_bloc.dart';
import '../bloc/audio_state.dart';
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

  // Showcase Keys
  final GlobalKey _dragKey = GlobalKey();
  final GlobalKey _qoriKey = GlobalKey();
  final GlobalKey _speedKey = GlobalKey();
  final GlobalKey _repeatKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    // Media Query for bounds
    final size = MediaQuery.of(context).size;

    return BlocListener<AudioBloc, AudioState>(
      listenWhen: (previous, current) =>
          !previous.isMiniPlayerVisible && current.isMiniPlayerVisible,
      listener: (context, state) {
        if (state.isMiniPlayerVisible) {
          // Delay slightly to ensure widget is rendered
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) _checkShowcase();
          });
        }
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
            // No showcase trigger here anymore
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
      child: AudioPlayerWidget(
        dragShowcaseKey: _dragKey,
        qoriShowcaseKey: _qoriKey,
        speedShowcaseKey: _speedKey,
        repeatShowcaseKey: _repeatKey,
      ),
    );
  }

  Future<void> _checkShowcase() async {
    // Check SharedPreferences first
    final prefs = await SharedPreferences.getInstance();
    final hasShown = prefs.getBool('hasShownPlayerShowcase') ?? false;

    if (!hasShown && mounted) {
      // Remove height check - trigger regardless of position
      ShowCaseWidget.of(
        context,
      ).startShowCase([_dragKey, _qoriKey, _speedKey, _repeatKey]);
      await prefs.setBool('hasShownPlayerShowcase', true);
    }
  }
}

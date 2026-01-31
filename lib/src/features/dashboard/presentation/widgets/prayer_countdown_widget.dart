import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PrayerCountdownWidget extends StatefulWidget {
  final DateTime targetTime;
  final TextStyle? textStyle;
  final Color baseColor;
  final VoidCallback? onFinished;

  const PrayerCountdownWidget({
    super.key,
    required this.targetTime,
    this.textStyle,
    required this.baseColor,
    this.onFinished,
  });

  @override
  State<PrayerCountdownWidget> createState() => _PrayerCountdownWidgetState();
}

class _PrayerCountdownWidgetState extends State<PrayerCountdownWidget> {
  late Timer _timer;
  Duration _timeLeft = Duration.zero;
  bool _hasFinished = false;

  @override
  void initState() {
    super.initState();
    _calculateTimeLeft();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _calculateTimeLeft();
    });
  }

  void _calculateTimeLeft() {
    final now = DateTime.now();
    final difference = widget.targetTime.difference(now);

    if (difference.isNegative) {
      // Prayer time passed
      if (!_hasFinished) {
        _hasFinished = true;
        widget.onFinished?.call();
      }
      setState(() {
        _timeLeft = Duration.zero;
      });
    } else {
      setState(() {
        _timeLeft = difference;
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    // If hours > 0, show H:MM:SS, otherwise just MM:SS
    // Actually standardizing on HH:mm:ss for consistency is usually better for countdowns
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, color: widget.baseColor, size: 16.sp),
          SizedBox(width: 8.w),
          Text(
            "- ${_formatDuration(_timeLeft)}",
            style:
                widget.textStyle ??
                TextStyle(
                  color: widget.baseColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

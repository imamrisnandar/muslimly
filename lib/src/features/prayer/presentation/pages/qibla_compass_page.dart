import 'dart:math' as math;
import 'dart:async'; // For Timer
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Haptic Feedback
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart'; // basic geolocator to get position for calculation
import 'package:go_router/go_router.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../core/utils/qibla_util.dart'; // Import utility we just made

class QiblaCompassPage extends StatefulWidget {
  const QiblaCompassPage({super.key});

  @override
  State<QiblaCompassPage> createState() => _QiblaCompassPageState();
}

class _QiblaCompassPageState extends State<QiblaCompassPage> {
  double? _qiblaDirection;
  bool _hasPermissions = false;
  bool _isAligned = false; // To track if we are currently aligned
  Timer? _alignmentDebounceTimer;
  bool _isStableAligned = false; // True only after 0.5s stable
  DateTime? _alignmentStartTime;

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndCalculateQibla();
  }

  @override
  void dispose() {
    _alignmentDebounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkPermissionsAndCalculateQibla() async {
    // 1. Check Location Permission (handled globally usually, but verify)
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      setState(() {
        _hasPermissions = true;
      });

      // 2. Get Current Location & Calculate Qibla
      final position = await Geolocator.getCurrentPosition();
      final qibla = QiblaUtil.calculateQiblaDirection(
        position.latitude,
        position.longitude,
      );

      if (mounted) {
        setState(() {
          _qiblaDirection = qibla;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          AppLocalizations.of(context)!.qiblaCompass,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // 1. Background Gradient (Always Full Screen)
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0F2027),
                  Color(0xFF203A43),
                  Color(0xFF2C5364),
                ],
              ),
            ),
          ),
          // 2. Content
          SafeArea(
            top:
                false, // Let header content flow but handle safe area if needed
            child: SizedBox(
              width: double.infinity,
              child: _hasPermissions
                  ? StreamBuilder<CompassEvent>(
                      stream: FlutterCompass.events,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              "Error reading compass: ${snapshot.error}",
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        double? direction = snapshot.data?.heading;

                        // If device doesn't support compass
                        if (direction == null) {
                          return Center(
                            child: Text(
                              AppLocalizations.of(context)!.qiblaNoSensor,
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }

                        return _buildCompassView(context, direction);
                      },
                    )
                  : Center(
                      child: Text(
                        AppLocalizations.of(
                          context,
                        )!.locationPermissionRequired,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompassView(BuildContext context, double heading) {
    final l10n = AppLocalizations.of(context)!;

    // Calculate Deviation
    double deviation = 0;
    String statusText = "";
    Color statusColor = const Color(0xFFD4AF37); // Gold default

    if (_qiblaDirection != null) {
      // Logic: Shortest path to Qibla
      // angle = qibla - heading
      // normalize to -180..180
      deviation = (_qiblaDirection! - heading);
      while (deviation < -180) deviation += 360;
      while (deviation > 180) deviation -= 360;

      // Check Alignment (Tolerance 5 degrees - increased from 2)
      bool nowAligned = deviation.abs() < 5.0;

      if (nowAligned) {
        // Start debounce timer if just entered alignment
        if (!_isAligned) {
          _isAligned = true;
          _alignmentStartTime = DateTime.now();

          // Start timer to confirm stable alignment after 0.5s
          _alignmentDebounceTimer?.cancel();
          _alignmentDebounceTimer = Timer(
            const Duration(milliseconds: 500),
            () {
              if (mounted && _isAligned) {
                setState(() {
                  _isStableAligned = true;
                });
                HapticFeedback.mediumImpact();
              }
            },
          );
        }

        // Update status based on stability
        if (_isStableAligned) {
          statusText = l10n.qiblaFacing;
          statusColor = const Color(0xFF00E676); // Green
        } else {
          statusText = l10n.qiblaLocating;
          statusColor = const Color(0xFFFFB74D); // Orange (transitioning)
        }
      } else {
        // Exited alignment - reset everything
        if (_isAligned) {
          _alignmentDebounceTimer?.cancel();
          setState(() {
            _isAligned = false;
            _isStableAligned = false;
            _alignmentStartTime = null;
          });
        }
        // Direction Instruction
        if (deviation > 0) {
          statusText = l10n.qiblaTurnRight;
        } else {
          statusText = l10n.qiblaTurnLeft;
        }
      }
    } else {
      statusText = l10n.qiblaLocating;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Top Info with Dynamic Status
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Column(
            key: ValueKey(statusText), // Animate when text changes
            children: [
              // Add visual indicator for stable alignment
              if (_isStableAligned)
                Container(
                  margin: EdgeInsets.only(bottom: 8.h),
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E676).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: const Color(0xFF00E676),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: const Color(0xFF00E676),
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        l10n.qiblaAligned,
                        style: TextStyle(
                          color: const Color(0xFF00E676),
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 26.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 5.h),
              Text(
                _qiblaDirection != null
                    ? "${heading.toStringAsFixed(0)}°"
                    : "--°",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 40.h),

        // Compass Stack
        SizedBox(
          width: 320.w,
          height: 320.w,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 1. Rotating Dial
              Transform.rotate(
                angle: (heading * -1) * (math.pi / 180),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Dial Background
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      width: 320.w,
                      height: 320.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            statusColor.withOpacity(0.05),
                            statusColor.withOpacity(0.15),
                          ],
                        ),
                        border: Border.all(
                          color: statusColor.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withOpacity(
                              _isStableAligned ? 0.5 : 0.1,
                            ),
                            blurRadius: _isStableAligned ? 60 : 20,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: CustomPaint(
                        painter: CompassDialPainter(color: statusColor),
                      ),
                    ),

                    // Qibla Marker (Needle)
                    if (_qiblaDirection != null)
                      Transform.rotate(
                        angle: (_qiblaDirection!) * (math.pi / 180),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: EdgeInsets.only(top: 20.w),
                            child: QiblaNeedleWidget(
                              color: statusColor,
                              isAligned: _isStableAligned,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // 2. Static Center Indicator (User)
              // Actually, in this design we focus on the Qibla Needle being aligned to Top Center?
              // No, typical Compass: Needle points to Target. You rotate phone until Needle is Top.
              // So we keep the needle as child of the Rotating Dial.

              // Center Pivot
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withOpacity(0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),

              // Top Indicator (Static Triangle) indicating "Front of Phone"
              Positioned(
                top: 0,
                child: Icon(
                  Icons.arrow_drop_down,
                  color: Colors.white.withOpacity(0.8),
                  size: 50.sp,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 40.h),

        // Bottom Info
        if (_qiblaDirection == null)
          Column(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                l10n.qiblaLocating,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14.sp,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          )
        else
          // Distance or confirmation
          Text(
            _isStableAligned ? '${l10n.qiblaAligned} ✓' : l10n.qiblaAlignArrow,
            style: TextStyle(
              color: _isStableAligned
                  ? const Color(0xFF00E676)
                  : Colors.white54,
              fontSize: _isStableAligned ? 16.sp : 14.sp,
              fontWeight: _isStableAligned
                  ? FontWeight.bold
                  : FontWeight.normal,
              letterSpacing: 2.0,
            ),
          ),
      ],
    );
  }
}

class QiblaNeedleWidget extends StatelessWidget {
  final Color color;
  final bool isAligned;

  const QiblaNeedleWidget({
    super.key,
    this.color = const Color(0xFFFF5252),
    this.isAligned = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // The Arrow Head
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 36.w,
          height: 36.w,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.6),
                blurRadius: isAligned ? 20 : 10,
                spreadRadius: 2,
              ),
            ],
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Icon(
            Icons.navigation_rounded,
            color: Colors.white,
            size: 24.sp,
          ),
        ),
      ],
    );
  }
}

class CompassDialPainter extends CustomPainter {
  final Color color;

  CompassDialPainter({this.color = Colors.white});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paintTick = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    // Draw Ticks
    for (int i = 0; i < 360; i += 5) {
      final isMajor = i % 90 == 0;
      final isMinor = i % 30 == 0;
      final angle = (i - 90) * math.pi / 180; // -90 to start at Top

      final outerRadius = radius - 20; // padding
      final innerRadius = isMajor
          ? outerRadius - 15
          : (isMinor ? outerRadius - 10 : outerRadius - 5);

      if (isMajor || isMinor) {
        paintTick.color = isMajor ? color : color.withOpacity(0.4);
        paintTick.strokeWidth = isMajor ? 3 : (isMinor ? 2 : 1);

        final p1 = Offset(
          center.dx + math.cos(angle) * innerRadius,
          center.dy + math.sin(angle) * innerRadius,
        );
        final p2 = Offset(
          center.dx + math.cos(angle) * outerRadius,
          center.dy + math.sin(angle) * outerRadius,
        );
        canvas.drawLine(p1, p2, paintTick);
      }
    }

    // Draw NESW Labels
    final labels = ['N', 'E', 'S', 'W'];
    for (int i = 0; i < 4; i++) {
      final angle = (i * 90 - 90) * math.pi / 180;
      final labelRadius = radius - 55;

      textPainter.text = TextSpan(
        text: labels[i],
        style: TextStyle(
          color: i == 0 ? color : Colors.white70, // N matches theme
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();

      final x =
          center.dx + math.cos(angle) * labelRadius - textPainter.width / 2;
      final y =
          center.dy + math.sin(angle) * labelRadius - textPainter.height / 2;

      textPainter.paint(canvas, Offset(x, y));
    }
  }

  @override
  bool shouldRepaint(covariant CompassDialPainter oldDelegate) =>
      color != oldDelegate.color;
}

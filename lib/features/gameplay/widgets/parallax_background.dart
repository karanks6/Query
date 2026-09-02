import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../../../theming/tokens/sci_fi_tokens.dart';

/// Layered parallax background (Section 3.1 & 6.1).
/// 
/// Uses gyroscope events to shift layers opposite to tilt.
class ParallaxBackground extends StatefulWidget {
  final Widget child;

  const ParallaxBackground({super.key, required this.child});

  @override
  State<ParallaxBackground> createState() => _ParallaxBackgroundState();
}

class _ParallaxBackgroundState extends State<ParallaxBackground> with SingleTickerProviderStateMixin {
  StreamSubscription? _gyroSubscription;
  double _pitch = 0.0; // Y axis rotation
  double _roll = 0.0;  // X axis rotation

  // Animated values for smooth damping
  late AnimationController _animController;
  double _currentPitch = 0.0;
  double _currentRoll = 0.0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // Runs continuously
    )..addListener(() {
      // Lerp current towards target (damped motion)
      setState(() {
        _currentPitch += (_pitch - _currentPitch) * 0.1;
        _currentRoll += (_roll - _currentRoll) * 0.1;
      });
    });
    _animController.repeat();

    // Listen to gyro if available
    try {
      _gyroSubscription = gyroscopeEventStream().listen((GyroscopeEvent event) {
        // Integrate gyro velocity to get approximate relative angle
        _pitch += event.x * 0.02; // Adjust multiplier for sensitivity
        _roll += event.y * 0.02;

        // Cap the max tilt (Section 3.2: "capping matters more than the effect itself")
        _pitch = _pitch.clamp(-0.2, 0.2);
        _roll = _roll.clamp(-0.2, 0.2);
      });
    } catch (e) {
      // Sensors not available (e.g. desktop), fallback to 0
    }
  }

  @override
  void dispose() {
    _gyroSubscription?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Layer 0 - Deep background (2-4% counter offset)
        Transform.translate(
          offset: Offset(_currentRoll * -20, _currentPitch * -20),
          child: Container(
            decoration: BoxDecoration(
              color: SciFiTokens.background,
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  SciFiTokens.surfaceHighlight.withValues(alpha: 0.3),
                  SciFiTokens.background,
                ],
              ),
            ),
          ),
        ),

        // Layer 1 - Mid background trace pattern (8-12% counter offset)
        Transform.translate(
          offset: Offset(_currentRoll * -60, _currentPitch * -60),
          child: Opacity(
            opacity: 0.5,
            child: CustomPaint(
              painter: _CircuitTracePainter(color: SciFiTokens.accentDim),
              size: Size.infinite,
            ),
          ),
        ),

        // The foreground UI
        widget.child,
      ],
    );
  }
}

class _CircuitTracePainter extends CustomPainter {
  final Color color;

  _CircuitTracePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Draw some stylized circuit lines
    final path = Path();
    path.moveTo(0, size.height * 0.2);
    path.lineTo(size.width * 0.3, size.height * 0.2);
    path.lineTo(size.width * 0.4, size.height * 0.3);
    path.lineTo(size.width, size.height * 0.3);

    path.moveTo(size.width * 0.8, 0);
    path.lineTo(size.width * 0.8, size.height * 0.5);
    path.lineTo(size.width * 0.9, size.height * 0.6);
    path.lineTo(size.width * 0.9, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

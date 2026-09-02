import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../tokens/sci_fi_tokens.dart';
import '../utils/motion_curves.dart';
import 'holo_panel.dart';

/// HoloButton Material (Section 5.1).
/// 
/// Implements the Anticipation-Action-Reaction micro-interaction.
class HoloButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isPrimary; // Hero emissive element (1.0 vs 0.5 budget)

  const HoloButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isPrimary = false,
  });

  @override
  State<HoloButton> createState() => _HoloButtonState();
}

class _HoloButtonState extends State<HoloButton> with TickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;
  
  late AnimationController _burstController;
  
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    // Press interaction (Anticipation -> Scale -> Return)
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      reverseDuration: const Duration(milliseconds: 250),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(
        parent: _pressController,
        curve: MotionCurves.anticipation,
        reverseCurve: MotionCurves.easeOutBack,
      ),
    );

    _burstController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    _burstController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed == null) return;
    _pressController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed == null) return;
    HapticFeedback.lightImpact();
    _burstController.forward(from: 0.0);
    _pressController.reverse();
    widget.onPressed?.call();
  }

  void _handleTapCancel() {
    if (widget.onPressed == null) return;
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null;
    final baseEmission = widget.isPrimary ? 1.0 : 0.5;
    final currentEmission = isDisabled ? 0.0 : (_isHovered ? 1.0 : baseEmission);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: isDisabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // The main button surface
              HoloPanel(
                emissionIntensity: currentEmission,
                colorOverride: isDisabled ? SciFiTokens.surface.withValues(alpha: 0.2) : null,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: DefaultTextStyle(
                  style: SciFiTokens.labelLarge.copyWith(
                    color: isDisabled ? SciFiTokens.disabledText : SciFiTokens.accent,
                  ),
                  child: widget.child,
                ),
              ),
              
              // Particle burst overlay
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _burstController,
                    builder: (context, child) {
                      if (!_burstController.isAnimating) return const SizedBox.shrink();
                      return CustomPaint(
                        painter: _ParticleBurstPainter(
                          progress: _burstController.value,
                          color: SciFiTokens.accent,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ParticleBurstPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final Color color;

  _ParticleBurstPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0 || progress == 1) return;

    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color.withValues(alpha: 1.0 - progress)
      ..style = PaintingStyle.fill;

    // Expand outward based on progress
    final maxRadius = math.max(size.width, size.height) * 0.8;
    final currentDistance = maxRadius * Curves.easeOutQuad.transform(progress);

    final numParticles = 8;
    for (int i = 0; i < numParticles; i++) {
      final angle = (i * 2 * math.pi) / numParticles;
      final x = center.dx + math.cos(angle) * currentDistance;
      final y = center.dy + math.sin(angle) * currentDistance;
      
      // Particles shrink as they travel
      final pSize = 3.0 * (1.0 - progress);
      canvas.drawCircle(Offset(x, y), pSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticleBurstPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

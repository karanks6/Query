import 'dart:ui';
import 'package:flutter/material.dart';
import '../tokens/game_tokens.dart';

class SlantedClipper extends CustomClipper<Path> {
  final double clipSize;
  SlantedClipper({this.clipSize = 12.0});

  @override
  Path getClip(Size size) {
    final path = Path();
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(clipSize),
    ));
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class SlantedBorderPainter extends CustomPainter {
  final double clipSize;
  final Color borderColor;
  final double strokeWidth;

  SlantedBorderPainter({
    this.clipSize = 12.0,
    required this.borderColor,
    this.strokeWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final path = Path();
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(clipSize),
    ));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// A stylized rounded panel with a frosted glass effect matching the earthy organic theme.
class SlantedPanel extends StatelessWidget {
  final Widget child;
  final Color? colorOverride;
  final Color? borderColorOverride;
  final EdgeInsetsGeometry? padding;
  final double clipSize;

  const SlantedPanel({
    super.key,
    required this.child,
    this.colorOverride,
    this.borderColorOverride,
    this.padding,
    this.clipSize = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = colorOverride ?? GameTokens.surface.withValues(alpha: 0.7);
    final borderColor = borderColorOverride ?? GameTokens.surfaceVariant;

    return CustomPaint(
      painter: SlantedBorderPainter(
        clipSize: clipSize,
        borderColor: borderColor,
        strokeWidth: 2.0,
      ),
      child: ClipPath(
        clipper: SlantedClipper(clipSize: clipSize),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            color: baseColor,
            padding: padding ?? const EdgeInsets.all(GameTokens.spaceMd),
            child: child,
          ),
        ),
      ),
    );
  }
}

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:google_fonts/google_fonts.dart';

class IconButtonComponent extends PositionComponent with TapCallbacks {
  final String label;
  final VoidCallback onTap;
  final Color primaryColor;

  late final RectangleComponent _bg;

  IconButtonComponent({
    required this.label,
    required this.onTap,
    this.primaryColor = const Color(0xFFFFB800), // Warning Amber by default
    super.position,
    super.size,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Dark background fill
    _bg = RectangleComponent(
      size: size,
      paint: Paint()
        ..color = const Color(0xFF121820)
        ..style = PaintingStyle.fill,
    );
    add(_bg);

    // Accent border
    add(RectangleComponent(
      size: size,
      paint: Paint()
        ..color = primaryColor.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    ));

    // Label text
    add(TextComponent(
      text: label,
      textRenderer: TextPaint(
        style: GoogleFonts.rajdhani(
          color: primaryColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
      position: Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
    ));
  }

  @override
  void onTapDown(TapDownEvent event) {
    _bg.paint = Paint()
      ..color = primaryColor.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    scale = Vector2.all(0.92);
  }

  @override
  void onTapUp(TapUpEvent event) {
    _bg.paint = Paint()
      ..color = const Color(0xFF121820)
      ..style = PaintingStyle.fill;
    scale = Vector2.all(1.0);
    onTap();
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    _bg.paint = Paint()
      ..color = const Color(0xFF121820)
      ..style = PaintingStyle.fill;
    scale = Vector2.all(1.0);
  }
}

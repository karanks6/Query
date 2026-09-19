import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class HudBarComponent extends PositionComponent {
  final String title;
  final int xp;
  final int streak;
  
  late final TextComponent _titleText;
  late final TextComponent _statsText;

  HudBarComponent({
    required this.title,
    this.xp = 0,
    this.streak = 0,
    super.size,
  });

  @override
  Future<void> onLoad() async {
    _titleText = TextComponent(
      text: title,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w900,
          fontSize: 20,
        ),
      ),
      position: Vector2(16, 16),
    );
    
    _statsText = TextComponent(
      text: 'XP: $xp   STREAK: $streak',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFFFCC00),
          fontFamily: 'JetBrainsMono',
          fontSize: 16,
        ),
      ),
      position: Vector2(size.x - 16, 16),
      anchor: Anchor.topRight,
    );

    add(_titleText);
    add(_statsText);
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    size = Vector2(gameSize.x, 60);
    if (isMounted) {
      _statsText.position = Vector2(size.x - 16, 16);
    }
  }

  @override
  void render(Canvas canvas) {
    // Draw top dark bar
    final paint = Paint()..color = const Color(0xFF111218);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), paint);
    
    // Draw bottom border line
    final borderPaint = Paint()
      ..color = const Color(0x33FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(0, size.y), Offset(size.x, size.y), borderPaint);
  }
}

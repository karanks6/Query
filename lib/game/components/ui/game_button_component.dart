import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class GameButtonComponent extends PositionComponent with TapCallbacks {
  final String title;
  final String subtitle;
  final VoidCallback onPressed;
  
  late final TextComponent _titleComponent;
  late final TextComponent _subtitleComponent;
  late final RectangleComponent _bgComponent;

  GameButtonComponent({
    required this.title,
    this.subtitle = '',
    required this.onPressed,
    Vector2? position,
    Vector2? size,
  }) : super(position: position, size: size ?? Vector2(340, 70));

  @override
  Future<void> onLoad() async {
    _bgComponent = RectangleComponent(
      size: size,
      paint: Paint()
        ..color = const Color(0xFF1E212A)
        ..style = PaintingStyle.fill,
    );
    
    // Add a border
    final border = RectangleComponent(
      size: size,
      paint: Paint()
        ..color = const Color(0xFF00E5FF).withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    _titleComponent = TextComponent(
      text: title,
      position: Vector2(20, 15),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFF00E5FF),
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
          fontFamily: 'Courier',
        ),
      ),
    );

    _subtitleComponent = TextComponent(
      text: subtitle,
      position: Vector2(20, 40),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFF8B92A5),
          fontSize: 12,
          fontFamily: 'Courier',
        ),
      ),
    );

    add(_bgComponent);
    add(border);
    add(_titleComponent);
    if (subtitle.isNotEmpty) {
      add(_subtitleComponent);
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    _bgComponent.paint.color = const Color(0xFF00E5FF).withOpacity(0.2);
    scale = Vector2.all(0.95);
  }

  @override
  void onTapUp(TapUpEvent event) {
    _bgComponent.paint.color = const Color(0xFF1E212A);
    scale = Vector2.all(1.0);
    onPressed();
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    _bgComponent.paint.color = const Color(0xFF1E212A);
    scale = Vector2.all(1.0);
  }
}

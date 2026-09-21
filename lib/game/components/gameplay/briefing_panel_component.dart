import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../../data/content/models/level_model.dart';

class BriefingPanelComponent extends PositionComponent {
  final LevelModel level;
  
  BriefingPanelComponent({
    required this.level,
    super.position,
    super.size,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Background
    add(RectangleComponent(
      size: size,
      paint: Paint()
        ..color = const Color(0xFF15171E).withValues(alpha: 0.9)
        ..style = PaintingStyle.fill,
    ));
    
    // Border
    add(RectangleComponent(
      size: size,
      paint: Paint()
        ..color = const Color(0xFF00FF9D).withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    ));

    // "TARGET" header
    add(TextComponent(
      text: 'TARGET',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFF00FF9D),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0,
        ),
      ),
      position: Vector2(10, 10),
    ));

    // Narrative text
    add(TextBoxComponent(
      text: level.narrative,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
          height: 1.4,
        ),
      ),
      boxConfig: TextBoxConfig(
        maxWidth: size.x - 20,
        timePerChar: 0.02, // Typewriter effect
      ),
      position: Vector2(10, 35),
    ));
  }
}

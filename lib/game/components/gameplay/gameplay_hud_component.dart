import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:google_fonts/google_fonts.dart';
import '../../../../data/content/models/level_model.dart';
import '../../../../features/gameplay/gameplay_provider.dart';
import '../ui/cyber_button.dart'; // Maybe use this for back button

class GameplayHudComponent extends PositionComponent with TapCallbacks {
  final LevelModel level;
  final GameplayState state;
  final VoidCallback onBackTap;
  
  late final TextComponent _levelText;
  
  GameplayHudComponent({
    required this.level,
    required this.state,
    required this.onBackTap,
    super.size,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Background: Dark slightly transparent overlay with a glowing bottom border
    final bgPaint = Paint()
      ..color = const Color(0xFF0B0C10).withValues(alpha: 0.95);
    add(RectangleComponent(
      size: Vector2(size.x, 60),
      paint: bgPaint,
    ));
    
    // Bottom glowing border
    add(RectangleComponent(
      position: Vector2(0, 59),
      size: Vector2(size.x, 2),
      paint: Paint()
        ..color = const Color(0xFF00F0FF)
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 4),
    ));
    add(RectangleComponent(
      position: Vector2(0, 59),
      size: Vector2(size.x, 1),
      paint: Paint()..color = const Color(0xFF00F0FF),
    ));
    
    _levelText = TextComponent(
      text: level.title.toUpperCase(),
      textRenderer: TextPaint(
        style: GoogleFonts.orbitron(
          color: const Color(0xFFE0E6ED),
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0,
        ),
      ),
      position: Vector2(80, 18),
    );
    add(_levelText);
    
    // Back button
    final backBtn = RectangleComponent(
      size: Vector2(60, 40),
      position: Vector2(10, 10),
      paint: Paint()..color = Colors.transparent,
    );
    backBtn.add(TextComponent(
      text: '< ABORT',
      textRenderer: TextPaint(
        style: GoogleFonts.rajdhani(
          color: const Color(0xFFFF0055),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(5, 10),
    ));
    add(backBtn);
  }
  
  @override
  // ignore: avoid_renaming_method_parameters
  void onGameResize(Vector2 s) {
    super.onGameResize(s);
    size = Vector2(s.x, 60);
    // update background widths if needed
    for (final child in children) {
      if (child is RectangleComponent && child.size.x != 60) {
        child.size = Vector2(s.x, child.size.y);
      }
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    // Check if back button tapped
    if (event.localPosition.x < 80 && event.localPosition.y < 60) {
      onBackTap();
    }
  }
}

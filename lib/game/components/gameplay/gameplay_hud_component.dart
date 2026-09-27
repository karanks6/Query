import 'package:flame/components.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:google_fonts/google_fonts.dart';
import '../../../../data/content/models/level_model.dart';
import '../../../../features/gameplay/gameplay_provider.dart';
import '../ui/wood_button.dart';

class GameplayHudComponent extends PositionComponent {
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
    
    // safe area top padding
    final safeAreaTop = 40.0;
    
    // Background: Wooden plank header
    final bgPaint = Paint()
      ..color = const Color(0xFF3D2817); // wood-800
    add(RectangleComponent(
      size: Vector2(size.x, 60 + safeAreaTop),
      paint: bgPaint,
    ));
    
    // Bottom border (lighter wood trim)
    add(RectangleComponent(
      position: Vector2(0, 58 + safeAreaTop),
      size: Vector2(size.x, 2),
      paint: Paint()..color = const Color(0xFF5C3D2E),
    ));
    
    _levelText = TextComponent(
      text: level.title.toUpperCase(),
      textRenderer: TextPaint(
        style: GoogleFonts.nunitoSans(
          color: const Color(0xFFF9F5EA),
          fontSize: 18,
          fontWeight: FontWeight.w900,
          letterSpacing: 2.0,
        ),
      ),
      position: Vector2(100, 18 + safeAreaTop),
    );
    add(_levelText);
    
    // Back button - explicit component for reliable hit testing
    final backBtn = WoodButton(
      text: '< BACK',
      size: Vector2(80, 40),
      position: Vector2(10, 10 + safeAreaTop),
      primaryColor: const Color(0xFF7A6B5D),
      onPressed: onBackTap,
    );
    add(backBtn);
  }
  
  @override
  // ignore: avoid_renaming_method_parameters
  void onGameResize(Vector2 s) {
    super.onGameResize(s);
    size = Vector2(s.x, 60 + 40.0);
    // update background widths
    for (final child in children) {
      if (child is RectangleComponent && child.paint.color == const Color(0xFF3D2817)) {
        child.size = Vector2(s.x, 60 + 40.0);
      }
      if (child is RectangleComponent && child.paint.color == const Color(0xFF5C3D2E)) {
        child.size = Vector2(s.x, 2);
      }
    }
  }
}


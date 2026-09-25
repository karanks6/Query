import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../../../../data/content/models/level_model.dart';
import '../../../../features/gameplay/gameplay_provider.dart';

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
    
    // Background
    add(RectangleComponent(
      size: Vector2(size.x, 60),
      paint: Paint()..color = const Color(0xFF15171E),
    ));
    
    // Bottom border
    add(RectangleComponent(
      position: Vector2(0, 59),
      size: Vector2(size.x, 1),
      paint: Paint()..color = const Color(0xFF333333),
    ));
    
    _levelText = TextComponent(
      text: level.title,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(60, 20),
    );
    add(_levelText);
    
    // Back button hit area
    final backBtn = RectangleComponent(
      size: Vector2(40, 40),
      position: Vector2(10, 10),
      paint: Paint()..color = Colors.transparent,
    );
    backBtn.add(TextComponent(
      text: '←',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFFFCC00),
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(8, 4),
    ));
    add(backBtn);
  }
  
  @override
  // ignore: avoid_renaming_method_parameters
  void onGameResize(Vector2 s) {
    super.onGameResize(s);
    size = Vector2(s.x, 60);
  }

  @override
  void onTapDown(TapDownEvent event) {
    // Check if back button tapped
    if (event.localPosition.x < 50) {
      onBackTap();
    }
  }
}

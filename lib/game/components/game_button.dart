import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'game_panel.dart';

class GameButtonComponent extends PositionComponent with TapCallbacks {
  final String text;
  final VoidCallback? onPressed;
  late final TextComponent _textComponent;
  late final GamePanelComponent _panel;

  GameButtonComponent({
    required this.text,
    this.onPressed,
    super.position,
    Vector2? size,
  }) : super(size: size ?? Vector2(200, 50));

  @override
  Future<void> onLoad() async {
    anchor = Anchor.center;
    
    _panel = GamePanelComponent(
      backgroundColor: const Color(0xFF2A2E3D),
      borderColor: const Color(0xFFFFCC00),
      size: size,
    );
    
    _textComponent = TextComponent(
      text: text,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFFFCC00),
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w900,
          fontSize: 16,
        ),
      ),
      anchor: Anchor.center,
      position: size / 2,
    );

    add(_panel);
    add(_textComponent);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (onPressed != null) {
      add(ScaleEffect.to(Vector2.all(0.95), EffectController(duration: 0.1)));
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (onPressed != null) {
      add(ScaleEffect.to(Vector2.all(1.0), EffectController(duration: 0.1)));
      onPressed!();
    }
  }
  
  @override
  void onTapCancel(TapCancelEvent event) {
    if (onPressed != null) {
      add(ScaleEffect.to(Vector2.all(1.0), EffectController(duration: 0.1)));
    }
  }
}

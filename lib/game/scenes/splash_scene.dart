import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:google_fonts/google_fonts.dart';

import 'query_scene.dart';
import '../components/glitch_overlay.dart';
import 'dashboard_scene.dart';

class SplashScene extends QueryScene with TapCallbacks {
  late GlitchOverlayComponent glitchOverlay;
  
  late TextComponent _terminalText;
  late TextComponent _logoText;
  late TextComponent _tapToContinue;
  
  double _timeElapsed = 0;
  bool _isLogoRevealed = false;
  
  final String _targetText = "> initializing QUERY protocol...\n> establishing secure connection...\n> ACCESS GRANTED.";
  int _charCount = 0;

  @override
  Future<void> onLoad() async {
    glitchOverlay = GlitchOverlayComponent();
    
    _terminalText = TextComponent(
      text: "",
      position: Vector2(40, 40),
      textRenderer: TextPaint(
        style: GoogleFonts.firaCode(
          color: const Color(0xFF00FF66),
          fontSize: 16,
        ),
      ),
    );
    
    _logoText = TextComponent(
      text: "QUERY",
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: GoogleFonts.orbitron(
          color: const Color(0xFF00F0FF),
          fontSize: 80,
          fontWeight: FontWeight.bold,
          letterSpacing: 10,
          shadows: [
            const Shadow(
              color: Color(0xFF00F0FF),
              blurRadius: 20,
            )
          ]
        ),
      ),
    );
    _logoText.text = ""; // Invisible initially

    _tapToContinue = TextComponent(
      text: "TAP TO CONTINUE",
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: GoogleFonts.rajdhani(
          color: const Color(0xFFE0E6ED),
          fontSize: 20,
          letterSpacing: 4,
        ),
      ),
    );
    _tapToContinue.text = "";

    add(_terminalText);
    add(_logoText);
    add(_tapToContinue);
    add(glitchOverlay); // Must be added last to overlay everything
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _logoText.position = size / 2;
    _tapToContinue.position = Vector2(size.x / 2, size.y / 2 + 100);
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    _timeElapsed += dt;
    
    // Typewriter effect
    if (!_isLogoRevealed) {
      int desiredChars = (_timeElapsed * 20).floor(); // 20 chars per second
      if (desiredChars > _targetText.length) {
        desiredChars = _targetText.length;
      }
      if (desiredChars > _charCount) {
        _charCount = desiredChars;
        _terminalText.text = _targetText.substring(0, _charCount) + (_charCount % 2 == 0 ? "_" : "");
      }
      
      // After text finishes typing, trigger glitch and reveal logo
      if (_charCount == _targetText.length && _timeElapsed > (_targetText.length / 20) + 0.5) {
        _isLogoRevealed = true;
        glitchOverlay.trigger(0.5);
        _terminalText.text = ""; // Hide terminal text
        _logoText.text = "QUERY"; // Show logo
      }
    } else {
      // Blinking tap to continue
      _tapToContinue.text = (_timeElapsed * 2).floor() % 2 == 0 ? "TAP TO CONTINUE" : "";
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (_isLogoRevealed) {
      game.pushScene(DashboardScene());
    } else {
      // Skip typing
      _timeElapsed = (_targetText.length / 20) + 0.5;
    }
  }
}

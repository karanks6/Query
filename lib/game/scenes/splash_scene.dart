import 'dart:ui';
import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:google_fonts/google_fonts.dart';

import 'query_scene.dart';
import 'dashboard_scene.dart';


class SplashScene extends QueryScene with TapCallbacks {
  late TextComponent _logoText;
  late TextComponent _subtitleText;
  late TextComponent _tapToContinue;
  
  double _timeElapsed = 0;
  bool _isLogoRevealed = false;
  
  final Color _logoBaseColor = const Color(0xFFEFE6D5);
  final Color _subtitleBaseColor = const Color(0xFFE59B28);
  final Color _tapBaseColor = const Color(0xFFF9F5EA);

  @override
  bool containsLocalPoint(Vector2 point) => true; // Essential to receive taps on this Component!

  @override
  Future<void> onLoad() async {
    _logoText = TextComponent(
      text: "QUERY", // App name
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: GoogleFonts.nunitoSans(
          color: _logoBaseColor.withValues(alpha: 0.0), // Parchment
          fontSize: 80,
          fontWeight: FontWeight.w900,
          letterSpacing: 10,
          shadows: [
            const Shadow(
              color: Color(0x80000000),
              offset: Offset(0, 4),
              blurRadius: 8,
            )
          ]
        ),
      ),
    );

    _subtitleText = TextComponent(
      text: "TALES OF THE WILD",
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: GoogleFonts.quicksand(
          color: _subtitleBaseColor.withValues(alpha: 0.0), // Amber Gold
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 8,
          shadows: [
            const Shadow(
              color: Color(0x80000000),
              offset: Offset(0, 2),
              blurRadius: 4,
            )
          ]
        ),
      ),
    );

    _tapToContinue = TextComponent(
      text: "- TAP TO EXPLORE -",
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: GoogleFonts.quicksand(
          color: _tapBaseColor.withValues(alpha: 0.0),
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
    );

    add(_logoText);
    add(_subtitleText);
    add(_tapToContinue);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _logoText.position = Vector2(size.x / 2, size.y / 2 - 20);
    _subtitleText.position = Vector2(size.x / 2, size.y / 2 + 40);
    _tapToContinue.position = Vector2(size.x / 2, size.y / 2 + 120);
  }

  void _updateOpacity(TextComponent comp, Color baseColor, double opacity) {
    if (comp.textRenderer is TextPaint) {
      final style = (comp.textRenderer as TextPaint).style;
      comp.textRenderer = TextPaint(
        style: style.copyWith(
          color: baseColor.withValues(alpha: opacity),
        ),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    _timeElapsed += dt;
    
    // Smooth fade-in animation
    if (!_isLogoRevealed) {
      if (_timeElapsed < 2.0) {
        double opacity = (_timeElapsed / 2.0).clamp(0.0, 1.0);
        _updateOpacity(_logoText, _logoBaseColor, opacity);
        _updateOpacity(_subtitleText, _subtitleBaseColor, opacity);
      } else {
        _isLogoRevealed = true;
      }
    } else {
      // Gentle pulsing tap to continue
      double pulse = (1.0 + math.sin(1.0 * _timeElapsed * 2.0)) / 2.0; 
      _updateOpacity(_tapToContinue, _tapBaseColor, 0.4 + 0.6 * pulse);
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (_isLogoRevealed) {
      game.replaceScene(DashboardScene());
    } else {
      // Skip fade-in
      _timeElapsed = 2.0;
    }
  }
}

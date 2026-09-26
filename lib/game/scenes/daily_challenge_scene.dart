import 'package:flame/components.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:google_fonts/google_fonts.dart';

import 'query_scene.dart';
import '../components/ui/cyber_button.dart';
import '../components/ui/holo_panel.dart';
import '../components/hex_grid_background.dart';

class DailyChallengeScene extends QueryScene {
  @override
  Future<void> onLoad() async {
    add(HexGridBackground(hexColor: const Color(0xFF00FF66)));

    final title = TextComponent(
      text: 'DAILY CYPHER',
      position: Vector2(60, 60),
      textRenderer: TextPaint(
        style: GoogleFonts.orbitron(
          color: const Color(0xFF00FF66),
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: 4,
          shadows: [
            const Shadow(
              color: Color(0xFF00FF66),
              blurRadius: 10,
            )
          ]
        ),
      ),
    );
    add(title);

    final backBtn = CyberButton(
      text: '< BACK',
      size: Vector2(150, 40),
      position: Vector2(60, 120),
      primaryColor: const Color(0xFF6B7A8F),
      onPressed: () {
        game.popScene();
      },
    );
    add(backBtn);

    final challengePanel = HoloPanelComponent(
      position: Vector2(60, 200),
      size: Vector2(500, 250),
      borderColor: const Color(0xFF00FF66),
    );
    add(challengePanel);

    final challengeTitle = TextComponent(
      text: 'SECURITY AUDIT',
      position: Vector2(80, 220),
      textRenderer: TextPaint(
        style: GoogleFonts.rajdhani(
          color: const Color(0xFFE0E6ED),
          fontSize: 28,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
    );
    add(challengeTitle);
    
    final desc = TextComponent(
      text: 'We need to check who had failed login\nattempts recently. Trace the logs in the\nauth_records table.',
      position: Vector2(80, 270),
      textRenderer: TextPaint(
        style: GoogleFonts.firaCode(
          color: const Color(0xFF8B92A5),
          fontSize: 16,
          height: 1.5,
        ),
      ),
    );
    add(desc);

    final startBtn = CyberButton(
      text: 'INITIATE HACK',
      position: Vector2(80, 360),
      size: Vector2(250, 60),
      primaryColor: const Color(0xFF00FF66),
      onPressed: () {
        // Placeholder for daily challenge push
      },
    );
    add(startBtn);
  }

  @override
  List<String> get activeOverlays => [];
}

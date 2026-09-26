import 'package:flame/components.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:google_fonts/google_fonts.dart';

import 'query_scene.dart';
import 'world_select_scene.dart';
import 'daily_challenge_scene.dart';
import '../components/persistent_hud.dart';
import '../components/ui/cyber_button.dart';
import '../components/ui/holo_panel.dart';
import '../components/hex_grid_background.dart';

class DashboardScene extends QueryScene {
  late PersistentHudComponent hud;

  @override
  Future<void> onLoad() async {
    // Add hex grid background
    add(HexGridBackground());
    
    hud = PersistentHudComponent();
    add(hud);

    final title = TextComponent(
      text: 'QUERY BUREAU',
      position: Vector2(60, 100),
      textRenderer: TextPaint(
        style: GoogleFonts.orbitron(
          color: const Color(0xFF00F0FF),
          fontSize: 48,
          fontWeight: FontWeight.bold,
          letterSpacing: 6,
          shadows: [
            const Shadow(
              color: Color(0xFF00F0FF),
              blurRadius: 10,
            )
          ]
        ),
      ),
    );
    add(title);

    final continueBtn = CyberButton(
      text: 'CONTINUE MISSION',
      secondaryText: 'The Archive Vaults - W4',
      position: Vector2(60, 200),
      onPressed: () {
        // Go to World 4 Level Map
        // For now, we will just open LevelMapScene manually later
      },
    );
    add(continueBtn);

    final dailyBtn = CyberButton(
      text: 'DAILY CHALLENGE',
      secondaryText: 'A new case every day. +2x XP.',
      position: Vector2(60, 280),
      primaryColor: const Color(0xFF00FF66),
      onPressed: () {
        game.pushScene(DailyChallengeScene());
      },
    );
    add(dailyBtn);

    final worldMapBtn = CyberButton(
      text: 'WORLD MAP',
      secondaryText: 'Access the global case map',
      position: Vector2(60, 360),
      primaryColor: const Color(0xFFFF0055),
      onPressed: () {
        game.pushScene(WorldSelectScene());
      },
    );
    add(worldMapBtn);

    // Decorative HoloPanel on the right side for "Agent Stats"
    final statsPanel = HoloPanelComponent(
      position: Vector2(400, 200),
      size: Vector2(300, 220),
    );
    add(statsPanel);

    final statsTitle = TextComponent(
      text: 'AGENT STATS',
      position: Vector2(420, 220),
      textRenderer: TextPaint(
        style: GoogleFonts.rajdhani(
          color: const Color(0xFF00F0FF),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(statsTitle);

    final statsContent = TextComponent(
      text: 'Rank: Analyst II\nCases Solved: 42\nSyntax Errors: 12\nEfficiency: 94%',
      position: Vector2(420, 260),
      textRenderer: TextPaint(
        style: GoogleFonts.firaCode(
          color: const Color(0xFFE0E6ED),
          fontSize: 16,
          height: 1.5,
        ),
      ),
    );
    add(statsContent);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    
    // We can position the stats panel dynamically based on screen width
    // But for a simple prototype, fixed coords are fine unless window is too small.
    // For safety, let's keep it anchored right if width allows.
    final panelX = size.x > 800 ? size.x - 360 : 400.0;
    
    for (final child in children) {
      if (child is HoloPanelComponent) {
        child.position = Vector2(panelX, 200);
      }
      if (child is TextComponent && child.text == 'AGENT STATS') {
        child.position = Vector2(panelX + 20, 220);
      }
      if (child is TextComponent && child.text.startsWith('Rank:')) {
        child.position = Vector2(panelX + 20, 260);
      }
    }
  }

  @override
  List<String> get activeOverlays => [];
}

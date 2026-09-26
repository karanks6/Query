import 'package:flame/components.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:google_fonts/google_fonts.dart';
import '../../../../data/content/models/level_model.dart';
import '../ui/holo_panel.dart';

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
    
    // Background using HoloPanel
    final panel = HoloPanelComponent(
      size: size,
      borderColor: const Color(0xFF00FF66),
    );
    add(panel);

    // "TARGET" header
    add(TextComponent(
      text: 'MISSION BRIEFING',
      textRenderer: TextPaint(
        style: GoogleFonts.rajdhani(
          color: const Color(0xFF00FF66),
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0,
        ),
      ),
      position: Vector2(16, 12),
    ));

    // Narrative text
    add(TextBoxComponent(
      text: level.narrative,
      textRenderer: TextPaint(
        style: GoogleFonts.firaCode(
          color: const Color(0xFFE0E6ED),
          fontSize: 14,
          height: 1.4,
        ),
      ),
      boxConfig: TextBoxConfig(
        maxWidth: size.x - 32,
        timePerChar: 0.02, // Typewriter effect
      ),
      position: Vector2(16, 40),
    ));
  }
}

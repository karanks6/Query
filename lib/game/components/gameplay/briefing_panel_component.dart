import 'package:flame/components.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:google_fonts/google_fonts.dart';
import '../../../../data/content/models/level_model.dart';
import '../ui/parchment_panel.dart';

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
    
    // Background using ParchmentPanel
    final panel = ParchmentPanel(
      size: size,
    );
    add(panel);

    // "TARGET" header
    add(TextComponent(
      text: 'TRAIL NOTES',
      textRenderer: TextPaint(
        style: GoogleFonts.nunitoSans(
          color: const Color(0xFF3D2817),
          fontSize: 18,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
        ),
      ),
      position: Vector2(16, 12),
    ));

    // Narrative text
    add(TextBoxComponent(
      text: level.narrative,
      textRenderer: TextPaint(
        style: GoogleFonts.quicksand(
          color: const Color(0xFF5C3D2E),
          fontSize: 14,
          height: 1.4,
          fontWeight: FontWeight.w600,
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


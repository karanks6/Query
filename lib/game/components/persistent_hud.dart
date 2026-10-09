import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/audio/audio_controller.dart';
import '../../core/settings/settings_modal.dart';
import '../../main.dart';

class PersistentHudComponent extends PositionComponent with RiverpodComponentMixin {
  late TextComponent _title;
  late TextComponent _settingsBtn;
  late _SettingsTapArea _settingsArea;
  
  @override
  Future<void> onLoad() async {
    _title = TextComponent(
      text: 'QUERY',
      textRenderer: TextPaint(
        style: GoogleFonts.nunitoSans(
          color: const Color(0xFFF9F5EA),
          fontWeight: FontWeight.w900,
          fontSize: 20,
          letterSpacing: 4,
          shadows: [const Shadow(color: Color(0x80000000), offset: Offset(0, 2), blurRadius: 4)],
        ),
      ),
      position: Vector2(16, 56), // Shifted down by 40 for safe area
    );

    _settingsBtn = TextComponent(
      text: '⚙️',
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 24),
      ),
      anchor: Anchor.center,
    );

    add(_title);
    
    // Add clickable area for settings
    _settingsArea = _SettingsTapArea(
      size: Vector2(48, 48),
      onTap: () {
        ref.read(audioControllerProvider).playSfx('click.wav');
        if (navigatorKey.currentContext != null) {
          showModalBottomSheet(
            context: navigatorKey.currentContext!,
            backgroundColor: Colors.transparent,
            builder: (context) => const SettingsModal(),
          );
        }
      },
    );
    _settingsArea.add(_settingsBtn);
    _settingsBtn.position = Vector2(24, 24);
    add(_settingsArea);
  }

  @override
  // ignore: avoid_renaming_method_parameters
  void onGameResize(Vector2 s) {
    super.onGameResize(s);
    size = Vector2(s.x, 100); // Increased height from 60 to 100 to account for 40px safe area
    _settingsArea.position = Vector2(s.x - 56, 40);
  }

  @override
  void render(Canvas canvas) {
    // Dark carved wood background
    final paint = Paint()..color = const Color(0xFF2C1B10);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), paint);
    
    // Bottom border - parchment/gold
    final borderPaint = Paint()..color = const Color(0xFFE59B28).withValues(alpha: 0.5)..style = PaintingStyle.stroke..strokeWidth = 2.0;
    canvas.drawLine(Offset(0, size.y), Offset(size.x, size.y), borderPaint);
  }
}

class _SettingsTapArea extends PositionComponent with TapCallbacks {
  final VoidCallback onTap;

  _SettingsTapArea({
    required super.size,
    required this.onTap,
  });

  @override
  void onTapUp(TapUpEvent event) {
    onTap();
  }
}

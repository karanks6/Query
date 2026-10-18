import 'dart:math';
import 'dart:ui' as ui;
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
  late _SettingsGearButton _settingsBtn;
  double _time = 0;
  
  @override
  Future<void> onLoad() async {
    _title = TextComponent(
      text: 'QUERY',
      textRenderer: TextPaint(
        style: GoogleFonts.nunitoSans(
          color: const Color(0xFFFFF7EA),
          fontWeight: FontWeight.w900,
          fontSize: 21,
          letterSpacing: 4.5,
          shadows: [
            const Shadow(color: Color(0x99000000), offset: Offset(0, 2), blurRadius: 4),
            const Shadow(color: Color(0x4DE59B28), offset: Offset(0, 1), blurRadius: 8),
          ],
        ),
      ),
      position: Vector2(40, 55),
    );
    add(_title);

    _settingsBtn = _SettingsGearButton(
      size: Vector2(44, 44),
      position: Vector2(size.x - 56, 42),
      onTap: () {
        ref.read(audioControllerProvider).playSfx('ui_click.wav');
        if (navigatorKey.currentContext != null) {
          showModalBottomSheet(
            context: navigatorKey.currentContext!,
            backgroundColor: Colors.transparent,
            builder: (context) => const SettingsModal(),
          );
        }
      },
    );
    add(_settingsBtn);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = Vector2(size.x, 100);
    if (isLoaded && _settingsBtn.isMounted) {
      _settingsBtn.position = Vector2(size.x - 56, 42);
    }
  }

  @override
  void render(Canvas canvas) {
    if (size.x == 0 || size.y == 0) return;

    // Dark carved wood background gradient
    final bgRect = Rect.fromLTWH(0, 0, size.x, size.y);
    final bgPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, 0),
        Offset(0, size.y),
        [
          const Color(0xFF381F12), // Deep mahogany top
          const Color(0xFF261309), // Carved wood mid
          const Color(0xFF170904), // Dark base
        ],
        [0.0, 0.6, 1.0],
      );
    canvas.drawRect(bgRect, bgPaint);

    // Subtle golden bottom trim
    final borderPaint = Paint()
      ..color = const Color(0xFFE59B28).withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawLine(Offset(0, size.y), Offset(size.x, size.y), borderPaint);

    final highlightLine = Paint()
      ..color = const Color(0xFFFFD54F).withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(0, size.y - 2), Offset(size.x, size.y - 2), highlightLine);

    // Ornate Golden Leaf Crest on the left of QUERY
    final crestX = 22.0;
    final crestY = 66.0;
    
    // Ambient breathing glow on emblem
    final glowAlpha = 0.25 + 0.15 * sin(_time * 2.5);
    final glowPaint = Paint()
      ..color = const Color(0xFFFFD54F).withValues(alpha: glowAlpha.clamp(0.0, 1.0))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
    canvas.drawCircle(Offset(crestX, crestY), 9.0, glowPaint);

    // Golden leaf icon path
    final leafPaint = Paint()
      ..color = const Color(0xFFFFD54F)
      ..style = PaintingStyle.fill;
    final leafBorder = Paint()
      ..color = const Color(0xFFE59B28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final leafPath = Path()
      ..moveTo(crestX - 6, crestY + 4)
      ..quadraticBezierTo(crestX - 7, crestY - 6, crestX, crestY - 7)
      ..quadraticBezierTo(crestX + 7, crestY - 6, crestX + 6, crestY + 4)
      ..quadraticBezierTo(crestX, crestY + 7, crestX - 6, crestY + 4)
      ..close();
    canvas.drawPath(leafPath, leafPaint);
    canvas.drawPath(leafPath, leafBorder);
  }
}

class _SettingsGearButton extends PositionComponent with TapCallbacks {
  final VoidCallback onTap;
  bool _isPressed = false;
  double _rotation = 0.0;

  _SettingsGearButton({
    required super.size,
    required super.position,
    required this.onTap,
  });

  @override
  void update(double dt) {
    super.update(dt);
    // Slow majestic idle clockwork gear rotation
    _rotation += dt * 0.45;
  }

  @override
  void render(Canvas canvas) {
    final cx = size.x / 2;
    final cy = size.y / 2 + (_isPressed ? 2.5 : 0.0);

    // 1. Button Drop Shadow
    if (!_isPressed) {
      canvas.drawCircle(
        Offset(cx, cy + 3),
        19.0,
        Paint()..color = const Color(0x66000000),
      );
    }

    // 2. Brass Medallion Base
    final discPaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(cx - 3, cy - 3),
        19.0,
        [
          const Color(0xFF8C5D35), // Antique brass highlight
          const Color(0xFF5A361C), // Deep bronze
          const Color(0xFF2E170A), // Shadow
        ],
        [0.0, 0.65, 1.0],
      );
    canvas.drawCircle(Offset(cx, cy), 18.0, discPaint);

    // Beveled rim
    final rimPaint = Paint()
      ..color = const Color(0xFFFFD54F).withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(cx, cy), 18.0, rimPaint);

    // 3. Rotating Clockwork Cog Gear Icon
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(_rotation);

    final gearPaint = Paint()
      ..color = const Color(0xFFFFF7EA)
      ..style = PaintingStyle.fill;

    // Draw 8 gear teeth
    const teeth = 8;
    for (int i = 0; i < teeth; i++) {
      canvas.save();
      canvas.rotate(i * (2 * pi / teeth));
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-2.2, -12.5, 4.4, 4.0),
          const Radius.circular(1.0),
        ),
        gearPaint,
      );
      canvas.restore();
    }

    // Outer gear wheel ring
    final gearRingPaint = Paint()
      ..color = const Color(0xFFFFF7EA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;
    canvas.drawCircle(Offset.zero, 9.5, gearRingPaint);

    // Central axle hole
    final axlePaint = Paint()
      ..color = const Color(0xFF2E170A)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, 4.5, axlePaint);

    final axleRivet = Paint()..color = const Color(0xFFFFD54F);
    canvas.drawCircle(Offset.zero, 2.0, axleRivet);

    canvas.restore();
  }

  @override
  void onTapDown(TapDownEvent event) {
    _isPressed = true;
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (_isPressed) {
      _isPressed = false;
      onTap();
    }
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    _isPressed = false;
  }
}


import 'package:flame/components.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/providers.dart';

class PersistentHudComponent extends PositionComponent with RiverpodComponentMixin {
  late TextComponent _title;
  late TextComponent _playerName;
  late TextComponent _rankTitle;
  
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

    _playerName = TextComponent(
      text: '',
      textRenderer: TextPaint(
        style: GoogleFonts.quicksand(
          color: const Color(0xFFEFE6D5),
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      anchor: Anchor.topRight,
    );

    _rankTitle = TextComponent(
      text: '',
      textRenderer: TextPaint(
        style: GoogleFonts.quicksand(
          color: const Color(0xFFE59B28), // Amber gold
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
      anchor: Anchor.topRight,
    );

    add(_title);
    add(_playerName);
    add(_rankTitle);
  }

  ProviderSubscription? _profileSub;

  @override
  void onMount() {
    super.onMount();
    
    _profileSub = ref.listenManual(
      playerProfileProvider,
      (previous, next) {
        if (next.hasValue && next.value != null) {
          _playerName.text = next.value!.displayName;
          _rankTitle.text = next.value!.rankTitle;
        }
      },
      fireImmediately: true,
    );
  }

  @override
  void onRemove() {
    _profileSub?.close();
    super.onRemove();
  }

  @override
  // ignore: avoid_renaming_method_parameters
  void onGameResize(Vector2 s) {
    super.onGameResize(s);
    size = Vector2(s.x, 100); // Increased height from 60 to 100 to account for 40px safe area
    _playerName.position = Vector2(s.x - 16, 56);
    _rankTitle.position = Vector2(s.x - 16, 74);
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

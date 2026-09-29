import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:google_fonts/google_fonts.dart';

import 'query_scene.dart';
import 'package:flame/parallax.dart';
import 'level_map_scene.dart';
import '../components/ui/wood_button.dart';
import '../components/ui/dirt_trail_component.dart';
import '../../data/content/level_loader.dart';

class WorldSelectScene extends QueryScene with DragCallbacks {
  late PositionComponent scrollContainer;
  double _scrollY = 0;
  double _maxScroll = 0;

  @override
  bool containsLocalPoint(Vector2 point) => true;

  @override
  Future<void> onLoad() async {
    // Parchment background
    final bg = await ParallaxComponent.load([ParallaxImageData("jungle_pattern.jpg")], baseVelocity: Vector2(0, -5), repeat: ImageRepeat.repeat); bg.size = game.size; add(bg); final overlay = RectangleComponent(size: game.size, paint: Paint()..color = const Color(0x99000000)); add(overlay);
    
    final compass = TextComponent(
      text: '✧\nN\nS',
      position: Vector2(40, game.size.y - 120),
      textRenderer: TextPaint(
        style: GoogleFonts.cinzel(
          color: const Color(0xFFD4C4A8),
          fontSize: 32,
          fontWeight: FontWeight.w200,
        ),
      ),
      anchor: Anchor.center,
    );
    add(compass);

    scrollContainer = PositionComponent(size: game.size);
    add(scrollContainer);

    final trailPath = DirtTrailComponent();
    scrollContainer.add(trailPath);

    final title = TextComponent(
      text: 'WILD WOODS TRAIL',
      position: Vector2(game.size.x / 2, 60),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: GoogleFonts.nunitoSans(
          color: const Color(0xFFEFE6D5),
          fontSize: 32,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
        ),
      ),
    );
    scrollContainer.add(title);

    final backBtn = WoodButton(
      text: 'BACK TO CAMP',
      size: Vector2(180, 50),
      position: Vector2((game.size.x - 180) / 2, 110),
      primaryColor: const Color(0xFFD4C4A8),
      textColor: const Color(0xFFEFE6D5),
      fontSize: 16,
      onPressed: () {
        game.popScene();
      },
    );
    scrollContainer.add(backBtn);

    final availableWorlds = LevelLoader.instance.availableWorlds;
    final points = <Vector2>[];

    for (int i = 0; i < availableWorlds.length; i++) {
      final worldId = availableWorlds[i];
      
      // Meandering trail layout
      final row = i;
      final isLeft = i % 2 == 0;
      final xOffset = isLeft ? -80.0 : 80.0;
      
      final x = (game.size.x / 2) + xOffset - 125.0; // center button 250 wide
      final y = 200.0 + (row * 140.0);
      
      points.add(Vector2(x + 125, y + 35)); // Center of the 250x70 button

      final node = WoodButton(
        text: worldId.toUpperCase().replaceAll('_', ' '),
        secondaryText: 'Packing gear...',
        position: Vector2(x, y),
        size: Vector2(250, 70),
        primaryColor: i % 2 == 0 ? const Color(0xFF4A7C59) : const Color(0xFFD48B3E),
        onPressed: () {
          game.pushScene(LevelMapScene(worldId: worldId));
        },
      );
      scrollContainer.add(node);
      
      // Async load title
      LevelLoader.instance.loadWorld(worldId).then((world) {
        if (isMounted) {
          node.text = world.title.toUpperCase();
          node.secondaryText = 'Chapter ${world.number} • ${world.levels.length} Stages';
        }
      });
    }

    trailPath.setPoints(points);
    if (points.isNotEmpty) {
      _maxScroll = (points.last.y + 100) > game.size.y ? (points.last.y + 100) - game.size.y : 0;
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (_maxScroll <= 0) return;
    _scrollY += event.localDelta.y;
    _scrollY = _scrollY.clamp(-_maxScroll, 0.0);
    scrollContainer.position.y = _scrollY;
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    for (final child in children) {
      if (child is RectangleComponent && child.paint.color == const Color(0xFFEFE6D5)) {
        child.size = size;
        break;
      }
    }
  }
}




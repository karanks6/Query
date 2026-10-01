// This file is retired — input is now handled by FlutterBlockWorkspace.
// Kept as an empty stub so dart analyze does not error on missing imports.
import 'package:flutter/material.dart';
import '../../../game/query_game.dart';

class BlockEditorOverlay extends StatelessWidget {
  final QueryGame game;
  const BlockEditorOverlay({super.key, required this.game});
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

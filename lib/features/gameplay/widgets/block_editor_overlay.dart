import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../game/query_game.dart';
import '../../../game/scenes/gameplay_scene.dart';

class BlockEditorOverlay extends StatefulWidget {
  final QueryGame game;

  const BlockEditorOverlay({super.key, required this.game});

  @override
  State<BlockEditorOverlay> createState() => _BlockEditorOverlayState();
}

class _BlockEditorOverlayState extends State<BlockEditorOverlay> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    
    // Get initial value from the block
    final scene = widget.game.sceneStack.last;
    if (scene is GameplayScene) {
      final block = scene.blockWorkspace.editingBlock;
      if (block != null) {
        _controller.text = block.value;
      }
    }
    
    // Automatically focus the text field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _save() {
    final scene = widget.game.sceneStack.last;
    if (scene is GameplayScene) {
      final block = scene.blockWorkspace.editingBlock;
      if (block != null) {
        block.updateValue(_controller.text);
      }
      scene.blockWorkspace.editingBlock = null;
    }
    widget.game.overlays.remove('block_editor');
  }

  void _cancel() {
    final scene = widget.game.sceneStack.last;
    if (scene is GameplayScene) {
      scene.blockWorkspace.editingBlock = null;
    }
    widget.game.overlays.remove('block_editor');
  }

  @override
  Widget build(BuildContext context) {
    String keyword = 'BLOCK';
    final scene = widget.game.sceneStack.last;
    if (scene is GameplayScene) {
      final block = scene.blockWorkspace.editingBlock;
      if (block != null) {
        keyword = block.type.keyword;
      }
    }

    return Container(
      color: Colors.black54, // Dim background
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 320,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFEFE6D5), // Parchment
              border: Border.all(color: const Color(0xFF8B5A2B), width: 3), // Brown border
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'DEFINE \',
                  style: GoogleFonts.cinzel(
                    color: const Color(0xFF3D2817),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  autofocus: true,
                  style: GoogleFonts.quicksand(
                    color: const Color(0xFF3D2817),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white70,
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFD4C4A8), width: 2),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF8B5A2B), width: 2),
                    ),
                    hintText: 'Enter value...',
                    hintStyle: TextStyle(color: Colors.black26),
                  ),
                  onSubmitted: (_) => _save(),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF8B5A2B),
                      ),
                      onPressed: _cancel,
                      child: Text('CANCEL', style: GoogleFonts.nunitoSans(fontWeight: FontWeight.bold)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A7C59), // Green
                        foregroundColor: const Color(0xFFEFE6D5),
                      ),
                      onPressed: _save,
                      child: Text('SAVE', style: GoogleFonts.nunitoSans(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

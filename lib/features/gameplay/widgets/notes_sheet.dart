import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../theming/tokens/game_tokens.dart';
import '../../../theming/components/action_button.dart';
import '../gameplay_provider.dart';

class NotesSheet extends ConsumerStatefulWidget {
  const NotesSheet({super.key});

  @override
  ConsumerState<NotesSheet> createState() => _NotesSheetState();
}

class _NotesSheetState extends ConsumerState<NotesSheet> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _loadNote();
  }

  Future<void> _loadNote() async {
    final gameplay = ref.read(gameplayProvider);
    if (gameplay.level != null) {
      final db = ref.read(appDatabaseProvider);
      final dao = db.levelNotesDao;
      final note = await dao.getNoteForLevel(gameplay.level!.id);
      if (note != null && mounted) {
        setState(() {
          _controller.text = note.noteText;
        });
      }
    }
  }

  Future<void> _saveNote() async {
    final gameplay = ref.read(gameplayProvider);
    if (gameplay.level != null) {
      final db = ref.read(appDatabaseProvider);
      final dao = db.levelNotesDao;
      await dao.saveNote(gameplay.level!.id, _controller.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note saved successfully!')),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: GameTokens.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Player Notes',
                style: TextStyle(
                  color: GameTokens.accent,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TextField(
                    controller: _controller,
                    maxLines: null,
                    expands: true,
                    style: const TextStyle(
                      color: GameTokens.primaryText,
                      fontFamily: 'FiraCode',
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Jot down your investigation thoughts...',
                      hintStyle: TextStyle(color: Colors.white30),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Expanded(
                      child: ActionButton(
                        isPrimary: true,
                        onPressed: _saveNote,
                        child: const Text('Save & Close'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

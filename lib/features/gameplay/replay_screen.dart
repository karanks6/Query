import 'dart:async';
import 'package:flutter/material.dart';
import '../../theming/tokens/game_tokens.dart';
import '../../theming/components/slanted_panel.dart';
import 'widgets/parallax_background.dart';
import '../../data/content/models/level_model.dart';

class ReplayScreen extends StatefulWidget {
  final LevelModel level;
  const ReplayScreen({super.key, required this.level});

  @override
  State<ReplayScreen> createState() => _ReplayScreenState();
}

class _ReplayScreenState extends State<ReplayScreen> {
  String _typedCode = '';
  late String _fullCode;
  Timer? _timer;

  @override
  void initState() {
    _fullCode = widget.level.hints.isNotEmpty 
        ? (widget.level.hints.last.codeSnippet ?? 'SELECT * FROM table;') 
        : 'SELECT * FROM table;';
    _startTyping();
  }

  void _startTyping() {
    int index = 0;
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (index < _fullCode.length) {
        setState(() {
          _typedCode += _fullCode[index];
          index++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameTokens.background,
      appBar: AppBar(
        backgroundColor: GameTokens.surface,
        title: const Text('PRO SOLUTION REPLAY', style: TextStyle(fontFamily: 'FiraCode', color: GameTokens.accent, letterSpacing: 1.5)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: GameTokens.primaryText),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ParallaxBackground(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                widget.level.title,
                style: const TextStyle(
                  color: GameTokens.accent,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Watch how a Senior Analyst solves this case:',
                style: GameTokens.bodyMedium.copyWith(color: GameTokens.primaryText),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SlantedPanel(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: GameTokens.accent.withValues(alpha: 0.3)),
                    ),
                    child: SingleChildScrollView(
                      child: SelectableText(
                        _typedCode,
                        style: GameTokens.code,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: GameTokens.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () {
                  setState(() {
                    _typedCode = _fullCode;
                    _timer?.cancel();
                  });
                },
                icon: const Icon(Icons.fast_forward),
                label: const Text('SKIP ANIMATION'),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

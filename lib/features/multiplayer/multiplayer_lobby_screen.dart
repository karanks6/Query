import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theming/tokens/game_tokens.dart';
import '../../theming/components/slanted_panel.dart';
import '../../theming/components/action_button.dart';
import '../gameplay/widgets/parallax_background.dart';

class MultiplayerLobbyScreen extends ConsumerStatefulWidget {
  const MultiplayerLobbyScreen({super.key});

  @override
  ConsumerState<MultiplayerLobbyScreen> createState() => _MultiplayerLobbyScreenState();
}

class _MultiplayerLobbyScreenState extends ConsumerState<MultiplayerLobbyScreen> {
  int _playersJoined = 1;
  bool _searching = false;
  Timer? _searchTimer;

  @override
  void dispose() {
    _searchTimer?.cancel();
    super.dispose();
  }

  void _startSearch() {
    setState(() {
      _searching = true;
      _playersJoined = 1;
    });

    _searchTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_playersJoined < 4) {
        setState(() {
          _playersJoined++;
        });
      } else {
        timer.cancel();
        _onMatchFound();
      }
    });
  }

  void _onMatchFound() {
    setState(() {
      _searching = false;
    });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: GameTokens.surface,
        title: const Text('Match Found!', style: TextStyle(color: GameTokens.success)),
        content: const Text('Preparing the arena...', style: TextStyle(color: GameTokens.primaryText)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to a mock race level
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Multiplayer Race started (Mock)')),
              );
            },
            child: const Text('ENTER', style: TextStyle(color: GameTokens.accent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameTokens.background,
      appBar: AppBar(
        backgroundColor: GameTokens.surface,
        title: const Text('MULTIPLAYER (BETA)', style: TextStyle(color: GameTokens.accent, letterSpacing: 1.5)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: GameTokens.primaryText),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ParallaxBackground(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SlantedPanel(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    const Icon(Icons.speed, size: 64, color: GameTokens.accent),
                    const SizedBox(height: 16),
                    Text(
                      'SQL SPRINT',
                      style: GameTokens.headlineLarge.copyWith(color: GameTokens.accent),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Race against 3 other analysts to solve a random case. Fastest correct query wins.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: GameTokens.primaryText),
                    ),
                    const SizedBox(height: 32),
                    if (_searching)
                      Column(
                        children: [
                          const CircularProgressIndicator(color: GameTokens.accent),
                          const SizedBox(height: 16),
                          Text(
                            'Searching for opponents... ($_playersJoined/4)',
                            style: const TextStyle(color: GameTokens.primaryText),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              _searchTimer?.cancel();
                              setState(() {
                                _searching = false;
                                _playersJoined = 1;
                              });
                            },
                            child: const Text('CANCEL', style: TextStyle(color: GameTokens.error)),
                          )
                        ],
                      )
                    else
                      ActionButton(
                        isPrimary: true,
                        onPressed: _startSearch,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                          child: Text('FIND MATCH', style: TextStyle(fontSize: 18)),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

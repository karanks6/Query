import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theming/tokens/game_tokens.dart';
import '../../theming/components/slanted_panel.dart';
import '../gameplay/widgets/parallax_background.dart';

import '../../core/providers.dart';
import '../../data/content/level_loader.dart';
import '../../data/content/content_updater_service.dart';
import '../../theming/app_theme.dart';

/// Splash screen and loading state (Section 5.1).
///
/// - Animated Query wordmark (typewriter reveal)
/// - Rotating "did you know?" SQL tips
/// - Masks cold-start asset loading (schema data, save data)
/// - Auto-advances to Onboarding (first launch) or Dashboard (returning player)
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  int _tipIndex = 0;
  String? _initError;

  static const _tips = [
    'SELECT retrieves columns from a table.',
    'WHERE filters rows before they\'re returned.',
    'JOIN combines data from two or more tables.',
    'GROUP BY collapses rows with the same value.',
    'NULL means unknown — use IS NULL, not = NULL.',
    'ORDER BY sorts your result. ASC is default.',
    'DISTINCT removes duplicate rows from results.',
    'LIMIT caps how many rows are returned.',
    'COUNT(*) counts all rows including NULLs.',
    'Aliases rename columns: SELECT name AS artist_name',
  ];

  @override
  void initState() {
    super.initState();
    _startTipRotation();
    _initializeApp();
  }

  Timer? _tipTimer;

  void _startTipRotation() {
    _tipTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _tipIndex = (_tipIndex + 1) % _tips.length;
      });
    });
  }

  @override
  void dispose() {
    _tipTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    try {
      // Preload bundled world content
      await LevelLoader.instance.preloadBundledWorlds();

      // Check for remote content updates (Section 7.3)
      await ContentUpdaterService.checkForUpdates();

      // Minimum 1.5s splash for branding impact
      await Future.delayed(const Duration(milliseconds: 1500));

      if (!mounted) return;

      // Check if player has a profile (returning vs new)
      final dao = ref.read(playerDaoProvider);
      final profile = await dao.getProfile();

      if (!mounted) return;

      if (profile == null) {
        Navigator.of(context).pushReplacementNamed('/onboarding');
      } else {
        // Load the player's active theme
        ref.read(themeNotifierProvider.notifier).setThemeById(profile.activeTheme);
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    } catch (e, st) {
      debugPrint('Splash init error: $e\n$st');
      if (!mounted) return;
      // Surface error to user on splash so they aren't stuck on a black screen
      setState(() {
        _initError = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_initError != null) {
      return Scaffold(
        backgroundColor: GameTokens.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Color(0xFFFF5555), size: 48),
                const SizedBox(height: 16),
                Text(
                  'INITIALIZATION ERROR',
                  style: TextStyle(
                    color: GameTokens.accent,
                    fontFamily: 'JetBrainsMono',
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _initError!,
                  style: const TextStyle(
                    color: Color(0xFFFF5555),
                    fontFamily: 'JetBrainsMono',
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: GameTokens.background,
      body: ParallaxBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(GameTokens.spaceXl),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Logo / wordmark
                            _QueryWordmark(),
                            const SizedBox(height: GameTokens.spaceLg),
                            Text(
                              'THE QUERY BUREAU',
                              style: GameTokens.bodySmall.copyWith(
                                letterSpacing: 4.0,
                                color: GameTokens.secondaryText,
                              ),
                            )
                                .animate()
                                .fadeIn(delay: 600.ms, duration: 800.ms),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Loading area + tips
              Padding(
                padding: const EdgeInsets.all(GameTokens.spaceLg),
                child: SlantedPanel(
                  padding: const EdgeInsets.symmetric(
                    horizontal: GameTokens.spaceLg,
                    vertical: GameTokens.spaceMd,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Tip rotator
                      AnimatedSwitcher(
                        duration: GameTokens.durationSlow,
                        child: Text(
                          '> ${_tips[_tipIndex]}',
                          key: ValueKey(_tipIndex),
                          style: GameTokens.bodySmall.copyWith(
                            color: GameTokens.secondaryText,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: GameTokens.spaceMd),

                      // Loading bar
                      SizedBox(
                        width: 160,
                        child: LinearProgressIndicator(
                          backgroundColor: GameTokens.surfaceVariant,
                          valueColor: const AlwaysStoppedAnimation(GameTokens.accent),
                          minHeight: 2,
                        )
                            .animate(onPlay: (c) => c.repeat())
                            .shimmer(
                              duration: 1500.ms,
                              color: GameTokens.accentGlow,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Animated "QUERY" wordmark with typewriter-reveal effect.
class _QueryWordmark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'QUERY',
              style: GameTokens.displayLarge.copyWith(
                fontSize: 64, // Larger, more imposing
                letterSpacing: 12, // More spaced out
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic, // Slanted/action feel
                color: GameTokens.primaryText,
                shadows: [
                  Shadow(
                    color: GameTokens.accent.withValues(alpha: 0.5),
                    offset: const Offset(4, 4), // Hard drop shadow for stylized look
                  ),
                ],
              ),
            )
                .animate()
                .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack, duration: 800.ms)
                .fadeIn(duration: 600.ms)
                .then()
                .shimmer(
                  duration: 800.ms,
                  color: GameTokens.accent,
                ),
          ],
        ),
      ],
    );
  }
}



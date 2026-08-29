import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theming/tokens/terminal_classic_tokens.dart';
import '../../shared/widgets/terminal_widgets.dart';
import '../../core/providers.dart';
import '../../data/content/level_loader.dart';

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
    'NULL means unknown â€” use IS NULL, not = NULL.',
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

  void _startTipRotation() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return false;
      setState(() {
        _tipIndex = (_tipIndex + 1) % _tips.length;
      });
      return true;
    });
  }

  Future<void> _initializeApp() async {
    try {
      // Preload bundled world content
      await LevelLoader.instance.preloadBundledWorlds();

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
        backgroundColor: TerminalClassicTokens.background,
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
                    color: TerminalClassicTokens.accent,
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
      backgroundColor: TerminalClassicTokens.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Scanline texture overlay
                    _ScanlineBackground(
                      child: Padding(
                        padding: const EdgeInsets.all(TerminalClassicTokens.spaceXl),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Logo / wordmark
                            _QueryWordmark(),
                            const SizedBox(height: TerminalClassicTokens.spaceLg),
                            Text(
                              'THE QUERY BUREAU',
                              style: TerminalClassicTokens.bodySmall.copyWith(
                                letterSpacing: 4.0,
                                color: TerminalClassicTokens.secondaryText,
                              ),
                            )
                                .animate()
                                .fadeIn(delay: 600.ms, duration: 800.ms),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Loading area + tips
            Padding(
              padding: const EdgeInsets.all(TerminalClassicTokens.spaceLg),
              child: Column(
                children: [
                  // Tip rotator
                  AnimatedSwitcher(
                    duration: TerminalClassicTokens.durationSlow,
                    child: Text(
                      '> ${_tips[_tipIndex]}',
                      key: ValueKey(_tipIndex),
                      style: TerminalClassicTokens.bodySmall.copyWith(
                        color: TerminalClassicTokens.secondaryText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: TerminalClassicTokens.spaceMd),

                  // Loading bar
                  SizedBox(
                    width: 160,
                    child: LinearProgressIndicator(
                      backgroundColor: TerminalClassicTokens.surfaceVariant,
                      valueColor: AlwaysStoppedAnimation(TerminalClassicTokens.accent),
                      minHeight: 2,
                    )
                        .animate(onPlay: (c) => c.repeat())
                        .shimmer(
                          duration: 1500.ms,
                          color: TerminalClassicTokens.accentGlow,
                        ),
                  ),
                ],
              ),
            ),
          ],
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
              style: TerminalClassicTokens.displayLarge.copyWith(
                fontSize: 52,
                letterSpacing: 8,
                shadows: [
                  Shadow(
                    color: TerminalClassicTokens.accentGlow,
                    blurRadius: 20,
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 600.ms)
                .then()
                .shimmer(
                  duration: 800.ms,
                  color: TerminalClassicTokens.accent.withValues(alpha: 0.6),
                ),
            const SizedBox(width: 4),
            BlinkingCursor(
              width: 10,
              height: 42,
            ),
          ],
        ),
      ],
    );
  }
}

/// Subtle scanline overlay (Terminal theme visual).
class _ScanlineBackground extends StatelessWidget {
  final Widget child;

  const _ScanlineBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        // Scanline effect via repeating gradient
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _ScanlinePainter(),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.08)
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += 3) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

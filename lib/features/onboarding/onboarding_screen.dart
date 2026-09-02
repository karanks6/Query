import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theming/tokens/game_tokens.dart';
import '../../theming/components/slanted_panel.dart';
import '../../theming/components/action_button.dart';
import '../gameplay/widgets/parallax_background.dart';
import '../../core/providers.dart';

/// Onboarding flow (Section 5.2):
/// 1. 3 narrative story cards ("Welcome to the Bureau")
/// 2. Name entry field
/// 3. Drops player into World 1 Level Map
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  int _currentPage = 0;
  bool _isSaving = false;
  String? _nameError;

  static const _storyCards = [
    _StoryCard(
      badge: '// CLASSIFIED',
      title: 'A new case has arrived.',
      body:
          'The Query Bureau is the world\'s only investigative agency that solves cases '
          'using one tool: data. Every mystery hides inside a database. '
          'Your job is to find it.',
      icon: Icons.folder_special_outlined,
    ),
    _StoryCard(
      badge: '// YOUR WEAPON',
      title: 'SQL is your interrogation tool.',
      body:
          'SELECT the truth. JOIN the evidence. WHERE the facts lead. '
          'Each case gives you a new database ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬Â and only the right query '
          'will crack it open.',
      icon: Icons.terminal_outlined,
    ),
    _StoryCard(
      badge: '// CASE #001',
      title: 'Your first assignment awaits.',
      body:
          'The Archive Vaults. A record store\'s entire catalog has gone cold - '
          'someone scrambled the inventory. It\'s a rookie case, but everyone starts '
          'somewhere. Time to write your first query.',
      icon: Icons.badge_outlined,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _storyCards.length) {
      _pageController.nextPage(
        duration: GameTokens.durationNormal,
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _createProfile() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = 'Enter your agent name to continue.');
      return;
    }
    if (name.length < 2 || name.length > 30) {
      setState(() => _nameError = 'Name must be 2ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬Å“30 characters.');
      return;
    }

    setState(() {
      _isSaving = true;
      _nameError = null;
    });

    try {
      final playerDao = ref.read(playerDaoProvider);
      await playerDao.createProfile(name);

      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/level_map', arguments: 'world_01');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameTokens.background,
      body: ParallaxBackground(
        child: SafeArea(
          child: Column(
          children: [
            // Top bar with skip
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: GameTokens.spaceMd,
                vertical: GameTokens.spaceSm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'THE QUERY BUREAU',
                    style: GameTokens.bodySmall.copyWith(
                      color: GameTokens.secondaryText,
                      letterSpacing: 2,
                    ),
                  ),
                  if (_currentPage < _storyCards.length)
                    TextButton(
                      onPressed: () {
                        _pageController.animateToPage(
                          _storyCards.length,
                          duration: GameTokens.durationNormal,
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Text(
                        'SKIP',
                        style: GameTokens.bodySmall.copyWith(
                          color: GameTokens.secondaryText,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Page indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i <= _storyCards.length; i++)
                  AnimatedContainer(
                    duration: GameTokens.durationFast,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _currentPage == i ? 20 : 6,
                    height: 2,
                    decoration: BoxDecoration(
                      color: _currentPage == i
                          ? GameTokens.accent
                          : GameTokens.accentDim,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: GameTokens.spaceMd),

            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  // Story cards
                  ..._storyCards.map((card) => _StoryCardPage(card: card)),
                  // Name entry
                  _NameEntryPage(
                    controller: _nameController,
                    error: _nameError,
                    onChanged: (_) => setState(() => _nameError = null),
                  ),
                ],
              ),
            ),

            // CTA button
            Padding(
              padding: const EdgeInsets.all(GameTokens.spaceLg),
              child: _currentPage < _storyCards.length
                  ? ActionButton(
                      isPrimary: true,
                      onPressed: _nextPage,
                      child: Text(
                        _currentPage == _storyCards.length - 1
                            ? 'ENTER THE BUREAU'
                            : 'NEXT',
                      ),
                    )
                  : ActionButton(
                      isPrimary: true,
                      onPressed: _isSaving ? null : _createProfile,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isSaving)
                            const Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: GameTokens.background),
                              ),
                            ),
                          const Text('BEGIN CASE #001'),
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

class _StoryCard {
  final String badge;
  final String title;
  final String body;
  final IconData icon;

  const _StoryCard({
    required this.badge,
    required this.title,
    required this.body,
    required this.icon,
  });
}

class _StoryCardPage extends StatelessWidget {
  final _StoryCard card;

  const _StoryCardPage({required this.card});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: GameTokens.spaceLg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          SlantedPanel(
            child: SizedBox(
              width: 80,
              height: 80,
              child: Icon(
                card.icon,
                color: GameTokens.accent,
                size: 36,
              ),
            ),
          ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.8, 0.8)),

          const SizedBox(height: GameTokens.spaceLg),

          // Badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: GameTokens.spaceSm,
              vertical: 3,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: GameTokens.accentDim, width: 1),
              borderRadius: GameTokens.borderRadiusSm,
            ),
            child: Text(
              card.badge,
              style: GameTokens.bodySmall.copyWith(
                color: GameTokens.secondaryText,
                letterSpacing: 1.5,
              ),
            ),
          ).animate().fadeIn(delay: 100.ms, duration: 300.ms),

          const SizedBox(height: GameTokens.spaceMd),

          // Title
          Text(
            card.title,
            style: GameTokens.headlineLarge,
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

          const SizedBox(height: GameTokens.spaceMd),

          // Body
          Text(
            card.body,
            style: GameTokens.bodyLarge.copyWith(
              color: GameTokens.secondaryText,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
        ],
      ),
    );
  }
}

class _NameEntryPage extends StatelessWidget {
  final TextEditingController controller;
  final String? error;
  final ValueChanged<String> onChanged;

  const _NameEntryPage({
    required this.controller,
    this.error,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: GameTokens.spaceLg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '// AGENT REGISTRATION',
            style: GameTokens.bodySmall.copyWith(
              color: GameTokens.secondaryText,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: GameTokens.spaceSm),
          Text(
            'What do we call you?',
            style: GameTokens.headlineLarge,
          ),
          const SizedBox(height: GameTokens.spaceSm),
          Text(
            'This name will appear on your detective file and the leaderboards.',
            style: GameTokens.bodyMedium.copyWith(
              color: GameTokens.secondaryText,
            ),
          ),
          const SizedBox(height: GameTokens.spaceLg),
          TextField(
            controller: controller,
            onChanged: onChanged,
            autofocus: true,
            style: GameTokens.code,
            cursorColor: GameTokens.accent,
            decoration: InputDecoration(
              hintText: 'Agent Name',
              errorText: error,
              prefixText: '> ',
              prefixStyle: GameTokens.code.copyWith(
                color: GameTokens.accent,
              ),
              errorStyle: GameTokens.bodySmall.copyWith(
                color: GameTokens.error,
              ),
            ),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }
}

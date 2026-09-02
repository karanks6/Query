import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theming/tokens/game_tokens.dart';
import '../../theming/components/slanted_panel.dart';
import '../../theming/components/action_button.dart';
import '../gameplay/widgets/parallax_background.dart';
import '../../shared/widgets/game_widgets.dart';
import '../../data/content/level_loader.dart';
import '../../data/content/models/level_model.dart';
import '../../core/providers.dart';

/// Level Selection Map / Grid (Section 5.4).
///
/// - Horizontally-scrollable world carousel at top
/// - Node-map of levels (locked/unlocked/starred states)
/// - World-themed background art
class LevelMapScreen extends ConsumerStatefulWidget {
  final String worldId;

  const LevelMapScreen({super.key, required this.worldId});

  @override
  ConsumerState<LevelMapScreen> createState() => _LevelMapScreenState();
}

class _LevelMapScreenState extends ConsumerState<LevelMapScreen> {
  WorldModel? _world;
  bool _loading = true;
  String? _error;
  Map<String, int> _levelStars = {};

  @override
  void initState() {
    super.initState();
    _loadWorld();
  }

  Future<void> _loadWorld() async {
    try {
      final world = await LevelLoader.instance.loadWorld(widget.worldId);
      final progressDao = ref.read(progressDaoProvider);
      final completedIds = await progressDao.getCompletedLevelIds(widget.worldId);

      final stars = <String, int>{};
      for (final levelId in completedIds) {
        final completion = await progressDao.getLevelCompletion(levelId);
        if (completion != null) {
          stars[levelId] = completion.starsEarned;
        }
      }

      if (mounted) {
        setState(() {
          _world = world;
          _levelStars = stars;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameTokens.background,
      appBar: AppBar(
        backgroundColor: GameTokens.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: GameTokens.accent, size: 16),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: _world != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CASE FILE', style: GameTokens.bodySmall),
                  Text(_world!.title, style: GameTokens.titleLarge),
                ],
              )
            : Text('CASE FILE', style: GameTokens.titleLarge),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: GameTokens.accentDim),
        ),
      ),
      body: ParallaxBackground(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation(GameTokens.accent),
                  strokeWidth: 1,
                ),
              )
            : _error != null
                ? _ErrorView(error: _error!)
                : _LevelGrid(
                    world: _world!,
                    levelStars: _levelStars,
                    onLevelTap: (level) => _onLevelTap(context, level),
                  ),
      ),
    );
  }

  void _onLevelTap(BuildContext context, LevelModel level) {
    // Show level preview sheet
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => SlantedPanel(
        child: _LevelPreviewSheet(
          level: level,
          stars: _levelStars[level.id] ?? 0,
          onStart: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed('/gameplay', arguments: level);
          },
        ),
      ),
    );
  }
}

class _LevelGrid extends StatelessWidget {
  final WorldModel world;
  final Map<String, int> levelStars;
  final void Function(LevelModel) onLevelTap;

  const _LevelGrid({
    required this.world,
    required this.levelStars,
    required this.onLevelTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // World narrative header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(GameTokens.spaceMd),
            child: SlantedPanel(
              padding: const EdgeInsets.all(GameTokens.spaceMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '// ${world.caseFile.toUpperCase()}',
                    style: GameTokens.bodySmall.copyWith(
                      color: GameTokens.secondaryText,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: GameTokens.spaceSm),
                  Text(
                    world.narrativeIntro,
                    style: GameTokens.bodyMedium.copyWith(
                      color: GameTokens.secondaryText,
                    ),
                  ),
                  const SizedBox(height: GameTokens.spaceMd),
                  Text(
                    'Concepts: ${world.coreSqlConcept}',
                    style: GameTokens.bodySmall.copyWith(
                      color: GameTokens.accent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Level nodes
        SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: GameTokens.spaceMd,
          ),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.9,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final level = world.levels[index];
                final stars = levelStars[level.id] ?? 0;
                final isCompleted = stars > 0;
                final isUnlocked = index == 0 ||
                    levelStars.containsKey(
                      world.levels[index - 1].id,
                    );

                return _LevelNode(
                  level: level,
                  stars: stars,
                  isCompleted: isCompleted,
                  isUnlocked: isUnlocked,
                  onTap: isUnlocked ? () => onLevelTap(level) : null,
                )
                    .animate()
                    .fadeIn(delay: (index * 40).ms, duration: 300.ms)
                    .scale(begin: const Offset(0.8, 0.8));
              },
              childCount: world.levels.length,
            ),
          ),
        ),

        const SliverToBoxAdapter(
          child: SizedBox(height: GameTokens.spaceXl),
        ),
      ],
    );
  }
}

class _LevelNode extends StatelessWidget {
  final LevelModel level;
  final int stars;
  final bool isCompleted;
  final bool isUnlocked;
  final VoidCallback? onTap;

  const _LevelNode({
    required this.level,
    required this.stars,
    required this.isCompleted,
    required this.isUnlocked,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isUnlocked
        ? GameTokens.primaryText
        : GameTokens.disabledText;

    return ActionButton(
      onPressed: onTap,
      isPrimary: isCompleted,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!isUnlocked)
            const Icon(Icons.lock_outline,
                color: GameTokens.disabledText, size: 14)
          else
            _LevelTypeIcon(type: level.type),
          const SizedBox(height: 3),
          Text(
            '${level.levelNumber}',
            style: GameTokens.bodySmall.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          if (isCompleted) ...[
            const SizedBox(height: 2),
            StarRow(starCount: stars),
          ],
        ],
      ),
    );
  }
}

class _LevelTypeIcon extends StatelessWidget {
  final LevelType type;

  const _LevelTypeIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case LevelType.tutorial:
        return const Icon(Icons.school_outlined,
            color: GameTokens.info, size: 14);
      case LevelType.debugging:
        return const Icon(Icons.bug_report_outlined,
            color: GameTokens.error, size: 14);
      case LevelType.optimizationChallenge:
        return const Icon(Icons.speed_outlined,
            color: GameTokens.warning, size: 14);
      case LevelType.boss:
        return const Icon(Icons.gavel_outlined,
            color: GameTokens.accent, size: 14);
      default:
        return const Icon(Icons.search_outlined,
            color: GameTokens.accent, size: 14);
    }
  }
}

class _LevelPreviewSheet extends StatelessWidget {
  final LevelModel level;
  final int stars;
  final VoidCallback onStart;

  const _LevelPreviewSheet({
    required this.level,
    required this.stars,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(GameTokens.spaceLg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _LevelTypeIcon(type: level.type),
              const SizedBox(width: GameTokens.spaceSm),
              Expanded(
                child: Text(
                  level.title,
                  style: GameTokens.headlineMedium,
                ),
              ),
              if (stars > 0) StarRow(starCount: stars),
            ],
          ),
          const SizedBox(height: GameTokens.spaceMd),
          Text(
            level.narrative,
            style: GameTokens.bodyMedium.copyWith(
              color: GameTokens.secondaryText,
            ),
          ),
          const SizedBox(height: GameTokens.spaceSm),
          Row(
            children: [
              const Icon(Icons.bolt,
                  color: GameTokens.accent, size: 14),
              const SizedBox(width: 4),
              Text(
                '+${level.xpReward} XP',
                style: GameTokens.bodySmall.copyWith(
                  color: GameTokens.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: GameTokens.spaceLg),
          Center(
            child: ActionButton(
              isPrimary: true,
              onPressed: onStart,
              child: Text(stars > 0 ? 'REPLAY' : 'START CASE'),
            ),
          ),
          const SizedBox(height: GameTokens.spaceSm),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;

  const _ErrorView({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(GameTokens.spaceLg),
        child: Text(
          '// ERROR: $error',
          style: GameTokens.bodyMedium.copyWith(
            color: GameTokens.error,
          ),
        ),
      ),
    );
  }
}

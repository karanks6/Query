import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theming/tokens/terminal_classic_tokens.dart';
import '../../shared/widgets/terminal_widgets.dart';
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
      backgroundColor: TerminalClassicTokens.background,
      appBar: AppBar(
        backgroundColor: TerminalClassicTokens.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: TerminalClassicTokens.accent, size: 16),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: _world != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CASE FILE', style: TerminalClassicTokens.bodySmall),
                  Text(_world!.title, style: TerminalClassicTokens.titleLarge),
                ],
              )
            : Text('CASE FILE', style: TerminalClassicTokens.titleLarge),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: TerminalClassicTokens.accentDim),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation(TerminalClassicTokens.accent),
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
    );
  }

  void _onLevelTap(BuildContext context, LevelModel level) {
    // Show level preview sheet
    showModalBottomSheet(
      context: context,
      backgroundColor: TerminalClassicTokens.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
        side: BorderSide(color: TerminalClassicTokens.accentDim, width: 1),
      ),
      builder: (_) => _LevelPreviewSheet(
        level: level,
        stars: _levelStars[level.id] ?? 0,
        onStart: () {
          Navigator.of(context).pop();
          Navigator.of(context).pushNamed('/gameplay', arguments: level);
        },
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
          child: Container(
            margin: const EdgeInsets.all(TerminalClassicTokens.spaceMd),
            padding: const EdgeInsets.all(TerminalClassicTokens.spaceMd),
            decoration: BoxDecoration(
              color: TerminalClassicTokens.surface,
              border: Border.all(color: TerminalClassicTokens.accentDim, width: 1),
              borderRadius: TerminalClassicTokens.borderRadiusSm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '// ${world.caseFile.toUpperCase()}',
                  style: TerminalClassicTokens.bodySmall.copyWith(
                    color: TerminalClassicTokens.secondaryText,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: TerminalClassicTokens.spaceSm),
                Text(
                  world.narrativeIntro,
                  style: TerminalClassicTokens.bodyMedium.copyWith(
                    color: TerminalClassicTokens.secondaryText,
                  ),
                ),
                const SizedBox(height: TerminalClassicTokens.spaceMd),
                Text(
                  'Concepts: ${world.coreSqlConcept}',
                  style: TerminalClassicTokens.bodySmall.copyWith(
                    color: TerminalClassicTokens.accent,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Level nodes
        SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: TerminalClassicTokens.spaceMd,
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
          child: SizedBox(height: TerminalClassicTokens.spaceXl),
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
    final borderColor = isCompleted
        ? TerminalClassicTokens.accent
        : isUnlocked
            ? TerminalClassicTokens.accentDim
            : TerminalClassicTokens.surfaceVariant;
    final textColor = isUnlocked
        ? TerminalClassicTokens.primaryText
        : TerminalClassicTokens.disabledText;
    final bg = isCompleted
        ? TerminalClassicTokens.accentDim.withValues(alpha: 0.15)
        : TerminalClassicTokens.surface;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: TerminalClassicTokens.borderRadiusSm,
          border: Border.all(color: borderColor, width: 1),
          boxShadow: isCompleted ? TerminalClassicTokens.cardShadow : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isUnlocked)
              const Icon(Icons.lock_outline,
                  color: TerminalClassicTokens.disabledText, size: 14)
            else
              _LevelTypeIcon(type: level.type),
            const SizedBox(height: 3),
            Text(
              '${level.levelNumber}',
              style: TerminalClassicTokens.bodySmall.copyWith(
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
            color: TerminalClassicTokens.info, size: 14);
      case LevelType.debugging:
        return const Icon(Icons.bug_report_outlined,
            color: TerminalClassicTokens.error, size: 14);
      case LevelType.optimizationChallenge:
        return const Icon(Icons.speed_outlined,
            color: TerminalClassicTokens.warning, size: 14);
      case LevelType.boss:
        return const Icon(Icons.gavel_outlined,
            color: TerminalClassicTokens.accent, size: 14);
      default:
        return const Icon(Icons.search_outlined,
            color: TerminalClassicTokens.accent, size: 14);
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
      padding: const EdgeInsets.all(TerminalClassicTokens.spaceLg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _LevelTypeIcon(type: level.type),
              const SizedBox(width: TerminalClassicTokens.spaceSm),
              Expanded(
                child: Text(
                  level.title,
                  style: TerminalClassicTokens.headlineMedium,
                ),
              ),
              if (stars > 0) StarRow(starCount: stars),
            ],
          ),
          const SizedBox(height: TerminalClassicTokens.spaceMd),
          Text(
            level.narrative,
            style: TerminalClassicTokens.bodyMedium.copyWith(
              color: TerminalClassicTokens.secondaryText,
            ),
          ),
          const SizedBox(height: TerminalClassicTokens.spaceSm),
          Row(
            children: [
              const Icon(Icons.bolt,
                  color: TerminalClassicTokens.accent, size: 14),
              const SizedBox(width: 4),
              Text(
                '+${level.xpReward} XP',
                style: TerminalClassicTokens.bodySmall.copyWith(
                  color: TerminalClassicTokens.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: TerminalClassicTokens.spaceLg),
          Center(
            child: TerminalButton(
              label: stars > 0 ? 'REPLAY' : 'START CASE',
              onPressed: onStart,
            ),
          ),
          const SizedBox(height: TerminalClassicTokens.spaceSm),
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
        padding: const EdgeInsets.all(TerminalClassicTokens.spaceLg),
        child: Text(
          '// ERROR: $error',
          style: TerminalClassicTokens.bodyMedium.copyWith(
            color: TerminalClassicTokens.error,
          ),
        ),
      ),
    );
  }
}

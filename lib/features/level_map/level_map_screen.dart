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
import '../../game/scenes/level_map_scene.dart';
import '../../main.dart';

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
  Set<String> _levelNotes = {};

  @override
  void initState() {
    super.initState();
    _loadWorld();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(queryGameProvider).pushScene(LevelMapScene());
    });
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

      final notes = <String>{};
      final levelNotesDao = ref.read(appDatabaseProvider).levelNotesDao;
      for (final level in world.levels) {
        final note = await levelNotesDao.getNoteForLevel(level.id);
        if (note != null && note.noteText.trim().isNotEmpty) {
          notes.add(level.id);
        }
      }

      if (mounted) {
        setState(() {
          _world = world;
          _levelStars = stars;
          _levelNotes = notes;
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
      backgroundColor: Colors.transparent,
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
                : _LevelPath(
                    world: _world!,
                    levelStars: _levelStars,
                    levelNotes: _levelNotes,
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
      isScrollControlled: true,
      builder: (_) => SlantedPanel(
        child: _LevelPreviewSheet(
          level: level,
          stars: _levelStars[level.id] ?? 0,
          onStart: () async {
            Navigator.of(context).pop();
            await Navigator.of(context).pushNamed('/gameplay', arguments: level);
            _loadWorld();
          },
        ),
      ),
    );
  }
}

class _LevelPath extends StatelessWidget {
  final WorldModel world;
  final Map<String, int> levelStars;
  final Set<String> levelNotes;
  final void Function(LevelModel) onLevelTap;

  const _LevelPath({
    required this.world,
    required this.levelStars,
    required this.levelNotes,
    required this.onLevelTap,
  });

  @override
  Widget build(BuildContext context) {
    // We create a scrolling area with a predefined height to fit the winding path.
    final height = 200.0 + (world.levels.length * 100.0);
    
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              // World narrative header
              Padding(
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
              
              // Winding path nodes
              SizedBox(
                height: height,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final centerX = constraints.maxWidth / 2;
                    return Stack(
                      children: List.generate(world.levels.length, (index) {
                        final level = world.levels[index];
                        final stars = levelStars[level.id] ?? 0;
                        final isCompleted = stars > 0;
                        final isUnlocked = index == 0 ||
                            levelStars.containsKey(
                              world.levels[index - 1].id,
                            );
                        final isNextToPlay = isUnlocked && !isCompleted &&
                            (index == 0 || levelStars.containsKey(world.levels[index - 1].id));
                        final hasNote = levelNotes.contains(level.id);

                        // Calculate position based on the winding path
                        double top = 50.0 + (index * 100.0);
                        double offset = (index % 4) == 1 || (index % 4) == 2 ? 100 : -100;
                        if (index % 2 == 0) offset = 0; // middle
                        double left = centerX - 30 + offset; // -30 for node radius

                        return Positioned(
                          top: top,
                          left: left,
                          child: _LevelNode(
                            level: level,
                            stars: stars,
                            isCompleted: isCompleted,
                            isUnlocked: isUnlocked,
                            isNextToPlay: isNextToPlay,
                            hasNote: hasNote,
                            onTap: isUnlocked ? () => onLevelTap(level) : null,
                          ).animate().fadeIn(delay: (index * 40).ms, duration: 300.ms).scale(begin: const Offset(0.8, 0.8)),
                        );
                      }),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelNode extends StatelessWidget {
  final LevelModel level;
  final int stars;
  final bool isCompleted;
  final bool isUnlocked;
  final bool isNextToPlay;
  final bool hasNote;
  final VoidCallback? onTap;

  const _LevelNode({
    required this.level,
    required this.stars,
    required this.isCompleted,
    required this.isUnlocked,
    this.isNextToPlay = false,
    this.hasNote = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isCompleted
        ? GameTokens.background
        : isUnlocked
            ? GameTokens.primaryText
            : GameTokens.disabledText;
    final isPerfect = stars == 3;

    Widget node = ActionButton(
      onPressed: onTap,
      isPrimary: isCompleted,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top icon area
            Stack(
              clipBehavior: Clip.none,
              children: [
                if (!isUnlocked)
                  const Icon(Icons.lock_outline,
                      color: GameTokens.disabledText, size: 14)
                else
                  _LevelTypeIcon(type: level.type, color: textColor),
                // Crown badge for 3-star perfect
                if (isPerfect)
                  Positioned(
                    top: -6,
                    right: -6,
                    child: Icon(Icons.workspace_premium,
                        color: GameTokens.warning, size: 11),
                  ),
                // Note badge
                if (hasNote)
                  Positioned(
                    top: -6,
                    left: -6,
                    child: Icon(Icons.note_alt,
                        color: GameTokens.info, size: 11),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              '${level.levelNumber}',
              style: GameTokens.bodySmall.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (isCompleted) ...[
              const SizedBox(height: 2),
              StarRow(
                starCount: stars,
                filledColor: GameTokens.background,
                unfilledColor: GameTokens.background.withValues(alpha: 0.3),
                starSize: 16.0,
              ),
            ],
          ],
        ),
      ),
    );

    // Pulsing ring for the next level to play
    if (isNextToPlay) {
      node = Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: GameTokens.accent, width: 2),
                borderRadius: GameTokens.borderRadiusSm,
              ),
            )
                .animate(onPlay: (c) => c.repeat())
                .scale(
                  begin: const Offset(1.0, 1.0),
                  end: const Offset(1.12, 1.12),
                  duration: 1000.ms,
                  curve: Curves.easeInOut,
                )
                .then()
                .scale(
                  begin: const Offset(1.12, 1.12),
                  end: const Offset(1.0, 1.0),
                  duration: 1000.ms,
                  curve: Curves.easeInOut,
                )
                .fade(begin: 1.0, end: 0.3, duration: 1000.ms)
                .then()
                .fade(begin: 0.3, end: 1.0, duration: 1000.ms),
          ),
          node,
        ],
      );
    }

    return node;
  }
}

class _LevelTypeIcon extends StatelessWidget {
  final LevelType type;
  final Color? color;

  const _LevelTypeIcon({required this.type, this.color});

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case LevelType.tutorial:
        return Icon(Icons.school_outlined,
            color: color ?? GameTokens.info, size: 14);
      case LevelType.debugging:
        return Icon(Icons.bug_report_outlined,
            color: color ?? GameTokens.error, size: 14);
      case LevelType.optimizationChallenge:
        return Icon(Icons.speed_outlined,
            color: color ?? GameTokens.warning, size: 14);
      case LevelType.boss:
        return Icon(Icons.gavel_outlined,
            color: color ?? GameTokens.accent, size: 14);
      default:
        return Icon(Icons.search_outlined,
            color: color ?? GameTokens.accent, size: 14);
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
      child: SingleChildScrollView(
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

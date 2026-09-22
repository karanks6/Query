import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'dart:math';

import '../../theming/tokens/game_tokens.dart';
import '../../theming/components/slanted_panel.dart';
import '../../shared/widgets/game_widgets.dart';
import '../../core/providers.dart';
import '../../data/local/app_database.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(playerProfileProvider);

    return Scaffold(
      backgroundColor: GameTokens.background, // Solid background prevents overlap
      appBar: GameAppBar(
        title: 'DETECTIVE PROFILE',
        onBack: () => Navigator.of(context).pop(),
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: GameTokens.accent)),
        error: (err, stack) => Center(child: Text('Error loading profile: $err', style: const TextStyle(color: GameTokens.error))),
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('Profile not found', style: TextStyle(color: GameTokens.error)));
          }

          return ListView(
            padding: const EdgeInsets.all(GameTokens.spaceLg),
            children: [
              _buildHeader(profile),
              const SizedBox(height: GameTokens.spaceXl),
              _buildStatsGrid(profile),
              const SizedBox(height: GameTokens.spaceXl),
              _buildMasteryTracker(ref),
              const SizedBox(height: GameTokens.spaceXl),
              _buildBadges(),
            ].animate(interval: 50.ms).fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0),
          );
        },
      ),
    );
  }

  Widget _buildHeader(PlayerProfile profile) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ANALYST DOSSIER', style: GameTokens.labelLarge.copyWith(color: GameTokens.secondaryText)),
            const SizedBox(height: GameTokens.spaceMd),
            // Holographic ID Card with 3D rotation effect
            TweenAnimationBuilder(
              tween: Tween<double>(begin: -0.05, end: 0.05),
              duration: const Duration(seconds: 4),
              curve: Curves.easeInOutSine,
              builder: (context, val, child) {
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(val)
                    ..rotateX(val * 0.5),
                  child: child,
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: GameTokens.borderRadiusMd,
                  border: Border.all(color: GameTokens.accent.withValues(alpha: 0.5), width: 2),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      GameTokens.surfaceHighlight.withValues(alpha: 0.8),
                      GameTokens.surface.withValues(alpha: 0.9),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: GameTokens.accent.withValues(alpha: 0.2),
                      blurRadius: 20,
                      spreadRadius: -5,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(GameTokens.spaceXl),
                child: Row(
                  children: [
                    // Avatar
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: GameTokens.accent.withValues(alpha: 0.1),
                        border: Border.all(color: GameTokens.accent, width: 2),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                      ),
                      child: const Icon(Icons.person, size: 64, color: GameTokens.accent),
                    ),
                    const SizedBox(width: GameTokens.spaceXl),
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.displayName.toUpperCase(),
                            style: GameTokens.displayMedium.copyWith(color: GameTokens.primaryText),
                          ),
                          Text(
                            profile.rankTitle.toUpperCase(),
                            style: GameTokens.labelLarge.copyWith(color: GameTokens.accent, letterSpacing: 2),
                          ),
                          const SizedBox(height: GameTokens.spaceMd),
                          Row(
                            children: [
                              const Icon(Icons.bolt, color: GameTokens.warning, size: 16),
                              const SizedBox(width: 4),
                              Text('${profile.totalXp} XP', style: GameTokens.bodyMedium),
                              const SizedBox(width: GameTokens.spaceLg),
                              const Icon(Icons.local_fire_department, color: GameTokens.error, size: 16),
                              const SizedBox(width: 4),
                              Text('Streak: ${profile.streakCount}', style: GameTokens.bodyMedium),
                            ],
                          ),
                          const SizedBox(height: GameTokens.spaceXs),
                          Row(
                            children: [
                              const Icon(Icons.lightbulb_outline, color: GameTokens.info, size: 16),
                              const SizedBox(width: 4),
                              Text('${profile.insightPoints} Insight Points', style: GameTokens.bodyMedium),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Security graphic
                    Column(
                      children: [
                        const Icon(Icons.qr_code_2, size: 64, color: GameTokens.surfaceHighlight),
                        const SizedBox(height: 8),
                        Text('AUTH: OK', style: GameTokens.bodySmall.copyWith(color: GameTokens.success)),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(PlayerProfile profile) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Row(
          children: [
            Expanded(child: _buildStatCard('TOTAL XP', profile.totalXp.toString(), Icons.bolt, GameTokens.accent)),
            const SizedBox(width: GameTokens.spaceMd),
            Expanded(child: _buildStatCard('STREAK', '${profile.streakCount} DAYS', Icons.local_fire_department, GameTokens.error)),
            const SizedBox(width: GameTokens.spaceMd),
            Expanded(child: _buildStatCard('INSIGHT', profile.insightPoints.toString(), Icons.lightbulb_outline, GameTokens.info)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return SlantedPanel(
      padding: const EdgeInsets.all(GameTokens.spaceMd),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: GameTokens.spaceSm),
          Text(value, style: GameTokens.headlineMedium.copyWith(color: GameTokens.primaryText)),
          const SizedBox(height: 4),
          Text(label, style: GameTokens.labelLarge.copyWith(color: GameTokens.secondaryText, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildMasteryTracker(WidgetRef ref) {
    final masteryAsync = ref.watch(masteryProgressProvider);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CONCEPT MASTERY', style: GameTokens.labelLarge.copyWith(color: GameTokens.secondaryText)),
            const SizedBox(height: GameTokens.spaceMd),
            SlantedPanel(
              padding: const EdgeInsets.all(GameTokens.spaceLg),
              child: masteryAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(color: GameTokens.accent)),
                error: (e, st) => Text('Failed to load mastery.', style: const TextStyle(color: GameTokens.error)),
                data: (masteries) {
                  if (masteries.isEmpty) {
                    return Text('No data yet.', style: GameTokens.bodyMedium.copyWith(color: GameTokens.secondaryText));
                  }
                  return Column(
                    children: masteries.map((m) => _buildMasteryBar(m['concept'] as String, m['progress'] as double)).toList(),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMasteryBar(String concept, double progress) {
    return Padding(
      padding: const EdgeInsets.only(bottom: GameTokens.spaceMd),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(concept, style: GameTokens.bodyMedium),
          ),
          Expanded(
            flex: 3,
            child: SizedBox(
              height: 12,
              // Inject a Flame widget here to render the mastery bar with particles
              child: GameWidget(
                game: MasteryBarGame(progress: progress),
              ),
            ),
          ),
          const SizedBox(width: GameTokens.spaceSm),
          SizedBox(
            width: 40,
            child: Text('${(progress * 100).toInt()}%', style: GameTokens.labelLarge, textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }

  Widget _buildBadges() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('BADGES', style: GameTokens.labelLarge.copyWith(color: GameTokens.secondaryText)),
            const SizedBox(height: GameTokens.spaceMd),
            SlantedPanel(
              padding: const EdgeInsets.all(GameTokens.spaceLg),
              child: GridView.count(
                crossAxisCount: 5,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: GameTokens.spaceMd,
                crossAxisSpacing: GameTokens.spaceMd,
                children: List.generate(10, (index) {
                  final isUnlocked = index < 4;
                  return _buildBadgeIcon(isUnlocked, index);
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeIcon(bool isUnlocked, int index) {
    return Container(
      decoration: BoxDecoration(
        color: isUnlocked ? GameTokens.accent.withValues(alpha: 0.2) : GameTokens.surfaceHighlight.withValues(alpha: 0.5),
        shape: BoxShape.circle,
        border: Border.all(
          color: isUnlocked ? GameTokens.accent : GameTokens.surfaceVariant,
          width: 2,
        ),
      ),
      child: Center(
        child: Icon(
          isUnlocked ? Icons.stars : Icons.lock_outline,
          color: isUnlocked ? GameTokens.accent : GameTokens.disabledText,
          size: 28,
        ),
      ),
    )
    .animate(target: isUnlocked ? 1 : 0)
    .flipV(duration: 600.ms, delay: (100 * index).ms)
    .shimmer(delay: 1000.ms, duration: 1500.ms, color: Colors.white24);
  }
}

/// A mini Flame Game strictly for rendering a cool particle-emitting progress bar
class MasteryBarGame extends FlameGame {
  final double progress;

  MasteryBarGame({required this.progress});

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    add(MasteryBarComponent(progress: progress));
  }
}

class MasteryBarComponent extends PositionComponent {
  final double progress;

  MasteryBarComponent({required this.progress});

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    
    // Clear old children if resizing
    removeAll(children);

    final barWidth = size.x * progress;
    final color = progress >= 1.0 ? const Color(0xFF00FFCC) : (progress > 0.5 ? const Color(0xFFFFCC00) : const Color(0xFFFF3366));

    // Particle emitter at the leading edge
    if (barWidth > 5) {
      add(
        ParticleSystemComponent(
          position: Vector2(barWidth, size.y / 2),
          particle: Particle.generate(
            count: 10,
            lifespan: 1.0,
            generator: (i) {
              final rnd = Random();
              return AcceleratedParticle(
                acceleration: Vector2(-rnd.nextDouble() * 20, (rnd.nextDouble() - 0.5) * 20),
                speed: Vector2(-rnd.nextDouble() * 10, (rnd.nextDouble() - 0.5) * 10),
                position: Vector2(0, (rnd.nextDouble() - 0.5) * size.y),
                child: ComputedParticle(
                  renderer: (canvas, particle) {
                    final paint = Paint()
                      ..color = color.withValues(alpha: 1.0 - particle.progress)
                      ..blendMode = BlendMode.screen;
                    canvas.drawCircle(Offset.zero, 1.5, paint);
                  },
                ),
              );
            },
          ),
        ),
      );
    }
  }

  @override
  void render(Canvas canvas) {
    // Draw background track
    final bgPaint = Paint()..color = const Color(0xFF2A2D39)..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.x, size.y), const Radius.circular(4)), bgPaint);

    if (progress <= 0) return;

    // Draw progress bar
    final barWidth = size.x * progress;
    final color = progress >= 1.0 ? const Color(0xFF00FFCC) : (progress > 0.5 ? const Color(0xFFFFCC00) : const Color(0xFFFF3366));
    
    final fgPaint = Paint()..color = color..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, barWidth, size.y), const Radius.circular(4)), fgPaint);
  }
}

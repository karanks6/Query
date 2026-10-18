import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/providers.dart';
import '../../data/local/app_database.dart';
import '../achievements/achievements_screen.dart';

/// Redesigned Detective Profile Screen with high-end animated Fantasy RPG UI,
/// crystal-clear readability, zero overflow, smooth scrolling, and warm adventure aesthetics.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(playerProfileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF1F1209), // Rich deep forest walnut
      appBar: _buildCustomAppBar(context),
      body: profileAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Color(0xFFE59B28)),
            strokeWidth: 2.5,
          ),
        ),
        error: (err, stack) => Center(
          child: Text(
            'Error loading dossier: $err',
            style: const TextStyle(color: Color(0xFFE57373)),
          ),
        ),
        data: (profile) {
          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
            children: [
              // 1. Analyst Dossier License Card
              _buildDossierCard(profile),
              const SizedBox(height: 20),

              // 2. High-End 3-Stat Badges Row
              _buildStatsRow(profile),
              const SizedBox(height: 24),

              // 3. Concept Mastery Skill Tracker
              _buildMasteryTracker(ref),
              const SizedBox(height: 24),

              // 4. Commendations & Badges Showcase
              _buildBadgesShowcase(context, ref),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  // ─── Custom Top Bar ────────────────────────────────────────────────────────
  PreferredSizeWidget _buildCustomAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60.0),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF2B180E),
          border: Border(
            bottom: BorderSide(color: Color(0xFF4A2C1A), width: 1.5),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 60.0,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFFF9F5EA), size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Back to Dashboard',
                ),
                Text(
                  'DETECTIVE PROFILE',
                  style: GoogleFonts.nunitoSans(
                    color: const Color(0xFFF9F5EA),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                  ),
                ),
                const Spacer(),
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF381F14),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE59B28).withValues(alpha: 0.5), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified_user_rounded, color: Color(0xFFE59B28), size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'QUERY ID',
                        style: GoogleFonts.quicksand(
                          color: const Color(0xFFE59B28),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── 1. Analyst Dossier License Card ──────────────────────────────────────
  Widget _buildDossierCard(PlayerProfile profile) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Row(
              children: [
                const Icon(Icons.badge_rounded, color: Color(0xFFE59B28), size: 16),
                const SizedBox(width: 6),
                Text(
                  'ANALYST DOSSIER',
                  style: GoogleFonts.quicksand(
                    color: const Color(0xFFDFD1B8),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Tactile Card Surface
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x66000000),
                    offset: Offset(0, 6),
                    blurRadius: 14,
                  ),
                ],
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF3B2115), // Warm dark mahogany
                    Color(0xFF28150C),
                    Color(0xFF1E0E08),
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
                border: Border.all(
                  color: const Color(0xFFE59B28).withValues(alpha: 0.65),
                  width: 1.8,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    // Background ambient backlight
                    Positioned(
                      top: -30,
                      left: -30,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFE59B28).withValues(alpha: 0.12),
                        ),
                      ),
                    ),

                    // Card Content
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Profile Row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Avatar Medallion with pulsing aura
                              _buildAvatarMedallion(),
                              const SizedBox(width: 14),

                              // Name & Rank
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Name
                                    Text(
                                      profile.displayName.toUpperCase(),
                                      style: GoogleFonts.nunitoSans(
                                        color: const Color(0xFFFFF7EA),
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.0,
                                        shadows: const [
                                          Shadow(
                                            color: Color(0x99000000),
                                            offset: Offset(0, 1.5),
                                            blurRadius: 3,
                                          ),
                                        ],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),

                                    // Rank Ribbon Badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF22543D).withValues(alpha: 0.7), // Forest green
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: const Color(0xFF48BB78).withValues(alpha: 0.6),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.stars_rounded, color: Color(0xFF9AE6B4), size: 13),
                                          const SizedBox(width: 5),
                                          Flexible(
                                            child: Text(
                                              profile.rankTitle.toUpperCase(),
                                              style: GoogleFonts.quicksand(
                                                color: const Color(0xFFE6FFFA),
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: 1.2,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Guild Seal Emblem
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF28160D),
                                  border: Border.all(
                                    color: const Color(0xFFE59B28).withValues(alpha: 0.5),
                                    width: 1.4,
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(Icons.shield_moon_rounded, color: Color(0xFFE59B28), size: 24),
                                ),
                              )
                              .animate(onPlay: (c) => c.repeat(reverse: true))
                              .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.06, 1.06), duration: 2400.ms),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Divider Line
                          Container(
                            height: 1,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFFE59B28).withValues(alpha: 0.1),
                                  const Color(0xFFE59B28).withValues(alpha: 0.5),
                                  const Color(0xFFE59B28).withValues(alpha: 0.1),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Responsive Bottom Stats Strip (Zero Overflow Guarantee!)
                          Row(
                            children: [
                              Expanded(
                                child: _buildMiniStatPill(
                                  icon: Icons.bolt_rounded,
                                  iconColor: const Color(0xFFFFD54F),
                                  label: 'EXPERIENCE',
                                  value: '${profile.totalXp} XP',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildMiniStatPill(
                                  icon: Icons.local_fire_department_rounded,
                                  iconColor: const Color(0xFFFF6D00),
                                  label: 'ACTIVE STREAK',
                                  value: '${profile.streakCount} DAYS',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildMiniStatPill(
                                  icon: Icons.lightbulb_rounded,
                                  iconColor: const Color(0xFF64B5F6),
                                  label: 'INSIGHT',
                                  value: '${profile.insightPoints} IP',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
            .animate()
            .fadeIn(duration: 500.ms)
            .slideY(begin: 0.06, end: 0, curve: Curves.easeOutQuad),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarMedallion() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [
            Color(0xFF4A2C1A),
            Color(0xFF28150C),
          ],
        ),
        border: Border.all(
          color: const Color(0xFFE59B28),
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE59B28).withValues(alpha: 0.35),
            blurRadius: 10,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF1B0F08),
          ),
          child: const Center(
            child: Icon(
              Icons.person_rounded,
              size: 40,
              color: Color(0xFFF9F5EA),
            ),
          ),
        ),
      ),
    )
    .animate(onPlay: (c) => c.repeat(reverse: true))
    .shimmer(delay: 2000.ms, duration: 2500.ms, color: const Color(0x33FFE082));
  }

  Widget _buildMiniStatPill({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A0D07).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF4A2C1A),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: iconColor, size: 14),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: GoogleFonts.quicksand(
                    color: const Color(0xFFA89F91),
                    fontSize: 8.0,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.nunitoSans(
                color: const Color(0xFFFFF7EA),
                fontSize: 13.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── 2. Tactile 3-Stat Badges ─────────────────────────────────────────────
  Widget _buildStatsRow(PlayerProfile profile) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'TOTAL XP',
                value: '${profile.totalXp}',
                icon: Icons.bolt_rounded,
                accentColor: const Color(0xFFFFD54F),
                glowColor: const Color(0x44FFD54F),
                badgeLabel: 'SCORE',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                title: 'STREAK',
                value: '${profile.streakCount} DAYS',
                icon: Icons.local_fire_department_rounded,
                accentColor: const Color(0xFFFF6D00),
                glowColor: const Color(0x44FF6D00),
                badgeLabel: 'DAILY',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                title: 'INSIGHT',
                value: '${profile.insightPoints}',
                icon: Icons.lightbulb_rounded,
                accentColor: const Color(0xFF64B5F6),
                glowColor: const Color(0x4464B5F6),
                badgeLabel: 'HINTS',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── 3. Concept Mastery Tracker ───────────────────────────────────────────
  Widget _buildMasteryTracker(WidgetRef ref) {
    final masteryAsync = ref.watch(masteryProgressProvider);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Row(
              children: [
                const Icon(Icons.auto_stories_rounded, color: Color(0xFFE59B28), size: 16),
                const SizedBox(width: 6),
                Text(
                  'CONCEPT MASTERY',
                  style: GoogleFonts.quicksand(
                    color: const Color(0xFFDFD1B8),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.8,
                  ),
                ),
                const Spacer(),
                Text(
                  'SQL SYLLABUS',
                  style: GoogleFonts.quicksand(
                    color: const Color(0xFFE59B28),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Mastery List Container
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF28150C),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF4A2C1A), width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x4D000000),
                    offset: Offset(0, 4),
                    blurRadius: 10,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: masteryAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Color(0xFFE59B28)),
                      strokeWidth: 2,
                    ),
                  ),
                ),
                error: (e, st) => Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Failed to load concept progress.',
                    style: GoogleFonts.quicksand(color: const Color(0xFFE57373)),
                  ),
                ),
                data: (masteries) {
                  if (masteries.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Embark on expeditions to unlock concept masteries.',
                        style: GoogleFonts.quicksand(color: const Color(0xFFA89F91)),
                      ),
                    );
                  }

                  return Column(
                    children: List.generate(masteries.length, (index) {
                      final item = masteries[index];
                      final rawConcept = item['concept'] as String;
                      final progress = (item['progress'] as double).clamp(0.0, 1.0);
                      final isLast = index == masteries.length - 1;

                      return _buildMasteryRow(
                        index: index + 1,
                        rawConcept: rawConcept,
                        progress: progress,
                        isLast: isLast,
                      );
                    }),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMasteryRow({
    required int index,
    required String rawConcept,
    required double progress,
    required bool isLast,
  }) {
    // Parse raw concept string into friendly title and tags
    final tags = rawConcept
        .split(',')
        .map((s) => s.trim().toUpperCase())
        .where((s) => s.isNotEmpty)
        .take(4)
        .toList();

    final percentage = (progress * 100).toInt();
    final isComplete = progress >= 1.0;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row Header: Domain Title & Percentage
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isComplete
                      ? const Color(0xFF2E6F4B)
                      : (progress > 0 ? const Color(0xFFD97706) : const Color(0xFF381F14)),
                  border: Border.all(
                    color: isComplete
                        ? const Color(0xFF48BB78)
                        : (progress > 0 ? const Color(0xFFF59E0B) : const Color(0xFF5C3826)),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: GoogleFonts.nunitoSans(
                      color: const Color(0xFFFFF7EA),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Title tags
              Expanded(
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B0E07),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFF4A2C1A), width: 0.8),
                      ),
                      child: Text(
                        tag,
                        style: GoogleFonts.quicksand(
                          color: const Color(0xFFDFD1B8),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(width: 8),

              // Percentage Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isComplete
                      ? const Color(0xFF2E6F4B).withValues(alpha: 0.4)
                      : const Color(0xFF1B0E07),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isComplete ? const Color(0xFF48BB78) : const Color(0xFFE59B28).withValues(alpha: 0.6),
                    width: 1,
                  ),
                ),
                child: Text(
                  '$percentage%',
                  style: GoogleFonts.nunitoSans(
                    color: isComplete ? const Color(0xFF9AE6B4) : const Color(0xFFFFD54F),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Custom Smooth Animated Progress Bar (No Laggy Flame GameWidgets!)
          _AnimatedProgressBar(progress: progress),
        ],
      ),
    );
  }

  // ─── 4. Commendations & Badges Showcase ───────────────────────────────────
  Widget _buildBadgesShowcase(BuildContext context, WidgetRef ref) {
    final achievementsAsync = ref.watch(allAchievementsProvider);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Row(
              children: [
                const Icon(Icons.workspace_premium_rounded, color: Color(0xFFE59B28), size: 16),
                const SizedBox(width: 6),
                Text(
                  'COMMENDATIONS & BADGES',
                  style: GoogleFonts.quicksand(
                    color: const Color(0xFFDFD1B8),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.8,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AchievementsScreen()),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'VIEW ALL',
                        style: GoogleFonts.quicksand(
                          color: const Color(0xFFE59B28),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.chevron_right_rounded, color: Color(0xFFE59B28), size: 14),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Badges Grid
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF28150C),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF4A2C1A), width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x4D000000),
                    offset: Offset(0, 4),
                    blurRadius: 10,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: achievementsAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Color(0xFFE59B28)),
                      strokeWidth: 2,
                    ),
                  ),
                ),
                error: (_, __) => const SizedBox.shrink(),
                data: (earnedList) {
                  final earnedIds = earnedList.map((e) => e.achievementId).toSet();
                  // Take first 8 achievements
                  final displayList = kAchievements.take(8).toList();

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.95,
                    ),
                    itemCount: displayList.length,
                    itemBuilder: (context, index) {
                      final def = displayList[index];
                      final isEarned = earnedIds.contains(def.id);
                      return _BadgeTile(def: def, isEarned: isEarned);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// TACTILE GAME STAT CARD (WITH PULSING AURA & HOVER BOUNCE)
// ════════════════════════════════════════════════════════════════════════════
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color accentColor;
  final Color glowColor;
  final String badgeLabel;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.accentColor,
    required this.glowColor,
    required this.badgeLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF28150C),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF4A2C1A),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            offset: Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon with ambient glow
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1B0E07),
              border: Border.all(color: accentColor.withValues(alpha: 0.7), width: 1.4),
              boxShadow: [
                BoxShadow(
                  color: glowColor,
                  blurRadius: 8,
                  spreadRadius: -1,
                ),
              ],
            ),
            child: Icon(icon, color: accentColor, size: 20),
          )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.08, 1.08), duration: 2000.ms),

          const SizedBox(height: 8),

          // Big bold number
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.nunitoSans(
                color: const Color(0xFFFFF7EA),
                fontSize: 16,
                fontWeight: FontWeight.w900,
                shadows: const [
                  Shadow(
                    color: Color(0x99000000),
                    offset: Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 3),

          // Subtitle label
          Text(
            title,
            style: GoogleFonts.quicksand(
              color: const Color(0xFFA89F91),
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// SMOOTH ANIMATED PROGRESS BAR WITH LIQUID SHIMMER GLINT
// ════════════════════════════════════════════════════════════════════════════
class _AnimatedProgressBar extends StatelessWidget {
  final double progress;

  const _AnimatedProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 9,
      decoration: BoxDecoration(
        color: const Color(0xFF140A05), // Carved groove track
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: const Color(0xFF381F14), width: 1),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxW = constraints.maxWidth;
          final barW = (maxW * progress).clamp(0.0, maxW);

          return Stack(
            children: [
              // Filled Progress Bar
              AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                width: barW,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: LinearGradient(
                    colors: progress >= 1.0
                        ? const [Color(0xFF2E7D32), Color(0xFF4CAF50)]
                        : (progress > 0.4
                            ? const [Color(0xFFD97706), Color(0xFFFFD54F)]
                            : const [Color(0xFFB45309), Color(0xFFF59E0B)]),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFA000).withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),

              // Animated Shimmer Glint
              if (progress > 0)
                Positioned.fill(
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Container()
                            .animate(onPlay: (c) => c.repeat())
                            .shimmer(
                              duration: 2200.ms,
                              color: Colors.white.withValues(alpha: 0.45),
                            ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// COMMENDATION BADGE TILE WITH TAP DIALOG
// ════════════════════════════════════════════════════════════════════════════
class _BadgeTile extends StatelessWidget {
  final AchievementDef def;
  final bool isEarned;

  const _BadgeTile({required this.def, required this.isEarned});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) => _BadgeDetailDialog(def: def, isEarned: isEarned),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isEarned ? const Color(0xFF381F14) : const Color(0xFF1B0E07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEarned ? const Color(0xFFE59B28) : const Color(0xFF3D2518),
            width: 1.5,
          ),
          boxShadow: isEarned
              ? [
                  BoxShadow(
                    color: const Color(0xFFE59B28).withValues(alpha: 0.25),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isEarned ? def.icon : Icons.lock_outline_rounded,
              color: isEarned ? const Color(0xFFFFD54F) : const Color(0xFF7D6C5D),
              size: 24,
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                def.title,
                style: GoogleFonts.quicksand(
                  color: isEarned ? const Color(0xFFFFF7EA) : const Color(0xFF8C7A6B),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// BADGE DETAIL DIALOG (TACTILE FANTASY SCROLL POPUP)
// ════════════════════════════════════════════════════════════════════════════
class _BadgeDetailDialog extends StatelessWidget {
  final AchievementDef def;
  final bool isEarned;

  const _BadgeDetailDialog({required this.def, required this.isEarned});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2B180E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE59B28), width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x99000000),
              offset: Offset(0, 8),
              blurRadius: 20,
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Badge Emblem
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isEarned ? const Color(0xFF4A2C1A) : const Color(0xFF1B0E07),
                border: Border.all(
                  color: isEarned ? const Color(0xFFE59B28) : const Color(0xFF5C3826),
                  width: 2,
                ),
              ),
              child: Icon(
                isEarned ? def.icon : Icons.lock_rounded,
                color: isEarned ? const Color(0xFFFFD54F) : const Color(0xFF8C7A6B),
                size: 32,
              ),
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              def.title.toUpperCase(),
              style: GoogleFonts.nunitoSans(
                color: const Color(0xFFFFF7EA),
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 6),

            // Description
            Text(
              def.description,
              style: GoogleFonts.quicksand(
                color: const Color(0xFFDFD1B8),
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),

            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isEarned ? const Color(0xFF2E6F4B) : const Color(0xFF1B0E07),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isEarned ? const Color(0xFF48BB78) : const Color(0xFFE59B28).withValues(alpha: 0.6),
                  width: 1,
                ),
              ),
              child: Text(
                isEarned ? '✓ COMMENDATION EARNED' : '🔒 REQUIRES ${def.requiredXp} XP',
                style: GoogleFonts.quicksand(
                  color: isEarned ? const Color(0xFFE6FFFA) : const Color(0xFFFFD54F),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Close Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A7C59),
                  foregroundColor: const Color(0xFFF9F5EA),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'CLOSE',
                  style: GoogleFonts.nunitoSans(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

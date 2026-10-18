import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/providers.dart';

class AchievementDef {
  final String id;
  final String title;
  final String description;
  final int requiredXp;
  final IconData icon;
  final String category;

  const AchievementDef({
    required this.id,
    required this.title,
    required this.description,
    required this.requiredXp,
    required this.icon,
    this.category = 'XP Milestones',
  });
}

const List<AchievementDef> kAchievements = [
  AchievementDef(id: 'xp_1', title: 'Sprout', description: 'Your journey begins in the ancient grove.', requiredXp: 50, icon: Icons.eco_rounded),
  AchievementDef(id: 'xp_2', title: 'Seedling', description: 'Taking root deep within the archive soils.', requiredXp: 150, icon: Icons.grass_rounded),
  AchievementDef(id: 'xp_3', title: 'Forager', description: 'Gathering essential data and knowledge.', requiredXp: 300, icon: Icons.spa_rounded),
  AchievementDef(id: 'xp_4', title: 'Pathfinder', description: 'Finding your way through convoluted queries.', requiredXp: 500, icon: Icons.map_rounded),
  AchievementDef(id: 'xp_5', title: 'Scout', description: 'Eyes set keen upon the distant horizon.', requiredXp: 750, icon: Icons.visibility_rounded),
  AchievementDef(id: 'xp_6', title: 'Wanderer', description: 'A steady pace through the wild woods.', requiredXp: 1000, icon: Icons.directions_walk_rounded),
  AchievementDef(id: 'xp_7', title: 'Explorer', description: 'Venturing further into uncharted schemas.', requiredXp: 1300, icon: Icons.explore_rounded),
  AchievementDef(id: 'xp_8', title: 'Adventurer', description: 'Seeking grand challenges and rare relics.', requiredXp: 1600, icon: Icons.terrain_rounded),
  AchievementDef(id: 'xp_9', title: 'Tracker', description: 'Following the clues left in table logs.', requiredXp: 2000, icon: Icons.track_changes_rounded),
  AchievementDef(id: 'xp_10', title: 'Ranger', description: 'Guardian of the forgotten mountain paths.', requiredXp: 2500, icon: Icons.shield_rounded),
  AchievementDef(id: 'xp_11', title: 'Pioneer', description: 'Breaking new ground with clean syntax.', requiredXp: 3000, icon: Icons.flag_rounded),
  AchievementDef(id: 'xp_12', title: 'Trailblazer', description: 'Leading the way through misty vales.', requiredXp: 3600, icon: Icons.local_fire_department_rounded),
  AchievementDef(id: 'xp_13', title: 'Navigator', description: 'Charting the unknown with aggregate keys.', requiredXp: 4200, icon: Icons.navigation_rounded),
  AchievementDef(id: 'xp_14', title: 'Voyager', description: 'A long expedition across stormy tables.', requiredXp: 4900, icon: Icons.sailing_rounded),
  AchievementDef(id: 'xp_15', title: 'Wayfarer', description: 'Walking the endless road of mastery.', requiredXp: 5700, icon: Icons.hiking_rounded),
  AchievementDef(id: 'xp_16', title: 'Veteran', description: 'Experienced and wise in relational lore.', requiredXp: 6600, icon: Icons.military_tech_rounded),
  AchievementDef(id: 'xp_17', title: 'Expert', description: 'Mastery in motion across all queries.', requiredXp: 7600, icon: Icons.psychology_rounded),
  AchievementDef(id: 'xp_18', title: 'Master', description: 'Unparalleled skill in complex subqueries.', requiredXp: 8700, icon: Icons.workspace_premium_rounded),
  AchievementDef(id: 'xp_19', title: 'Grandmaster', description: 'A true living legend of the archives.', requiredXp: 9900, icon: Icons.stars_rounded),
  AchievementDef(id: 'xp_20', title: 'Oracle', description: 'Seeing all truths buried in datasets.', requiredXp: 11200, icon: Icons.remove_red_eye_rounded),
  AchievementDef(id: 'xp_21', title: 'Sage', description: 'Boundless wisdom and timeless patience.', requiredXp: 12600, icon: Icons.auto_awesome_rounded),
  AchievementDef(id: 'xp_22', title: 'Mythic', description: 'Beyond the realm of mere mortal analysts.', requiredXp: 14100, icon: Icons.auto_fix_high_rounded),
  AchievementDef(id: 'xp_23', title: 'Immortal', description: 'An eternal legacy inscribed in stone.', requiredXp: 15700, icon: Icons.diamond_rounded),
  AchievementDef(id: 'xp_24', title: 'Divine', description: 'Wielding powers over the cosmic database.', requiredXp: 17400, icon: Icons.bolt_rounded),
  AchievementDef(id: 'xp_25', title: 'Query God', description: 'The ultimate truth of all knowledge.', requiredXp: 19200, icon: Icons.wb_sunny_rounded),
];

class AchievementsScreen extends ConsumerStatefulWidget {
  const AchievementsScreen({super.key});

  @override
  ConsumerState<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends ConsumerState<AchievementsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final achievementsAsync = ref.watch(allAchievementsProvider);
    final playerProfileAsync = ref.watch(playerProfileProvider);
    final currentXp = playerProfileAsync.value?.totalXp ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFF1F1209), // Rich deep forest walnut
      appBar: _buildCustomAppBar(context),
      body: achievementsAsync.when(
        data: (earnedList) {
          final earnedMap = <String, DateTime>{
            for (final e in earnedList)
              e.achievementId: DateTime.fromMillisecondsSinceEpoch(e.earnedAt),
          };

          final earnedCount = earnedList.length;
          final totalCount = kAchievements.length;
          final progressRatio = (earnedCount / totalCount).clamp(0.0, 1.0);

          return Column(
            children: [
              const SizedBox(height: 14),

              // 1. Commendations Hall Overview Banner
              _buildOverviewHeader(earnedCount, totalCount, progressRatio),
              const SizedBox(height: 14),

              // 2. Custom Game Tab Console
              _buildTabConsole(),
              const SizedBox(height: 12),

              // 3. Grid View with Bouncing Physics
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildGrid(kAchievements, earnedMap, currentXp),
                    _buildGrid(
                      kAchievements.where((a) => earnedMap.containsKey(a.id)).toList(),
                      earnedMap,
                      currentXp,
                    ),
                    _buildGrid(
                      kAchievements.where((a) => !earnedMap.containsKey(a.id)).toList(),
                      earnedMap,
                      currentXp,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Color(0xFFE59B28)),
            strokeWidth: 2.5,
          ),
        ),
        error: (err, stack) => Center(
          child: Text(
            'Error loading commendations: $err',
            style: const TextStyle(color: Color(0xFFE57373)),
          ),
        ),
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
                  tooltip: 'Back',
                ),
                Text(
                  'COMMENDATIONS ARCHIVE',
                  style: GoogleFonts.nunitoSans(
                    color: const Color(0xFFF9F5EA),
                    fontSize: 17,
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
                      const Icon(Icons.military_tech_rounded, color: Color(0xFFFFD54F), size: 15),
                      const SizedBox(width: 4),
                      Text(
                        'MEDALS',
                        style: GoogleFonts.quicksand(
                          color: const Color(0xFFFFD54F),
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

  // ─── 1. Commendations Hall Overview Banner ────────────────────────────────
  Widget _buildOverviewHeader(int earned, int total, double progress) {
    final percentage = (progress * 100).toInt();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF381F14), // Mahogany
                  Color(0xFF26130A),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE59B28).withValues(alpha: 0.7), width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66000000),
                  offset: Offset(0, 4),
                  blurRadius: 10,
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Golden Trophy with Breathing Animation
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [Color(0xFF5C3826), Color(0xFF1B0E07)],
                    ),
                    border: Border.all(color: const Color(0xFFFFD54F), width: 1.8),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD54F).withValues(alpha: 0.3),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.emoji_events_rounded, color: Color(0xFFFFD54F), size: 30),
                  ),
                )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.08, 1.08), duration: 2200.ms),

                const SizedBox(width: 14),

                // Stats & Progress Bar
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'COMMENDATIONS',
                            style: GoogleFonts.quicksand(
                              color: const Color(0xFFDFD1B8),
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            '$earned / $total EARNED',
                            style: GoogleFonts.nunitoSans(
                              color: const Color(0xFFFFD54F),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Progress Bar
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: const Color(0xFF140A05),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFF381F14), width: 0.8),
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final w = constraints.maxWidth * progress;
                            return Stack(
                              children: [
                                Container(
                                  width: w,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFD97706), Color(0xFFFFD54F)],
                                    ),
                                  ),
                                ),
                                if (progress > 0)
                                  Positioned.fill(
                                    child: FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: progress,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: Container()
                                            .animate(onPlay: (c) => c.repeat())
                                            .shimmer(
                                              duration: 2500.ms,
                                              color: Colors.white.withValues(alpha: 0.4),
                                            ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Percentage Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B0E07),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE59B28).withValues(alpha: 0.6), width: 1),
                  ),
                  child: Text(
                    '$percentage%',
                    style: GoogleFonts.nunitoSans(
                      color: const Color(0xFFFFD54F),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── 2. Custom Game Tab Console ───────────────────────────────────────────
  Widget _buildTabConsole() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF140A05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF381F14), width: 1.2),
            ),
            padding: const EdgeInsets.all(3),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(9),
                gradient: const LinearGradient(
                  colors: [Color(0xFFD97706), Color(0xFFB45309)],
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x4D000000),
                    offset: Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: const Color(0xFFFFF7EA),
              unselectedLabelColor: const Color(0xFFA89F91),
              labelStyle: GoogleFonts.nunitoSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
              unselectedLabelStyle: GoogleFonts.quicksand(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
              tabs: const [
                Tab(text: 'ALL'),
                Tab(text: 'EARNED'),
                Tab(text: 'LOCKED'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── 3. Grid View ─────────────────────────────────────────────────────────
  Widget _buildGrid(List<AchievementDef> achievements, Map<String, DateTime> earnedMap, int currentXp) {
    if (achievements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shield_outlined, color: Color(0xFF5C3826), size: 48),
            const SizedBox(height: 12),
            Text(
              'NO COMMENDATIONS HERE YET',
              style: GoogleFonts.nunitoSans(
                color: const Color(0xFFA89F91),
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820),
        child: GridView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 220,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.73,
          ),
          itemCount: achievements.length,
          itemBuilder: (context, index) {
            final def = achievements[index];
            final earnedAt = earnedMap[def.id];
            return _AchievementTile(
              key: ValueKey(def.id),
              def: def,
              isEarned: earnedAt != null,
              earnedAt: earnedAt,
              currentXp: currentXp,
              index: index,
              animationDelay: (index * 25).ms,
            );
          },
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// TACTILE COMMENDATION TILE WITH SMOOTH 3D FLIP & MOVING ANIMATED EMBLEM
// ════════════════════════════════════════════════════════════════════════════
class _AchievementTile extends StatefulWidget {
  final AchievementDef def;
  final bool isEarned;
  final DateTime? earnedAt;
  final int currentXp;
  final int index;
  final Duration animationDelay;

  const _AchievementTile({
    super.key,
    required this.def,
    required this.isEarned,
    required this.earnedAt,
    required this.currentXp,
    required this.index,
    required this.animationDelay,
  });

  @override
  State<_AchievementTile> createState() => _AchievementTileState();
}

class _AchievementTileState extends State<_AchievementTile> with SingleTickerProviderStateMixin {
  late AnimationController _idleController;
  bool _isFlipped = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );
    // Phase offset so all tiles do not bob up and down in unison
    final initialPhase = ((widget.index * 0.17) % 1.0);
    _idleController.value = initialPhase;
    _idleController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _idleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() {
            _isPressed = false;
            _isFlipped = !_isFlipped;
          });
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutCubic,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: _isFlipped ? 1.0 : 0.0),
            duration: const Duration(milliseconds: 440),
            curve: Curves.easeOutBack,
            builder: (context, double val, child) {
              final isBack = val > 0.5;
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0012) // 3D Perspective
                  ..rotateY(val * pi),
                child: isBack
                    ? Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..rotateY(pi),
                        child: _buildBackPanel(context),
                      )
                    : _buildFrontPanel(context),
              );
            },
          ),
        ),
      ),
    )
    .animate()
    .fadeIn(delay: widget.animationDelay, duration: 320.ms)
    .scale(begin: const Offset(0.92, 0.92), curve: Curves.easeOut);
  }

  // ─── Front Panel: Filled, Balanced with Big Animated Emblem ───────────────
  Widget _buildFrontPanel(BuildContext context) {
    final isEarned = widget.isEarned;
    final def = widget.def;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isEarned
              ? const [
                  Color(0xFF381F14), // Warm Mahogany
                  Color(0xFF28140B),
                  Color(0xFF1B0C06),
                ]
              : const [
                  Color(0xFF20110A),
                  Color(0xFF170B06),
                  Color(0xFF0F0603),
                ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isEarned ? const Color(0xFFE59B28) : const Color(0xFF4A2C1A),
          width: isEarned ? 1.8 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isEarned
                ? const Color(0xFFE59B28).withValues(alpha: 0.22)
                : const Color(0x66000000),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Corner fantasy star accents
            Positioned(
              top: 4,
              left: 4,
              child: Icon(
                Icons.star_rate_rounded,
                size: 8,
                color: isEarned ? const Color(0xFFE59B28).withValues(alpha: 0.4) : const Color(0xFF4A2C1A),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: Icon(
                Icons.star_rate_rounded,
                size: 8,
                color: isEarned ? const Color(0xFFE59B28).withValues(alpha: 0.4) : const Color(0xFF4A2C1A),
              ),
            ),

            // Diagonal Shimmer Gleam across the entire earned card
            if (isEarned)
              Positioned.fill(
                child: Container()
                    .animate(onPlay: (c) => c.repeat())
                    .shimmer(
                      delay: 2400.ms,
                      duration: 2200.ms,
                      color: const Color(0xFFFFD54F).withValues(alpha: 0.15),
                    ),
              ),

            // Main Card Content: Perfectly fills the card from top to bottom
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 1. Top Ribbon Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: isEarned ? const Color(0xFF261309) : const Color(0xFF140904),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isEarned
                              ? const Color(0xFFE59B28).withValues(alpha: 0.5)
                              : const Color(0xFF381F14),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isEarned ? Icons.workspace_premium_rounded : Icons.lock_outline_rounded,
                            size: 11,
                            color: isEarned ? const Color(0xFFFFD54F) : const Color(0xFF8C7A6B),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isEarned ? 'COMMENDATION' : 'MILESTONE',
                            style: GoogleFonts.nunitoSans(
                              color: isEarned ? const Color(0xFFFFD54F) : const Color(0xFFA89F91),
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 2. The BIG Moving Animated Emblem!
                    _AnimatedAchievementEmblem(
                      icon: def.icon,
                      isEarned: isEarned,
                      animation: _idleController,
                      size: 80,
                    ),

                    // 3. Title & XP Info
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          def.title.toUpperCase(),
                          style: GoogleFonts.nunitoSans(
                            color: isEarned ? const Color(0xFFFFF7EA) : const Color(0xFFA89F91),
                            fontSize: 13.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          isEarned ? '+${def.requiredXp} XP MILESTONE' : 'REQUIRES ${def.requiredXp} XP',
                          style: GoogleFonts.quicksand(
                            color: isEarned ? const Color(0xFFDFD1B8) : const Color(0xFF7D6C5D),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),

                    // 4. Bottom Status / Interactive Hint Ribbon
                    if (isEarned)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF26593B), Color(0xFF1E462E)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF48BB78).withValues(alpha: 0.8), width: 0.8),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x33000000),
                              offset: Offset(0, 1),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle_rounded, color: Color(0xFFE6FFFA), size: 11),
                            const SizedBox(width: 4),
                            Text(
                              'UNLOCKED · FLIP',
                              style: GoogleFonts.nunitoSans(
                                color: const Color(0xFFE6FFFA),
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      _buildLockedProgressRibbon(def),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Back Panel: Rich Codex Lore with Big Animated Emblem ─────────────────
  Widget _buildBackPanel(BuildContext context) {
    final isEarned = widget.isEarned;
    final def = widget.def;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isEarned
              ? const [
                  Color(0xFF2B160C), // Rich Antique Leather / Codex Backing
                  Color(0xFF200F07),
                  Color(0xFF140804),
                ]
              : const [
                  Color(0xFF1B0D06),
                  Color(0xFF120703),
                  Color(0xFF0A0402),
                ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isEarned ? const Color(0xFFE59B28) : const Color(0xFF4A2C1A),
          width: isEarned ? 1.8 : 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Top Header with Big Animated Icon Crest
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _AnimatedAchievementEmblem(
                    icon: def.icon,
                    isEarned: isEarned,
                    animation: _idleController,
                    size: 46, // Prominent and animated on the back too!
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          def.title.toUpperCase(),
                          style: GoogleFonts.nunitoSans(
                            color: isEarned ? const Color(0xFFFFF7EA) : const Color(0xFFA89F91),
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isEarned ? 'COMMENDATION' : 'LOCKED ARCHIVE',
                          style: GoogleFonts.quicksand(
                            color: isEarned ? const Color(0xFFFFD54F) : const Color(0xFF7D6C5D),
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // 2. Lore Parchment Box (Antique Relic Codex Text)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF150A05).withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isEarned
                        ? const Color(0xFFE59B28).withValues(alpha: 0.4)
                        : const Color(0xFF381F14),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  '“${def.description}”',
                  style: GoogleFonts.quicksand(
                    color: const Color(0xFFFFF7EA),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // 3. Rewards & Unlock Details Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: isEarned
                      ? const Color(0xFF381F14).withValues(alpha: 0.6)
                      : const Color(0xFF140804),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isEarned
                        ? const Color(0xFFFFD54F).withValues(alpha: 0.3)
                        : const Color(0xFF2D160C),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  children: [
                    // XP Reward
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'REWARD',
                            style: GoogleFonts.quicksand(
                              color: const Color(0xFFA89F91),
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Row(
                            children: [
                              const Icon(Icons.bolt_rounded, color: Color(0xFFFFD54F), size: 11),
                              const SizedBox(width: 2),
                              Text(
                                '+${def.requiredXp} XP',
                                style: GoogleFonts.nunitoSans(
                                  color: const Color(0xFFFFD54F),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 22, color: const Color(0xFF4A2C1A)),
                    const SizedBox(width: 8),
                    // Unlock Status
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEarned ? 'EARNED ON' : 'STATUS',
                            style: GoogleFonts.quicksand(
                              color: const Color(0xFFA89F91),
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            isEarned
                                ? _formatDate(widget.earnedAt!)
                                : 'TARGET ${def.requiredXp} XP',
                            style: GoogleFonts.nunitoSans(
                              color: isEarned ? const Color(0xFF9AE6B4) : const Color(0xFFDFD1B8),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 4. Bottom Interactive "Flip Back" Action
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 3.5),
                decoration: BoxDecoration(
                  color: const Color(0xFF140A05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFE59B28).withValues(alpha: 0.5),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.flip_to_front_rounded, color: Color(0xFFFFD54F), size: 11),
                    const SizedBox(width: 4),
                    Text(
                      'TAP TO FLIP FRONT',
                      style: GoogleFonts.quicksand(
                        color: const Color(0xFFFFD54F),
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
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

  // ─── Locked Card Progress Ribbon with Live XP Progress ────────────────────
  Widget _buildLockedProgressRibbon(AchievementDef def) {
    final progress = def.requiredXp > 0
        ? (widget.currentXp / def.requiredXp).clamp(0.0, 1.0)
        : 0.0;
    final percent = (progress * 100).toInt();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3.5),
      decoration: BoxDecoration(
        color: const Color(0xFF140904),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF381F14), width: 0.8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_rounded, color: Color(0xFFFFD54F), size: 10),
                  const SizedBox(width: 3),
                  Text(
                    '${widget.currentXp}/${def.requiredXp} XP',
                    style: GoogleFonts.nunitoSans(
                      color: const Color(0xFFFFD54F),
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              Text(
                '$percent%',
                style: GoogleFonts.quicksand(
                  color: const Color(0xFFA89F91),
                  fontSize: 8.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 3.5,
              backgroundColor: const Color(0xFF26130A),
              valueColor: const AlwaysStoppedAnimation(Color(0xFFE59B28)),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = <String>['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}

// ════════════════════════════════════════════════════════════════════════════
// HIGH-END ANIMATED ACHIEVEMENT EMBLEM (FLOATING, BREATHING, SHIMMERING)
// ════════════════════════════════════════════════════════════════════════════
class _AnimatedAchievementEmblem extends StatelessWidget {
  final IconData icon;
  final bool isEarned;
  final Animation<double> animation;
  final double size;

  const _AnimatedAchievementEmblem({
    required this.icon,
    required this.isEarned,
    required this.animation,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = animation.value;
        // Smooth sine wave hovering motion
        final hoverY = sin(t * 2 * pi) * (isEarned ? 3.5 : 1.5);
        final glowOpacity = isEarned ? (0.24 + 0.16 * sin(t * 2 * pi)) : 0.08;
        final iconScale = isEarned ? (1.0 + 0.04 * sin(t * 2 * pi)) : 1.0;

        return Transform.translate(
          offset: Offset(0, hoverY),
          child: SizedBox(
            width: size + 14,
            height: size + 14,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 1. Ambient Breathing Halo
                Container(
                  width: size + 10,
                  height: size + 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: isEarned
                            ? const Color(0xFFE59B28).withValues(alpha: glowOpacity.clamp(0.0, 1.0))
                            : const Color(0xFF381F14).withValues(alpha: 0.15),
                        blurRadius: isEarned ? (14 + 6 * t) : 8,
                        spreadRadius: isEarned ? (2 + 2 * t) : 0,
                      ),
                    ],
                  ),
                ),

                // 2. Rotating Accent Rune Ring (Breathing rotation)
                if (isEarned)
                  Transform.rotate(
                    angle: t * 0.25 * pi,
                    child: Container(
                      width: size + 6,
                      height: size + 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFFFD54F).withValues(alpha: 0.35 + 0.15 * t),
                          width: 1.2,
                        ),
                      ),
                    ),
                  ),

                // 3. Medallion Body (Rich Fantasy Disc)
                Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      center: const Alignment(-0.25, -0.35),
                      radius: 0.85,
                      colors: isEarned
                          ? const [
                              Color(0xFF6B4226), // Light bronze gold
                              Color(0xFF452414), // Mahogany
                              Color(0xFF200F07), // Deep shadow
                            ]
                          : const [
                              Color(0xFF321B0F),
                              Color(0xFF1D0E07),
                              Color(0xFF0F0603),
                            ],
                    ),
                    border: Border.all(
                      color: isEarned ? const Color(0xFFFFD54F) : const Color(0xFF5C3826),
                      width: isEarned ? 2.2 : 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isEarned
                            ? const Color(0xFFFFD54F).withValues(alpha: 0.3)
                            : const Color(0x66000000),
                        offset: const Offset(0, 3),
                        blurRadius: isEarned ? 8 : 4,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Transform.scale(
                      scale: iconScale,
                      child: Icon(
                        isEarned ? icon : Icons.lock_outline_rounded,
                        size: size * 0.52,
                        color: isEarned ? const Color(0xFFFFD54F) : const Color(0xFF8C7A6B),
                      ),
                    ),
                  ),
                ),

                // 4. Highlight Glint (Top rim reflection curve)
                Positioned(
                  top: 8,
                  child: Container(
                    width: size * 0.45,
                    height: size * 0.18,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(size),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          (isEarned ? Colors.white : const Color(0xFFDFD1B8)).withValues(alpha: isEarned ? 0.35 : 0.1),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


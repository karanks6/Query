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
                    _buildGrid(kAchievements, earnedMap),
                    _buildGrid(
                      kAchievements.where((a) => earnedMap.containsKey(a.id)).toList(),
                      earnedMap,
                    ),
                    _buildGrid(
                      kAchievements.where((a) => !earnedMap.containsKey(a.id)).toList(),
                      earnedMap,
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
  Widget _buildGrid(List<AchievementDef> achievements, Map<String, DateTime> earnedMap) {
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
            childAspectRatio: 0.82,
          ),
          itemCount: achievements.length,
          itemBuilder: (context, index) {
            final def = achievements[index];
            final earnedAt = earnedMap[def.id];
            return _AchievementTile(
              def: def,
              isEarned: earnedAt != null,
              earnedAt: earnedAt,
              animationDelay: (index * 30).ms,
            );
          },
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// TACTILE COMMENDATION TILE WITH SMOOTH 3D FLIP & DIAGONAL SHIMMER
// ════════════════════════════════════════════════════════════════════════════
class _AchievementTile extends StatefulWidget {
  final AchievementDef def;
  final bool isEarned;
  final DateTime? earnedAt;
  final Duration animationDelay;

  const _AchievementTile({
    required this.def,
    required this.isEarned,
    required this.earnedAt,
    required this.animationDelay,
  });

  @override
  State<_AchievementTile> createState() => _AchievementTileState();
}

class _AchievementTileState extends State<_AchievementTile> {
  bool _isFlipped = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isFlipped = !_isFlipped;
        });
      },
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: _isFlipped ? 1 : 0),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutBack,
        builder: (context, double val, child) {
          final isBack = val > 0.5;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // 3D Perspective
              ..rotateY(val * pi),
            child: isBack
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(pi),
                    child: _buildBackPanel(),
                  )
                : _buildFrontPanel(),
          );
        },
      ),
    )
    .animate()
    .fadeIn(delay: widget.animationDelay, duration: 350.ms)
    .scale(begin: const Offset(0.92, 0.92), curve: Curves.easeOut);
  }

  Widget _buildFrontPanel() {
    final isEarned = widget.isEarned;

    return Container(
      decoration: BoxDecoration(
        color: isEarned ? const Color(0xFF381F14) : const Color(0xFF1A0D07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEarned ? const Color(0xFFE59B28) : const Color(0xFF3D2518),
          width: isEarned ? 1.6 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isEarned
                ? const Color(0xFFE59B28).withValues(alpha: 0.25)
                : const Color(0x66000000),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            // Ambient glow for earned
            if (isEarned)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFFD54F).withValues(alpha: 0.12),
                    ),
                  ),
                ),
              ),

            // Shimmer Sweep across earned badges
            if (isEarned)
              Positioned.fill(
                child: Container()
                    .animate(onPlay: (c) => c.repeat())
                    .shimmer(
                      delay: 2000.ms,
                      duration: 2000.ms,
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
              ),

            // Content
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Medal Emblem
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: isEarned
                          ? const [Color(0xFF5C3826), Color(0xFF28150C)]
                          : const [Color(0xFF2B180E), Color(0xFF140A05)],
                    ),
                    border: Border.all(
                      color: isEarned ? const Color(0xFFFFD54F) : const Color(0xFF5C3826),
                      width: 1.8,
                    ),
                    boxShadow: isEarned
                        ? [
                            BoxShadow(
                              color: const Color(0xFFFFD54F).withValues(alpha: 0.35),
                              blurRadius: 10,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Icon(
                      isEarned ? widget.def.icon : Icons.lock_outline_rounded,
                      size: 28,
                      color: isEarned ? const Color(0xFFFFD54F) : const Color(0xFF7D6C5D),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Title
                Text(
                  widget.def.title.toUpperCase(),
                  style: GoogleFonts.nunitoSans(
                    color: isEarned ? const Color(0xFFFFF7EA) : const Color(0xFFA89F91),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 6),

                // Requirement or Earned Ribbon (High Contrast, Crystal Clear!)
                if (isEarned)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E6F4B).withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF48BB78), width: 0.8),
                    ),
                    child: Text(
                      '✓ EARNED',
                      style: GoogleFonts.quicksand(
                        color: const Color(0xFFE6FFFA),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF140A05),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE59B28).withValues(alpha: 0.5), width: 0.8),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '🔒 ${widget.def.requiredXp} XP',
                        style: GoogleFonts.nunitoSans(
                          color: const Color(0xFFFFD54F),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackPanel() {
    final isEarned = widget.isEarned;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF28150C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEarned ? const Color(0xFFE59B28) : const Color(0xFF5C3826),
          width: 1.6,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            offset: Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                widget.def.icon,
                color: isEarned ? const Color(0xFFFFD54F) : const Color(0xFF8C7A6B),
                size: 18,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.def.title.toUpperCase(),
                  style: GoogleFonts.nunitoSans(
                    color: const Color(0xFFFFF7EA),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Lore Description
          Expanded(
            child: Text(
              widget.def.description,
              style: GoogleFonts.quicksand(
                color: const Color(0xFFDFD1B8),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),

          const SizedBox(height: 6),

          // Requirement / Earned info
          if (widget.earnedAt != null)
            Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Color(0xFF48BB78), size: 12),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Unlocked: ${_formatDate(widget.earnedAt!)}',
                    style: GoogleFonts.quicksand(
                      color: const Color(0xFF9AE6B4),
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                const Icon(Icons.lock_rounded, color: Color(0xFFFFD54F), size: 12),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Target: ${widget.def.requiredXp} XP',
                    style: GoogleFonts.nunitoSans(
                      color: const Color(0xFFFFD54F),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),

          const SizedBox(height: 6),

          Center(
            child: Text(
              'TAP TO FLIP',
              style: GoogleFonts.quicksand(
                color: const Color(0xFFA89F91),
                fontSize: 8.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
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

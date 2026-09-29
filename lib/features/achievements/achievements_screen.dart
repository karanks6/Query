import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theming/tokens/game_tokens.dart';
import '../../theming/components/slanted_panel.dart';
import '../../theming/components/action_button.dart';
import '../../shared/widgets/game_widgets.dart';
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
  AchievementDef(id:'xp_1',title:'Sprout',description:'Your journey begins.',requiredXp:50,icon:Icons.eco),
  AchievementDef(id:'xp_2',title:'Seedling',description:'Taking root.',requiredXp:150,icon:Icons.grass),
  AchievementDef(id:'xp_3',title:'Forager',description:'Gathering knowledge.',requiredXp:300,icon:Icons.spa),
  AchievementDef(id:'xp_4',title:'Pathfinder',description:'Finding your way.',requiredXp:500,icon:Icons.map),
  AchievementDef(id:'xp_5',title:'Scout',description:'Eyes on the horizon.',requiredXp:750,icon:Icons.visibility),
  AchievementDef(id:'xp_6',title:'Wanderer',description:'A steady pace.',requiredXp:1000,icon:Icons.directions_walk),
  AchievementDef(id:'xp_7',title:'Explorer',description:'Venturing further.',requiredXp:1300,icon:Icons.explore),
  AchievementDef(id:'xp_8',title:'Adventurer',description:'Seeking new challenges.',requiredXp:1600,icon:Icons.terrain),
  AchievementDef(id:'xp_9',title:'Tracker',description:'Following the clues.',requiredXp:2000,icon:Icons.track_changes),
  AchievementDef(id:'xp_10',title:'Ranger',description:'Guardian of the paths.',requiredXp:2500,icon:Icons.shield),
  AchievementDef(id:'xp_11',title:'Pioneer',description:'Breaking new ground.',requiredXp:3000,icon:Icons.flag),
  AchievementDef(id:'xp_12',title:'Trailblazer',description:'Leading the way.',requiredXp:3600,icon:Icons.local_fire_department),
  AchievementDef(id:'xp_13',title:'Navigator',description:'Charting the unknown.',requiredXp:4200,icon:Icons.navigation),
  AchievementDef(id:'xp_14',title:'Voyager',description:'A long journey.',requiredXp:4900,icon:Icons.sailing),
  AchievementDef(id:'xp_15',title:'Wayfarer',description:'Walking the endless road.',requiredXp:5700,icon:Icons.hiking),
  AchievementDef(id:'xp_16',title:'Veteran',description:'Experienced and wise.',requiredXp:6600,icon:Icons.military_tech),
  AchievementDef(id:'xp_17',title:'Expert',description:'Mastery in motion.',requiredXp:7600,icon:Icons.psychology),
  AchievementDef(id:'xp_18',title:'Master',description:'Unparalleled skill.',requiredXp:8700,icon:Icons.workspace_premium),
  AchievementDef(id:'xp_19',title:'Grandmaster',description:'A true legend.',requiredXp:9900,icon:Icons.stars),
  AchievementDef(id:'xp_20',title:'Oracle',description:'Seeing all.',requiredXp:11200,icon:Icons.visibility),
  AchievementDef(id:'xp_21',title:'Sage',description:'Boundless wisdom.',requiredXp:12600,icon:Icons.auto_awesome),
  AchievementDef(id:'xp_22',title:'Mythic',description:'Beyond the realm of mortals.',requiredXp:14100,icon:Icons.auto_fix_high),
  AchievementDef(id:'xp_23',title:'Immortal',description:'Eternal legacy.',requiredXp:15700,icon:Icons.diamond),
  AchievementDef(id:'xp_24',title:'Divine',description:'Godlike powers.',requiredXp:17400,icon:Icons.bolt),
  AchievementDef(id:'xp_25',title:'Query God',description:'The ultimate truth.',requiredXp:19200,icon:Icons.wb_sunny),
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
      backgroundColor: GameTokens.background, // Solid background
      appBar: GameAppBar(title: 'COMMENDATIONS ARCHIVE', onBack: () => Navigator.of(context).pop()),
      body: achievementsAsync.when(
        data: (earnedList) {
          final earnedMap = <String, DateTime>{
            for (final e in earnedList)
              e.achievementId: DateTime.fromMillisecondsSinceEpoch(e.earnedAt),
          };

          return Column(
            children: [
              const SizedBox(height: GameTokens.spaceLg),
              const SizedBox(height: GameTokens.spaceLg),
              // Custom TabBar
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: SlantedPanel(
                    child: TabBar(
                      controller: _tabController,
                      indicatorColor: GameTokens.accent,
                      labelColor: GameTokens.accent,
                      unselectedLabelColor: GameTokens.secondaryText,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicatorWeight: 4,
                      dividerColor: Colors.transparent,
                      tabs: const [
                        Tab(text: 'ALL'),
                        Tab(text: 'EARNED'),
                        Tab(text: 'LOCKED'),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: GameTokens.spaceLg),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildGrid(kAchievements, earnedMap),
                    _buildGrid(kAchievements.where((a) => earnedMap.containsKey(a.id)).toList(), earnedMap),
                    _buildGrid(kAchievements.where((a) => !earnedMap.containsKey(a.id)).toList(), earnedMap),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(GameTokens.accent), strokeWidth: 2)),
        error: (err, stack) => Center(child: Text('ERROR: ', style: GameTokens.bodyMedium.copyWith(color: GameTokens.error))),
      ),
    );
  }

  Widget _buildGrid(List<AchievementDef> achievements, Map<String, DateTime> earnedMap) {
    if (achievements.isEmpty) {
      return Center(
        child: Text(
          'NO ACHIEVEMENTS FOUND',
          style: GameTokens.headlineMedium.copyWith(color: GameTokens.secondaryText),
        ),
      );
    }
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: GridView.builder(
          padding: const EdgeInsets.all(GameTokens.spaceLg),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 250,
            crossAxisSpacing: GameTokens.spaceLg,
            mainAxisSpacing: GameTokens.spaceLg,
            childAspectRatio: 0.8,
          ),
          itemCount: achievements.length,
          itemBuilder: (context, index) {
            final def = achievements[index];
            final earnedAt = earnedMap[def.id];
            return _AchievementTile(
              def: def,
              isEarned: earnedAt != null,
              earnedAt: earnedAt,
              animationDelay: (index * 40).ms,
            );
          },
        ),
      ),
    );
  }
}

class _AchievementTile extends StatefulWidget {
  final AchievementDef def;
  final bool isEarned;
  final DateTime? earnedAt;
  final Duration animationDelay;
  
  const _AchievementTile({
    required this.def, 
    required this.isEarned, 
    required this.earnedAt, 
    required this.animationDelay
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
        if (widget.isEarned) {
          setState(() {
            _isFlipped = !_isFlipped;
          });
        }
      },
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: _isFlipped ? 1 : 0),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutBack,
        builder: (context, double val, child) {
          // 3D flip effect on Y-axis
          final isBack = val > 0.5;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // perspective
              ..rotateY(val * 3.14159), // 180 degree flip
            child: isBack
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(3.14159),
                    child: _buildDetailPanel(),
                  )
                : _buildFrontPanel(),
          );
        },
      ),
    ).animate().fadeIn(delay: widget.animationDelay, duration: 400.ms).scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildFrontPanel() {
    return SlantedPanel(
      borderColorOverride: widget.isEarned ? GameTokens.accent : GameTokens.secondaryText,
      colorOverride: widget.isEarned ? GameTokens.surface : GameTokens.background,
      padding: const EdgeInsets.all(GameTokens.spaceMd),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: widget.isEarned ? GameTokens.surfaceHighlight : GameTokens.surfaceVariant,
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.isEarned ? GameTokens.warning : GameTokens.secondaryText,
                width: 2,
              ),
              boxShadow: widget.isEarned
                  ? [
                      BoxShadow(
                        color: GameTokens.warning.withValues(alpha: 0.5),
                        blurRadius: 15,
                        spreadRadius: -5,
                      )
                    ]
                  : null,
            ),
            child: Icon(
              widget.isEarned ? widget.def.icon : Icons.lock_outline,
              size: 40,
              color: widget.isEarned ? GameTokens.warning : GameTokens.secondaryText,
            ),
          ).animate(target: widget.isEarned ? 1 : 0).shimmer(duration: 2000.ms),
          const SizedBox(height: GameTokens.spaceLg),
          Text(
            widget.def.title.toUpperCase(),
            style: GameTokens.headlineMedium.copyWith(
              color: widget.isEarned ? GameTokens.primaryText : GameTokens.surface,
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (!widget.isEarned) ...[
             const SizedBox(height: GameTokens.spaceSm),
             Text(
               'REQUIRES ${widget.def.requiredXp} XP',
               style: GameTokens.bodySmall.copyWith(color: GameTokens.secondaryText, fontSize: 10, letterSpacing: 2),
             ),
          ],
          if (widget.isEarned) ...[
             const SizedBox(height: GameTokens.spaceSm),
             Text(
               'TAP FOR DETAILS',
               style: GameTokens.bodySmall.copyWith(color: GameTokens.accent, fontSize: 10, letterSpacing: 2),
             ),
          ]
        ],
      ),
    );
  }

  Widget _buildDetailPanel() {
    return SlantedPanel(
      borderColorOverride: GameTokens.accent,
      colorOverride: GameTokens.surfaceHighlight,
      padding: const EdgeInsets.all(GameTokens.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(widget.def.icon, color: GameTokens.accent, size: 24),
              const SizedBox(width: GameTokens.spaceSm),
              Expanded(
                child: Text(
                  widget.def.title.toUpperCase(),
                  style: GameTokens.headlineMedium.copyWith(color: GameTokens.accent),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: GameTokens.spaceMd),
          Expanded(
            child: Text(
              widget.def.description,
              style: GameTokens.bodyMedium.copyWith(color: GameTokens.primaryText, height: 1.4),
            ),
          ),
          const SizedBox(height: GameTokens.spaceMd),
          if (widget.earnedAt != null)
            Row(
              children: [
                const Icon(Icons.calendar_today, color: GameTokens.success, size: 14),
                const SizedBox(width: 4),
                Text(
                  'Earned: ${_formatDate(widget.earnedAt!)}',
                  style: GameTokens.bodySmall.copyWith(color: GameTokens.success),
                ),
              ],
            ),
          const SizedBox(height: GameTokens.spaceSm),
          Row(
            children: [
              const Icon(Icons.star, color: GameTokens.warning, size: 14),
              const SizedBox(width: 4),
              Text(
                'Requires: ${widget.def.requiredXp} XP',
                style: GameTokens.bodySmall.copyWith(color: GameTokens.warning),
              ),
            ],
          ),
          const Spacer(),
          Center(
            child: ActionButton(
              onPressed: () {
                // Share functionality stub
              },
              isPrimary: true,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.share, size: 16),
                  SizedBox(width: 8),
                  Text('SHARE'),
                ],
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

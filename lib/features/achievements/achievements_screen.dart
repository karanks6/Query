import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theming/tokens/game_tokens.dart';
import '../../theming/components/slanted_panel.dart';
import '../../theming/components/action_button.dart';
import '../gameplay/widgets/parallax_background.dart';
import '../../shared/widgets/game_widgets.dart';
import '../../core/providers.dart';

class AchievementDef {
  final String id;
  final String title;
  final String description;
  final String unlockCondition;
  final IconData icon;
  final String category;
  const AchievementDef({
    required this.id,
    required this.title,
    required this.description,
    required this.unlockCondition,
    required this.icon,
    this.category = 'General',
  });
}

const List<AchievementDef> _kAchievements = [
  AchievementDef(id:'first_query',title:'Hello World',description:'You executed your first SQL query. Every agent starts somewhere.',unlockCondition:'Complete any level for the first time.',icon:Icons.keyboard_return,category:'Milestones'),
  AchievementDef(id:'three_stars',title:'Star Witness',description:'A perfect 3-star solve. Clean query, first try, no hints.',unlockCondition:'Earn 3 stars on any level (first attempt + no hints + optimal query).',icon:Icons.star,category:'Milestones'),
  AchievementDef(id:'no_hints',title:'Solo Operative',description:'Solved it without any assistance from the Bureau.',unlockCondition:'Complete any level without using any hints.',icon:Icons.psychology_outlined,category:'Milestones'),
  AchievementDef(id:'speedrun',title:'Lightning Query',description:'You cracked the case faster than the Bureau expected.',unlockCondition:'Earn a Gold time medal by solving a level within the gold time threshold.',icon:Icons.flash_on,category:'Milestones'),
  AchievementDef(id:'comeback',title:'Persistent Detective',description:'Five failed attempts and you still cracked the case. Respect.',unlockCondition:'Complete a level after 5 or more failed attempts.',icon:Icons.local_fire_department,category:'Milestones'),
  AchievementDef(id:'perfect_optimization',title:'100% Efficiency',description:'Your query was perfectly optimised — not a byte wasted.',unlockCondition:'Score 100% efficiency on any performance challenge level.',icon:Icons.speed,category:'Milestones'),
  AchievementDef(id:'world_01_complete',title:'Archivist',description:'The Archive Vaults are yours. SELECT and FROM hold no secrets.',unlockCondition:'Complete all levels in World 1 — The Archive Vaults.',icon:Icons.folder_special,category:'Worlds'),
  AchievementDef(id:'world_02_complete',title:'Filter Specialist',description:'You have mastered the WHERE clause. Data has nowhere to hide.',unlockCondition:'Complete all levels in World 2 — Filter District.',icon:Icons.filter_alt,category:'Worlds'),
  AchievementDef(id:'world_03_complete',title:'Aggregator',description:'GROUP BY and HAVING are old friends now.',unlockCondition:'Complete all levels in World 3 — Aggregation Alley.',icon:Icons.functions,category:'Worlds'),
  AchievementDef(id:'world_04_complete',title:'Nexus Weaver',description:'JOINs? You speak their language fluently.',unlockCondition:'Complete all levels in World 4 — The JOIN Nexus.',icon:Icons.account_tree,category:'Worlds'),
  AchievementDef(id:'world_05_complete',title:'Deep Diver',description:'Subqueries are no longer a mystery.',unlockCondition:'Complete all levels in World 5 — Subquery Depths.',icon:Icons.layers,category:'Worlds'),
  AchievementDef(id:'world_06_complete',title:'CTE Architect',description:'WITH clauses structured like a master planner.',unlockCondition:'Complete all levels in World 6 — CTE Chambers.',icon:Icons.schema,category:'Worlds'),
  AchievementDef(id:'world_07_complete',title:'Window Washer',description:'RANK, ROW_NUMBER, LAG, LEAD all in a days work.',unlockCondition:'Complete all levels in World 7 — The Window Towers.',icon:Icons.view_carousel,category:'Worlds'),
  AchievementDef(id:'world_08_complete',title:'Optimizer',description:'Performance queries bent to your will.',unlockCondition:'Complete all levels in World 8 — Optimization Labs.',icon:Icons.memory,category:'Worlds'),
  AchievementDef(id:'world_09_complete',title:'Debug Master',description:'Every broken query found and fixed.',unlockCondition:'Complete all levels in World 9 — The Debug Dungeon.',icon:Icons.bug_report,category:'Worlds'),
  AchievementDef(id:'world_10_complete',title:'Grand Architect',description:'All ten worlds conquered. The Bureau finest.',unlockCondition:'Complete all levels in World 10 — The Grand Archives.',icon:Icons.emoji_events,category:'Worlds'),
  AchievementDef(id:'daily_streak_3',title:'Consistency',description:'Three days in a row. The Bureau notes your dedication.',unlockCondition:'Maintain a 3-day daily challenge streak.',icon:Icons.local_fire_department,category:'Dedication'),
  AchievementDef(id:'daily_streak_7',title:'Week Agent',description:'A full week without missing a case.',unlockCondition:'Maintain a 7-day daily challenge streak.',icon:Icons.whatshot,category:'Dedication'),
  AchievementDef(id:'rank_silver',title:'Moving Up',description:'Silver Rank achieved. The Bureau promotes you.',unlockCondition:'Reach Silver Rank by earning enough XP through level completions.',icon:Icons.workspace_premium,category:'Dedication'),
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
          
          final earnedCount = earnedMap.length;
          final totalCount = _kAchievements.length;

          return Column(
            children: [
              const SizedBox(height: GameTokens.spaceLg),
              _ProgressBanner(earned: earnedCount, total: totalCount),
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
                    _buildGrid(_kAchievements, earnedMap),
                    _buildGrid(_kAchievements.where((a) => earnedMap.containsKey(a.id)).toList(), earnedMap),
                    _buildGrid(_kAchievements.where((a) => !earnedMap.containsKey(a.id)).toList(), earnedMap),
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

class _ProgressBanner extends StatelessWidget {
  final int earned;
  final int total;
  const _ProgressBanner({required this.earned, required this.total});
  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : earned / total;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: GameTokens.spaceLg),
          child: SlantedPanel(
            borderColorOverride: GameTokens.accent,
            padding: const EdgeInsets.all(GameTokens.spaceMd),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('BUREAU RECORD', style: GameTokens.bodySmall.copyWith(color: GameTokens.secondaryText, letterSpacing: 1.5)),
                Text('$earned / $total', style: GameTokens.headlineLarge.copyWith(color: GameTokens.accent)),
              ]),
              const SizedBox(height: GameTokens.spaceSm),
              ClipRRect(
                borderRadius: GameTokens.borderRadiusSm,
                child: LinearProgressIndicator(value: pct, minHeight: 6, backgroundColor: GameTokens.surfaceVariant, valueColor: const AlwaysStoppedAnimation(GameTokens.accent)),
              ),
              const SizedBox(height: 6),
              Text('${(pct * 100).toInt()}% complete', style: GameTokens.bodySmall.copyWith(color: GameTokens.secondaryText, fontSize: 10)),
            ]),
          ),
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
      borderColorOverride: widget.isEarned ? GameTokens.accent : GameTokens.accentDim,
      colorOverride: widget.isEarned ? GameTokens.accent.withValues(alpha: 0.1) : GameTokens.surface,
      padding: const EdgeInsets.all(GameTokens.spaceMd),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: widget.isEarned ? GameTokens.accent.withValues(alpha: 0.2) : GameTokens.background,
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.isEarned ? GameTokens.accent : GameTokens.accentDim,
                width: 2,
              ),
              boxShadow: widget.isEarned
                  ? [
                      BoxShadow(
                        color: GameTokens.accent.withValues(alpha: 0.5),
                        blurRadius: 15,
                        spreadRadius: -5,
                      )
                    ]
                  : null,
            ),
            child: Icon(
              widget.isEarned ? widget.def.icon : Icons.lock_outline,
              size: 40,
              color: widget.isEarned ? GameTokens.accent : GameTokens.accentDim,
            ),
          ).animate(target: widget.isEarned ? 1 : 0).shimmer(duration: 2000.ms),
          const SizedBox(height: GameTokens.spaceLg),
          Text(
            widget.isEarned ? widget.def.title.toUpperCase() : '???',
            style: GameTokens.headlineMedium.copyWith(
              color: widget.isEarned ? GameTokens.primaryText : GameTokens.disabledText,
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
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
              const Icon(Icons.bolt, color: GameTokens.warning, size: 14),
              const SizedBox(width: 4),
              Text(
                'XP: +150',
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

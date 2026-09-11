import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theming/tokens/game_tokens.dart';
import '../../theming/components/slanted_panel.dart';
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

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementsAsync = ref.watch(allAchievementsProvider);
    return Scaffold(
      backgroundColor: GameTokens.background,
      appBar: GameAppBar(title: 'ACHIEVEMENTS', onBack: () => Navigator.of(context).pop()),
      body: ParallaxBackground(
        child: achievementsAsync.when(
          data: (earnedList) {
            final earnedMap = <String, DateTime>{
              for (final e in earnedList)
                e.achievementId: DateTime.fromMillisecondsSinceEpoch(e.earnedAt),
            };
            final categories = <String>[];
            final byCategory = <String, List<AchievementDef>>{};
            for (final def in _kAchievements) {
              if (!categories.contains(def.category)) categories.add(def.category);
              byCategory.putIfAbsent(def.category, () => []).add(def);
            }
            final earned = earnedMap.length;
            final total = _kAchievements.length;
            return ListView(
              padding: const EdgeInsets.all(GameTokens.spaceMd),
              children: [
                _ProgressBanner(earned: earned, total: total),
                const SizedBox(height: GameTokens.spaceLg),
                for (final cat in categories) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: GameTokens.spaceSm),
                    child: Text(cat.toUpperCase(), style: GameTokens.bodySmall.copyWith(color: GameTokens.secondaryText, letterSpacing: 2, fontSize: 10)),
                  ),
                  ...byCategory[cat]!.asMap().entries.map((entry) {
                    final index = entry.key;
                    final def = entry.value;
                    final earnedAt = earnedMap[def.id];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: GameTokens.spaceSm),
                      child: _AchievementTile(def: def, isEarned: earnedAt != null, earnedAt: earnedAt, animationDelay: (index * 40).ms),
                    );
                  }),
                  const SizedBox(height: GameTokens.spaceMd),
                ],
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(GameTokens.accent), strokeWidth: 2)),
          error: (err, stack) => Center(child: Text('ERROR: ', style: GameTokens.bodyMedium.copyWith(color: GameTokens.error))),
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
    return SlantedPanel(
      borderColorOverride: GameTokens.accent,
      padding: const EdgeInsets.all(GameTokens.spaceMd),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('BUREAU RECORD', style: GameTokens.bodySmall.copyWith(color: GameTokens.secondaryText, letterSpacing: 1.5)),
          Text(' / ', style: GameTokens.headlineLarge.copyWith(color: GameTokens.accent)),
        ]),
        const SizedBox(height: GameTokens.spaceSm),
        ClipRRect(
          borderRadius: GameTokens.borderRadiusSm,
          child: LinearProgressIndicator(value: pct, minHeight: 6, backgroundColor: GameTokens.surfaceVariant, valueColor: const AlwaysStoppedAnimation(GameTokens.accent)),
        ),
        const SizedBox(height: 6),
        Text('% complete', style: GameTokens.bodySmall.copyWith(color: GameTokens.secondaryText, fontSize: 10)),
      ]),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  final AchievementDef def;
  final bool isEarned;
  final DateTime? earnedAt;
  final Duration animationDelay;
  const _AchievementTile({required this.def, required this.isEarned, required this.earnedAt, required this.animationDelay});

  void _showUnlockInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: SlantedPanel(
          borderColorOverride: GameTokens.info,
          colorOverride: GameTokens.surface,
          padding: const EdgeInsets.all(GameTokens.spaceLg),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.lock_outline, color: GameTokens.info, size: 14),
              const SizedBox(width: 8),
              Text('HOW TO UNLOCK', style: GameTokens.bodySmall.copyWith(color: GameTokens.info, letterSpacing: 1.5)),
            ]),
            const SizedBox(height: GameTokens.spaceMd),
            Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: GameTokens.accentDim.withValues(alpha: 0.1), borderRadius: GameTokens.borderRadiusSm, border: Border.all(color: GameTokens.accentDim)),
                child: Icon(def.icon, color: GameTokens.accentDim, size: 22),
              ),
              const SizedBox(width: GameTokens.spaceSm),
              Expanded(child: Text(def.title, style: GameTokens.headlineMedium.copyWith(color: GameTokens.primaryText))),
            ]),
            const SizedBox(height: GameTokens.spaceMd),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(GameTokens.spaceMd),
              decoration: BoxDecoration(
                color: GameTokens.info.withValues(alpha: 0.07),
                borderRadius: GameTokens.borderRadiusSm,
                border: Border.all(color: GameTokens.info.withValues(alpha: 0.35)),
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.info_outline, color: GameTokens.info, size: 14),
                const SizedBox(width: 8),
                Expanded(child: Text(def.unlockCondition, style: GameTokens.bodyMedium.copyWith(color: GameTokens.primaryText, height: 1.5))),
              ]),
            ),
            const SizedBox(height: GameTokens.spaceLg),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('GOT IT', style: GameTokens.labelLarge.copyWith(color: GameTokens.accent)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SlantedPanel(
      borderColorOverride: isEarned ? GameTokens.accent : GameTokens.accentDim,
      padding: const EdgeInsets.symmetric(horizontal: GameTokens.spaceMd, vertical: GameTokens.spaceSm),
      colorOverride: isEarned ? null : GameTokens.surface,
      child: Row(children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
            color: isEarned ? GameTokens.accent.withValues(alpha: 0.12) : GameTokens.background,
            border: Border.all(color: isEarned ? GameTokens.accent : GameTokens.accentDim),
            borderRadius: GameTokens.borderRadiusSm,
          ),
          child: Icon(isEarned ? def.icon : Icons.lock_outline, color: isEarned ? GameTokens.accent : GameTokens.accentDim, size: 24),
        ),
        const SizedBox(width: GameTokens.spaceMd),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(def.title, style: GameTokens.headlineMedium.copyWith(color: isEarned ? GameTokens.primaryText : GameTokens.accentDim)),
            const SizedBox(height: 2),
            Text(
              isEarned ? def.description : def.unlockCondition,
              style: GameTokens.bodySmall.copyWith(color: isEarned ? GameTokens.secondaryText : GameTokens.accentDim.withValues(alpha: 0.75), fontSize: 11),
              maxLines: 2, overflow: TextOverflow.ellipsis,
            ),
            if (isEarned && earnedAt != null) ...[
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.check_circle_outline, color: GameTokens.success, size: 11),
                const SizedBox(width: 4),
                Text('Unlocked ${_formatDate(earnedAt!)}', style: GameTokens.bodySmall.copyWith(color: GameTokens.success, fontSize: 10)),
              ]),
            ],
          ]),
        ),
        if (isEarned)
          const Padding(padding: EdgeInsets.only(left: 8), child: Icon(Icons.check_circle, color: GameTokens.accent, size: 20))
        else
          IconButton(
            onPressed: () => _showUnlockInfo(context),
            tooltip: 'How to unlock this achievement',
            icon: const Icon(Icons.info_outline, color: GameTokens.info, size: 20),
            padding: const EdgeInsets.all(6),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
      ]),
    ).animate().fadeIn(delay: animationDelay, duration: 300.ms).slideY(begin: 0.08, end: 0);
  }

  String _formatDate(DateTime dt) {
    const months = <String>['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}

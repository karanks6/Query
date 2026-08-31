import 'package:equatable/equatable.dart';
import '../../../core/sandbox_engine/level_schema.dart';
import '../../../core/scoring/level_scorer.dart';

/// The complete definition of a game world, loaded from the content pack.
class WorldModel extends Equatable {
  final String id; // e.g. "world_01"
  final int number; // 1–10
  final String title; // "The Archive Vaults"
  final String caseFile; // Narrative subtitle
  final String clientName; // "A small record store's inventory"
  final String narrativeIntro; // Opening story paragraph
  final String coreSqlConcept; // "SELECT, FROM, LIMIT, DISTINCT"
  final int totalLevels;
  final List<LevelModel> levels;
  final String unlockThemeId; // Theme unlocked upon world completion

  const WorldModel({
    required this.id,
    required this.number,
    required this.title,
    required this.caseFile,
    required this.clientName,
    required this.narrativeIntro,
    required this.coreSqlConcept,
    required this.totalLevels,
    required this.levels,
    required this.unlockThemeId,
  });

  factory WorldModel.fromJson(Map<String, dynamic> json) {
    final levelsJson = json['levels'] as List<dynamic>? ?? [];
    return WorldModel(
      id: json['id'] as String,
      number: json['number'] as int,
      title: json['title'] as String,
      caseFile: (json['case_file'] ?? json['caseFile']) as String? ?? '',
      clientName: (json['client_name'] ?? json['clientName']) as String? ?? '',
      narrativeIntro: (json['narrative_intro'] ?? json['narrativeIntro']) as String? ?? '',
      coreSqlConcept: (json['core_sql_concept'] ?? json['coreSqlConcept']) as String? ?? '',
      totalLevels: (json['total_levels'] ?? json['totalLevels']) as int? ?? 0,
      levels: levelsJson
          .map((l) => LevelModel.fromJson(l as Map<String, dynamic>))
          .toList(),
      unlockThemeId: (json['unlock_theme_id'] ?? json['unlockThemeId']) as String? ?? 'terminal_classic',
    );
  }

  @override
  List<Object?> get props => [id];
}

/// The complete definition of a single puzzle level.
class LevelModel extends Equatable {
  final String id; // e.g. "world_01_level_01"
  final String worldId;
  final int levelNumber;
  final String title;
  final String narrative; // The "case" story setup
  final LevelType type;
  final LevelSchema schema;
  final String schemaSql; // CREATE TABLE statements
  final String seedSql; // INSERT statements to populate sandbox
  final List<Map<String, dynamic>> expectedResult;
  final bool orderSensitive;
  final bool performanceActive;
  final double efficiencyThreshold;
  final List<HintModel> hints;
  final String? conceptCardId; // Shown on first exposure
  final int xpReward;
  final int allowedWorldNumber; // Whitelist derived from this
  final LevelTimingThresholds? timingThresholds;
  final List<String> allowedStatements; // Overrides world default if set

  // For Tutorial levels: the expected partial answer to guide with
  final String? guidedAnswer;

  // For Debugging levels: the pre-loaded broken query
  final String? brokenQuery;

  const LevelModel({
    required this.id,
    required this.worldId,
    required this.levelNumber,
    required this.title,
    required this.narrative,
    required this.type,
    required this.schema,
    required this.schemaSql,
    required this.seedSql,
    required this.expectedResult,
    required this.orderSensitive,
    required this.performanceActive,
    required this.efficiencyThreshold,
    required this.hints,
    this.conceptCardId,
    required this.xpReward,
    required this.allowedWorldNumber,
    this.timingThresholds,
    this.allowedStatements = const [],
    this.guidedAnswer,
    this.brokenQuery,
  });

  factory LevelModel.fromJson(Map<String, dynamic> json) {
    final hintsJson = (json['hints'] as List<dynamic>?) ?? [];
    final expectedJson = ((json['expected_result'] ?? json['expectedResult']) as List<dynamic>?) ?? [];
    final timingJson = (json['timing_thresholds'] ?? json['timingThresholds']) as Map<String, dynamic>?;

    return LevelModel(
      id: json['id'] as String,
      worldId: (json['world_id'] ?? json['worldId']) as String? ?? '',
      levelNumber: (json['level_number'] ?? json['levelNumber']) as int? ?? 1,
      title: json['title'] as String? ?? 'Unknown Title',
      narrative: json['narrative'] as String? ?? '',
      type: LevelType.fromString(json['type'] as String? ?? 'puzzle'),
      schema: LevelSchema.fromJson(json['schema'] as Map<String, dynamic>),
      schemaSql: (json['schema_sql'] ?? json['schemaSql']) as String? ?? '',
      seedSql: (json['seed_sql'] ?? json['seedSql']) as String? ?? '',
      expectedResult: expectedJson
          .map((r) => Map<String, dynamic>.from(r as Map))
          .toList(),
      orderSensitive: (json['order_sensitive'] ?? json['orderSensitive']) as bool? ?? false,
      performanceActive: (json['performance_active'] ?? json['performanceActive']) as bool? ?? false,
      efficiencyThreshold: ((json['efficiency_threshold'] ?? json['efficiencyThreshold']) as num?)?.toDouble() ?? 0.8,
      hints: hintsJson
          .map((h) => HintModel.fromJson(h as Map<String, dynamic>))
          .toList(),
      conceptCardId: (json['concept_card_id'] ?? json['conceptCardId']) as String?,
      xpReward: (json['xp_reward'] ?? json['xpReward']) as int? ?? 50,
      allowedWorldNumber: (json['allowed_world_number'] ?? json['allowedWorldNumber']) as int? ?? 1,
      timingThresholds: timingJson != null
          ? LevelTimingThresholds.fromJson(timingJson)
          : null,
      allowedStatements: ((json['allowed_statements'] ?? json['allowedStatements']) as List<dynamic>?)
              ?.cast<String>() ??
          const [],
      guidedAnswer: (json['guided_answer'] ?? json['guidedAnswer']) as String?,
      brokenQuery: (json['broken_query'] ?? json['brokenQuery']) as String?,
    );
  }

  @override
  List<Object?> get props => [id];
}

enum LevelType {
  tutorial,
  puzzle,
  debugging,
  optimizationChallenge,
  boss;

  static LevelType fromString(String s) {
    switch (s) {
      case 'tutorial':
        return LevelType.tutorial;
      case 'puzzle':
        return LevelType.puzzle;
      case 'debugging':
        return LevelType.debugging;
      case 'optimization_challenge':
        return LevelType.optimizationChallenge;
      case 'boss':
        return LevelType.boss;
      default:
        return LevelType.puzzle;
    }
  }

  bool get isBlockModeOnly => this == LevelType.tutorial;
  bool get requiresCodeMode =>
      this == LevelType.debugging ||
      this == LevelType.optimizationChallenge ||
      this == LevelType.boss;
  bool get canFail => this != LevelType.tutorial;
  bool get hasStarRating => this != LevelType.tutorial;
}

/// A single hint in the 3-tier system.
class HintModel {
  final HintTierType tier;
  final String content;
  final String? codeSnippet; // Only for PartialReveal and FullSolution

  const HintModel({
    required this.tier,
    required this.content,
    this.codeSnippet,
  });

  factory HintModel.fromJson(Map<String, dynamic> json) {
    HintTierType parsedTier = HintTierType.nudge;
    if (json['tier'] is int) {
      final tierInt = json['tier'] as int;
      if (tierInt == 1) parsedTier = HintTierType.nudge;
      if (tierInt == 2) parsedTier = HintTierType.partialReveal;
      if (tierInt == 3) parsedTier = HintTierType.fullSolution;
    } else if (json['tier'] is String) {
      parsedTier = HintTierType.fromString(json['tier'] as String);
    }

    return HintModel(
      tier: parsedTier,
      content: (json['content'] ?? json['text']) as String? ?? '',
      codeSnippet: (json['code_snippet'] ?? json['codeSnippet']) as String?,
    );
  }
}

enum HintTierType {
  nudge,
  partialReveal,
  fullSolution;

  static HintTierType fromString(String s) {
    switch (s) {
      case 'nudge':
        return HintTierType.nudge;
      case 'partial_reveal':
        return HintTierType.partialReveal;
      case 'full_solution':
        return HintTierType.fullSolution;
      default:
        return HintTierType.nudge;
    }
  }

  int get insightPointCost {
    switch (this) {
      case HintTierType.nudge:
        return 5;
      case HintTierType.partialReveal:
        return 15;
      case HintTierType.fullSolution:
        return 30;
    }
  }
}

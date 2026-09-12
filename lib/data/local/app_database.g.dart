// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PlayerProfilesTable extends PlayerProfiles
    with TableInfo<$PlayerProfilesTable, PlayerProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlayerProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _displayNameMeta =
      const VerificationMeta('displayName');
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
      'display_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _rankTitleMeta =
      const VerificationMeta('rankTitle');
  @override
  late final GeneratedColumn<String> rankTitle = GeneratedColumn<String>(
      'rank_title', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Junior Analyst'));
  static const VerificationMeta _totalXpMeta =
      const VerificationMeta('totalXp');
  @override
  late final GeneratedColumn<int> totalXp = GeneratedColumn<int>(
      'total_xp', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _insightPointsMeta =
      const VerificationMeta('insightPoints');
  @override
  late final GeneratedColumn<int> insightPoints = GeneratedColumn<int>(
      'insight_points', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _streakCountMeta =
      const VerificationMeta('streakCount');
  @override
  late final GeneratedColumn<int> streakCount = GeneratedColumn<int>(
      'streak_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _streakFreezeAvailableMeta =
      const VerificationMeta('streakFreezeAvailable');
  @override
  late final GeneratedColumn<int> streakFreezeAvailable = GeneratedColumn<int>(
      'streak_freeze_available', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _activeThemeMeta =
      const VerificationMeta('activeTheme');
  @override
  late final GeneratedColumn<String> activeTheme = GeneratedColumn<String>(
      'active_theme', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('terminal_classic'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _cloudSyncIdMeta =
      const VerificationMeta('cloudSyncId');
  @override
  late final GeneratedColumn<String> cloudSyncId = GeneratedColumn<String>(
      'cloud_sync_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        displayName,
        rankTitle,
        totalXp,
        insightPoints,
        streakCount,
        streakFreezeAvailable,
        activeTheme,
        createdAt,
        cloudSyncId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'player_profiles';
  @override
  VerificationContext validateIntegrity(Insertable<PlayerProfile> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('display_name')) {
      context.handle(
          _displayNameMeta,
          displayName.isAcceptableOrUnknown(
              data['display_name']!, _displayNameMeta));
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('rank_title')) {
      context.handle(_rankTitleMeta,
          rankTitle.isAcceptableOrUnknown(data['rank_title']!, _rankTitleMeta));
    }
    if (data.containsKey('total_xp')) {
      context.handle(_totalXpMeta,
          totalXp.isAcceptableOrUnknown(data['total_xp']!, _totalXpMeta));
    }
    if (data.containsKey('insight_points')) {
      context.handle(
          _insightPointsMeta,
          insightPoints.isAcceptableOrUnknown(
              data['insight_points']!, _insightPointsMeta));
    }
    if (data.containsKey('streak_count')) {
      context.handle(
          _streakCountMeta,
          streakCount.isAcceptableOrUnknown(
              data['streak_count']!, _streakCountMeta));
    }
    if (data.containsKey('streak_freeze_available')) {
      context.handle(
          _streakFreezeAvailableMeta,
          streakFreezeAvailable.isAcceptableOrUnknown(
              data['streak_freeze_available']!, _streakFreezeAvailableMeta));
    }
    if (data.containsKey('active_theme')) {
      context.handle(
          _activeThemeMeta,
          activeTheme.isAcceptableOrUnknown(
              data['active_theme']!, _activeThemeMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('cloud_sync_id')) {
      context.handle(
          _cloudSyncIdMeta,
          cloudSyncId.isAcceptableOrUnknown(
              data['cloud_sync_id']!, _cloudSyncIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlayerProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlayerProfile(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      displayName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}display_name'])!,
      rankTitle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rank_title'])!,
      totalXp: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_xp'])!,
      insightPoints: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}insight_points'])!,
      streakCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}streak_count'])!,
      streakFreezeAvailable: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}streak_freeze_available'])!,
      activeTheme: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}active_theme'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      cloudSyncId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cloud_sync_id']),
    );
  }

  @override
  $PlayerProfilesTable createAlias(String alias) {
    return $PlayerProfilesTable(attachedDatabase, alias);
  }
}

class PlayerProfile extends DataClass implements Insertable<PlayerProfile> {
  final int id;
  final String displayName;
  final String rankTitle;
  final int totalXp;
  final int insightPoints;
  final int streakCount;
  final int streakFreezeAvailable;
  final String activeTheme;
  final int createdAt;
  final String? cloudSyncId;
  const PlayerProfile(
      {required this.id,
      required this.displayName,
      required this.rankTitle,
      required this.totalXp,
      required this.insightPoints,
      required this.streakCount,
      required this.streakFreezeAvailable,
      required this.activeTheme,
      required this.createdAt,
      this.cloudSyncId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['display_name'] = Variable<String>(displayName);
    map['rank_title'] = Variable<String>(rankTitle);
    map['total_xp'] = Variable<int>(totalXp);
    map['insight_points'] = Variable<int>(insightPoints);
    map['streak_count'] = Variable<int>(streakCount);
    map['streak_freeze_available'] = Variable<int>(streakFreezeAvailable);
    map['active_theme'] = Variable<String>(activeTheme);
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || cloudSyncId != null) {
      map['cloud_sync_id'] = Variable<String>(cloudSyncId);
    }
    return map;
  }

  PlayerProfilesCompanion toCompanion(bool nullToAbsent) {
    return PlayerProfilesCompanion(
      id: Value(id),
      displayName: Value(displayName),
      rankTitle: Value(rankTitle),
      totalXp: Value(totalXp),
      insightPoints: Value(insightPoints),
      streakCount: Value(streakCount),
      streakFreezeAvailable: Value(streakFreezeAvailable),
      activeTheme: Value(activeTheme),
      createdAt: Value(createdAt),
      cloudSyncId: cloudSyncId == null && nullToAbsent
          ? const Value.absent()
          : Value(cloudSyncId),
    );
  }

  factory PlayerProfile.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlayerProfile(
      id: serializer.fromJson<int>(json['id']),
      displayName: serializer.fromJson<String>(json['displayName']),
      rankTitle: serializer.fromJson<String>(json['rankTitle']),
      totalXp: serializer.fromJson<int>(json['totalXp']),
      insightPoints: serializer.fromJson<int>(json['insightPoints']),
      streakCount: serializer.fromJson<int>(json['streakCount']),
      streakFreezeAvailable:
          serializer.fromJson<int>(json['streakFreezeAvailable']),
      activeTheme: serializer.fromJson<String>(json['activeTheme']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      cloudSyncId: serializer.fromJson<String?>(json['cloudSyncId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'displayName': serializer.toJson<String>(displayName),
      'rankTitle': serializer.toJson<String>(rankTitle),
      'totalXp': serializer.toJson<int>(totalXp),
      'insightPoints': serializer.toJson<int>(insightPoints),
      'streakCount': serializer.toJson<int>(streakCount),
      'streakFreezeAvailable': serializer.toJson<int>(streakFreezeAvailable),
      'activeTheme': serializer.toJson<String>(activeTheme),
      'createdAt': serializer.toJson<int>(createdAt),
      'cloudSyncId': serializer.toJson<String?>(cloudSyncId),
    };
  }

  PlayerProfile copyWith(
          {int? id,
          String? displayName,
          String? rankTitle,
          int? totalXp,
          int? insightPoints,
          int? streakCount,
          int? streakFreezeAvailable,
          String? activeTheme,
          int? createdAt,
          Value<String?> cloudSyncId = const Value.absent()}) =>
      PlayerProfile(
        id: id ?? this.id,
        displayName: displayName ?? this.displayName,
        rankTitle: rankTitle ?? this.rankTitle,
        totalXp: totalXp ?? this.totalXp,
        insightPoints: insightPoints ?? this.insightPoints,
        streakCount: streakCount ?? this.streakCount,
        streakFreezeAvailable:
            streakFreezeAvailable ?? this.streakFreezeAvailable,
        activeTheme: activeTheme ?? this.activeTheme,
        createdAt: createdAt ?? this.createdAt,
        cloudSyncId: cloudSyncId.present ? cloudSyncId.value : this.cloudSyncId,
      );
  PlayerProfile copyWithCompanion(PlayerProfilesCompanion data) {
    return PlayerProfile(
      id: data.id.present ? data.id.value : this.id,
      displayName:
          data.displayName.present ? data.displayName.value : this.displayName,
      rankTitle: data.rankTitle.present ? data.rankTitle.value : this.rankTitle,
      totalXp: data.totalXp.present ? data.totalXp.value : this.totalXp,
      insightPoints: data.insightPoints.present
          ? data.insightPoints.value
          : this.insightPoints,
      streakCount:
          data.streakCount.present ? data.streakCount.value : this.streakCount,
      streakFreezeAvailable: data.streakFreezeAvailable.present
          ? data.streakFreezeAvailable.value
          : this.streakFreezeAvailable,
      activeTheme:
          data.activeTheme.present ? data.activeTheme.value : this.activeTheme,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      cloudSyncId:
          data.cloudSyncId.present ? data.cloudSyncId.value : this.cloudSyncId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlayerProfile(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('rankTitle: $rankTitle, ')
          ..write('totalXp: $totalXp, ')
          ..write('insightPoints: $insightPoints, ')
          ..write('streakCount: $streakCount, ')
          ..write('streakFreezeAvailable: $streakFreezeAvailable, ')
          ..write('activeTheme: $activeTheme, ')
          ..write('createdAt: $createdAt, ')
          ..write('cloudSyncId: $cloudSyncId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      displayName,
      rankTitle,
      totalXp,
      insightPoints,
      streakCount,
      streakFreezeAvailable,
      activeTheme,
      createdAt,
      cloudSyncId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlayerProfile &&
          other.id == this.id &&
          other.displayName == this.displayName &&
          other.rankTitle == this.rankTitle &&
          other.totalXp == this.totalXp &&
          other.insightPoints == this.insightPoints &&
          other.streakCount == this.streakCount &&
          other.streakFreezeAvailable == this.streakFreezeAvailable &&
          other.activeTheme == this.activeTheme &&
          other.createdAt == this.createdAt &&
          other.cloudSyncId == this.cloudSyncId);
}

class PlayerProfilesCompanion extends UpdateCompanion<PlayerProfile> {
  final Value<int> id;
  final Value<String> displayName;
  final Value<String> rankTitle;
  final Value<int> totalXp;
  final Value<int> insightPoints;
  final Value<int> streakCount;
  final Value<int> streakFreezeAvailable;
  final Value<String> activeTheme;
  final Value<int> createdAt;
  final Value<String?> cloudSyncId;
  const PlayerProfilesCompanion({
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.rankTitle = const Value.absent(),
    this.totalXp = const Value.absent(),
    this.insightPoints = const Value.absent(),
    this.streakCount = const Value.absent(),
    this.streakFreezeAvailable = const Value.absent(),
    this.activeTheme = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.cloudSyncId = const Value.absent(),
  });
  PlayerProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String displayName,
    this.rankTitle = const Value.absent(),
    this.totalXp = const Value.absent(),
    this.insightPoints = const Value.absent(),
    this.streakCount = const Value.absent(),
    this.streakFreezeAvailable = const Value.absent(),
    this.activeTheme = const Value.absent(),
    required int createdAt,
    this.cloudSyncId = const Value.absent(),
  })  : displayName = Value(displayName),
        createdAt = Value(createdAt);
  static Insertable<PlayerProfile> custom({
    Expression<int>? id,
    Expression<String>? displayName,
    Expression<String>? rankTitle,
    Expression<int>? totalXp,
    Expression<int>? insightPoints,
    Expression<int>? streakCount,
    Expression<int>? streakFreezeAvailable,
    Expression<String>? activeTheme,
    Expression<int>? createdAt,
    Expression<String>? cloudSyncId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (displayName != null) 'display_name': displayName,
      if (rankTitle != null) 'rank_title': rankTitle,
      if (totalXp != null) 'total_xp': totalXp,
      if (insightPoints != null) 'insight_points': insightPoints,
      if (streakCount != null) 'streak_count': streakCount,
      if (streakFreezeAvailable != null)
        'streak_freeze_available': streakFreezeAvailable,
      if (activeTheme != null) 'active_theme': activeTheme,
      if (createdAt != null) 'created_at': createdAt,
      if (cloudSyncId != null) 'cloud_sync_id': cloudSyncId,
    });
  }

  PlayerProfilesCompanion copyWith(
      {Value<int>? id,
      Value<String>? displayName,
      Value<String>? rankTitle,
      Value<int>? totalXp,
      Value<int>? insightPoints,
      Value<int>? streakCount,
      Value<int>? streakFreezeAvailable,
      Value<String>? activeTheme,
      Value<int>? createdAt,
      Value<String?>? cloudSyncId}) {
    return PlayerProfilesCompanion(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      rankTitle: rankTitle ?? this.rankTitle,
      totalXp: totalXp ?? this.totalXp,
      insightPoints: insightPoints ?? this.insightPoints,
      streakCount: streakCount ?? this.streakCount,
      streakFreezeAvailable:
          streakFreezeAvailable ?? this.streakFreezeAvailable,
      activeTheme: activeTheme ?? this.activeTheme,
      createdAt: createdAt ?? this.createdAt,
      cloudSyncId: cloudSyncId ?? this.cloudSyncId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (rankTitle.present) {
      map['rank_title'] = Variable<String>(rankTitle.value);
    }
    if (totalXp.present) {
      map['total_xp'] = Variable<int>(totalXp.value);
    }
    if (insightPoints.present) {
      map['insight_points'] = Variable<int>(insightPoints.value);
    }
    if (streakCount.present) {
      map['streak_count'] = Variable<int>(streakCount.value);
    }
    if (streakFreezeAvailable.present) {
      map['streak_freeze_available'] =
          Variable<int>(streakFreezeAvailable.value);
    }
    if (activeTheme.present) {
      map['active_theme'] = Variable<String>(activeTheme.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (cloudSyncId.present) {
      map['cloud_sync_id'] = Variable<String>(cloudSyncId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlayerProfilesCompanion(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('rankTitle: $rankTitle, ')
          ..write('totalXp: $totalXp, ')
          ..write('insightPoints: $insightPoints, ')
          ..write('streakCount: $streakCount, ')
          ..write('streakFreezeAvailable: $streakFreezeAvailable, ')
          ..write('activeTheme: $activeTheme, ')
          ..write('createdAt: $createdAt, ')
          ..write('cloudSyncId: $cloudSyncId')
          ..write(')'))
        .toString();
  }
}

class $WorldProgressTable extends WorldProgress
    with TableInfo<$WorldProgressTable, WorldProgressData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorldProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _worldIdMeta =
      const VerificationMeta('worldId');
  @override
  late final GeneratedColumn<String> worldId = GeneratedColumn<String>(
      'world_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _levelsCompletedMeta =
      const VerificationMeta('levelsCompleted');
  @override
  late final GeneratedColumn<int> levelsCompleted = GeneratedColumn<int>(
      'levels_completed', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _totalLevelsMeta =
      const VerificationMeta('totalLevels');
  @override
  late final GeneratedColumn<int> totalLevels = GeneratedColumn<int>(
      'total_levels', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _unlockedMeta =
      const VerificationMeta('unlocked');
  @override
  late final GeneratedColumn<bool> unlocked = GeneratedColumn<bool>(
      'unlocked', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("unlocked" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [worldId, levelsCompleted, totalLevels, unlocked];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'world_progress';
  @override
  VerificationContext validateIntegrity(Insertable<WorldProgressData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('world_id')) {
      context.handle(_worldIdMeta,
          worldId.isAcceptableOrUnknown(data['world_id']!, _worldIdMeta));
    } else if (isInserting) {
      context.missing(_worldIdMeta);
    }
    if (data.containsKey('levels_completed')) {
      context.handle(
          _levelsCompletedMeta,
          levelsCompleted.isAcceptableOrUnknown(
              data['levels_completed']!, _levelsCompletedMeta));
    }
    if (data.containsKey('total_levels')) {
      context.handle(
          _totalLevelsMeta,
          totalLevels.isAcceptableOrUnknown(
              data['total_levels']!, _totalLevelsMeta));
    } else if (isInserting) {
      context.missing(_totalLevelsMeta);
    }
    if (data.containsKey('unlocked')) {
      context.handle(_unlockedMeta,
          unlocked.isAcceptableOrUnknown(data['unlocked']!, _unlockedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {worldId};
  @override
  WorldProgressData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorldProgressData(
      worldId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}world_id'])!,
      levelsCompleted: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}levels_completed'])!,
      totalLevels: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_levels'])!,
      unlocked: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}unlocked'])!,
    );
  }

  @override
  $WorldProgressTable createAlias(String alias) {
    return $WorldProgressTable(attachedDatabase, alias);
  }
}

class WorldProgressData extends DataClass
    implements Insertable<WorldProgressData> {
  final String worldId;
  final int levelsCompleted;
  final int totalLevels;
  final bool unlocked;
  const WorldProgressData(
      {required this.worldId,
      required this.levelsCompleted,
      required this.totalLevels,
      required this.unlocked});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['world_id'] = Variable<String>(worldId);
    map['levels_completed'] = Variable<int>(levelsCompleted);
    map['total_levels'] = Variable<int>(totalLevels);
    map['unlocked'] = Variable<bool>(unlocked);
    return map;
  }

  WorldProgressCompanion toCompanion(bool nullToAbsent) {
    return WorldProgressCompanion(
      worldId: Value(worldId),
      levelsCompleted: Value(levelsCompleted),
      totalLevels: Value(totalLevels),
      unlocked: Value(unlocked),
    );
  }

  factory WorldProgressData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorldProgressData(
      worldId: serializer.fromJson<String>(json['worldId']),
      levelsCompleted: serializer.fromJson<int>(json['levelsCompleted']),
      totalLevels: serializer.fromJson<int>(json['totalLevels']),
      unlocked: serializer.fromJson<bool>(json['unlocked']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'worldId': serializer.toJson<String>(worldId),
      'levelsCompleted': serializer.toJson<int>(levelsCompleted),
      'totalLevels': serializer.toJson<int>(totalLevels),
      'unlocked': serializer.toJson<bool>(unlocked),
    };
  }

  WorldProgressData copyWith(
          {String? worldId,
          int? levelsCompleted,
          int? totalLevels,
          bool? unlocked}) =>
      WorldProgressData(
        worldId: worldId ?? this.worldId,
        levelsCompleted: levelsCompleted ?? this.levelsCompleted,
        totalLevels: totalLevels ?? this.totalLevels,
        unlocked: unlocked ?? this.unlocked,
      );
  WorldProgressData copyWithCompanion(WorldProgressCompanion data) {
    return WorldProgressData(
      worldId: data.worldId.present ? data.worldId.value : this.worldId,
      levelsCompleted: data.levelsCompleted.present
          ? data.levelsCompleted.value
          : this.levelsCompleted,
      totalLevels:
          data.totalLevels.present ? data.totalLevels.value : this.totalLevels,
      unlocked: data.unlocked.present ? data.unlocked.value : this.unlocked,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorldProgressData(')
          ..write('worldId: $worldId, ')
          ..write('levelsCompleted: $levelsCompleted, ')
          ..write('totalLevels: $totalLevels, ')
          ..write('unlocked: $unlocked')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(worldId, levelsCompleted, totalLevels, unlocked);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorldProgressData &&
          other.worldId == this.worldId &&
          other.levelsCompleted == this.levelsCompleted &&
          other.totalLevels == this.totalLevels &&
          other.unlocked == this.unlocked);
}

class WorldProgressCompanion extends UpdateCompanion<WorldProgressData> {
  final Value<String> worldId;
  final Value<int> levelsCompleted;
  final Value<int> totalLevels;
  final Value<bool> unlocked;
  final Value<int> rowid;
  const WorldProgressCompanion({
    this.worldId = const Value.absent(),
    this.levelsCompleted = const Value.absent(),
    this.totalLevels = const Value.absent(),
    this.unlocked = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorldProgressCompanion.insert({
    required String worldId,
    this.levelsCompleted = const Value.absent(),
    required int totalLevels,
    this.unlocked = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : worldId = Value(worldId),
        totalLevels = Value(totalLevels);
  static Insertable<WorldProgressData> custom({
    Expression<String>? worldId,
    Expression<int>? levelsCompleted,
    Expression<int>? totalLevels,
    Expression<bool>? unlocked,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (worldId != null) 'world_id': worldId,
      if (levelsCompleted != null) 'levels_completed': levelsCompleted,
      if (totalLevels != null) 'total_levels': totalLevels,
      if (unlocked != null) 'unlocked': unlocked,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorldProgressCompanion copyWith(
      {Value<String>? worldId,
      Value<int>? levelsCompleted,
      Value<int>? totalLevels,
      Value<bool>? unlocked,
      Value<int>? rowid}) {
    return WorldProgressCompanion(
      worldId: worldId ?? this.worldId,
      levelsCompleted: levelsCompleted ?? this.levelsCompleted,
      totalLevels: totalLevels ?? this.totalLevels,
      unlocked: unlocked ?? this.unlocked,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (worldId.present) {
      map['world_id'] = Variable<String>(worldId.value);
    }
    if (levelsCompleted.present) {
      map['levels_completed'] = Variable<int>(levelsCompleted.value);
    }
    if (totalLevels.present) {
      map['total_levels'] = Variable<int>(totalLevels.value);
    }
    if (unlocked.present) {
      map['unlocked'] = Variable<bool>(unlocked.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorldProgressCompanion(')
          ..write('worldId: $worldId, ')
          ..write('levelsCompleted: $levelsCompleted, ')
          ..write('totalLevels: $totalLevels, ')
          ..write('unlocked: $unlocked, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LevelAttemptsTable extends LevelAttempts
    with TableInfo<$LevelAttemptsTable, LevelAttempt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LevelAttemptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _levelIdMeta =
      const VerificationMeta('levelId');
  @override
  late final GeneratedColumn<String> levelId = GeneratedColumn<String>(
      'level_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _attemptNumberMeta =
      const VerificationMeta('attemptNumber');
  @override
  late final GeneratedColumn<int> attemptNumber = GeneratedColumn<int>(
      'attempt_number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _submittedQueryMeta =
      const VerificationMeta('submittedQuery');
  @override
  late final GeneratedColumn<String> submittedQuery = GeneratedColumn<String>(
      'submitted_query', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _passedSyntaxMeta =
      const VerificationMeta('passedSyntax');
  @override
  late final GeneratedColumn<bool> passedSyntax = GeneratedColumn<bool>(
      'passed_syntax', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("passed_syntax" IN (0, 1))'));
  static const VerificationMeta _passedSemanticMeta =
      const VerificationMeta('passedSemantic');
  @override
  late final GeneratedColumn<bool> passedSemantic = GeneratedColumn<bool>(
      'passed_semantic', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("passed_semantic" IN (0, 1))'));
  static const VerificationMeta _passedResultMeta =
      const VerificationMeta('passedResult');
  @override
  late final GeneratedColumn<bool> passedResult = GeneratedColumn<bool>(
      'passed_result', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("passed_result" IN (0, 1))'));
  static const VerificationMeta _efficiencyScoreMeta =
      const VerificationMeta('efficiencyScore');
  @override
  late final GeneratedColumn<double> efficiencyScore = GeneratedColumn<double>(
      'efficiency_score', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _hintTierUsedMeta =
      const VerificationMeta('hintTierUsed');
  @override
  late final GeneratedColumn<int> hintTierUsed = GeneratedColumn<int>(
      'hint_tier_used', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _durationMsMeta =
      const VerificationMeta('durationMs');
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
      'duration_ms', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        levelId,
        attemptNumber,
        submittedQuery,
        passedSyntax,
        passedSemantic,
        passedResult,
        efficiencyScore,
        hintTierUsed,
        durationMs,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'level_attempts';
  @override
  VerificationContext validateIntegrity(Insertable<LevelAttempt> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('level_id')) {
      context.handle(_levelIdMeta,
          levelId.isAcceptableOrUnknown(data['level_id']!, _levelIdMeta));
    } else if (isInserting) {
      context.missing(_levelIdMeta);
    }
    if (data.containsKey('attempt_number')) {
      context.handle(
          _attemptNumberMeta,
          attemptNumber.isAcceptableOrUnknown(
              data['attempt_number']!, _attemptNumberMeta));
    } else if (isInserting) {
      context.missing(_attemptNumberMeta);
    }
    if (data.containsKey('submitted_query')) {
      context.handle(
          _submittedQueryMeta,
          submittedQuery.isAcceptableOrUnknown(
              data['submitted_query']!, _submittedQueryMeta));
    } else if (isInserting) {
      context.missing(_submittedQueryMeta);
    }
    if (data.containsKey('passed_syntax')) {
      context.handle(
          _passedSyntaxMeta,
          passedSyntax.isAcceptableOrUnknown(
              data['passed_syntax']!, _passedSyntaxMeta));
    } else if (isInserting) {
      context.missing(_passedSyntaxMeta);
    }
    if (data.containsKey('passed_semantic')) {
      context.handle(
          _passedSemanticMeta,
          passedSemantic.isAcceptableOrUnknown(
              data['passed_semantic']!, _passedSemanticMeta));
    } else if (isInserting) {
      context.missing(_passedSemanticMeta);
    }
    if (data.containsKey('passed_result')) {
      context.handle(
          _passedResultMeta,
          passedResult.isAcceptableOrUnknown(
              data['passed_result']!, _passedResultMeta));
    } else if (isInserting) {
      context.missing(_passedResultMeta);
    }
    if (data.containsKey('efficiency_score')) {
      context.handle(
          _efficiencyScoreMeta,
          efficiencyScore.isAcceptableOrUnknown(
              data['efficiency_score']!, _efficiencyScoreMeta));
    }
    if (data.containsKey('hint_tier_used')) {
      context.handle(
          _hintTierUsedMeta,
          hintTierUsed.isAcceptableOrUnknown(
              data['hint_tier_used']!, _hintTierUsedMeta));
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
          _durationMsMeta,
          durationMs.isAcceptableOrUnknown(
              data['duration_ms']!, _durationMsMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LevelAttempt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LevelAttempt(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      levelId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}level_id'])!,
      attemptNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}attempt_number'])!,
      submittedQuery: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}submitted_query'])!,
      passedSyntax: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}passed_syntax'])!,
      passedSemantic: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}passed_semantic'])!,
      passedResult: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}passed_result'])!,
      efficiencyScore: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}efficiency_score']),
      hintTierUsed: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}hint_tier_used'])!,
      durationMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_ms']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $LevelAttemptsTable createAlias(String alias) {
    return $LevelAttemptsTable(attachedDatabase, alias);
  }
}

class LevelAttempt extends DataClass implements Insertable<LevelAttempt> {
  final int id;
  final String levelId;
  final int attemptNumber;
  final String submittedQuery;
  final bool passedSyntax;
  final bool passedSemantic;
  final bool passedResult;
  final double? efficiencyScore;
  final int hintTierUsed;
  final int? durationMs;
  final int createdAt;
  const LevelAttempt(
      {required this.id,
      required this.levelId,
      required this.attemptNumber,
      required this.submittedQuery,
      required this.passedSyntax,
      required this.passedSemantic,
      required this.passedResult,
      this.efficiencyScore,
      required this.hintTierUsed,
      this.durationMs,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['level_id'] = Variable<String>(levelId);
    map['attempt_number'] = Variable<int>(attemptNumber);
    map['submitted_query'] = Variable<String>(submittedQuery);
    map['passed_syntax'] = Variable<bool>(passedSyntax);
    map['passed_semantic'] = Variable<bool>(passedSemantic);
    map['passed_result'] = Variable<bool>(passedResult);
    if (!nullToAbsent || efficiencyScore != null) {
      map['efficiency_score'] = Variable<double>(efficiencyScore);
    }
    map['hint_tier_used'] = Variable<int>(hintTierUsed);
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  LevelAttemptsCompanion toCompanion(bool nullToAbsent) {
    return LevelAttemptsCompanion(
      id: Value(id),
      levelId: Value(levelId),
      attemptNumber: Value(attemptNumber),
      submittedQuery: Value(submittedQuery),
      passedSyntax: Value(passedSyntax),
      passedSemantic: Value(passedSemantic),
      passedResult: Value(passedResult),
      efficiencyScore: efficiencyScore == null && nullToAbsent
          ? const Value.absent()
          : Value(efficiencyScore),
      hintTierUsed: Value(hintTierUsed),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      createdAt: Value(createdAt),
    );
  }

  factory LevelAttempt.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LevelAttempt(
      id: serializer.fromJson<int>(json['id']),
      levelId: serializer.fromJson<String>(json['levelId']),
      attemptNumber: serializer.fromJson<int>(json['attemptNumber']),
      submittedQuery: serializer.fromJson<String>(json['submittedQuery']),
      passedSyntax: serializer.fromJson<bool>(json['passedSyntax']),
      passedSemantic: serializer.fromJson<bool>(json['passedSemantic']),
      passedResult: serializer.fromJson<bool>(json['passedResult']),
      efficiencyScore: serializer.fromJson<double?>(json['efficiencyScore']),
      hintTierUsed: serializer.fromJson<int>(json['hintTierUsed']),
      durationMs: serializer.fromJson<int?>(json['durationMs']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'levelId': serializer.toJson<String>(levelId),
      'attemptNumber': serializer.toJson<int>(attemptNumber),
      'submittedQuery': serializer.toJson<String>(submittedQuery),
      'passedSyntax': serializer.toJson<bool>(passedSyntax),
      'passedSemantic': serializer.toJson<bool>(passedSemantic),
      'passedResult': serializer.toJson<bool>(passedResult),
      'efficiencyScore': serializer.toJson<double?>(efficiencyScore),
      'hintTierUsed': serializer.toJson<int>(hintTierUsed),
      'durationMs': serializer.toJson<int?>(durationMs),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  LevelAttempt copyWith(
          {int? id,
          String? levelId,
          int? attemptNumber,
          String? submittedQuery,
          bool? passedSyntax,
          bool? passedSemantic,
          bool? passedResult,
          Value<double?> efficiencyScore = const Value.absent(),
          int? hintTierUsed,
          Value<int?> durationMs = const Value.absent(),
          int? createdAt}) =>
      LevelAttempt(
        id: id ?? this.id,
        levelId: levelId ?? this.levelId,
        attemptNumber: attemptNumber ?? this.attemptNumber,
        submittedQuery: submittedQuery ?? this.submittedQuery,
        passedSyntax: passedSyntax ?? this.passedSyntax,
        passedSemantic: passedSemantic ?? this.passedSemantic,
        passedResult: passedResult ?? this.passedResult,
        efficiencyScore: efficiencyScore.present
            ? efficiencyScore.value
            : this.efficiencyScore,
        hintTierUsed: hintTierUsed ?? this.hintTierUsed,
        durationMs: durationMs.present ? durationMs.value : this.durationMs,
        createdAt: createdAt ?? this.createdAt,
      );
  LevelAttempt copyWithCompanion(LevelAttemptsCompanion data) {
    return LevelAttempt(
      id: data.id.present ? data.id.value : this.id,
      levelId: data.levelId.present ? data.levelId.value : this.levelId,
      attemptNumber: data.attemptNumber.present
          ? data.attemptNumber.value
          : this.attemptNumber,
      submittedQuery: data.submittedQuery.present
          ? data.submittedQuery.value
          : this.submittedQuery,
      passedSyntax: data.passedSyntax.present
          ? data.passedSyntax.value
          : this.passedSyntax,
      passedSemantic: data.passedSemantic.present
          ? data.passedSemantic.value
          : this.passedSemantic,
      passedResult: data.passedResult.present
          ? data.passedResult.value
          : this.passedResult,
      efficiencyScore: data.efficiencyScore.present
          ? data.efficiencyScore.value
          : this.efficiencyScore,
      hintTierUsed: data.hintTierUsed.present
          ? data.hintTierUsed.value
          : this.hintTierUsed,
      durationMs:
          data.durationMs.present ? data.durationMs.value : this.durationMs,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LevelAttempt(')
          ..write('id: $id, ')
          ..write('levelId: $levelId, ')
          ..write('attemptNumber: $attemptNumber, ')
          ..write('submittedQuery: $submittedQuery, ')
          ..write('passedSyntax: $passedSyntax, ')
          ..write('passedSemantic: $passedSemantic, ')
          ..write('passedResult: $passedResult, ')
          ..write('efficiencyScore: $efficiencyScore, ')
          ..write('hintTierUsed: $hintTierUsed, ')
          ..write('durationMs: $durationMs, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      levelId,
      attemptNumber,
      submittedQuery,
      passedSyntax,
      passedSemantic,
      passedResult,
      efficiencyScore,
      hintTierUsed,
      durationMs,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LevelAttempt &&
          other.id == this.id &&
          other.levelId == this.levelId &&
          other.attemptNumber == this.attemptNumber &&
          other.submittedQuery == this.submittedQuery &&
          other.passedSyntax == this.passedSyntax &&
          other.passedSemantic == this.passedSemantic &&
          other.passedResult == this.passedResult &&
          other.efficiencyScore == this.efficiencyScore &&
          other.hintTierUsed == this.hintTierUsed &&
          other.durationMs == this.durationMs &&
          other.createdAt == this.createdAt);
}

class LevelAttemptsCompanion extends UpdateCompanion<LevelAttempt> {
  final Value<int> id;
  final Value<String> levelId;
  final Value<int> attemptNumber;
  final Value<String> submittedQuery;
  final Value<bool> passedSyntax;
  final Value<bool> passedSemantic;
  final Value<bool> passedResult;
  final Value<double?> efficiencyScore;
  final Value<int> hintTierUsed;
  final Value<int?> durationMs;
  final Value<int> createdAt;
  const LevelAttemptsCompanion({
    this.id = const Value.absent(),
    this.levelId = const Value.absent(),
    this.attemptNumber = const Value.absent(),
    this.submittedQuery = const Value.absent(),
    this.passedSyntax = const Value.absent(),
    this.passedSemantic = const Value.absent(),
    this.passedResult = const Value.absent(),
    this.efficiencyScore = const Value.absent(),
    this.hintTierUsed = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  LevelAttemptsCompanion.insert({
    this.id = const Value.absent(),
    required String levelId,
    required int attemptNumber,
    required String submittedQuery,
    required bool passedSyntax,
    required bool passedSemantic,
    required bool passedResult,
    this.efficiencyScore = const Value.absent(),
    this.hintTierUsed = const Value.absent(),
    this.durationMs = const Value.absent(),
    required int createdAt,
  })  : levelId = Value(levelId),
        attemptNumber = Value(attemptNumber),
        submittedQuery = Value(submittedQuery),
        passedSyntax = Value(passedSyntax),
        passedSemantic = Value(passedSemantic),
        passedResult = Value(passedResult),
        createdAt = Value(createdAt);
  static Insertable<LevelAttempt> custom({
    Expression<int>? id,
    Expression<String>? levelId,
    Expression<int>? attemptNumber,
    Expression<String>? submittedQuery,
    Expression<bool>? passedSyntax,
    Expression<bool>? passedSemantic,
    Expression<bool>? passedResult,
    Expression<double>? efficiencyScore,
    Expression<int>? hintTierUsed,
    Expression<int>? durationMs,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (levelId != null) 'level_id': levelId,
      if (attemptNumber != null) 'attempt_number': attemptNumber,
      if (submittedQuery != null) 'submitted_query': submittedQuery,
      if (passedSyntax != null) 'passed_syntax': passedSyntax,
      if (passedSemantic != null) 'passed_semantic': passedSemantic,
      if (passedResult != null) 'passed_result': passedResult,
      if (efficiencyScore != null) 'efficiency_score': efficiencyScore,
      if (hintTierUsed != null) 'hint_tier_used': hintTierUsed,
      if (durationMs != null) 'duration_ms': durationMs,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  LevelAttemptsCompanion copyWith(
      {Value<int>? id,
      Value<String>? levelId,
      Value<int>? attemptNumber,
      Value<String>? submittedQuery,
      Value<bool>? passedSyntax,
      Value<bool>? passedSemantic,
      Value<bool>? passedResult,
      Value<double?>? efficiencyScore,
      Value<int>? hintTierUsed,
      Value<int?>? durationMs,
      Value<int>? createdAt}) {
    return LevelAttemptsCompanion(
      id: id ?? this.id,
      levelId: levelId ?? this.levelId,
      attemptNumber: attemptNumber ?? this.attemptNumber,
      submittedQuery: submittedQuery ?? this.submittedQuery,
      passedSyntax: passedSyntax ?? this.passedSyntax,
      passedSemantic: passedSemantic ?? this.passedSemantic,
      passedResult: passedResult ?? this.passedResult,
      efficiencyScore: efficiencyScore ?? this.efficiencyScore,
      hintTierUsed: hintTierUsed ?? this.hintTierUsed,
      durationMs: durationMs ?? this.durationMs,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (levelId.present) {
      map['level_id'] = Variable<String>(levelId.value);
    }
    if (attemptNumber.present) {
      map['attempt_number'] = Variable<int>(attemptNumber.value);
    }
    if (submittedQuery.present) {
      map['submitted_query'] = Variable<String>(submittedQuery.value);
    }
    if (passedSyntax.present) {
      map['passed_syntax'] = Variable<bool>(passedSyntax.value);
    }
    if (passedSemantic.present) {
      map['passed_semantic'] = Variable<bool>(passedSemantic.value);
    }
    if (passedResult.present) {
      map['passed_result'] = Variable<bool>(passedResult.value);
    }
    if (efficiencyScore.present) {
      map['efficiency_score'] = Variable<double>(efficiencyScore.value);
    }
    if (hintTierUsed.present) {
      map['hint_tier_used'] = Variable<int>(hintTierUsed.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LevelAttemptsCompanion(')
          ..write('id: $id, ')
          ..write('levelId: $levelId, ')
          ..write('attemptNumber: $attemptNumber, ')
          ..write('submittedQuery: $submittedQuery, ')
          ..write('passedSyntax: $passedSyntax, ')
          ..write('passedSemantic: $passedSemantic, ')
          ..write('passedResult: $passedResult, ')
          ..write('efficiencyScore: $efficiencyScore, ')
          ..write('hintTierUsed: $hintTierUsed, ')
          ..write('durationMs: $durationMs, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $LevelCompletionsTable extends LevelCompletions
    with TableInfo<$LevelCompletionsTable, LevelCompletion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LevelCompletionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _levelIdMeta =
      const VerificationMeta('levelId');
  @override
  late final GeneratedColumn<String> levelId = GeneratedColumn<String>(
      'level_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _starsEarnedMeta =
      const VerificationMeta('starsEarned');
  @override
  late final GeneratedColumn<int> starsEarned = GeneratedColumn<int>(
      'stars_earned', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _timeMedalMeta =
      const VerificationMeta('timeMedal');
  @override
  late final GeneratedColumn<int> timeMedal = GeneratedColumn<int>(
      'time_medal', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _bestDurationMsMeta =
      const VerificationMeta('bestDurationMs');
  @override
  late final GeneratedColumn<int> bestDurationMs = GeneratedColumn<int>(
      'best_duration_ms', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<int> completedAt = GeneratedColumn<int>(
      'completed_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [levelId, starsEarned, timeMedal, bestDurationMs, completedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'level_completions';
  @override
  VerificationContext validateIntegrity(Insertable<LevelCompletion> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('level_id')) {
      context.handle(_levelIdMeta,
          levelId.isAcceptableOrUnknown(data['level_id']!, _levelIdMeta));
    } else if (isInserting) {
      context.missing(_levelIdMeta);
    }
    if (data.containsKey('stars_earned')) {
      context.handle(
          _starsEarnedMeta,
          starsEarned.isAcceptableOrUnknown(
              data['stars_earned']!, _starsEarnedMeta));
    } else if (isInserting) {
      context.missing(_starsEarnedMeta);
    }
    if (data.containsKey('time_medal')) {
      context.handle(_timeMedalMeta,
          timeMedal.isAcceptableOrUnknown(data['time_medal']!, _timeMedalMeta));
    }
    if (data.containsKey('best_duration_ms')) {
      context.handle(
          _bestDurationMsMeta,
          bestDurationMs.isAcceptableOrUnknown(
              data['best_duration_ms']!, _bestDurationMsMeta));
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {levelId};
  @override
  LevelCompletion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LevelCompletion(
      levelId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}level_id'])!,
      starsEarned: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}stars_earned'])!,
      timeMedal: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}time_medal']),
      bestDurationMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}best_duration_ms']),
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}completed_at'])!,
    );
  }

  @override
  $LevelCompletionsTable createAlias(String alias) {
    return $LevelCompletionsTable(attachedDatabase, alias);
  }
}

class LevelCompletion extends DataClass implements Insertable<LevelCompletion> {
  final String levelId;
  final int starsEarned;
  final int? timeMedal;
  final int? bestDurationMs;
  final int completedAt;
  const LevelCompletion(
      {required this.levelId,
      required this.starsEarned,
      this.timeMedal,
      this.bestDurationMs,
      required this.completedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['level_id'] = Variable<String>(levelId);
    map['stars_earned'] = Variable<int>(starsEarned);
    if (!nullToAbsent || timeMedal != null) {
      map['time_medal'] = Variable<int>(timeMedal);
    }
    if (!nullToAbsent || bestDurationMs != null) {
      map['best_duration_ms'] = Variable<int>(bestDurationMs);
    }
    map['completed_at'] = Variable<int>(completedAt);
    return map;
  }

  LevelCompletionsCompanion toCompanion(bool nullToAbsent) {
    return LevelCompletionsCompanion(
      levelId: Value(levelId),
      starsEarned: Value(starsEarned),
      timeMedal: timeMedal == null && nullToAbsent
          ? const Value.absent()
          : Value(timeMedal),
      bestDurationMs: bestDurationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(bestDurationMs),
      completedAt: Value(completedAt),
    );
  }

  factory LevelCompletion.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LevelCompletion(
      levelId: serializer.fromJson<String>(json['levelId']),
      starsEarned: serializer.fromJson<int>(json['starsEarned']),
      timeMedal: serializer.fromJson<int?>(json['timeMedal']),
      bestDurationMs: serializer.fromJson<int?>(json['bestDurationMs']),
      completedAt: serializer.fromJson<int>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'levelId': serializer.toJson<String>(levelId),
      'starsEarned': serializer.toJson<int>(starsEarned),
      'timeMedal': serializer.toJson<int?>(timeMedal),
      'bestDurationMs': serializer.toJson<int?>(bestDurationMs),
      'completedAt': serializer.toJson<int>(completedAt),
    };
  }

  LevelCompletion copyWith(
          {String? levelId,
          int? starsEarned,
          Value<int?> timeMedal = const Value.absent(),
          Value<int?> bestDurationMs = const Value.absent(),
          int? completedAt}) =>
      LevelCompletion(
        levelId: levelId ?? this.levelId,
        starsEarned: starsEarned ?? this.starsEarned,
        timeMedal: timeMedal.present ? timeMedal.value : this.timeMedal,
        bestDurationMs:
            bestDurationMs.present ? bestDurationMs.value : this.bestDurationMs,
        completedAt: completedAt ?? this.completedAt,
      );
  LevelCompletion copyWithCompanion(LevelCompletionsCompanion data) {
    return LevelCompletion(
      levelId: data.levelId.present ? data.levelId.value : this.levelId,
      starsEarned:
          data.starsEarned.present ? data.starsEarned.value : this.starsEarned,
      timeMedal: data.timeMedal.present ? data.timeMedal.value : this.timeMedal,
      bestDurationMs: data.bestDurationMs.present
          ? data.bestDurationMs.value
          : this.bestDurationMs,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LevelCompletion(')
          ..write('levelId: $levelId, ')
          ..write('starsEarned: $starsEarned, ')
          ..write('timeMedal: $timeMedal, ')
          ..write('bestDurationMs: $bestDurationMs, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(levelId, starsEarned, timeMedal, bestDurationMs, completedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LevelCompletion &&
          other.levelId == this.levelId &&
          other.starsEarned == this.starsEarned &&
          other.timeMedal == this.timeMedal &&
          other.bestDurationMs == this.bestDurationMs &&
          other.completedAt == this.completedAt);
}

class LevelCompletionsCompanion extends UpdateCompanion<LevelCompletion> {
  final Value<String> levelId;
  final Value<int> starsEarned;
  final Value<int?> timeMedal;
  final Value<int?> bestDurationMs;
  final Value<int> completedAt;
  final Value<int> rowid;
  const LevelCompletionsCompanion({
    this.levelId = const Value.absent(),
    this.starsEarned = const Value.absent(),
    this.timeMedal = const Value.absent(),
    this.bestDurationMs = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LevelCompletionsCompanion.insert({
    required String levelId,
    required int starsEarned,
    this.timeMedal = const Value.absent(),
    this.bestDurationMs = const Value.absent(),
    required int completedAt,
    this.rowid = const Value.absent(),
  })  : levelId = Value(levelId),
        starsEarned = Value(starsEarned),
        completedAt = Value(completedAt);
  static Insertable<LevelCompletion> custom({
    Expression<String>? levelId,
    Expression<int>? starsEarned,
    Expression<int>? timeMedal,
    Expression<int>? bestDurationMs,
    Expression<int>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (levelId != null) 'level_id': levelId,
      if (starsEarned != null) 'stars_earned': starsEarned,
      if (timeMedal != null) 'time_medal': timeMedal,
      if (bestDurationMs != null) 'best_duration_ms': bestDurationMs,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LevelCompletionsCompanion copyWith(
      {Value<String>? levelId,
      Value<int>? starsEarned,
      Value<int?>? timeMedal,
      Value<int?>? bestDurationMs,
      Value<int>? completedAt,
      Value<int>? rowid}) {
    return LevelCompletionsCompanion(
      levelId: levelId ?? this.levelId,
      starsEarned: starsEarned ?? this.starsEarned,
      timeMedal: timeMedal ?? this.timeMedal,
      bestDurationMs: bestDurationMs ?? this.bestDurationMs,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (levelId.present) {
      map['level_id'] = Variable<String>(levelId.value);
    }
    if (starsEarned.present) {
      map['stars_earned'] = Variable<int>(starsEarned.value);
    }
    if (timeMedal.present) {
      map['time_medal'] = Variable<int>(timeMedal.value);
    }
    if (bestDurationMs.present) {
      map['best_duration_ms'] = Variable<int>(bestDurationMs.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<int>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LevelCompletionsCompanion(')
          ..write('levelId: $levelId, ')
          ..write('starsEarned: $starsEarned, ')
          ..write('timeMedal: $timeMedal, ')
          ..write('bestDurationMs: $bestDurationMs, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AchievementsEarnedTable extends AchievementsEarned
    with TableInfo<$AchievementsEarnedTable, AchievementsEarnedData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AchievementsEarnedTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _achievementIdMeta =
      const VerificationMeta('achievementId');
  @override
  late final GeneratedColumn<String> achievementId = GeneratedColumn<String>(
      'achievement_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _earnedAtMeta =
      const VerificationMeta('earnedAt');
  @override
  late final GeneratedColumn<int> earnedAt = GeneratedColumn<int>(
      'earned_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [achievementId, earnedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'achievements_earned';
  @override
  VerificationContext validateIntegrity(
      Insertable<AchievementsEarnedData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('achievement_id')) {
      context.handle(
          _achievementIdMeta,
          achievementId.isAcceptableOrUnknown(
              data['achievement_id']!, _achievementIdMeta));
    } else if (isInserting) {
      context.missing(_achievementIdMeta);
    }
    if (data.containsKey('earned_at')) {
      context.handle(_earnedAtMeta,
          earnedAt.isAcceptableOrUnknown(data['earned_at']!, _earnedAtMeta));
    } else if (isInserting) {
      context.missing(_earnedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {achievementId};
  @override
  AchievementsEarnedData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AchievementsEarnedData(
      achievementId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}achievement_id'])!,
      earnedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}earned_at'])!,
    );
  }

  @override
  $AchievementsEarnedTable createAlias(String alias) {
    return $AchievementsEarnedTable(attachedDatabase, alias);
  }
}

class AchievementsEarnedData extends DataClass
    implements Insertable<AchievementsEarnedData> {
  final String achievementId;
  final int earnedAt;
  const AchievementsEarnedData(
      {required this.achievementId, required this.earnedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['achievement_id'] = Variable<String>(achievementId);
    map['earned_at'] = Variable<int>(earnedAt);
    return map;
  }

  AchievementsEarnedCompanion toCompanion(bool nullToAbsent) {
    return AchievementsEarnedCompanion(
      achievementId: Value(achievementId),
      earnedAt: Value(earnedAt),
    );
  }

  factory AchievementsEarnedData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AchievementsEarnedData(
      achievementId: serializer.fromJson<String>(json['achievementId']),
      earnedAt: serializer.fromJson<int>(json['earnedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'achievementId': serializer.toJson<String>(achievementId),
      'earnedAt': serializer.toJson<int>(earnedAt),
    };
  }

  AchievementsEarnedData copyWith({String? achievementId, int? earnedAt}) =>
      AchievementsEarnedData(
        achievementId: achievementId ?? this.achievementId,
        earnedAt: earnedAt ?? this.earnedAt,
      );
  AchievementsEarnedData copyWithCompanion(AchievementsEarnedCompanion data) {
    return AchievementsEarnedData(
      achievementId: data.achievementId.present
          ? data.achievementId.value
          : this.achievementId,
      earnedAt: data.earnedAt.present ? data.earnedAt.value : this.earnedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AchievementsEarnedData(')
          ..write('achievementId: $achievementId, ')
          ..write('earnedAt: $earnedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(achievementId, earnedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AchievementsEarnedData &&
          other.achievementId == this.achievementId &&
          other.earnedAt == this.earnedAt);
}

class AchievementsEarnedCompanion
    extends UpdateCompanion<AchievementsEarnedData> {
  final Value<String> achievementId;
  final Value<int> earnedAt;
  final Value<int> rowid;
  const AchievementsEarnedCompanion({
    this.achievementId = const Value.absent(),
    this.earnedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AchievementsEarnedCompanion.insert({
    required String achievementId,
    required int earnedAt,
    this.rowid = const Value.absent(),
  })  : achievementId = Value(achievementId),
        earnedAt = Value(earnedAt);
  static Insertable<AchievementsEarnedData> custom({
    Expression<String>? achievementId,
    Expression<int>? earnedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (achievementId != null) 'achievement_id': achievementId,
      if (earnedAt != null) 'earned_at': earnedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AchievementsEarnedCompanion copyWith(
      {Value<String>? achievementId, Value<int>? earnedAt, Value<int>? rowid}) {
    return AchievementsEarnedCompanion(
      achievementId: achievementId ?? this.achievementId,
      earnedAt: earnedAt ?? this.earnedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (achievementId.present) {
      map['achievement_id'] = Variable<String>(achievementId.value);
    }
    if (earnedAt.present) {
      map['earned_at'] = Variable<int>(earnedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AchievementsEarnedCompanion(')
          ..write('achievementId: $achievementId, ')
          ..write('earnedAt: $earnedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ThemeUnlocksTable extends ThemeUnlocks
    with TableInfo<$ThemeUnlocksTable, ThemeUnlock> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ThemeUnlocksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _themeIdMeta =
      const VerificationMeta('themeId');
  @override
  late final GeneratedColumn<String> themeId = GeneratedColumn<String>(
      'theme_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _unlockedAtMeta =
      const VerificationMeta('unlockedAt');
  @override
  late final GeneratedColumn<int> unlockedAt = GeneratedColumn<int>(
      'unlocked_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [themeId, unlockedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'theme_unlocks';
  @override
  VerificationContext validateIntegrity(Insertable<ThemeUnlock> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('theme_id')) {
      context.handle(_themeIdMeta,
          themeId.isAcceptableOrUnknown(data['theme_id']!, _themeIdMeta));
    } else if (isInserting) {
      context.missing(_themeIdMeta);
    }
    if (data.containsKey('unlocked_at')) {
      context.handle(
          _unlockedAtMeta,
          unlockedAt.isAcceptableOrUnknown(
              data['unlocked_at']!, _unlockedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {themeId};
  @override
  ThemeUnlock map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ThemeUnlock(
      themeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}theme_id'])!,
      unlockedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}unlocked_at']),
    );
  }

  @override
  $ThemeUnlocksTable createAlias(String alias) {
    return $ThemeUnlocksTable(attachedDatabase, alias);
  }
}

class ThemeUnlock extends DataClass implements Insertable<ThemeUnlock> {
  final String themeId;
  final int? unlockedAt;
  const ThemeUnlock({required this.themeId, this.unlockedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['theme_id'] = Variable<String>(themeId);
    if (!nullToAbsent || unlockedAt != null) {
      map['unlocked_at'] = Variable<int>(unlockedAt);
    }
    return map;
  }

  ThemeUnlocksCompanion toCompanion(bool nullToAbsent) {
    return ThemeUnlocksCompanion(
      themeId: Value(themeId),
      unlockedAt: unlockedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(unlockedAt),
    );
  }

  factory ThemeUnlock.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ThemeUnlock(
      themeId: serializer.fromJson<String>(json['themeId']),
      unlockedAt: serializer.fromJson<int?>(json['unlockedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'themeId': serializer.toJson<String>(themeId),
      'unlockedAt': serializer.toJson<int?>(unlockedAt),
    };
  }

  ThemeUnlock copyWith(
          {String? themeId, Value<int?> unlockedAt = const Value.absent()}) =>
      ThemeUnlock(
        themeId: themeId ?? this.themeId,
        unlockedAt: unlockedAt.present ? unlockedAt.value : this.unlockedAt,
      );
  ThemeUnlock copyWithCompanion(ThemeUnlocksCompanion data) {
    return ThemeUnlock(
      themeId: data.themeId.present ? data.themeId.value : this.themeId,
      unlockedAt:
          data.unlockedAt.present ? data.unlockedAt.value : this.unlockedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ThemeUnlock(')
          ..write('themeId: $themeId, ')
          ..write('unlockedAt: $unlockedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(themeId, unlockedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ThemeUnlock &&
          other.themeId == this.themeId &&
          other.unlockedAt == this.unlockedAt);
}

class ThemeUnlocksCompanion extends UpdateCompanion<ThemeUnlock> {
  final Value<String> themeId;
  final Value<int?> unlockedAt;
  final Value<int> rowid;
  const ThemeUnlocksCompanion({
    this.themeId = const Value.absent(),
    this.unlockedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ThemeUnlocksCompanion.insert({
    required String themeId,
    this.unlockedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : themeId = Value(themeId);
  static Insertable<ThemeUnlock> custom({
    Expression<String>? themeId,
    Expression<int>? unlockedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (themeId != null) 'theme_id': themeId,
      if (unlockedAt != null) 'unlocked_at': unlockedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ThemeUnlocksCompanion copyWith(
      {Value<String>? themeId, Value<int?>? unlockedAt, Value<int>? rowid}) {
    return ThemeUnlocksCompanion(
      themeId: themeId ?? this.themeId,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (themeId.present) {
      map['theme_id'] = Variable<String>(themeId.value);
    }
    if (unlockedAt.present) {
      map['unlocked_at'] = Variable<int>(unlockedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ThemeUnlocksCompanion(')
          ..write('themeId: $themeId, ')
          ..write('unlockedAt: $unlockedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(Insertable<Setting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final String key;
  final String value;
  const Setting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      key: Value(key),
      value: Value(value),
    );
  }

  factory Setting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  Setting copyWith({String? key, String? value}) => Setting(
        key: key ?? this.key,
        value: value ?? this.value,
      );
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting && other.key == this.key && other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<Setting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith(
      {Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ContentCacheManifestTable extends ContentCacheManifest
    with TableInfo<$ContentCacheManifestTable, ContentCacheManifestData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContentCacheManifestTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _contentPackIdMeta =
      const VerificationMeta('contentPackId');
  @override
  late final GeneratedColumn<String> contentPackId = GeneratedColumn<String>(
      'content_pack_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _checksumMeta =
      const VerificationMeta('checksum');
  @override
  late final GeneratedColumn<String> checksum = GeneratedColumn<String>(
      'checksum', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _downloadedAtMeta =
      const VerificationMeta('downloadedAt');
  @override
  late final GeneratedColumn<int> downloadedAt = GeneratedColumn<int>(
      'downloaded_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [contentPackId, version, checksum, downloadedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'content_cache_manifest';
  @override
  VerificationContext validateIntegrity(
      Insertable<ContentCacheManifestData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('content_pack_id')) {
      context.handle(
          _contentPackIdMeta,
          contentPackId.isAcceptableOrUnknown(
              data['content_pack_id']!, _contentPackIdMeta));
    } else if (isInserting) {
      context.missing(_contentPackIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('checksum')) {
      context.handle(_checksumMeta,
          checksum.isAcceptableOrUnknown(data['checksum']!, _checksumMeta));
    } else if (isInserting) {
      context.missing(_checksumMeta);
    }
    if (data.containsKey('downloaded_at')) {
      context.handle(
          _downloadedAtMeta,
          downloadedAt.isAcceptableOrUnknown(
              data['downloaded_at']!, _downloadedAtMeta));
    } else if (isInserting) {
      context.missing(_downloadedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {contentPackId};
  @override
  ContentCacheManifestData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContentCacheManifestData(
      contentPackId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}content_pack_id'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      checksum: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}checksum'])!,
      downloadedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}downloaded_at'])!,
    );
  }

  @override
  $ContentCacheManifestTable createAlias(String alias) {
    return $ContentCacheManifestTable(attachedDatabase, alias);
  }
}

class ContentCacheManifestData extends DataClass
    implements Insertable<ContentCacheManifestData> {
  final String contentPackId;
  final int version;
  final String checksum;
  final int downloadedAt;
  const ContentCacheManifestData(
      {required this.contentPackId,
      required this.version,
      required this.checksum,
      required this.downloadedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['content_pack_id'] = Variable<String>(contentPackId);
    map['version'] = Variable<int>(version);
    map['checksum'] = Variable<String>(checksum);
    map['downloaded_at'] = Variable<int>(downloadedAt);
    return map;
  }

  ContentCacheManifestCompanion toCompanion(bool nullToAbsent) {
    return ContentCacheManifestCompanion(
      contentPackId: Value(contentPackId),
      version: Value(version),
      checksum: Value(checksum),
      downloadedAt: Value(downloadedAt),
    );
  }

  factory ContentCacheManifestData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContentCacheManifestData(
      contentPackId: serializer.fromJson<String>(json['contentPackId']),
      version: serializer.fromJson<int>(json['version']),
      checksum: serializer.fromJson<String>(json['checksum']),
      downloadedAt: serializer.fromJson<int>(json['downloadedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'contentPackId': serializer.toJson<String>(contentPackId),
      'version': serializer.toJson<int>(version),
      'checksum': serializer.toJson<String>(checksum),
      'downloadedAt': serializer.toJson<int>(downloadedAt),
    };
  }

  ContentCacheManifestData copyWith(
          {String? contentPackId,
          int? version,
          String? checksum,
          int? downloadedAt}) =>
      ContentCacheManifestData(
        contentPackId: contentPackId ?? this.contentPackId,
        version: version ?? this.version,
        checksum: checksum ?? this.checksum,
        downloadedAt: downloadedAt ?? this.downloadedAt,
      );
  ContentCacheManifestData copyWithCompanion(
      ContentCacheManifestCompanion data) {
    return ContentCacheManifestData(
      contentPackId: data.contentPackId.present
          ? data.contentPackId.value
          : this.contentPackId,
      version: data.version.present ? data.version.value : this.version,
      checksum: data.checksum.present ? data.checksum.value : this.checksum,
      downloadedAt: data.downloadedAt.present
          ? data.downloadedAt.value
          : this.downloadedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContentCacheManifestData(')
          ..write('contentPackId: $contentPackId, ')
          ..write('version: $version, ')
          ..write('checksum: $checksum, ')
          ..write('downloadedAt: $downloadedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(contentPackId, version, checksum, downloadedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContentCacheManifestData &&
          other.contentPackId == this.contentPackId &&
          other.version == this.version &&
          other.checksum == this.checksum &&
          other.downloadedAt == this.downloadedAt);
}

class ContentCacheManifestCompanion
    extends UpdateCompanion<ContentCacheManifestData> {
  final Value<String> contentPackId;
  final Value<int> version;
  final Value<String> checksum;
  final Value<int> downloadedAt;
  final Value<int> rowid;
  const ContentCacheManifestCompanion({
    this.contentPackId = const Value.absent(),
    this.version = const Value.absent(),
    this.checksum = const Value.absent(),
    this.downloadedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContentCacheManifestCompanion.insert({
    required String contentPackId,
    required int version,
    required String checksum,
    required int downloadedAt,
    this.rowid = const Value.absent(),
  })  : contentPackId = Value(contentPackId),
        version = Value(version),
        checksum = Value(checksum),
        downloadedAt = Value(downloadedAt);
  static Insertable<ContentCacheManifestData> custom({
    Expression<String>? contentPackId,
    Expression<int>? version,
    Expression<String>? checksum,
    Expression<int>? downloadedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (contentPackId != null) 'content_pack_id': contentPackId,
      if (version != null) 'version': version,
      if (checksum != null) 'checksum': checksum,
      if (downloadedAt != null) 'downloaded_at': downloadedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContentCacheManifestCompanion copyWith(
      {Value<String>? contentPackId,
      Value<int>? version,
      Value<String>? checksum,
      Value<int>? downloadedAt,
      Value<int>? rowid}) {
    return ContentCacheManifestCompanion(
      contentPackId: contentPackId ?? this.contentPackId,
      version: version ?? this.version,
      checksum: checksum ?? this.checksum,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (contentPackId.present) {
      map['content_pack_id'] = Variable<String>(contentPackId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (checksum.present) {
      map['checksum'] = Variable<String>(checksum.value);
    }
    if (downloadedAt.present) {
      map['downloaded_at'] = Variable<int>(downloadedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContentCacheManifestCompanion(')
          ..write('contentPackId: $contentPackId, ')
          ..write('version: $version, ')
          ..write('checksum: $checksum, ')
          ..write('downloadedAt: $downloadedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BookmarkedConceptsTable extends BookmarkedConcepts
    with TableInfo<$BookmarkedConceptsTable, BookmarkedConcept> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookmarkedConceptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _conceptIdMeta =
      const VerificationMeta('conceptId');
  @override
  late final GeneratedColumn<String> conceptId = GeneratedColumn<String>(
      'concept_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _savedAtMeta =
      const VerificationMeta('savedAt');
  @override
  late final GeneratedColumn<int> savedAt = GeneratedColumn<int>(
      'saved_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [conceptId, savedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookmarked_concepts';
  @override
  VerificationContext validateIntegrity(Insertable<BookmarkedConcept> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('concept_id')) {
      context.handle(_conceptIdMeta,
          conceptId.isAcceptableOrUnknown(data['concept_id']!, _conceptIdMeta));
    } else if (isInserting) {
      context.missing(_conceptIdMeta);
    }
    if (data.containsKey('saved_at')) {
      context.handle(_savedAtMeta,
          savedAt.isAcceptableOrUnknown(data['saved_at']!, _savedAtMeta));
    } else if (isInserting) {
      context.missing(_savedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {conceptId};
  @override
  BookmarkedConcept map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookmarkedConcept(
      conceptId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}concept_id'])!,
      savedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}saved_at'])!,
    );
  }

  @override
  $BookmarkedConceptsTable createAlias(String alias) {
    return $BookmarkedConceptsTable(attachedDatabase, alias);
  }
}

class BookmarkedConcept extends DataClass
    implements Insertable<BookmarkedConcept> {
  final String conceptId;
  final int savedAt;
  const BookmarkedConcept({required this.conceptId, required this.savedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['concept_id'] = Variable<String>(conceptId);
    map['saved_at'] = Variable<int>(savedAt);
    return map;
  }

  BookmarkedConceptsCompanion toCompanion(bool nullToAbsent) {
    return BookmarkedConceptsCompanion(
      conceptId: Value(conceptId),
      savedAt: Value(savedAt),
    );
  }

  factory BookmarkedConcept.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookmarkedConcept(
      conceptId: serializer.fromJson<String>(json['conceptId']),
      savedAt: serializer.fromJson<int>(json['savedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'conceptId': serializer.toJson<String>(conceptId),
      'savedAt': serializer.toJson<int>(savedAt),
    };
  }

  BookmarkedConcept copyWith({String? conceptId, int? savedAt}) =>
      BookmarkedConcept(
        conceptId: conceptId ?? this.conceptId,
        savedAt: savedAt ?? this.savedAt,
      );
  BookmarkedConcept copyWithCompanion(BookmarkedConceptsCompanion data) {
    return BookmarkedConcept(
      conceptId: data.conceptId.present ? data.conceptId.value : this.conceptId,
      savedAt: data.savedAt.present ? data.savedAt.value : this.savedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookmarkedConcept(')
          ..write('conceptId: $conceptId, ')
          ..write('savedAt: $savedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(conceptId, savedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookmarkedConcept &&
          other.conceptId == this.conceptId &&
          other.savedAt == this.savedAt);
}

class BookmarkedConceptsCompanion extends UpdateCompanion<BookmarkedConcept> {
  final Value<String> conceptId;
  final Value<int> savedAt;
  final Value<int> rowid;
  const BookmarkedConceptsCompanion({
    this.conceptId = const Value.absent(),
    this.savedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookmarkedConceptsCompanion.insert({
    required String conceptId,
    required int savedAt,
    this.rowid = const Value.absent(),
  })  : conceptId = Value(conceptId),
        savedAt = Value(savedAt);
  static Insertable<BookmarkedConcept> custom({
    Expression<String>? conceptId,
    Expression<int>? savedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (conceptId != null) 'concept_id': conceptId,
      if (savedAt != null) 'saved_at': savedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookmarkedConceptsCompanion copyWith(
      {Value<String>? conceptId, Value<int>? savedAt, Value<int>? rowid}) {
    return BookmarkedConceptsCompanion(
      conceptId: conceptId ?? this.conceptId,
      savedAt: savedAt ?? this.savedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (conceptId.present) {
      map['concept_id'] = Variable<String>(conceptId.value);
    }
    if (savedAt.present) {
      map['saved_at'] = Variable<int>(savedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookmarkedConceptsCompanion(')
          ..write('conceptId: $conceptId, ')
          ..write('savedAt: $savedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PlayerProfilesTable playerProfiles = $PlayerProfilesTable(this);
  late final $WorldProgressTable worldProgress = $WorldProgressTable(this);
  late final $LevelAttemptsTable levelAttempts = $LevelAttemptsTable(this);
  late final $LevelCompletionsTable levelCompletions =
      $LevelCompletionsTable(this);
  late final $AchievementsEarnedTable achievementsEarned =
      $AchievementsEarnedTable(this);
  late final $ThemeUnlocksTable themeUnlocks = $ThemeUnlocksTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $ContentCacheManifestTable contentCacheManifest =
      $ContentCacheManifestTable(this);
  late final $BookmarkedConceptsTable bookmarkedConcepts =
      $BookmarkedConceptsTable(this);
  late final PlayerDao playerDao = PlayerDao(this as AppDatabase);
  late final ProgressDao progressDao = ProgressDao(this as AppDatabase);
  late final AttemptsDao attemptsDao = AttemptsDao(this as AppDatabase);
  late final AchievementsDao achievementsDao =
      AchievementsDao(this as AppDatabase);
  late final ConceptDao conceptDao = ConceptDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        playerProfiles,
        worldProgress,
        levelAttempts,
        levelCompletions,
        achievementsEarned,
        themeUnlocks,
        settings,
        contentCacheManifest,
        bookmarkedConcepts
      ];
}

typedef $$PlayerProfilesTableCreateCompanionBuilder = PlayerProfilesCompanion
    Function({
  Value<int> id,
  required String displayName,
  Value<String> rankTitle,
  Value<int> totalXp,
  Value<int> insightPoints,
  Value<int> streakCount,
  Value<int> streakFreezeAvailable,
  Value<String> activeTheme,
  required int createdAt,
  Value<String?> cloudSyncId,
});
typedef $$PlayerProfilesTableUpdateCompanionBuilder = PlayerProfilesCompanion
    Function({
  Value<int> id,
  Value<String> displayName,
  Value<String> rankTitle,
  Value<int> totalXp,
  Value<int> insightPoints,
  Value<int> streakCount,
  Value<int> streakFreezeAvailable,
  Value<String> activeTheme,
  Value<int> createdAt,
  Value<String?> cloudSyncId,
});

class $$PlayerProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $PlayerProfilesTable> {
  $$PlayerProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rankTitle => $composableBuilder(
      column: $table.rankTitle, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalXp => $composableBuilder(
      column: $table.totalXp, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get insightPoints => $composableBuilder(
      column: $table.insightPoints, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get streakCount => $composableBuilder(
      column: $table.streakCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get streakFreezeAvailable => $composableBuilder(
      column: $table.streakFreezeAvailable,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get activeTheme => $composableBuilder(
      column: $table.activeTheme, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cloudSyncId => $composableBuilder(
      column: $table.cloudSyncId, builder: (column) => ColumnFilters(column));
}

class $$PlayerProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $PlayerProfilesTable> {
  $$PlayerProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rankTitle => $composableBuilder(
      column: $table.rankTitle, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalXp => $composableBuilder(
      column: $table.totalXp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get insightPoints => $composableBuilder(
      column: $table.insightPoints,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get streakCount => $composableBuilder(
      column: $table.streakCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get streakFreezeAvailable => $composableBuilder(
      column: $table.streakFreezeAvailable,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get activeTheme => $composableBuilder(
      column: $table.activeTheme, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cloudSyncId => $composableBuilder(
      column: $table.cloudSyncId, builder: (column) => ColumnOrderings(column));
}

class $$PlayerProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlayerProfilesTable> {
  $$PlayerProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => column);

  GeneratedColumn<String> get rankTitle =>
      $composableBuilder(column: $table.rankTitle, builder: (column) => column);

  GeneratedColumn<int> get totalXp =>
      $composableBuilder(column: $table.totalXp, builder: (column) => column);

  GeneratedColumn<int> get insightPoints => $composableBuilder(
      column: $table.insightPoints, builder: (column) => column);

  GeneratedColumn<int> get streakCount => $composableBuilder(
      column: $table.streakCount, builder: (column) => column);

  GeneratedColumn<int> get streakFreezeAvailable => $composableBuilder(
      column: $table.streakFreezeAvailable, builder: (column) => column);

  GeneratedColumn<String> get activeTheme => $composableBuilder(
      column: $table.activeTheme, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get cloudSyncId => $composableBuilder(
      column: $table.cloudSyncId, builder: (column) => column);
}

class $$PlayerProfilesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PlayerProfilesTable,
    PlayerProfile,
    $$PlayerProfilesTableFilterComposer,
    $$PlayerProfilesTableOrderingComposer,
    $$PlayerProfilesTableAnnotationComposer,
    $$PlayerProfilesTableCreateCompanionBuilder,
    $$PlayerProfilesTableUpdateCompanionBuilder,
    (
      PlayerProfile,
      BaseReferences<_$AppDatabase, $PlayerProfilesTable, PlayerProfile>
    ),
    PlayerProfile,
    PrefetchHooks Function()> {
  $$PlayerProfilesTableTableManager(
      _$AppDatabase db, $PlayerProfilesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlayerProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlayerProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlayerProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> displayName = const Value.absent(),
            Value<String> rankTitle = const Value.absent(),
            Value<int> totalXp = const Value.absent(),
            Value<int> insightPoints = const Value.absent(),
            Value<int> streakCount = const Value.absent(),
            Value<int> streakFreezeAvailable = const Value.absent(),
            Value<String> activeTheme = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<String?> cloudSyncId = const Value.absent(),
          }) =>
              PlayerProfilesCompanion(
            id: id,
            displayName: displayName,
            rankTitle: rankTitle,
            totalXp: totalXp,
            insightPoints: insightPoints,
            streakCount: streakCount,
            streakFreezeAvailable: streakFreezeAvailable,
            activeTheme: activeTheme,
            createdAt: createdAt,
            cloudSyncId: cloudSyncId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String displayName,
            Value<String> rankTitle = const Value.absent(),
            Value<int> totalXp = const Value.absent(),
            Value<int> insightPoints = const Value.absent(),
            Value<int> streakCount = const Value.absent(),
            Value<int> streakFreezeAvailable = const Value.absent(),
            Value<String> activeTheme = const Value.absent(),
            required int createdAt,
            Value<String?> cloudSyncId = const Value.absent(),
          }) =>
              PlayerProfilesCompanion.insert(
            id: id,
            displayName: displayName,
            rankTitle: rankTitle,
            totalXp: totalXp,
            insightPoints: insightPoints,
            streakCount: streakCount,
            streakFreezeAvailable: streakFreezeAvailable,
            activeTheme: activeTheme,
            createdAt: createdAt,
            cloudSyncId: cloudSyncId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PlayerProfilesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PlayerProfilesTable,
    PlayerProfile,
    $$PlayerProfilesTableFilterComposer,
    $$PlayerProfilesTableOrderingComposer,
    $$PlayerProfilesTableAnnotationComposer,
    $$PlayerProfilesTableCreateCompanionBuilder,
    $$PlayerProfilesTableUpdateCompanionBuilder,
    (
      PlayerProfile,
      BaseReferences<_$AppDatabase, $PlayerProfilesTable, PlayerProfile>
    ),
    PlayerProfile,
    PrefetchHooks Function()>;
typedef $$WorldProgressTableCreateCompanionBuilder = WorldProgressCompanion
    Function({
  required String worldId,
  Value<int> levelsCompleted,
  required int totalLevels,
  Value<bool> unlocked,
  Value<int> rowid,
});
typedef $$WorldProgressTableUpdateCompanionBuilder = WorldProgressCompanion
    Function({
  Value<String> worldId,
  Value<int> levelsCompleted,
  Value<int> totalLevels,
  Value<bool> unlocked,
  Value<int> rowid,
});

class $$WorldProgressTableFilterComposer
    extends Composer<_$AppDatabase, $WorldProgressTable> {
  $$WorldProgressTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get worldId => $composableBuilder(
      column: $table.worldId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get levelsCompleted => $composableBuilder(
      column: $table.levelsCompleted,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalLevels => $composableBuilder(
      column: $table.totalLevels, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get unlocked => $composableBuilder(
      column: $table.unlocked, builder: (column) => ColumnFilters(column));
}

class $$WorldProgressTableOrderingComposer
    extends Composer<_$AppDatabase, $WorldProgressTable> {
  $$WorldProgressTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get worldId => $composableBuilder(
      column: $table.worldId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get levelsCompleted => $composableBuilder(
      column: $table.levelsCompleted,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalLevels => $composableBuilder(
      column: $table.totalLevels, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get unlocked => $composableBuilder(
      column: $table.unlocked, builder: (column) => ColumnOrderings(column));
}

class $$WorldProgressTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorldProgressTable> {
  $$WorldProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get worldId =>
      $composableBuilder(column: $table.worldId, builder: (column) => column);

  GeneratedColumn<int> get levelsCompleted => $composableBuilder(
      column: $table.levelsCompleted, builder: (column) => column);

  GeneratedColumn<int> get totalLevels => $composableBuilder(
      column: $table.totalLevels, builder: (column) => column);

  GeneratedColumn<bool> get unlocked =>
      $composableBuilder(column: $table.unlocked, builder: (column) => column);
}

class $$WorldProgressTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WorldProgressTable,
    WorldProgressData,
    $$WorldProgressTableFilterComposer,
    $$WorldProgressTableOrderingComposer,
    $$WorldProgressTableAnnotationComposer,
    $$WorldProgressTableCreateCompanionBuilder,
    $$WorldProgressTableUpdateCompanionBuilder,
    (
      WorldProgressData,
      BaseReferences<_$AppDatabase, $WorldProgressTable, WorldProgressData>
    ),
    WorldProgressData,
    PrefetchHooks Function()> {
  $$WorldProgressTableTableManager(_$AppDatabase db, $WorldProgressTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorldProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorldProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorldProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> worldId = const Value.absent(),
            Value<int> levelsCompleted = const Value.absent(),
            Value<int> totalLevels = const Value.absent(),
            Value<bool> unlocked = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WorldProgressCompanion(
            worldId: worldId,
            levelsCompleted: levelsCompleted,
            totalLevels: totalLevels,
            unlocked: unlocked,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String worldId,
            Value<int> levelsCompleted = const Value.absent(),
            required int totalLevels,
            Value<bool> unlocked = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WorldProgressCompanion.insert(
            worldId: worldId,
            levelsCompleted: levelsCompleted,
            totalLevels: totalLevels,
            unlocked: unlocked,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$WorldProgressTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WorldProgressTable,
    WorldProgressData,
    $$WorldProgressTableFilterComposer,
    $$WorldProgressTableOrderingComposer,
    $$WorldProgressTableAnnotationComposer,
    $$WorldProgressTableCreateCompanionBuilder,
    $$WorldProgressTableUpdateCompanionBuilder,
    (
      WorldProgressData,
      BaseReferences<_$AppDatabase, $WorldProgressTable, WorldProgressData>
    ),
    WorldProgressData,
    PrefetchHooks Function()>;
typedef $$LevelAttemptsTableCreateCompanionBuilder = LevelAttemptsCompanion
    Function({
  Value<int> id,
  required String levelId,
  required int attemptNumber,
  required String submittedQuery,
  required bool passedSyntax,
  required bool passedSemantic,
  required bool passedResult,
  Value<double?> efficiencyScore,
  Value<int> hintTierUsed,
  Value<int?> durationMs,
  required int createdAt,
});
typedef $$LevelAttemptsTableUpdateCompanionBuilder = LevelAttemptsCompanion
    Function({
  Value<int> id,
  Value<String> levelId,
  Value<int> attemptNumber,
  Value<String> submittedQuery,
  Value<bool> passedSyntax,
  Value<bool> passedSemantic,
  Value<bool> passedResult,
  Value<double?> efficiencyScore,
  Value<int> hintTierUsed,
  Value<int?> durationMs,
  Value<int> createdAt,
});

class $$LevelAttemptsTableFilterComposer
    extends Composer<_$AppDatabase, $LevelAttemptsTable> {
  $$LevelAttemptsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get levelId => $composableBuilder(
      column: $table.levelId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get attemptNumber => $composableBuilder(
      column: $table.attemptNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get submittedQuery => $composableBuilder(
      column: $table.submittedQuery,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get passedSyntax => $composableBuilder(
      column: $table.passedSyntax, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get passedSemantic => $composableBuilder(
      column: $table.passedSemantic,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get passedResult => $composableBuilder(
      column: $table.passedResult, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get efficiencyScore => $composableBuilder(
      column: $table.efficiencyScore,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get hintTierUsed => $composableBuilder(
      column: $table.hintTierUsed, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$LevelAttemptsTableOrderingComposer
    extends Composer<_$AppDatabase, $LevelAttemptsTable> {
  $$LevelAttemptsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get levelId => $composableBuilder(
      column: $table.levelId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get attemptNumber => $composableBuilder(
      column: $table.attemptNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get submittedQuery => $composableBuilder(
      column: $table.submittedQuery,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get passedSyntax => $composableBuilder(
      column: $table.passedSyntax,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get passedSemantic => $composableBuilder(
      column: $table.passedSemantic,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get passedResult => $composableBuilder(
      column: $table.passedResult,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get efficiencyScore => $composableBuilder(
      column: $table.efficiencyScore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get hintTierUsed => $composableBuilder(
      column: $table.hintTierUsed,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$LevelAttemptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LevelAttemptsTable> {
  $$LevelAttemptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get levelId =>
      $composableBuilder(column: $table.levelId, builder: (column) => column);

  GeneratedColumn<int> get attemptNumber => $composableBuilder(
      column: $table.attemptNumber, builder: (column) => column);

  GeneratedColumn<String> get submittedQuery => $composableBuilder(
      column: $table.submittedQuery, builder: (column) => column);

  GeneratedColumn<bool> get passedSyntax => $composableBuilder(
      column: $table.passedSyntax, builder: (column) => column);

  GeneratedColumn<bool> get passedSemantic => $composableBuilder(
      column: $table.passedSemantic, builder: (column) => column);

  GeneratedColumn<bool> get passedResult => $composableBuilder(
      column: $table.passedResult, builder: (column) => column);

  GeneratedColumn<double> get efficiencyScore => $composableBuilder(
      column: $table.efficiencyScore, builder: (column) => column);

  GeneratedColumn<int> get hintTierUsed => $composableBuilder(
      column: $table.hintTierUsed, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LevelAttemptsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LevelAttemptsTable,
    LevelAttempt,
    $$LevelAttemptsTableFilterComposer,
    $$LevelAttemptsTableOrderingComposer,
    $$LevelAttemptsTableAnnotationComposer,
    $$LevelAttemptsTableCreateCompanionBuilder,
    $$LevelAttemptsTableUpdateCompanionBuilder,
    (
      LevelAttempt,
      BaseReferences<_$AppDatabase, $LevelAttemptsTable, LevelAttempt>
    ),
    LevelAttempt,
    PrefetchHooks Function()> {
  $$LevelAttemptsTableTableManager(_$AppDatabase db, $LevelAttemptsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LevelAttemptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LevelAttemptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LevelAttemptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> levelId = const Value.absent(),
            Value<int> attemptNumber = const Value.absent(),
            Value<String> submittedQuery = const Value.absent(),
            Value<bool> passedSyntax = const Value.absent(),
            Value<bool> passedSemantic = const Value.absent(),
            Value<bool> passedResult = const Value.absent(),
            Value<double?> efficiencyScore = const Value.absent(),
            Value<int> hintTierUsed = const Value.absent(),
            Value<int?> durationMs = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
          }) =>
              LevelAttemptsCompanion(
            id: id,
            levelId: levelId,
            attemptNumber: attemptNumber,
            submittedQuery: submittedQuery,
            passedSyntax: passedSyntax,
            passedSemantic: passedSemantic,
            passedResult: passedResult,
            efficiencyScore: efficiencyScore,
            hintTierUsed: hintTierUsed,
            durationMs: durationMs,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String levelId,
            required int attemptNumber,
            required String submittedQuery,
            required bool passedSyntax,
            required bool passedSemantic,
            required bool passedResult,
            Value<double?> efficiencyScore = const Value.absent(),
            Value<int> hintTierUsed = const Value.absent(),
            Value<int?> durationMs = const Value.absent(),
            required int createdAt,
          }) =>
              LevelAttemptsCompanion.insert(
            id: id,
            levelId: levelId,
            attemptNumber: attemptNumber,
            submittedQuery: submittedQuery,
            passedSyntax: passedSyntax,
            passedSemantic: passedSemantic,
            passedResult: passedResult,
            efficiencyScore: efficiencyScore,
            hintTierUsed: hintTierUsed,
            durationMs: durationMs,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LevelAttemptsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LevelAttemptsTable,
    LevelAttempt,
    $$LevelAttemptsTableFilterComposer,
    $$LevelAttemptsTableOrderingComposer,
    $$LevelAttemptsTableAnnotationComposer,
    $$LevelAttemptsTableCreateCompanionBuilder,
    $$LevelAttemptsTableUpdateCompanionBuilder,
    (
      LevelAttempt,
      BaseReferences<_$AppDatabase, $LevelAttemptsTable, LevelAttempt>
    ),
    LevelAttempt,
    PrefetchHooks Function()>;
typedef $$LevelCompletionsTableCreateCompanionBuilder
    = LevelCompletionsCompanion Function({
  required String levelId,
  required int starsEarned,
  Value<int?> timeMedal,
  Value<int?> bestDurationMs,
  required int completedAt,
  Value<int> rowid,
});
typedef $$LevelCompletionsTableUpdateCompanionBuilder
    = LevelCompletionsCompanion Function({
  Value<String> levelId,
  Value<int> starsEarned,
  Value<int?> timeMedal,
  Value<int?> bestDurationMs,
  Value<int> completedAt,
  Value<int> rowid,
});

class $$LevelCompletionsTableFilterComposer
    extends Composer<_$AppDatabase, $LevelCompletionsTable> {
  $$LevelCompletionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get levelId => $composableBuilder(
      column: $table.levelId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get starsEarned => $composableBuilder(
      column: $table.starsEarned, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get timeMedal => $composableBuilder(
      column: $table.timeMedal, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get bestDurationMs => $composableBuilder(
      column: $table.bestDurationMs,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));
}

class $$LevelCompletionsTableOrderingComposer
    extends Composer<_$AppDatabase, $LevelCompletionsTable> {
  $$LevelCompletionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get levelId => $composableBuilder(
      column: $table.levelId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get starsEarned => $composableBuilder(
      column: $table.starsEarned, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get timeMedal => $composableBuilder(
      column: $table.timeMedal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get bestDurationMs => $composableBuilder(
      column: $table.bestDurationMs,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));
}

class $$LevelCompletionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LevelCompletionsTable> {
  $$LevelCompletionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get levelId =>
      $composableBuilder(column: $table.levelId, builder: (column) => column);

  GeneratedColumn<int> get starsEarned => $composableBuilder(
      column: $table.starsEarned, builder: (column) => column);

  GeneratedColumn<int> get timeMedal =>
      $composableBuilder(column: $table.timeMedal, builder: (column) => column);

  GeneratedColumn<int> get bestDurationMs => $composableBuilder(
      column: $table.bestDurationMs, builder: (column) => column);

  GeneratedColumn<int> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);
}

class $$LevelCompletionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LevelCompletionsTable,
    LevelCompletion,
    $$LevelCompletionsTableFilterComposer,
    $$LevelCompletionsTableOrderingComposer,
    $$LevelCompletionsTableAnnotationComposer,
    $$LevelCompletionsTableCreateCompanionBuilder,
    $$LevelCompletionsTableUpdateCompanionBuilder,
    (
      LevelCompletion,
      BaseReferences<_$AppDatabase, $LevelCompletionsTable, LevelCompletion>
    ),
    LevelCompletion,
    PrefetchHooks Function()> {
  $$LevelCompletionsTableTableManager(
      _$AppDatabase db, $LevelCompletionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LevelCompletionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LevelCompletionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LevelCompletionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> levelId = const Value.absent(),
            Value<int> starsEarned = const Value.absent(),
            Value<int?> timeMedal = const Value.absent(),
            Value<int?> bestDurationMs = const Value.absent(),
            Value<int> completedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LevelCompletionsCompanion(
            levelId: levelId,
            starsEarned: starsEarned,
            timeMedal: timeMedal,
            bestDurationMs: bestDurationMs,
            completedAt: completedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String levelId,
            required int starsEarned,
            Value<int?> timeMedal = const Value.absent(),
            Value<int?> bestDurationMs = const Value.absent(),
            required int completedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              LevelCompletionsCompanion.insert(
            levelId: levelId,
            starsEarned: starsEarned,
            timeMedal: timeMedal,
            bestDurationMs: bestDurationMs,
            completedAt: completedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LevelCompletionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LevelCompletionsTable,
    LevelCompletion,
    $$LevelCompletionsTableFilterComposer,
    $$LevelCompletionsTableOrderingComposer,
    $$LevelCompletionsTableAnnotationComposer,
    $$LevelCompletionsTableCreateCompanionBuilder,
    $$LevelCompletionsTableUpdateCompanionBuilder,
    (
      LevelCompletion,
      BaseReferences<_$AppDatabase, $LevelCompletionsTable, LevelCompletion>
    ),
    LevelCompletion,
    PrefetchHooks Function()>;
typedef $$AchievementsEarnedTableCreateCompanionBuilder
    = AchievementsEarnedCompanion Function({
  required String achievementId,
  required int earnedAt,
  Value<int> rowid,
});
typedef $$AchievementsEarnedTableUpdateCompanionBuilder
    = AchievementsEarnedCompanion Function({
  Value<String> achievementId,
  Value<int> earnedAt,
  Value<int> rowid,
});

class $$AchievementsEarnedTableFilterComposer
    extends Composer<_$AppDatabase, $AchievementsEarnedTable> {
  $$AchievementsEarnedTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get achievementId => $composableBuilder(
      column: $table.achievementId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get earnedAt => $composableBuilder(
      column: $table.earnedAt, builder: (column) => ColumnFilters(column));
}

class $$AchievementsEarnedTableOrderingComposer
    extends Composer<_$AppDatabase, $AchievementsEarnedTable> {
  $$AchievementsEarnedTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get achievementId => $composableBuilder(
      column: $table.achievementId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get earnedAt => $composableBuilder(
      column: $table.earnedAt, builder: (column) => ColumnOrderings(column));
}

class $$AchievementsEarnedTableAnnotationComposer
    extends Composer<_$AppDatabase, $AchievementsEarnedTable> {
  $$AchievementsEarnedTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get achievementId => $composableBuilder(
      column: $table.achievementId, builder: (column) => column);

  GeneratedColumn<int> get earnedAt =>
      $composableBuilder(column: $table.earnedAt, builder: (column) => column);
}

class $$AchievementsEarnedTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AchievementsEarnedTable,
    AchievementsEarnedData,
    $$AchievementsEarnedTableFilterComposer,
    $$AchievementsEarnedTableOrderingComposer,
    $$AchievementsEarnedTableAnnotationComposer,
    $$AchievementsEarnedTableCreateCompanionBuilder,
    $$AchievementsEarnedTableUpdateCompanionBuilder,
    (
      AchievementsEarnedData,
      BaseReferences<_$AppDatabase, $AchievementsEarnedTable,
          AchievementsEarnedData>
    ),
    AchievementsEarnedData,
    PrefetchHooks Function()> {
  $$AchievementsEarnedTableTableManager(
      _$AppDatabase db, $AchievementsEarnedTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AchievementsEarnedTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AchievementsEarnedTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AchievementsEarnedTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> achievementId = const Value.absent(),
            Value<int> earnedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AchievementsEarnedCompanion(
            achievementId: achievementId,
            earnedAt: earnedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String achievementId,
            required int earnedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              AchievementsEarnedCompanion.insert(
            achievementId: achievementId,
            earnedAt: earnedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AchievementsEarnedTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AchievementsEarnedTable,
    AchievementsEarnedData,
    $$AchievementsEarnedTableFilterComposer,
    $$AchievementsEarnedTableOrderingComposer,
    $$AchievementsEarnedTableAnnotationComposer,
    $$AchievementsEarnedTableCreateCompanionBuilder,
    $$AchievementsEarnedTableUpdateCompanionBuilder,
    (
      AchievementsEarnedData,
      BaseReferences<_$AppDatabase, $AchievementsEarnedTable,
          AchievementsEarnedData>
    ),
    AchievementsEarnedData,
    PrefetchHooks Function()>;
typedef $$ThemeUnlocksTableCreateCompanionBuilder = ThemeUnlocksCompanion
    Function({
  required String themeId,
  Value<int?> unlockedAt,
  Value<int> rowid,
});
typedef $$ThemeUnlocksTableUpdateCompanionBuilder = ThemeUnlocksCompanion
    Function({
  Value<String> themeId,
  Value<int?> unlockedAt,
  Value<int> rowid,
});

class $$ThemeUnlocksTableFilterComposer
    extends Composer<_$AppDatabase, $ThemeUnlocksTable> {
  $$ThemeUnlocksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get themeId => $composableBuilder(
      column: $table.themeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get unlockedAt => $composableBuilder(
      column: $table.unlockedAt, builder: (column) => ColumnFilters(column));
}

class $$ThemeUnlocksTableOrderingComposer
    extends Composer<_$AppDatabase, $ThemeUnlocksTable> {
  $$ThemeUnlocksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get themeId => $composableBuilder(
      column: $table.themeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get unlockedAt => $composableBuilder(
      column: $table.unlockedAt, builder: (column) => ColumnOrderings(column));
}

class $$ThemeUnlocksTableAnnotationComposer
    extends Composer<_$AppDatabase, $ThemeUnlocksTable> {
  $$ThemeUnlocksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get themeId =>
      $composableBuilder(column: $table.themeId, builder: (column) => column);

  GeneratedColumn<int> get unlockedAt => $composableBuilder(
      column: $table.unlockedAt, builder: (column) => column);
}

class $$ThemeUnlocksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ThemeUnlocksTable,
    ThemeUnlock,
    $$ThemeUnlocksTableFilterComposer,
    $$ThemeUnlocksTableOrderingComposer,
    $$ThemeUnlocksTableAnnotationComposer,
    $$ThemeUnlocksTableCreateCompanionBuilder,
    $$ThemeUnlocksTableUpdateCompanionBuilder,
    (
      ThemeUnlock,
      BaseReferences<_$AppDatabase, $ThemeUnlocksTable, ThemeUnlock>
    ),
    ThemeUnlock,
    PrefetchHooks Function()> {
  $$ThemeUnlocksTableTableManager(_$AppDatabase db, $ThemeUnlocksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ThemeUnlocksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ThemeUnlocksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ThemeUnlocksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> themeId = const Value.absent(),
            Value<int?> unlockedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ThemeUnlocksCompanion(
            themeId: themeId,
            unlockedAt: unlockedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String themeId,
            Value<int?> unlockedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ThemeUnlocksCompanion.insert(
            themeId: themeId,
            unlockedAt: unlockedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ThemeUnlocksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ThemeUnlocksTable,
    ThemeUnlock,
    $$ThemeUnlocksTableFilterComposer,
    $$ThemeUnlocksTableOrderingComposer,
    $$ThemeUnlocksTableAnnotationComposer,
    $$ThemeUnlocksTableCreateCompanionBuilder,
    $$ThemeUnlocksTableUpdateCompanionBuilder,
    (
      ThemeUnlock,
      BaseReferences<_$AppDatabase, $ThemeUnlocksTable, ThemeUnlock>
    ),
    ThemeUnlock,
    PrefetchHooks Function()>;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SettingsTable,
    Setting,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableAnnotationComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder,
    (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
    Setting,
    PrefetchHooks Function()> {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SettingsCompanion(
            key: key,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) =>
              SettingsCompanion.insert(
            key: key,
            value: value,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SettingsTable,
    Setting,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableAnnotationComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder,
    (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
    Setting,
    PrefetchHooks Function()>;
typedef $$ContentCacheManifestTableCreateCompanionBuilder
    = ContentCacheManifestCompanion Function({
  required String contentPackId,
  required int version,
  required String checksum,
  required int downloadedAt,
  Value<int> rowid,
});
typedef $$ContentCacheManifestTableUpdateCompanionBuilder
    = ContentCacheManifestCompanion Function({
  Value<String> contentPackId,
  Value<int> version,
  Value<String> checksum,
  Value<int> downloadedAt,
  Value<int> rowid,
});

class $$ContentCacheManifestTableFilterComposer
    extends Composer<_$AppDatabase, $ContentCacheManifestTable> {
  $$ContentCacheManifestTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get contentPackId => $composableBuilder(
      column: $table.contentPackId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get checksum => $composableBuilder(
      column: $table.checksum, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get downloadedAt => $composableBuilder(
      column: $table.downloadedAt, builder: (column) => ColumnFilters(column));
}

class $$ContentCacheManifestTableOrderingComposer
    extends Composer<_$AppDatabase, $ContentCacheManifestTable> {
  $$ContentCacheManifestTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get contentPackId => $composableBuilder(
      column: $table.contentPackId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get checksum => $composableBuilder(
      column: $table.checksum, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get downloadedAt => $composableBuilder(
      column: $table.downloadedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$ContentCacheManifestTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContentCacheManifestTable> {
  $$ContentCacheManifestTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get contentPackId => $composableBuilder(
      column: $table.contentPackId, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get checksum =>
      $composableBuilder(column: $table.checksum, builder: (column) => column);

  GeneratedColumn<int> get downloadedAt => $composableBuilder(
      column: $table.downloadedAt, builder: (column) => column);
}

class $$ContentCacheManifestTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ContentCacheManifestTable,
    ContentCacheManifestData,
    $$ContentCacheManifestTableFilterComposer,
    $$ContentCacheManifestTableOrderingComposer,
    $$ContentCacheManifestTableAnnotationComposer,
    $$ContentCacheManifestTableCreateCompanionBuilder,
    $$ContentCacheManifestTableUpdateCompanionBuilder,
    (
      ContentCacheManifestData,
      BaseReferences<_$AppDatabase, $ContentCacheManifestTable,
          ContentCacheManifestData>
    ),
    ContentCacheManifestData,
    PrefetchHooks Function()> {
  $$ContentCacheManifestTableTableManager(
      _$AppDatabase db, $ContentCacheManifestTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContentCacheManifestTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContentCacheManifestTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContentCacheManifestTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> contentPackId = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String> checksum = const Value.absent(),
            Value<int> downloadedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ContentCacheManifestCompanion(
            contentPackId: contentPackId,
            version: version,
            checksum: checksum,
            downloadedAt: downloadedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String contentPackId,
            required int version,
            required String checksum,
            required int downloadedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ContentCacheManifestCompanion.insert(
            contentPackId: contentPackId,
            version: version,
            checksum: checksum,
            downloadedAt: downloadedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ContentCacheManifestTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $ContentCacheManifestTable,
        ContentCacheManifestData,
        $$ContentCacheManifestTableFilterComposer,
        $$ContentCacheManifestTableOrderingComposer,
        $$ContentCacheManifestTableAnnotationComposer,
        $$ContentCacheManifestTableCreateCompanionBuilder,
        $$ContentCacheManifestTableUpdateCompanionBuilder,
        (
          ContentCacheManifestData,
          BaseReferences<_$AppDatabase, $ContentCacheManifestTable,
              ContentCacheManifestData>
        ),
        ContentCacheManifestData,
        PrefetchHooks Function()>;
typedef $$BookmarkedConceptsTableCreateCompanionBuilder
    = BookmarkedConceptsCompanion Function({
  required String conceptId,
  required int savedAt,
  Value<int> rowid,
});
typedef $$BookmarkedConceptsTableUpdateCompanionBuilder
    = BookmarkedConceptsCompanion Function({
  Value<String> conceptId,
  Value<int> savedAt,
  Value<int> rowid,
});

class $$BookmarkedConceptsTableFilterComposer
    extends Composer<_$AppDatabase, $BookmarkedConceptsTable> {
  $$BookmarkedConceptsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get conceptId => $composableBuilder(
      column: $table.conceptId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get savedAt => $composableBuilder(
      column: $table.savedAt, builder: (column) => ColumnFilters(column));
}

class $$BookmarkedConceptsTableOrderingComposer
    extends Composer<_$AppDatabase, $BookmarkedConceptsTable> {
  $$BookmarkedConceptsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get conceptId => $composableBuilder(
      column: $table.conceptId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get savedAt => $composableBuilder(
      column: $table.savedAt, builder: (column) => ColumnOrderings(column));
}

class $$BookmarkedConceptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookmarkedConceptsTable> {
  $$BookmarkedConceptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get conceptId =>
      $composableBuilder(column: $table.conceptId, builder: (column) => column);

  GeneratedColumn<int> get savedAt =>
      $composableBuilder(column: $table.savedAt, builder: (column) => column);
}

class $$BookmarkedConceptsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BookmarkedConceptsTable,
    BookmarkedConcept,
    $$BookmarkedConceptsTableFilterComposer,
    $$BookmarkedConceptsTableOrderingComposer,
    $$BookmarkedConceptsTableAnnotationComposer,
    $$BookmarkedConceptsTableCreateCompanionBuilder,
    $$BookmarkedConceptsTableUpdateCompanionBuilder,
    (
      BookmarkedConcept,
      BaseReferences<_$AppDatabase, $BookmarkedConceptsTable, BookmarkedConcept>
    ),
    BookmarkedConcept,
    PrefetchHooks Function()> {
  $$BookmarkedConceptsTableTableManager(
      _$AppDatabase db, $BookmarkedConceptsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookmarkedConceptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookmarkedConceptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookmarkedConceptsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> conceptId = const Value.absent(),
            Value<int> savedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BookmarkedConceptsCompanion(
            conceptId: conceptId,
            savedAt: savedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String conceptId,
            required int savedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              BookmarkedConceptsCompanion.insert(
            conceptId: conceptId,
            savedAt: savedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BookmarkedConceptsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BookmarkedConceptsTable,
    BookmarkedConcept,
    $$BookmarkedConceptsTableFilterComposer,
    $$BookmarkedConceptsTableOrderingComposer,
    $$BookmarkedConceptsTableAnnotationComposer,
    $$BookmarkedConceptsTableCreateCompanionBuilder,
    $$BookmarkedConceptsTableUpdateCompanionBuilder,
    (
      BookmarkedConcept,
      BaseReferences<_$AppDatabase, $BookmarkedConceptsTable, BookmarkedConcept>
    ),
    BookmarkedConcept,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PlayerProfilesTableTableManager get playerProfiles =>
      $$PlayerProfilesTableTableManager(_db, _db.playerProfiles);
  $$WorldProgressTableTableManager get worldProgress =>
      $$WorldProgressTableTableManager(_db, _db.worldProgress);
  $$LevelAttemptsTableTableManager get levelAttempts =>
      $$LevelAttemptsTableTableManager(_db, _db.levelAttempts);
  $$LevelCompletionsTableTableManager get levelCompletions =>
      $$LevelCompletionsTableTableManager(_db, _db.levelCompletions);
  $$AchievementsEarnedTableTableManager get achievementsEarned =>
      $$AchievementsEarnedTableTableManager(_db, _db.achievementsEarned);
  $$ThemeUnlocksTableTableManager get themeUnlocks =>
      $$ThemeUnlocksTableTableManager(_db, _db.themeUnlocks);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$ContentCacheManifestTableTableManager get contentCacheManifest =>
      $$ContentCacheManifestTableTableManager(_db, _db.contentCacheManifest);
  $$BookmarkedConceptsTableTableManager get bookmarkedConcepts =>
      $$BookmarkedConceptsTableTableManager(_db, _db.bookmarkedConcepts);
}

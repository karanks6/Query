import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'models/level_model.dart';
/// Loads world and level content from bundled JSON assets.
///
/// Content structure (Section 7.3):
///   assets/levels/world_01_archive_vaults/world.json  — world metadata
///   assets/levels/world_01_archive_vaults/level_01.json … level_15.json
///
/// Worlds 1–3 are bundled at launch for offline-first play.
class LevelLoader {
  LevelLoader._();
  static final LevelLoader instance = LevelLoader._();

  // In-memory cache after first load
  final Map<String, WorldModel> _worldCache = {};
  final Map<String, LevelModel> _levelCache = {};

  static const _worldDirectories = {
    'world_01': 'assets/levels/world_01_archive_vaults',
    'world_02': 'assets/levels/world_02_filter_district',
    'world_03': 'assets/levels/world_03_aggregation_district',
    'world_04': 'assets/levels/world_04_join_nexus',
    'world_05': 'assets/levels/world_05_nested_depths',
    'world_06': 'assets/levels/world_06_data_forge',
    'world_07': 'assets/levels/world_07_blueprint_bureau',
    'world_08': 'assets/levels/world_08_function_foundry',
    'world_09': 'assets/levels/world_09_optimization_observatory',
    'world_10': 'assets/levels/world_10_grand_archive',
  };

  /// Loads and caches a world and all its levels.
  Future<WorldModel> loadWorld(String worldId) async {
    if (_worldCache.containsKey(worldId)) return _worldCache[worldId]!;

    final dir = _worldDirectories[worldId];
    if (dir == null) throw ContentNotFoundError('World $worldId not found.');

    // Load world metadata
    final worldJson = await _loadJson('$dir/world.json');
    final world = WorldModel.fromJson(worldJson);

    // Load all levels
    final levels = <LevelModel>[];
    for (int i = 1; i <= world.totalLevels; i++) {
      final levelId = '${worldId}_level_${i.toString().padLeft(2, '0')}';
      final levelJson = await _loadJson(
          '$dir/level_${i.toString().padLeft(2, '0')}.json');
      final level = LevelModel.fromJson(levelJson);
      levels.add(level);
      _levelCache[levelId] = level;
    }

    // Re-build world with loaded levels (JSON world.json may not include inline levels)
    final fullWorld = WorldModel(
      id: world.id,
      number: world.number,
      title: world.title,
      caseFile: world.caseFile,
      clientName: world.clientName,
      narrativeIntro: world.narrativeIntro,
      coreSqlConcept: world.coreSqlConcept,
      totalLevels: world.totalLevels,
      levels: levels,
      unlockThemeId: world.unlockThemeId,
    );

    _worldCache[worldId] = fullWorld;
    return fullWorld;
  }

  /// Loads a single level by ID (e.g. "world_01_level_03").
  Future<LevelModel> loadLevel(String levelId) async {
    if (_levelCache.containsKey(levelId)) return _levelCache[levelId]!;

    // Parse world ID from level ID
    final parts = levelId.split('_');
    if (parts.length < 4) throw ContentNotFoundError('Invalid level ID: $levelId');
    final worldId = '${parts[0]}_${parts[1]}';

    // Loading the world populates the level cache
    await loadWorld(worldId);

    final level = _levelCache[levelId];
    if (level == null) throw ContentNotFoundError('Level $levelId not found.');
    return level;
  }

  /// Preloads all bundled worlds — call on app startup.
  Future<void> preloadBundledWorlds() async {
    for (final worldId in _worldDirectories.keys) {
      try {
        await loadWorld(worldId);
      } catch (e) {
        // Log but don't crash — missing content will surface at level entry
      }
    }
  }

  Future<Map<String, dynamic>> _loadJson(String assetPath) async {
    try {
      final docDir = await getApplicationDocumentsDirectory();
      final localFile = File('${docDir.path}/$assetPath');
      if (await localFile.exists()) {
        final raw = await localFile.readAsString();
        return json.decode(raw) as Map<String, dynamic>;
      }
    } catch (e) {
      // Fallback to bundled asset
    }

    final raw = await rootBundle.loadString(assetPath);
    return json.decode(raw) as Map<String, dynamic>;
  }

  void clearCache() {
    _worldCache.clear();
    _levelCache.clear();
  }
}

class ContentNotFoundError implements Exception {
  final String message;
  const ContentNotFoundError(this.message);
  @override
  String toString() => 'ContentNotFoundError: $message';
}

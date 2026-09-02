import 'dart:convert';
import 'dart:io';

// Simplified mock of LevelLoader to test parsing logic
void main() {
  final directories = [
    'assets/levels/world_01_archive_vaults',
    'assets/levels/world_02_filter_district',
    'assets/levels/world_03_aggregation_district',
    'assets/levels/world_04_join_nexus',
    'assets/levels/world_05_nested_depths',
    'assets/levels/world_06_data_forge',
  ];

  for (final dir in directories) {
    print('Testing $dir...');
    final worldFile = File('$dir/world.json');
    if (!worldFile.existsSync()) {
      print('  Missing world.json');
      continue;
    }
    
    try {
      final worldJson = json.decode(worldFile.readAsStringSync());
      final totalLevels = (worldJson['total_levels'] ?? worldJson['totalLevels']) as int? ?? 0;
      
      for (int i = 1; i <= totalLevels; i++) {
        final levelFile = File('$dir/level_${i.toString().padLeft(2, '0')}.json');
        if (!levelFile.existsSync()) {
          print('  Missing level $i');
          continue;
        }
        
        final levelJson = json.decode(levelFile.readAsStringSync());
        
        // Emulate the exact parsing logic to see if it throws
        try {
          final hintsJson = (levelJson['hints'] as List<dynamic>?) ?? [];
          final expectedJson = ((levelJson['expected_result'] ?? levelJson['expectedResult']) as List<dynamic>?) ?? [];
          final timingJson = (levelJson['timing_thresholds'] ?? levelJson['timingThresholds']) as Map<String, dynamic>?;

          // ... check required fields ...
          final id = levelJson['id'] as String;
          final title = levelJson['title'] as String? ?? 'Unknown Title';
          final schema = levelJson['schema'] as Map<String, dynamic>;
          
          final tablesJson = schema['tables'] as List<dynamic>? ?? [];
          for (final t in tablesJson) {
            final name = t['name'] as String;
            final cols = t['columns'] as List<dynamic>? ?? [];
            for (final c in cols) {
               final cname = c['name'] as String;
               final type = c['type'] as String? ?? 'TEXT';
               final pk = (c['primary_key'] ?? c['primaryKey']) as bool? ?? false;
               final nn = (c['not_null'] ?? c['notNull'] ?? c['nullable'] == false) as bool? ?? false;
            }
          }
        } catch (e) {
          print('  ERROR parsing level $i: $e');
        }
      }
    } catch (e) {
      print('  ERROR parsing world: $e');
    }
  }
  print('Done.');
}

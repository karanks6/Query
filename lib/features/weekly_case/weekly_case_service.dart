import 'dart:convert';
import 'package:flutter/services.dart';
import '../../data/content/models/level_model.dart';

/// A single weekly case definition loaded from assets/levels/weekly_cases/cases.json.
class WeeklyCase {
  final String caseId;
  final String title;
  final String client;
  final String narrative;
  final String difficulty;
  final int xpReward;
  final List<LevelModel> levels;

  const WeeklyCase({
    required this.caseId,
    required this.title,
    required this.client,
    required this.narrative,
    required this.difficulty,
    required this.xpReward,
    required this.levels,
  });

  factory WeeklyCase.fromJson(Map<String, dynamic> json) {
    final levelsJson = json['levels'] as List<dynamic>? ?? [];
    return WeeklyCase(
      caseId:    json['case_id']   as String,
      title:     json['title']     as String,
      client:    json['client']    as String? ?? '',
      narrative: json['narrative'] as String? ?? '',
      difficulty:json['difficulty']as String? ?? 'Standard',
      xpReward:  json['xp_reward'] as int? ?? 500,
      levels:    levelsJson
          .map((l) => LevelModel.fromJson(l as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Loads and rotates weekly case files from bundled assets.
///
/// Rotation logic: the case index is computed from the ISO week number so
/// the same case appears for all 7 days of the week, rotating every Monday.
class WeeklyCaseService {
  WeeklyCaseService._();
  static final WeeklyCaseService instance = WeeklyCaseService._();

  List<WeeklyCase>? _cases;

  Future<void> _ensureLoaded() async {
    if (_cases != null) return;
    try {
      final raw = await rootBundle.loadString('assets/levels/weekly_cases/cases.json');
      final list = jsonDecode(raw) as List<dynamic>;
      _cases = list.map((j) => WeeklyCase.fromJson(j as Map<String, dynamic>)).toList();
    } catch (e) {
      _cases = [];
    }
  }

  /// Returns the WeeklyCase active during the current ISO week.
  Future<WeeklyCase?> getCurrentCase() async {
    await _ensureLoaded();
    if (_cases == null || _cases!.isEmpty) return null;
    final weekNumber = _isoWeekNumber(DateTime.now());
    final index = weekNumber % _cases!.length;
    return _cases![index];
  }

  /// Number of seconds until next Monday 00:00 local time.
  Duration timeUntilReset() {
    final now = DateTime.now();
    // Days until next Monday (weekday: Mon=1 … Sun=7)
    final daysUntilMonday = (8 - now.weekday) % 7 == 0 ? 7 : (8 - now.weekday) % 7;
    final nextMonday = DateTime(now.year, now.month, now.day + daysUntilMonday);
    return nextMonday.difference(now);
  }

  static int _isoWeekNumber(DateTime date) {
    // ISO 8601 week number
    final dayOfYear = int.parse(
      '${date.difference(DateTime(date.year, 1, 1)).inDays + 1}',
    );
    final weekday = date.weekday; // Mon=1, Sun=7
    return ((dayOfYear - weekday + 10) / 7).floor();
  }
}

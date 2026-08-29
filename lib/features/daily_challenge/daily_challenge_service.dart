import 'dart:convert';
import 'package:flutter/services.dart';
import '../../data/content/models/level_model.dart';

class DailyChallengeService {
  DailyChallengeService._();
  static final DailyChallengeService instance = DailyChallengeService._();

  List<LevelModel>? _pool;

  /// Loads the static pool of daily challenges from bundled assets
  Future<void> _ensurePoolLoaded() async {
    if (_pool != null) return;
    try {
      final jsonStr = await rootBundle.loadString('assets/levels/daily_challenges/pool.json');
      final List<dynamic> jsonList = jsonDecode(jsonStr);
      _pool = jsonList.map((j) => LevelModel.fromJson(j as Map<String, dynamic>)).toList();
    } catch (e) {
      _pool = [];
    }
  }

  /// Returns the challenge for the current day based on the date.
  Future<LevelModel?> getTodayChallenge() async {
    await _ensurePoolLoaded();
    if (_pool == null || _pool!.isEmpty) return null;

    final now = DateTime.now();
    // Use the days since epoch to deterministically pick a puzzle for everyone
    final daysSinceEpoch = now.difference(DateTime.utc(1970, 1, 1)).inDays;
    
    final index = daysSinceEpoch % _pool!.length;
    return _pool![index];
  }
}

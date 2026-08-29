import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'sync_service.dart';
import '../../data/local/daos/progress_dao.dart';
import '../../data/local/daos/player_dao.dart';

class FirebaseSyncService implements SyncService {
  final _statusController = StreamController<SyncStatus>.broadcast();
  SyncStatus _currentStatus = SyncStatus.idle;
  
  final ProgressDao progressDao;
  final PlayerDao playerDao;

  FirebaseSyncService({
    required this.progressDao,
    required this.playerDao,
  }) {
    _statusController.add(_currentStatus);
  }

  void _updateStatus(SyncStatus status) {
    _currentStatus = status;
    _statusController.add(status);
  }

  @override
  Stream<SyncStatus> get status => _statusController.stream;

  @override
  Future<void> initialize() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        await FirebaseAuth.instance.signInAnonymously();
      }
      debugPrint("FirebaseSyncService: Initialized for user: \${FirebaseAuth.instance.currentUser?.uid}");
    } catch (e) {
      debugPrint("FirebaseSyncService init error: \$e");
      _updateStatus(SyncStatus.error);
    }
  }

  @override
  Future<void> syncUp() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _updateStatus(SyncStatus.syncing);
    try {
      // Collect local state
      final profile = await playerDao.getProfile();
      final completedLevels = await progressDao.getAllLevelCompletions();

      // Batch write to Firestore
      final batch = FirebaseFirestore.instance.batch();
      
      final playerRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      batch.set(playerRef, {
        'xp': profile?.totalXp ?? 0,
        'currentRank': profile?.rankTitle ?? 'Intern',
        'lastSync': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      for (final lvl in completedLevels) {
        final lvlRef = playerRef.collection('completed_levels').doc(lvl.levelId);
        batch.set(lvlRef, {
          'stars': lvl.starsEarned,
          'best_duration_ms': lvl.bestDurationMs,
          'time_medal': lvl.timeMedal,
          'completed_at': DateTime.fromMillisecondsSinceEpoch(lvl.completedAt).toIso8601String(),
        }, SetOptions(merge: true));
      }

      await batch.commit();
      _updateStatus(SyncStatus.idle);
    } catch (e) {
      debugPrint("FirebaseSyncService syncUp error: \$e");
      _updateStatus(SyncStatus.error);
    }
  }

  @override
  Future<void> syncDown() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _updateStatus(SyncStatus.syncing);
    try {
      final playerRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final playerSnap = await playerRef.get();
      
      if (playerSnap.exists) {
        final data = playerSnap.data()!;
        final cloudXp = data['xp'] as int? ?? 0;
        
        // Simple conflict resolution: Cloud wins if higher
        final profile = await playerDao.getProfile();
        if (profile == null || cloudXp > profile.totalXp) {
          await playerDao.addXp(cloudXp - (profile?.totalXp ?? 0));
        }
      }

      final levelsSnap = await playerRef.collection('completed_levels').get();
      for (final doc in levelsSnap.docs) {
        final data = doc.data();
        await progressDao.saveLevelCompletion(
          levelId: doc.id,
          starsEarned: data['stars'] as int? ?? 1,
          timeMedal: data['time_medal'] as int?,
          durationMs: data['best_duration_ms'] as int?,
        );
      }

      _updateStatus(SyncStatus.idle);
    } catch (e) {
      debugPrint("FirebaseSyncService syncDown error: \$e");
      _updateStatus(SyncStatus.error);
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LeaderboardEntry {
  final String uid;
  final String displayName;
  final int totalXp;
  final String rankTitle;

  const LeaderboardEntry({
    required this.uid,
    required this.displayName,
    required this.totalXp,
    required this.rankTitle,
  });

  factory LeaderboardEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LeaderboardEntry(
      uid: doc.id,
      displayName: data['displayName'] as String? ?? 'Unknown',
      totalXp: data['totalXp'] as int? ?? 0,
      rankTitle: data['rankTitle'] as String? ?? 'Junior Analyst',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'totalXp': totalXp,
      'rankTitle': rankTitle,
      'lastUpdated': FieldValue.serverTimestamp(),
    };
  }
}

class LeaderboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> _getUserId() async {
    if (_auth.currentUser == null) {
      try {
        await _auth.signInAnonymously();
      } catch (e) {
        return null;
      }
    }
    return _auth.currentUser?.uid;
  }

  /// Pushes the local player profile data to the global leaderboard.
  Future<void> syncPlayerXp({
    required String displayName,
    required int totalXp,
    required String rankTitle,
  }) async {
    final uid = await _getUserId();
    if (uid == null) return; // Silent fail if offline or auth fails

    final entry = LeaderboardEntry(
      uid: uid,
      displayName: displayName,
      totalXp: totalXp,
      rankTitle: rankTitle,
    );

    try {
      await _firestore.collection('leaderboard').doc(uid).set(
            entry.toMap(),
            SetOptions(merge: true),
          );
    } catch (e) {
      // Ignore if firestore rules reject or offline
    }
  }

  /// Fetches the top players ordered by XP.
  Stream<List<LeaderboardEntry>> getTopPlayers({int limit = 25}) {
    return _firestore
        .collection('leaderboard')
        .orderBy('totalXp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => LeaderboardEntry.fromFirestore(doc)).toList());
  }
}

final leaderboardServiceProvider = Provider<LeaderboardService>((ref) {
  return LeaderboardService();
});

final topPlayersProvider = StreamProvider<List<LeaderboardEntry>>((ref) {
  final service = ref.watch(leaderboardServiceProvider);
  return service.getTopPlayers();
});

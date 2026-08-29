import 'dart:async';

/// Defines the core contract for cloud synchronization (e.g., Firebase).
///
/// In Phase 5, this will be implemented by FirebaseSyncService to persist
/// the local Drift SQLite meta-database (XP, ranks, completed levels) to Firestore.
abstract class SyncService {
  /// Initializes the sync service (e.g., authenticating anonymously if needed).
  Future<void> initialize();

  /// Pushes local progress to the cloud.
  Future<void> syncUp();

  /// Pulls cloud progress and merges it with local data.
  Future<void> syncDown();

  /// Streams the current sync status.
  Stream<SyncStatus> get status;
}

enum SyncStatus {
  idle,
  syncing,
  error,
  offline
}

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'sync_service.dart';

/// A mock implementation of the SyncService for Phase 4.
///
/// This simulates Firebase cloud sync delays and state transitions
/// without requiring actual Firebase configuration.
class MockFirebaseSyncService implements SyncService {
  final _statusController = StreamController<SyncStatus>.broadcast();
  SyncStatus _currentStatus = SyncStatus.idle;

  MockFirebaseSyncService() {
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
    debugPrint("MockFirebaseSyncService: Initializing...");
    await Future.delayed(const Duration(milliseconds: 500));
    debugPrint("MockFirebaseSyncService: Initialized (Mock Anonymous Auth).");
  }

  @override
  Future<void> syncUp() async {
    debugPrint("MockFirebaseSyncService: syncUp started...");
    _updateStatus(SyncStatus.syncing);
    
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    debugPrint("MockFirebaseSyncService: syncUp completed.");
    _updateStatus(SyncStatus.idle);
  }

  @override
  Future<void> syncDown() async {
    debugPrint("MockFirebaseSyncService: syncDown started...");
    _updateStatus(SyncStatus.syncing);
    
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    debugPrint("MockFirebaseSyncService: syncDown completed.");
    _updateStatus(SyncStatus.idle);
  }
}

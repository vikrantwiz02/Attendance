import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../datasources/local_data_source.dart';
import '../datasources/remote_data_source.dart';
import '../models/sync_response.dart';

/// Synchronization Engine for offline-first architecture
/// Manages the bidirectional sync between local Hive database and MongoDB backend
class SyncEngine {
  final LocalDataSource localDataSource;
  final RemoteDataSource remoteDataSource;
  final Connectivity connectivity;
  final Logger logger;

  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  
  // Stream controllers for sync status
  final _syncStatusController = StreamController<SyncStatus>.broadcast();
  final _syncProgressController = StreamController<SyncProgress>.broadcast();

  bool _isSyncing = false;
  bool _isConnected = false;

  // Configuration
  static const Duration _syncInterval = Duration(minutes: 5);
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 5);

  SyncEngine({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.connectivity,
    required this.logger,
  });

  /// Initialize the sync engine and start listening for connectivity changes
  Future<void> init() async {
    // Check initial connectivity
    final result = await connectivity.checkConnectivity();
    _isConnected = result != ConnectivityResult.none;
    logger.i('Initial connectivity: $_isConnected');

    // Listen to connectivity changes
    _connectivitySubscription = connectivity.onConnectivityChanged.listen(
      (result) {
        final wasConnected = _isConnected;
        _isConnected = result.contains(ConnectivityResult.none) == false;
        
        logger.i('Connectivity changed: $_isConnected');

        if (!wasConnected && _isConnected) {
          // Went from offline to online - trigger sync
          logger.i('Network restored - triggering sync');
          _triggerSync();
        }
      },
    );

    // Start periodic sync timer
    Timer.periodic(_syncInterval, (_) {
      if (_isConnected && !_isSyncing) {
        _triggerSync();
      }
    });

    // Initial sync if online
    if (_isConnected) {
      await Future.delayed(const Duration(seconds: 2));
      _triggerSync();
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _connectivitySubscription.cancel();
    await _syncStatusController.close();
    await _syncProgressController.close();
  }

  /// Manually trigger a sync operation
  Future<void> _triggerSync() async {
    if (_isSyncing || !_isConnected) return;

    _isSyncing = true;
    _syncStatusController.add(SyncStatus.syncing);

    try {
      await _performSync();
      _syncStatusController.add(SyncStatus.synced);
    } catch (e) {
      logger.e('Sync failed: $e');
      _syncStatusController.add(SyncStatus.failed);
    } finally {
      _isSyncing = false;
    }
  }

  /// Perform the actual sync operation
  Future<void> _performSync() async {
    logger.i('Starting sync operation');
    
    // Get all pending logs
    final pendingLogs = await localDataSource.getPendingAttendanceLogs();
    
    if (pendingLogs.isEmpty) {
      logger.i('No pending logs to sync');
      return;
    }

    logger.i('Syncing ${pendingLogs.length} pending logs');

    // Sort by client timestamp (ascending) for Last-Write-Wins strategy
    pendingLogs.sort((a, b) =>
        (a['clientTimestamp'] as String)
            .compareTo(b['clientTimestamp'] as String));

    // Attempt to sync with retries
    for (int attempt = 0; attempt < _maxRetries; attempt++) {
      try {
        // Update status to syncing
        for (final log in pendingLogs) {
          await localDataSource.updateAttendanceLogSyncStatus(
            log['clientId'] as String,
            'syncing',
          );
        }

        // Emit progress
        _syncProgressController.add(
          SyncProgress(
            total: pendingLogs.length,
            synced: 0,
            failed: 0,
          ),
        );

        // Send to server
        final response = await remoteDataSource.syncAttendanceLogs(
          pendingLogs,
        );

        // Parse response
        final syncResponse = SyncResponse.fromJson(response);

        // Update local records based on response
        for (final syncedRecord in syncResponse.syncedRecords) {
          final clientId = syncedRecord['clientId'] as String;
          await localDataSource.updateAttendanceLogSyncStatus(
            clientId,
            'synced',
          );
          await localDataSource.removeFromSyncQueue(clientId);
        }

        // Handle failed records
        for (final failedId in syncResponse.failedRecordIds) {
          await localDataSource.updateAttendanceLogSyncStatus(failedId, 'failed');
        }

        // Emit final progress
        _syncProgressController.add(
          SyncProgress(
            total: pendingLogs.length,
            synced: syncResponse.syncedRecords.length,
            failed: syncResponse.failedRecordIds.length,
          ),
        );

        logger.i(
          'Sync completed: ${syncResponse.syncedRecords.length} synced, '
          '${syncResponse.failedRecordIds.length} failed',
        );

        return; // Success
      } catch (e) {
        logger.w('Sync attempt $attempt failed: $e');
        
        if (attempt < _maxRetries - 1) {
          await Future.delayed(_retryDelay);
        } else {
          rethrow;
        }
      }
    }
  }

  /// Force an immediate sync
  Future<void> forceSync() async {
    if (!_isConnected) {
      throw Exception('No internet connection');
    }
    await _triggerSync();
  }

  /// Get sync status stream
  Stream<SyncStatus> get syncStatus => _syncStatusController.stream;

  /// Get sync progress stream
  Stream<SyncProgress> get syncProgress => _syncProgressController.stream;

  /// Check if currently syncing
  bool get isSyncing => _isSyncing;

  /// Check if connected to internet
  bool get isConnected => _isConnected;
}

/// Sync status enum
enum SyncStatus {
  idle,
  syncing,
  synced,
  failed,
}

/// Sync progress information
class SyncProgress {
  final int total;
  final int synced;
  final int failed;

  int get remaining => total - synced - failed;
  double get progress => total == 0 ? 1.0 : (synced + failed) / total;

  SyncProgress({
    required this.total,
    required this.synced,
    required this.failed,
  });

  @override
  String toString() =>
      'SyncProgress(total: $total, synced: $synced, failed: $failed, progress: ${(progress * 100).toStringAsFixed(1)}%)';
}

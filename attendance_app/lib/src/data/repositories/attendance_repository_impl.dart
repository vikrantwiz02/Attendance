import 'package:flutter/foundation.dart';
import '../datasources/local_data_source.dart';
import '../datasources/remote_data_source.dart';
import '../../domain/models/attendance_log.dart';
import '../../domain/repositories/attendance_repository.dart';

/// Implementation of AttendanceRepository
class AttendanceRepositoryImpl implements AttendanceRepository {
  final LocalDataSource localDataSource;
  final RemoteDataSource remoteDataSource;

  AttendanceRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<void> saveAttendanceLog(AttendanceLog log) async {
    // Save locally first (offline-first approach)
    await localDataSource.saveAttendanceLog(log);
    
    // Add to sync queue for later sync
    await localDataSource.addToSyncQueue(
      log.clientId,
      log.toJson(),
    );
  }

  @override
  Future<List<AttendanceLog>> getPendingLogs() async {
    final logs = await localDataSource.getPendingAttendanceLogs();
    return logs.map((json) => AttendanceLog.fromJson(json)).toList();
  }

  @override
  Future<List<AttendanceLog>> getAttendanceHistory({
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    try {
      // Try to fetch from server first
      final remoteLogs = await remoteDataSource.getAttendanceHistory(
        fromDate: fromDate,
        toDate: toDate,
      );
      return remoteLogs.map((json) => AttendanceLog.fromJson(json)).toList();
    } catch (e) {
      // Fall back to local data if offline
      debugPrint('Failed to fetch from server: $e');
      final localLogs = await localDataSource.getAttendanceLogsByDateRange(
        fromDate,
        toDate,
      );
      return localLogs.map((json) => AttendanceLog.fromJson(json)).toList();
    }
  }

  @override
  Future<AttendanceLog?> getLatestLog() async {
    final log = await localDataSource.getLatestAttendanceLog();
    if (log != null) {
      return AttendanceLog.fromJson(log);
    }
    return null;
  }

  @override
  Future<void> markLogAsSynced(String clientId) async {
    await localDataSource.updateAttendanceLogSyncStatus(
      clientId,
      'synced',
    );
  }

  @override
  Future<void> markLogAsFailed(String clientId) async {
    await localDataSource.updateAttendanceLogSyncStatus(
      clientId,
      'failed',
    );
  }
}

import '../models/attendance_log.dart';

/// Repository interface for attendance operations
abstract class AttendanceRepository {
  /// Save an attendance log locally and queue for sync
  Future<void> saveAttendanceLog(AttendanceLog log);

  /// Get all pending logs that haven't been synced yet
  Future<List<AttendanceLog>> getPendingLogs();

  /// Get attendance history for a date range
  Future<List<AttendanceLog>> getAttendanceHistory({
    required DateTime fromDate,
    required DateTime toDate,
  });

  /// Get the most recent attendance log
  Future<AttendanceLog?> getLatestLog();

  /// Mark a log as successfully synced
  Future<void> markLogAsSynced(String clientId);

  /// Mark a log as failed sync
  Future<void> markLogAsFailed(String clientId);
}

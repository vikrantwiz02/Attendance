import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/models/attendance_log.dart';
import '../../domain/models/geofence.dart';
import '../../domain/models/leave_request.dart';
import '../../domain/models/user.dart';

/// Local data source using Hive for offline-first storage
class LocalDataSource {
  static const String _attendanceBoxName = 'attendance_logs';
  static const String _userBoxName = 'user';
  static const String _geofenceBoxName = 'geofences';
  static const String _leaveRequestBoxName = 'leave_requests';
  static const String _syncQueueBoxName = 'sync_queue';

  late Box<Map<String, dynamic>> _attendanceBox;
  late Box<Map<String, dynamic>> _userBox;
  late Box<Map<String, dynamic>> _geofenceBox;
  late Box<Map<String, dynamic>> _leaveRequestBox;
  late Box<Map<String, dynamic>> _syncQueueBox;

  /// Initialize Hive and open all boxes
  Future<void> init() async {
    await Hive.initFlutter();
    _attendanceBox = await Hive.openBox(_attendanceBoxName);
    _userBox = await Hive.openBox(_userBoxName);
    _geofenceBox = await Hive.openBox(_geofenceBoxName);
    _leaveRequestBox = await Hive.openBox(_leaveRequestBoxName);
    _syncQueueBox = await Hive.openBox(_syncQueueBoxName);
  }

  /// Close all boxes
  Future<void> close() async {
    await _attendanceBox.close();
    await _userBox.close();
    await _geofenceBox.close();
    await _leaveRequestBox.close();
    await _syncQueueBox.close();
  }

  // ============= ATTENDANCE LOGS =============

  /// Save an attendance log locally
  Future<void> saveAttendanceLog(AttendanceLog log) async {
    await _attendanceBox.put(log.clientId, log.toJson());
  }

  /// Get all pending attendance logs (not yet synced)
  Future<List<Map<String, dynamic>>> getPendingAttendanceLogs() async {
    final allLogs = _attendanceBox.values.toList();
    return allLogs
        .where((log) => log['syncStatus'] == 'pending')
        .toList()
        ..sort((a, b) => (a['clientTimestamp'] as String)
            .compareTo(b['clientTimestamp'] as String));
  }

  /// Update attendance log sync status
  Future<void> updateAttendanceLogSyncStatus(
    String clientId,
    String syncStatus,
  ) async {
    final log = _attendanceBox.get(clientId);
    if (log != null) {
      log['syncStatus'] = syncStatus;
      await _attendanceBox.put(clientId, log);
    }
  }

  /// Get all attendance logs for a date range
  Future<List<Map<String, dynamic>>> getAttendanceLogsByDateRange(
    DateTime fromDate,
    DateTime toDate,
  ) async {
    final allLogs = _attendanceBox.values.toList();
    return allLogs
        .where((log) {
          final timestamp = DateTime.parse(log['clientTimestamp'] as String);
          return timestamp.isAfter(fromDate) && timestamp.isBefore(toDate);
        })
        .toList()
        ..sort((a, b) => (b['clientTimestamp'] as String)
            .compareTo(a['clientTimestamp'] as String));
  }

  /// Get the latest clock-in/out action
  Future<Map<String, dynamic>?> getLatestAttendanceLog() async {
    final logs = _attendanceBox.values.toList();
    if (logs.isEmpty) return null;
    logs.sort((a, b) =>
        (b['clientTimestamp'] as String)
            .compareTo(a['clientTimestamp'] as String));
    return logs.first;
  }

  /// Clear all attendance logs (use with caution)
  Future<void> clearAllAttendanceLogs() async {
    await _attendanceBox.clear();
  }

  // ============= USER =============

  /// Save user data
  Future<void> saveUser(User user) async {
    await _userBox.put('current_user', user.toJson());
  }

  /// Get saved user data
  Future<Map<String, dynamic>?> getUser() async {
    return _userBox.get('current_user');
  }

  /// Clear user data
  Future<void> clearUser() async {
    await _userBox.delete('current_user');
  }

  // ============= GEOFENCES =============

  /// Save geofences list
  Future<void> saveGeofences(List<Geofence> geofences) async {
    final geofenceList = geofences.map((g) => g.toJson()).toList();
    await _geofenceBox.put('geofences', {'list': geofenceList});
  }

  /// Get all geofences
  Future<List<Map<String, dynamic>>> getGeofences() async {
    final data = _geofenceBox.get('geofences', defaultValue: {'list': []}) as Map;
    final geofenceList = data['list'] as List? ?? [];
    return List<Map<String, dynamic>>.from(geofenceList);
  }

  // ============= LEAVE REQUESTS =============

  /// Save a leave request
  Future<void> saveLeaveRequest(LeaveRequest request) async {
    await _leaveRequestBox.put(request.id, request.toJson());
  }

  /// Get all leave requests
  Future<List<Map<String, dynamic>>> getLeaveRequests() async {
    return _leaveRequestBox.values.toList();
  }

  /// Get leave request by ID
  Future<Map<String, dynamic>?> getLeaveRequestById(String id) async {
    return _leaveRequestBox.get(id);
  }

  // ============= SYNC QUEUE =============

  /// Add item to sync queue
  Future<void> addToSyncQueue(String clientId, Map<String, dynamic> data) async {
    await _syncQueueBox.put(clientId, data);
  }

  /// Get all items in sync queue
  Future<List<Map<String, dynamic>>> getSyncQueue() async {
    return _syncQueueBox.values.toList();
  }

  /// Remove item from sync queue
  Future<void> removeFromSyncQueue(String clientId) async {
    await _syncQueueBox.delete(clientId);
  }

  /// Clear sync queue
  Future<void> clearSyncQueue() async {
    await _syncQueueBox.clear();
  }
}

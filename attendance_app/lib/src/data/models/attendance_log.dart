import 'package:freezed_annotation/freezed_annotation.dart';

part 'attendance_log.freezed.dart';
part 'attendance_log.g.dart';

enum AttendanceActionType {
  clockIn,
  clockOut,
  break,
}

enum SyncStatus {
  pending,
  syncing,
  synced,
  failed,
}

/// Represents an attendance action (clock in/out, break, etc.)
@freezed
class AttendanceLog with _$AttendanceLog {
  const factory AttendanceLog({
    /// Unique identifier generated on the client
    required String clientId,
    
    /// Server-assigned ID (populated after sync)
    String? serverId,
    
    /// User ID (populated after authentication)
    String? userId,
    
    /// Type of attendance action
    required AttendanceActionType actionType,
    
    /// Client timestamp (always in UTC)
    required DateTime clientTimestamp,
    
    /// Server timestamp (set by backend, used for conflict resolution)
    DateTime? serverTimestamp,
    
    /// GPS latitude
    required double latitude,
    
    /// GPS longitude
    required double longitude,
    
    /// Accuracy of GPS reading in meters
    required double accuracy,
    
    /// Whether the action was within geofence
    required bool withinGeofence,
    
    /// Distance from geofence center in meters
    double? distanceFromGeofence,
    
    /// Current sync status
    required SyncStatus syncStatus,
    
    /// Notes or remarks
    String? notes,
    
    /// Device identifier
    String? deviceId,
    
    /// Network type when action was taken
    String? networkType,
  }) = _AttendanceLog;

  factory AttendanceLog.fromJson(Map<String, dynamic> json) =>
      _$AttendanceLogFromJson(json);
}

import '../models/attendance_log.dart';
import '../repositories/attendance_repository.dart';
import 'package:uuid/uuid.dart';

/// Use case for recording a clock in/out action
class ClockActionUseCase {
  final AttendanceRepository repository;

  ClockActionUseCase({required this.repository});

  Future<AttendanceLog> execute({
    required AttendanceActionType actionType,
    required double latitude,
    required double longitude,
    required double accuracy,
    required bool withinGeofence,
    double? distanceFromGeofence,
    String? notes,
    String? deviceId,
    String? networkType,
  }) async {
    // Generate unique client ID
    const uuid = Uuid();
    final clientId = uuid.v4();

    // Create attendance log
    final log = AttendanceLog(
      clientId: clientId,
      actionType: actionType,
      clientTimestamp: DateTime.now().toUtc(),
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      withinGeofence: withinGeofence,
      distanceFromGeofence: distanceFromGeofence,
      syncStatus: SyncStatus.pending,
      notes: notes,
      deviceId: deviceId,
      networkType: networkType,
    );

    // Save to local database (offline-first)
    await repository.saveAttendanceLog(log);

    return log;
  }
}

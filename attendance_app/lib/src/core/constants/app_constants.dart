/// API configuration constants
class ApiConstants {
  static const String baseUrl = 'https://api.attendance-app.com';
  
  // Endpoints
  static const String authGoogleVerify = '/api/auth/google-verify';
  static const String syncLogs = '/api/sync-logs';
  static const String geofences = '/api/geofences';
  static const String userProfile = '/api/users/profile';
  static const String leaveRequests = '/api/leave-requests';
  static const String attendanceLogs = '/api/attendance-logs';

  // Timeout
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

/// Local storage keys
class LocalStorageKeys {
  static const String jwtToken = 'jwt_token';
  static const String currentUser = 'current_user';
  static const String lastSyncTime = 'last_sync_time';
}

/// Geofencing configuration
class GeofenceConfig {
  /// Default geofence radius in meters
  static const double defaultRadiusMeters = 100.0;
  
  /// Minimum accuracy for GPS reading in meters
  static const double minGpsAccuracy = 50.0;
}

/// Sync configuration
class SyncConfig {
  /// Interval between periodic syncs
  static const Duration syncInterval = Duration(minutes: 5);
  
  /// Maximum number of sync retries
  static const int maxRetries = 3;
  
  /// Delay between retry attempts
  static const Duration retryDelay = Duration(seconds: 5);
  
  /// Maximum number of logs to sync in a single batch
  static const int maxBatchSize = 100;
}

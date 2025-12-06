import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Remote data source for API calls
class RemoteDataSource {
  final Dio dio;
  final FlutterSecureStorage secureStorage;
  
  static const String _baseUrl = 'https://api.attendance-app.com';
  static const String _jwtTokenKey = 'jwt_token';

  RemoteDataSource({
    required this.dio,
    required this.secureStorage,
  }) {
    dio.options.baseUrl = _baseUrl;
    dio.interceptors.add(_AuthInterceptor(secureStorage: secureStorage));
  }

  /// Verify Google token and get JWT
  Future<Map<String, dynamic>> verifyGoogleToken(String googleToken) async {
    try {
      final response = await dio.post(
        '/api/auth/google-verify',
        data: {'idToken': googleToken},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Save JWT token securely
  Future<void> saveJwtToken(String token) async {
    await secureStorage.write(
      key: _jwtTokenKey,
      value: token,
    );
  }

  /// Retrieve JWT token
  Future<String?> getJwtToken() async {
    return await secureStorage.read(key: _jwtTokenKey);
  }

  /// Clear JWT token on logout
  Future<void> clearJwtToken() async {
    await secureStorage.delete(key: _jwtTokenKey);
  }

  /// Sync attendance logs with server
  /// Sends pending logs and receives server-synced versions
  Future<Map<String, dynamic>> syncAttendanceLogs(
    List<Map<String, dynamic>> pendingLogs,
  ) async {
    try {
      final response = await dio.post(
        '/api/sync-logs',
        data: {
          'logs': pendingLogs,
          'clientTimestamp': DateTime.now().toIso8601String(),
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get geofence data from server
  Future<List<Map<String, dynamic>>> getGeofences() async {
    try {
      final response = await dio.get('/api/geofences');
      return List<Map<String, dynamic>>.from(response.data['geofences'] ?? []);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get user profile
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await dio.get('/api/users/profile');
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Submit leave request
  Future<Map<String, dynamic>> submitLeaveRequest(
    Map<String, dynamic> leaveRequest,
  ) async {
    try {
      final response = await dio.post(
        '/api/leave-requests',
        data: leaveRequest,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get attendance history
  Future<List<Map<String, dynamic>>> getAttendanceHistory({
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    try {
      final response = await dio.get(
        '/api/attendance-logs',
        queryParameters: {
          'from': fromDate.toIso8601String(),
          'to': toDate.toIso8601String(),
        },
      );
      return List<Map<String, dynamic>>.from(response.data['logs'] ?? []);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout';
      case DioExceptionType.sendTimeout:
        return 'Send timeout';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout';
      case DioExceptionType.badResponse:
        return 'Bad response: ${e.response?.statusCode}';
      case DioExceptionType.unknown:
        return 'Unknown error: ${e.message}';
      case DioExceptionType.cancel:
        return 'Request cancelled';
      case DioExceptionType.badCertificate:
        return 'Bad certificate';
      case DioExceptionType.connectionError:
        return 'Connection error';
    }
  }
}

/// Interceptor to automatically add JWT token to requests
class _AuthInterceptor extends Interceptor {
  final FlutterSecureStorage secureStorage;

  _AuthInterceptor({required this.secureStorage});

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await secureStorage.read(key: 'jwt_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }
}

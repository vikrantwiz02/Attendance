import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../data/datasources/local_data_source.dart';
import '../../data/datasources/remote_data_source.dart';
import '../../data/repositories/attendance_repository_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../core/services/sync_engine.dart';
import '../../core/services/location_service.dart';
import '../../core/services/notification_service.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../../domain/usecases/clock_action_usecase.dart';

// ============= Core Services =============

final loggerProvider = Provider<Logger>((ref) {
  return Logger();
});

final dioProvider = Provider<Dio>((ref) {
  return Dio();
});

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final connectivityProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});

final flutterLocalNotificationsPlugin =
    Provider<FlutterLocalNotificationsPlugin>((ref) {
  return FlutterLocalNotificationsPlugin();
});

// ============= Data Sources =============

final localDataSourceProvider =
    Provider.autoDispose<LocalDataSource>((ref) {
  return LocalDataSource();
});

final remoteDataSourceProvider =
    Provider.autoDispose<RemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  return RemoteDataSource(
    dio: dio,
    secureStorage: secureStorage,
  );
});

// ============= Repositories =============

final authRepositoryProvider = Provider.autoDispose<AuthRepositoryImpl>((ref) {
  final local = ref.watch(localDataSourceProvider);
  final remote = ref.watch(remoteDataSourceProvider);
  return AuthRepositoryImpl(
    localDataSource: local,
    remoteDataSource: remote,
  );
});

final attendanceRepositoryProvider =
    Provider.autoDispose<AttendanceRepositoryImpl>((ref) {
  final local = ref.watch(localDataSourceProvider);
  final remote = ref.watch(remoteDataSourceProvider);
  return AttendanceRepositoryImpl(
    localDataSource: local,
    remoteDataSource: remote,
  );
});

// ============= Core Services =============

final syncEngineProvider = Provider<SyncEngine>((ref) {
  final local = ref.watch(localDataSourceProvider);
  final remote = ref.watch(remoteDataSourceProvider);
  final connectivity = ref.watch(connectivityProvider);
  final logger = ref.watch(loggerProvider);

  return SyncEngine(
    localDataSource: local,
    remoteDataSource: remote,
    connectivity: connectivity,
    logger: logger,
  );
});

final locationServiceProvider = Provider<LocationService>((ref) {
  final logger = ref.watch(loggerProvider);
  return LocationService(logger: logger);
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final plugin = ref.watch(flutterLocalNotificationsPlugin);
  final logger = ref.watch(loggerProvider);
  return NotificationService(
    flutterLocalNotificationsPlugin: plugin,
    logger: logger,
  );
});

// ============= Use Cases =============

final googleSignInUseCaseProvider = Provider<GoogleSignInUseCase>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return GoogleSignInUseCase(repository: authRepo);
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return GetCurrentUserUseCase(repository: authRepo);
});

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return SignOutUseCase(repository: authRepo);
});

final clockActionUseCaseProvider = Provider<ClockActionUseCase>((ref) {
  final attendanceRepo = ref.watch(attendanceRepositoryProvider);
  return ClockActionUseCase(repository: attendanceRepo);
});

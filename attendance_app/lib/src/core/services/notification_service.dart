import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';

/// Service for local notifications
class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final Logger logger;

  NotificationService({
    required this.flutterLocalNotificationsPlugin,
    required this.logger,
  });

  /// Initialize notification service
  Future<void> init() async {
    // Initialize for both Android and iOS
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Request permissions for iOS
    if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }

    logger.i('Notification service initialized');
  }

  /// Show clock-out reminder notification
  Future<void> showClockOutReminder() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'clock_out_channel',
      'Clock Out Reminders',
      channelDescription: 'Reminder to clock out at end of day',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(
      sound: 'default',
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      1,
      'Clock Out Reminder',
      'Don\'t forget to clock out!',
      notificationDetails,
    );

    logger.i('Clock out reminder notification shown');
  }

  /// Show sync status notification
  Future<void> showSyncNotification({
    required String title,
    required String body,
    bool isSuccess = true,
  }) async {
    final androidNotificationDetails = AndroidNotificationDetails(
      'sync_channel',
      'Sync Status',
      channelDescription: 'Notifications about data synchronization',
      importance: Importance.low,
      priority: Priority.low,
    );

    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: false,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      2,
      title,
      body,
      notificationDetails,
    );

    logger.i('Sync notification shown: $title');
  }

  /// Show error notification
  Future<void> showErrorNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'error_channel',
      'Errors',
      channelDescription: 'Error notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      3,
      title,
      body,
      notificationDetails,
    );

    logger.e('Error notification shown: $title - $body');
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}

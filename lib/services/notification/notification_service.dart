// ignore_for_file: unused_element

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:restaurant_review/data/api/api_service.dart';
import 'package:restaurant_review/data/model/received_notification.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final StreamController<ReceivedNotification> didReceiveLocalNotificationStream =
    StreamController<ReceivedNotification>.broadcast();

final StreamController<String?> selectNotificationStream =
    StreamController<String?>.broadcast();

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final ApiService apiService = ApiService();

class NotificationService {
  Future<void> init() async {
    configureLocalTimeZone();
    const initializationSettingsAndroid = AndroidInitializationSettings(
      'ic_launcher_foreground',
    );
    final initializationSettingsDarwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (notificationResponse) {
        final payload = notificationResponse.payload;
        if (payload != null && payload.isNotEmpty) {
          selectNotificationStream.add(payload);
        }
      },
    );
  }

  Future<bool> _isAndroidNotificationPermissionGranted() async {
    final androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    return await androidImplementation?.areNotificationsEnabled() ?? false;
  }

  Future<bool> _requestAndroidNotificationPermission() async {
    final androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    return await androidImplementation?.requestNotificationsPermission() ??
        false;
  }

  Future<bool> _requestExactAlarmsPermission() async {
    final androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    return await androidImplementation?.requestExactAlarmsPermission() ?? false;
  }

  Future<bool> _requestActivityRecognitionPermission() async {
    return await Permission.activityRecognition.request().isGranted;
  }

  Future<bool> _requestIgnoreBatteryOptimizationPermission() async {
    return await Permission.ignoreBatteryOptimizations.request().isGranted;
  }

  Future<bool?> requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iOSImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      return await iOSImplementation?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      final notificationEnabled =
          await _isAndroidNotificationPermissionGranted();
      final alarmPermissionGranted = await _requestExactAlarmsPermission();
      final activityRecognitionGranted =
          await _requestActivityRecognitionPermission();
      final ignoreBatteryOptimizationsGranted =
          await _requestIgnoreBatteryOptimizationPermission();

      if (!notificationEnabled) {
        final requestNotificationsPermission =
            await _requestAndroidNotificationPermission();
        return requestNotificationsPermission &&
            alarmPermissionGranted &&
            activityRecognitionGranted &&
            ignoreBatteryOptimizationsGranted;
      }

      return notificationEnabled &&
          alarmPermissionGranted &&
          activityRecognitionGranted &&
          ignoreBatteryOptimizationsGranted;
    } else {
      return false;
    }
  }

  Future<void> configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  tz.TZDateTime _nextInstanceOfTenSecondsFromNow() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    return now.add(const Duration(seconds: 10));
  }

  tz.TZDateTime _nextInstanceOfElevenAM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, 11);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(
          days: 1));
    }
    return scheduledDate;
  }

  Future<void> scheduleDailyElevenAMNotification({
    required int id,
    String channelId = "rr_daily_notification_channel",
    String channelName = "Schedule Notification",
  }) async {
    try {
      await flutterLocalNotificationsPlugin.cancelAll();
      print('All previous notifications canceled.');

      final restaurantListResponse = await apiService.getRestaurantList();
      print(
          'Got restaurant list: ${restaurantListResponse.restaurants.length} items');
      if (restaurantListResponse.restaurants.isEmpty) {
        return;
      }

      final restaurant = restaurantListResponse.restaurants[
          DateTime.now().millisecondsSinceEpoch %
              restaurantListResponse.restaurants.length];

      final androidPlatformChannelSpecifics = AndroidNotificationDetails(
        channelId,
        channelName,
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
      );
      const iOSPlatformChannelSpecifics = DarwinNotificationDetails();

      final notificationDetails = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      final datetimeSchedule = _nextInstanceOfElevenAM();
      // final datetimeSchedule = _nextInstanceOfTenSecondsFromNow(); // Untuk testing
      print('Scheduling notification at $datetimeSchedule');

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        '🔥 Time for lunch! Today Recommendation: ${restaurant.name} 🍕',
        '📍 Location: ${restaurant.city} | ⭐ Rating: ${restaurant.rating} 🌟',
        datetimeSchedule,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      showTestNotification();

      checkPendingNotifications();
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  Future<void> showTestNotification() async {
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'confirmation_notification_channel',
      'Confirmation Channel',
      importance: Importance.max,
      priority: Priority.high,
    );

    final notificationDetails = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(),
    );

    await flutterLocalNotificationsPlugin.show(
      999,
      'Daily Notification Turned On',
      'You will receive daily restaurant recommendations at 11 AM',
      notificationDetails,
    );
  }

  Future<List<PendingNotificationRequest>> pendingNotificationRequests() async {
    final List<PendingNotificationRequest> pendingNotificationRequests =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    return pendingNotificationRequests;
  }

  Future<void> checkPendingNotifications() async {
    final pendingNotifications =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();

    print("Pending Notifications Count: ${pendingNotifications.length}");
    for (var n in pendingNotifications) {
      print("ID: ${n.id}, Title: ${n.title}, Body: ${n.body}");
    }
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}

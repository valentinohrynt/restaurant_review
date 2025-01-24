import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class NotificationProvider with ChangeNotifier {
  
  NotificationProvider() {
    _loadNotificationStatus();
  }

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _dailyNotificationsEnabled = false;

  bool get dailyNotificationsEnabled => _dailyNotificationsEnabled;

  Future<void> requestPermission() async {
    if (await Permission.scheduleExactAlarm.status.isDenied &&
        await Permission.notification.status.isDenied) {
      await Permission.scheduleExactAlarm.request();
      await Permission.notification.request();
    }
  }

  Future<void> toggleDailyNotifications() async {
    await requestPermission();
    _dailyNotificationsEnabled = !_dailyNotificationsEnabled;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dailyNotifications', _dailyNotificationsEnabled);

    if (_dailyNotificationsEnabled) {
      await _showImmediateNotification();
      await _scheduleDailyNotification();
    } else {
      await flutterLocalNotificationsPlugin.cancelAll();
    }

    notifyListeners();
  }

  Future<void> _loadNotificationStatus() async {
    tz.initializeTimeZones();

    final prefs = await SharedPreferences.getInstance();
    _dailyNotificationsEnabled = prefs.getBool('dailyNotifications') ?? false;

    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    const initializationSettingsIOS = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    if (_dailyNotificationsEnabled) {
      return;
    }

    notifyListeners();
  }

  Future<void> _showImmediateNotification() async {
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'rr_immediate_channel_restaurant_review',
      'Immediate Notifications',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
    );

    const iOSPlatformChannelSpecifics = DarwinNotificationDetails();

    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      'Notifications Enabled',
      'Daily notifications are now active!',
      platformChannelSpecifics,
    );
  }

  Future<void> _scheduleDailyNotification() async {
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'rr_daily_channel_restaurant_review',
      'Daily Notifications',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
    );

    const iOSPlatformChannelSpecifics = DarwinNotificationDetails();

    const platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.periodicallyShow(
      0,
      'Daily Reminder',
      'Your daily notification is here!',
      RepeatInterval.daily,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exact,
    );
  }
}

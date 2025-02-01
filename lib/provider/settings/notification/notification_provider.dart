import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:restaurant_review/provider/settings/notification/restaurant_notification_helper.dart';
import 'package:restaurant_review/provider/settings/notification/work_manager.dart';

class NotificationProvider with ChangeNotifier {
  bool _isDailyReminderActive = false;

  bool get isDailyReminderActive => _isDailyReminderActive;

  NotificationProvider() {
    _loadNotificationStatus();
  }

  Future<void> requestPermission() async {
    if (await Permission.scheduleExactAlarm.status.isDenied &&
        await Permission.notification.status.isDenied) {
      await Permission.scheduleExactAlarm.request();
      await Permission.notification.request();
    }
  }

  Future<void> _loadNotificationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isDailyReminderActive = prefs.getBool('dailyRestaurantReminder') ?? false;
    notifyListeners();
  }

  Future<void> toggleDailyReminder() async {
    await requestPermission();
    _isDailyReminderActive = !_isDailyReminderActive;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dailyRestaurantReminder', _isDailyReminderActive);

    if (_isDailyReminderActive) {
      await _startDailyReminder();
    } else {
      await _stopDailyReminder();
    }

    notifyListeners();
  }

  Future<void> _startDailyReminder() async {
    await Workmanager().initialize(callbackDispatcher);

    await Workmanager().registerPeriodicTask(
      'restaurantReminder',
      'fetchRestaurantTask',
      frequency: const Duration(days: 1),
      initialDelay: _getInitialDelay(),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );

    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'restaurant_immediate_channel',
      'Restaurant Immediate Notifications',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
    );

    const iOSPlatformChannelSpecifics = DarwinNotificationDetails();

    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await RestaurantNotificationHelper.flutterLocalNotificationsPlugin.show(
      1,
      'Daily Restaurant Recommendations Activated',
      'You will receive daily restaurant recommendations at 11:00 AM!',
      platformChannelSpecifics,
    );
  }

  Future<void> _stopDailyReminder() async {
    await Workmanager().cancelAll();
  }

  Duration _getInitialDelay() {
    final now = DateTime.now();
    var scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      11,
      0,
    );

    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    return scheduledTime.difference(now);
  }
}

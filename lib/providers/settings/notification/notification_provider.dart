import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:restaurant_review/services/notification/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  bool _isDailyReminderActive = false;
  static const String taskName = 'restaurantDailyReminder';
  static const String taskUniqueName = 'dailyRestaurantNotification';
  final _notificationService = NotificationService();
  int _notificationId = 3699;
  bool get isDailyReminderActive => _isDailyReminderActive;

  NotificationProvider() {
    _notificationService.init();
    _loadNotificationStatus();
  }

  Future<void> requestPermission() async {
    final notificationStatus = await Permission.notification.status;
    final alarmStatus = await Permission.scheduleExactAlarm.status;

    if (!notificationStatus.isGranted) {
      await Permission.notification.request();
    }

    if (!alarmStatus.isGranted) {
      await Permission.scheduleExactAlarm.request();
    }

    final finalNotificationStatus = await Permission.notification.status;
    final finalAlarmStatus = await Permission.scheduleExactAlarm.status;

    if (kDebugMode) {
      print('Notification permission: ${finalNotificationStatus.isGranted}');
      print('Alarm permission: ${finalAlarmStatus.isGranted}');
    }

    if (!finalNotificationStatus.isGranted || !finalAlarmStatus.isGranted) {
      _isDailyReminderActive = false;
      notifyListeners();
      throw Exception('Required permissions not granted');
    }
  }

  Future<void> _loadNotificationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isDailyReminderActive = prefs.getBool('dailyRestaurantReminder') ?? false;

    if (_isDailyReminderActive) {
      await _notificationService.scheduleDailyElevenAMNotification(id: 3);
    }

    notifyListeners();
  }

  Future<void> toggleDailyReminder() async {
    try {
      if (!_isDailyReminderActive) {
        await requestPermission();
      }

      _isDailyReminderActive = !_isDailyReminderActive;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('dailyRestaurantReminder', _isDailyReminderActive);
      int id = _notificationId += 1;
      if (_isDailyReminderActive) {
        await _notificationService.scheduleDailyElevenAMNotification(
            id: id);
      } else {
        await _notificationService.cancelNotification(id);
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling notification: $e');
      }

      _isDailyReminderActive = false;
      notifyListeners();
    }
  }
}

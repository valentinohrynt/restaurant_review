import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:restaurant_review/providers/settings/notification/work_manager.dart';

class NotificationProvider with ChangeNotifier {
  bool _isDailyReminderActive = false;
  static const String taskName = 'restaurantDailyReminder';
  static const String taskUniqueName = 'dailyRestaurantNotification';
  bool get isDailyReminderActive => _isDailyReminderActive;

  bool _isTestMode = false;
  bool get isTestMode => _isTestMode;
  
  NotificationProvider() {
    _loadNotificationStatus();
  }

  Future<void> toggleTestMode(bool isTest) async {
    _isTestMode = isTest;
    if (_isDailyReminderActive) {
      await _startDailyReminder();
    }
    notifyListeners();
  }

  Duration _getInitialDelay() {
    if (_isTestMode) {
      return const Duration(seconds: 15);
    }

    final now = DateTime.now();
    var scheduledTime = DateTime(now.year, now.month, now.day, 11, 0);

    if (now.isAfter(scheduledTime)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    final delay = scheduledTime.difference(now);
    return delay.isNegative
        ? scheduledTime.add(const Duration(days: 1)).difference(now)
        : delay;
  }

  Future<void> _startDailyReminder() async {
    await Workmanager().cancelAll();
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: isTestMode);

    final initialDelay = _getInitialDelay();
    if (kDebugMode) {
      print(
          'Scheduling periodic task with initial delay: ${initialDelay.inSeconds} seconds');
    }

    final testFrequency = const Duration(minutes: 15);
    final productionFrequency = const Duration(hours: 24);

    await Workmanager().registerPeriodicTask(
      taskUniqueName,
      taskName,
      frequency: _isTestMode ? testFrequency : productionFrequency,
      initialDelay: initialDelay,
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
      ),
      existingWorkPolicy: ExistingWorkPolicy.replace,
      backoffPolicy: BackoffPolicy.linear,
      backoffPolicyDelay: const Duration(minutes: 5),
    );

    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final scheduledTime = now.add(initialDelay);
    await prefs.setString(
        'nextScheduledNotification', scheduledTime.toString());
    await prefs.setInt('notificationFrequencyMinutes',
        _isTestMode ? testFrequency.inMinutes : productionFrequency.inMinutes);

    if (kDebugMode) {
      print('Periodic task scheduled:');
      print('- First notification at: $scheduledTime');
      print('- Frequency: ${_isTestMode ? '15 minutes' : '24 hours'}');
    }
  }

  Future<Map<String, dynamic>> getNotificationScheduleInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final nextScheduled = prefs.getString('nextScheduledNotification');
    final frequencyMinutes = prefs.getInt('notificationFrequencyMinutes');

    return {
      'isActive': _isDailyReminderActive,
      'nextScheduled':
          nextScheduled != null ? DateTime.parse(nextScheduled) : null,
      'frequencyMinutes': frequencyMinutes,
      'isTestMode': _isTestMode,
    };
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
      await _startDailyReminder();
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

      if (_isDailyReminderActive) {
        await _startDailyReminder();
      } else {
        await _stopDailyReminder();
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

  Future<void> _stopDailyReminder() async {
    await Workmanager().cancelAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('nextScheduledNotification');
  }

  Future<DateTime?> getNextScheduledNotificationTime() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString('nextScheduledNotification');
    return dateString != null ? DateTime.parse(dateString) : null;
  }
}

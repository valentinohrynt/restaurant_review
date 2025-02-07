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

  NotificationProvider() {
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

  Future<void> _startDailyReminder() async {
    await Workmanager().cancelAll();
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false
    );

    final initialDelay = _getInitialDelay();
    print('Scheduling daily notification with initial delay: ${initialDelay.inHours} hours, ${initialDelay.inMinutes % 60} minutes');

    await Workmanager().registerPeriodicTask(
      taskUniqueName,
      taskName,
      frequency: const Duration(hours: 24),
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
    await prefs.setString('nextScheduledNotification', scheduledTime.toString());
    
    print('Next notification scheduled for: $scheduledTime');
  }

  Future<void> _stopDailyReminder() async {
    await Workmanager().cancelAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('nextScheduledNotification');
  }

  Duration _getInitialDelay() {
    final now = DateTime.now();
    var scheduledTime = DateTime(now.year, now.month, now.day, 11, 0);
    
    if (now.isAfter(scheduledTime)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    final delay = scheduledTime.difference(now);
    
    return delay.isNegative ? scheduledTime.add(const Duration(days: 1)).difference(now) : delay;
  }

  Future<DateTime?> getNextScheduledNotificationTime() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString('nextScheduledNotification');
    return dateString != null ? DateTime.parse(dateString) : null;
  }
}
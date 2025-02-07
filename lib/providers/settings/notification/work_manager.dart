import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';
import 'package:restaurant_review/utils/restaurant_notification_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      final now = DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      
      if (kDebugMode) {
        print("Native called background task: $task");
        print("Current time: $now");
        
        final lastRun = prefs.getString('lastNotificationRun');
        if (lastRun != null) {
          final lastRunTime = DateTime.parse(lastRun);
          final difference = now.difference(lastRunTime);
          print("Time since last execution: ${difference.inMinutes} minutes");
        }
        
        await prefs.setString('lastNotificationRun', now.toString());
      }

      switch (task) {
        case 'restaurantDailyReminder': 
          if (kDebugMode) {
            print("Starting daily restaurant notification task");
            
            final prefs = await SharedPreferences.getInstance();
            final scheduledTimeStr = prefs.getString('nextScheduledNotification');
            if (scheduledTimeStr != null) {
              final scheduledTime = DateTime.parse(scheduledTimeStr);
              final delay = now.difference(scheduledTime);
              print("Execution delay from scheduled time: ${delay.inMinutes} minutes");
            }
          }
          
          await RestaurantNotificationHelper.showRandomRestaurantNotification();
          
          if (kDebugMode) {
            print("Successfully showed restaurant notification");
            
            final frequency = await prefs.getInt('notificationFrequencyMinutes') ?? 1440;
            final nextRun = now.add(Duration(minutes: frequency));
            print("Next expected run: $nextRun");
            await prefs.setString('nextScheduledNotification', nextRun.toString());
          }
          break;
          
        default:
          if (kDebugMode) {
            print("Unknown task: $task");
          }
          return Future.value(false);
      }

      return Future.value(true);
    } catch (err) {
      if (kDebugMode) {
        print("Error executing task: $err");
        print("Stack trace: ${err is Error ? err.stackTrace : ''}");
      }
      return Future.value(false);
    }
  });
}
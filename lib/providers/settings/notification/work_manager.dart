import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';
import 'package:restaurant_review/utils/restaurant_notification_helper.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      if (kDebugMode) {
        print("Native called background task: $task");
        print("Current time: ${DateTime.now()}");
      }

      switch (task) {
        case 'restaurantDailyReminder': 
          if (kDebugMode) {
            print("Starting daily restaurant notification task");
          }
          
          await RestaurantNotificationHelper.showRandomRestaurantNotification();
          
          if (kDebugMode) {
            print("Successfully showed restaurant notification");
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
      }
      return Future.value(false);
    }
  });
}
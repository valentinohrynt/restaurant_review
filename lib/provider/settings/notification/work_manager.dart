import 'package:workmanager/workmanager.dart';
import 'package:restaurant_review/provider/settings/notification/restaurant_notification_helper.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case 'fetchRestaurantTask':
        await RestaurantNotificationHelper.showRandomRestaurantNotification();
        break;
    }
    return Future.value(true);
  });
}
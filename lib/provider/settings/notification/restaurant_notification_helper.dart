import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:restaurant_review/data/model/restaurant.dart';

class RestaurantNotificationHelper {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initializeNotification() async {
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    const initializationSettingsIOS = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static Future<List<Restaurant>> fetchRestaurants() async {
    final response = await http.get(
      Uri.parse('https://restaurant-api.dicoding.dev/'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> restaurants = json.decode(response.body)['restaurants'];
      return restaurants.map((json) => Restaurant.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load restaurants');
    }
  }

  static Future<Restaurant> getRandomRestaurant() async {
    final restaurants = await fetchRestaurants();
    final random = Random();
    return restaurants[random.nextInt(restaurants.length)];
  }

  static Future<void> showRandomRestaurantNotification() async {
    try {
      final restaurant = await getRandomRestaurant();

      const androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'restaurant_daily_channel',
        'Restaurant Daily Recommendations',
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
        'Restaurant Recommendation: ${restaurant.name}',
        '⭐ ${restaurant.rating} - ${restaurant.description?.substring(0, min(100, restaurant.description!.length))}...',
        platformChannelSpecifics,
      );
    } catch (e) {
      print('Error showing notification: $e');
    }
  }
}
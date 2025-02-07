import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:restaurant_review/data/api/api_service.dart';
import 'package:restaurant_review/data/model/restaurant.dart';

class RestaurantNotificationHelper {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static final ApiService _apiService = ApiService();
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

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

  static Future<bool> showRandomRestaurantNotification() async {
    try {
      final restaurant = await compute(_fetchRestaurantData, null);

      if (restaurant == null) {
        if (kDebugMode) {
          print('Failed to get restaurant after $_maxRetries attempts');
        }
        return false;
      }

      const androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'restaurant_daily_reminder_channel',
        'Restaurant Daily Recommendations',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/launcher_icon',
        styleInformation: BigTextStyleInformation(''),
      );

      const platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: DarwinNotificationDetails(),
      );

      final description = restaurant.description ?? '';
      final truncatedDescription = description.length > 100
          ? '${description.substring(0, 100)}...'
          : description;

      await flutterLocalNotificationsPlugin.show(
        0,
        'Time for Lunch! Recommendation: ${restaurant.name} 🍽️',
        '⭐ ${restaurant.rating} - $truncatedDescription',
        platformChannelSpecifics,
      );

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error showing notification: $e');
      }
      return false;
    }
  }

  static Future<Restaurant?> _fetchRestaurantData(dynamic _) async {
    return await _getRandomRestaurantWithRetry();
  }

  static Future<Restaurant?> _getRandomRestaurantWithRetry(
      [int retryCount = 0]) async {
    try {
      final response = await _apiService.getRestaurantList();
      final restaurants = response.restaurants;

      if (restaurants.isNotEmpty) {
        final random = Random();
        return restaurants[random.nextInt(restaurants.length)];
      }

      throw Exception('No restaurants available');
    } catch (e) {
      if (kDebugMode) {
        print('Attempt ${retryCount + 1} failed: $e');
      }

      if (retryCount < _maxRetries - 1) {
        if (kDebugMode) {
          print('Retrying in ${_retryDelay.inSeconds} seconds...');
        }
        await Future.delayed(_retryDelay);
        return _getRandomRestaurantWithRetry(retryCount + 1);
      }

      return null;
    }
  }

  static Future<void> showInitialNotification() async {
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

    await flutterLocalNotificationsPlugin.show(
      1,
      'Daily Restaurant Recommendations Activated',
      'You will receive restaurant recommendations daily at 11:00 AM!',
      platformChannelSpecifics,
    );
  }

  static Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
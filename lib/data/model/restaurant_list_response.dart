import 'package:restaurant_review/data/model/restaurant.dart';

class RestaurantListResponse {
  RestaurantListResponse({
    required this.error,
    required this.message,
    required this.count,
    required this.restaurants,
  });

  final bool? error;
  final String? message;
  final int? count;
  final List<Restaurant> restaurants;

  factory RestaurantListResponse.fromJson(Map<String, dynamic> json) {
    return RestaurantListResponse(
      error: json["error"],
      message: json["message"],
      count: json["count"],
      restaurants: json["restaurants"] == null
          ? []
          : List<Restaurant>.from(
              json["restaurants"]!.map((x) => Restaurant.fromJson(x))),
    );
  }
}

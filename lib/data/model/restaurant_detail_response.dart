import 'package:restaurant_review/data/model/restaurant.dart';

class RestaurantDetailResponse {
  RestaurantDetailResponse({
    required this.error,
    required this.message,
    required this.restaurant,
  });

  final bool? error;
  final String? message;
  final Restaurant restaurant;

  factory RestaurantDetailResponse.fromJson(Map<String, dynamic> json) {
    return RestaurantDetailResponse(
      error: json["error"],
      message: json["message"],
      restaurant: Restaurant.fromJson(json["restaurant"]),
    );
  }
}

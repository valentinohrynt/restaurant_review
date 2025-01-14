import 'package:restaurant_review/data/model/restaurant.dart';

class RestaurantSearchResultResponse {
  RestaurantSearchResultResponse({
    required this.error,
    required this.founded,
    required this.restaurants,
  });

  final bool? error;
  final int? founded;
  final List<Restaurant> restaurants;

  factory RestaurantSearchResultResponse.fromJson(Map<String, dynamic> json) {
    return RestaurantSearchResultResponse(
      error: json["error"],
      founded: json["founded"],
      restaurants: json["restaurants"] == null
          ? []
          : List<Restaurant>.from(
              json["restaurants"].map((x) => Restaurant.fromJson(x))),
    );
  }
}
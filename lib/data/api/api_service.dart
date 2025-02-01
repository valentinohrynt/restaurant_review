import 'dart:convert';
import 'package:restaurant_review/data/model/customer_review_list_response.dart';
import 'package:restaurant_review/data/model/restaurant_detail_response.dart';
import 'package:restaurant_review/data/model/restaurant_list_response.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'https://restaurant-api.dicoding.dev/';

  Future<RestaurantListResponse> getRestaurantList() async {
    try {
      final response = await http.get(Uri.parse('${_baseUrl}list'));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return RestaurantListResponse.fromJson(json.decode(response.body));
      } else {
        throw Exception('Something went wrong. Please try again.');
      }
    } catch (e) {
      throw Exception('Failed to load restaurant list. Please check your connection');
    }
  }

  Future<RestaurantDetailResponse> getRestaurantDetail(String id) async {
    try {
      final response = await http.get(Uri.parse('${_baseUrl}detail/$id'));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return RestaurantDetailResponse.fromJson(json.decode(response.body));
      } else {
        throw Exception('Something went wrong. Please try again.');
      }
    } catch (e) {
      throw Exception('Failed to load restaurant detail. Please check your connection');
    }
  }

  Future<RestaurantListResponse> searchRestaurant(String query) async {
    try {
      final response = await http.get(Uri.parse('${_baseUrl}search?q=$query'));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return RestaurantListResponse.fromJson(json.decode(response.body));
      } else {
        throw Exception('Something went wrong. Please try again.');
      }
    } catch (e) {
      throw Exception('Failed to search restaurant. Please check your connection');
    }
  }

  Future<CustomerReviewListResponse> postReview(
      String id, String name, String review) async {
    try {
      final response = await http.post(
        Uri.parse('${_baseUrl}review'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'id': id,
          'name': name,
          'review': review,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return CustomerReviewListResponse.fromJson(json.decode(response.body));
      } else {
        throw Exception('Something went wrong. Please try again.');
      }
    } catch (e) {
      throw Exception('Failed to post review. Please check your connection');
    }
  }
}

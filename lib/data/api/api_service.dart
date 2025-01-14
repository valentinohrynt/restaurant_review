import 'dart:convert';
import 'package:restaurant_review/data/model/restaurant_detail_response.dart';
import 'package:restaurant_review/data/model/restaurant_list_response.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'https://restaurant-api.dicoding.dev/';

  Future<RestaurantListResponse> getRestaurantList() async {
    try {
      final response = await http.get(Uri.parse('${_baseUrl}list'));
      
      if (response.statusCode == 200) {
        return RestaurantListResponse.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load restaurant list');
      }
    } catch (e) {
      rethrow;  
    }
  }

  Future<RestaurantDetailResponse> getRestaurantDetail(String id) async {
    try {
      final response = await http.get(Uri.parse('${_baseUrl}detail/$id'));
      
      if (response.statusCode == 200) {
        return RestaurantDetailResponse.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load restaurant detail');
      }
    } catch (e) {
      rethrow;  
    }
  }
}

// ignore_for_file: unused_catch_clause

import 'package:flutter/widgets.dart';
import 'package:restaurant_review/data/api/api_service.dart';
import 'package:restaurant_review/static/restaurant_list_result_state.dart';

class RestaurantListProvider extends ChangeNotifier {
  final ApiService _apiService;

  RestaurantListProvider(this._apiService);

  RestaurantListResultState _resultState = RestaurantListNoneState();

  RestaurantListResultState get resultState => _resultState;

  Future<void> fetchRestaurantList() async {
    try {
      _resultState = RestaurantListLoadingState();
      notifyListeners();

      final result = await _apiService.getRestaurantList();

      if (result.error != false) {
        _resultState =
            RestaurantListErrorState('Something went wrong. Please try again.');
        notifyListeners();
      } else {
        _resultState = RestaurantListLoadedState(result.restaurants);
        notifyListeners();
      }
    } on Exception catch (e) {
      _resultState = RestaurantListErrorState('Failed to load restaurant list. Please check your connection');
      notifyListeners();
    }
  }

  Future<void> searchRestaurantList(String query) async {
    try {
      _resultState = RestaurantListLoadingState();
      notifyListeners();

      final result = await _apiService.searchRestaurant(query);

      if (result.error != false) {
        _resultState =
            RestaurantListErrorState('Something went wrong. Please try again.');
        notifyListeners();
      } else {
        _resultState = RestaurantListLoadedState(result.restaurants);
        notifyListeners();
      }
    } on Exception catch (e) {
      _resultState = RestaurantListErrorState('Failed to search restaurant. Please check your connection');
      notifyListeners();
    }
  }
}

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/widgets.dart';
import 'package:restaurant_review/data/api/api_service.dart';
import 'package:restaurant_review/data/local/database_helper.dart';
import 'package:restaurant_review/static/restaurant_detail_result_state.dart';
import 'package:restaurant_review/data/model/restaurant.dart';
import 'package:collection/collection.dart';

class RestaurantDetailProvider extends ChangeNotifier {
  final ApiService _apiService;
  final DatabaseHelper _databaseHelper;
  bool _isFromLocal = false;
  bool _isRefreshing = false;

  RestaurantDetailProvider(this._apiService)
      : _databaseHelper = DatabaseHelper();

  RestaurantDetailResultState _resultState = RestaurantDetailNoneState();
  RestaurantDetailResultState get resultState => _resultState;

  bool get isFromLocal => _isFromLocal;
  bool get isRefreshing => _isRefreshing;

  Future<void> fetchRestaurantDetail(String id) async {
    try {
      _resultState = RestaurantDetailLoadingState();
      notifyListeners();

      final favorites = await _databaseHelper.getFavorites();
      final localRestaurant =
          favorites.firstWhereOrNull((restaurant) => restaurant.id == id);

      if (localRestaurant != null) {
        _isFromLocal = true;
        _resultState = RestaurantDetailLoadedState(localRestaurant);
        notifyListeners();
        _updateFromApi(id);
      } else {
        _isFromLocal = false;
        await _fetchFromApi(id);
      }
    } catch (e) {
      _resultState = RestaurantDetailErrorState(e.toString());
      notifyListeners();
    }
  }

  Future<void> _fetchFromApi(String id) async {
    try {
      final result = await _apiService.getRestaurantDetail(id);

      if (result.error == true) {
        _resultState = RestaurantDetailErrorState(
            'Something went wrong. Please try again.');
      } else {
        _resultState = RestaurantDetailLoadedState(result.restaurant);
      }
    } catch (e) {
      _resultState = RestaurantDetailErrorState(
          "Failed to fetch restaurant details: ${e.toString()}");
    }
    notifyListeners();
  }

  Future<void> _updateFromApi(String id) async {
    try {
      final result = await _apiService.getRestaurantDetail(id);

      if (result.error == false) {
        if (_resultState is RestaurantDetailLoadedState) {
          final currentState = _resultState as RestaurantDetailLoadedState;
          if (_isDataDifferent(currentState.data, result.restaurant)) {
            _isFromLocal = false;
            _resultState = RestaurantDetailLoadedState(result.restaurant);
            notifyListeners();
          }
        }
      }
    } on Exception {
      throw Exception('Failed to update restaurant detail');
    }
  }

  bool _isDataDifferent(Restaurant local, Restaurant remote) {
    return local.name != remote.name ||
        local.description != remote.description ||
        local.city != remote.city ||
        local.address != remote.address ||
        local.pictureId != remote.pictureId ||
        local.rating != remote.rating;
  }

  Future<void> refreshFromApi(String id) async {
    _isRefreshing = true;
    notifyListeners();

    _isFromLocal = false;
    await _fetchFromApi(id);

    _isRefreshing = false;
    notifyListeners();
  }
}

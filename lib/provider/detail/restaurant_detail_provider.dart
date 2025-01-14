import 'package:flutter/widgets.dart';
import 'package:restaurant_review/data/api/api_service.dart';
import 'package:restaurant_review/static/restaurant_detail_result_state.dart';

class RestaurantDetailProvider extends ChangeNotifier {
  final ApiService _apiService;

  RestaurantDetailProvider(this._apiService);

  RestaurantDetailResultState _resultState = RestaurantDetailNoneState();

  RestaurantDetailResultState get resultState => _resultState;

  Future<void> fetchRestaurantDetail(String id) async {
    try {
      _resultState = RestaurantDetailLoadingState();
      notifyListeners();

      final result = await _apiService.getRestaurantDetail(id);

      if (result.error != false) {
        _resultState =
            RestaurantDetailErrorState(result.message ?? 'Unknown error');
        notifyListeners();
      } else {
        _resultState = RestaurantDetailLoadedState(result.restaurant);
        notifyListeners();
      }
    } on Exception catch (e) {
      _resultState = RestaurantDetailErrorState(e.toString());
      notifyListeners();
    }
  }
}

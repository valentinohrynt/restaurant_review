import 'package:flutter/widgets.dart';
import 'package:restaurant_review/data/api/api_service.dart';
import 'package:restaurant_review/static/customer_review_list_result_state.dart';

class CustomerReviewListProvider extends ChangeNotifier {
  final ApiService _apiService;

  CustomerReviewListProvider(this._apiService);

  CustomerReviewListResultState _resultState = CustomerReviewListNoneState();

  CustomerReviewListResultState get resultState => _resultState;

  Future<bool> postReview(String id, String name, String review) async {
    try {
      _resultState = CustomerReviewListLoadingState();
      notifyListeners();

      final result = await _apiService.postReview(id, name, review);

      if (result.error != false) {
        _resultState =
            CustomerReviewListErrorState('Something went wrong. Please try again.');
        notifyListeners();
        return false;
      } else {
        _resultState = CustomerReviewListLoadedState(result.customerReviews);
        return true;
      }
    } on Exception catch (e) {
      _resultState = CustomerReviewListErrorState('Failed to post review, please try again later.');
      notifyListeners();
      return false;
    }
  }
}

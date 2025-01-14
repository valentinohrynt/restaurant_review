import 'package:restaurant_review/data/model/restaurant.dart';

class CustomerReviewListResponse {
  CustomerReviewListResponse({
    required this.error,
    required this.message,
    required this.customerReviews,
  });

  final bool? error;
  final String? message;
  final List<CustomerReview> customerReviews; 

  factory CustomerReviewListResponse.fromJson(Map<String, dynamic> json) {
    return CustomerReviewListResponse(
      error: json["error"],
      message: json["message"],
      customerReviews: (json["customerReviews"] as List)
          .map((item) => CustomerReview.fromJson(item))
          .toList(),
    );
  }
}

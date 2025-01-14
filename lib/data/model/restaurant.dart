class Restaurant {
  Restaurant({
    this.id = '',
    this.name = '',
    this.description = '',
    this.city = '',
    this.address = '',
    this.pictureId = '',
    this.categories = const [],
    this.menus,
    this.rating = 0.0,
    this.customerReviews = const [],
  });

  final String? id;
  final String? name;
  final String? description;
  final String? city;
  final String? address;
  final String? pictureId;
  final List<Category> categories;
  final Menus? menus;
  final double rating;
  final List<CustomerReview> customerReviews;

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json["id"],
      name: json["name"],
      description: json["description"],
      city: json["city"],
      address: json["address"],
      pictureId: json["pictureId"],
      categories: json["categories"] == null
          ? []
          : List<Category>.from(
              json["categories"]!.map((x) => Category.fromJson(x))),
      menus: json["menus"] == null ? null : Menus.fromJson(json["menus"]),
      rating: json["rating"] is double
          ? json["rating"]
          : (json["rating"] is int ? (json["rating"] as int).toDouble() : null),
      customerReviews: json["customerReviews"] == null
          ? []
          : List<CustomerReview>.from(
              json["customerReviews"]!.map((x) => CustomerReview.fromJson(x))),
    );
  }
}

class Category {
  Category({
    this.name = '',
  });

  final String? name;

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      name: json["name"] ?? '',
    );
  }
}

class CustomerReview {
  CustomerReview({
    this.name = '',
    this.review = '',
    this.date = '',
  });

  final String? name;
  final String? review;
  final String? date;

  factory CustomerReview.fromJson(Map<String, dynamic> json) {
    return CustomerReview(
      name: json["name"] ?? '',
      review: json["review"] ?? '',
      date: json["date"] ?? '',
    );
  }
}

class Menus {
  Menus({
    this.foods = const [],
    this.drinks = const [],
  });

  final List<Category> foods;
  final List<Category> drinks;

  factory Menus.fromJson(Map<String, dynamic> json) {
    return Menus(
      foods: json["foods"] == null
          ? []
          : List<Category>.from(
              json["foods"]!.map((x) => Category.fromJson(x))),
      drinks: json["drinks"] == null
          ? []
          : List<Category>.from(
              json["drinks"]!.map((x) => Category.fromJson(x))),
    );
  }
}

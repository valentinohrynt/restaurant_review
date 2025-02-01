class Restaurant {
  Restaurant({
    this.id = '',
    this.name = '',
    this.description = '',
    this.city = '',
    this.address = '',
    this.pictureId = '',
    List<Category>? categories,
    this.menus,
    this.rating = 0.0,
    List<CustomerReview>? customerReviews,
  })  : categories = categories ?? [],
        customerReviews = customerReviews ?? [];

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

  Map<String, dynamic> toJson() {
    return {
      'id': id ?? '',
      'name': name ?? '',
      'description': description ?? '',
      'city': city ?? '',
      'address': address ?? '',
      'pictureId': pictureId ?? '',
      'categories': categories.map((e) => e.toJson()).toList(),
      'menus': menus?.toJson(),
      'rating': rating,
      'customerReviews': customerReviews.map((e) => e.toJson()).toList(),
    };
  }

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json["id"],
      name: json["name"],
      description: json["description"],
      city: json["city"],
      address: json["address"],
      pictureId: json["pictureId"],
      categories: (json["categories"] as List<dynamic>?)
              ?.map((x) => Category.fromJson(x))
              .toList() ??
          [],
      menus: json["menus"] != null ? Menus.fromJson(json["menus"]) : null,
      rating: (json["rating"] is num) ? (json["rating"] as num).toDouble() : 0.0,
      customerReviews: (json["customerReviews"] as List<dynamic>?)
              ?.map((x) => CustomerReview.fromJson(x))
              .toList() ??
          [],
    );
  }
}

class Category {
  Category({this.name = ''});

  final String? name;

  Map<String, dynamic> toJson() => {'name': name ?? ''};

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(name: json["name"] ?? '');
  }
}

class CustomerReview {
  CustomerReview({this.name = '', this.review = '', this.date = ''});

  final String? name;
  final String? review;
  final String? date;

  Map<String, dynamic> toJson() => {
        'name': name ?? '',
        'review': review ?? '',
        'date': date ?? '',
      };

  factory CustomerReview.fromJson(Map<String, dynamic> json) {
    return CustomerReview(
      name: json["name"] ?? '',
      review: json["review"] ?? '',
      date: json["date"] ?? '',
    );
  }
}

class Menus {
  Menus({List<Category>? foods, List<Category>? drinks})
      : foods = foods ?? [],
        drinks = drinks ?? [];

  final List<Category> foods;
  final List<Category> drinks;

  Map<String, dynamic> toJson() => {
        'foods': foods.map((e) => e.toJson()).toList(),
        'drinks': drinks.map((e) => e.toJson()).toList(),
      };

  factory Menus.fromJson(Map<String, dynamic> json) {
    return Menus(
      foods: (json["foods"] as List<dynamic>?)
              ?.map((x) => Category.fromJson(x))
              .toList() ??
          [],
      drinks: (json["drinks"] as List<dynamic>?)
              ?.map((x) => Category.fromJson(x))
              .toList() ??
          [],
    );
  }
}

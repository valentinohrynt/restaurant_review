import 'package:flutter/widgets.dart';
import 'package:restaurant_review/data/model/restaurant.dart';

class FavoriteListProvider extends ChangeNotifier {
  final List<Restaurant> _favoriteList = [];

  List<Restaurant> get favoriteList => _favoriteList;

  void addFavorite(Restaurant restaurant) {
    _favoriteList.add(restaurant);
    notifyListeners();
  }

  void removeFavorite(Restaurant restaurant) {
    _favoriteList.removeWhere((element) => element.id == restaurant.id);
    notifyListeners();
  }

  bool isFavorite(Restaurant restaurant) {
    final isFavorited = _favoriteList.where((element) => element.id == restaurant.id);
    return isFavorited.isNotEmpty;
  }
}

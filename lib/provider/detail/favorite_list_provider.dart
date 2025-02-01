import 'package:flutter/widgets.dart';
import 'package:restaurant_review/data/model/restaurant.dart';
import 'package:restaurant_review/data/local/database_helper.dart';

class FavoriteListProvider extends ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final List<Restaurant> _favoriteList = [];
  bool _isLoading = false;

  List<Restaurant> get favoriteList => _favoriteList;
  bool get isLoading => _isLoading;

  FavoriteListProvider() {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    _isLoading = true;
    notifyListeners();

    try {
      final favorites = await _databaseHelper.getFavorites();
      _favoriteList.clear();
      _favoriteList.addAll(favorites);
    } catch (e) {
      print('Error loading favorites: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addFavorite(Restaurant restaurant) async {
    try {
      await _databaseHelper.insertFavorite(restaurant);
      await _loadFavorites();
    } catch (e) {
      print('Error adding favorite: $e');
    }
  }

  Future<void> removeFavorite(Restaurant restaurant) async {
    try {
      await _databaseHelper.removeFavorite(restaurant.id);
      await _loadFavorites();
    } catch (e) {
      print('Error removing favorite: $e');
    }
  }

  Future<bool> isFavorite(Restaurant restaurant) async {
    try {
      return await _databaseHelper.isFavorite(restaurant.id);
    } catch (e) {
      print('Error checking favorite status: $e');
      return false;
    }
  }

  Future<void> refresh() async {
    await _loadFavorites();
  }
}
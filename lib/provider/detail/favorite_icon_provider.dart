import 'package:flutter/widgets.dart';

class FavoriteIconProvider extends ChangeNotifier {
  bool _isFavorite = false;

  bool get isFavorite => _isFavorite;

  set isFavorite(bool value) {
    if (_isFavorite != value) {
      _isFavorite = value;
      notifyListeners();
    }
  }
}


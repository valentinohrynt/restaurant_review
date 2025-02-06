import 'package:flutter/material.dart';

class SearchProvider extends ChangeNotifier {
  bool _isSearchFocused = false;
  String _previousSearch = '';

  bool get isSearchFocused => _isSearchFocused;
  String get previousSearch => _previousSearch;

  void setSearchFocus(bool focus) {
    _isSearchFocused = focus;
    notifyListeners();
  }

  void setPreviousSearch(String query) {
    _previousSearch = query;
    notifyListeners();
  }
}

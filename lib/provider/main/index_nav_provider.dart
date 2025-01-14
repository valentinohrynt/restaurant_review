import 'package:flutter/widgets.dart';

class IndexNavProvider extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  set currentIndex(int value) {
    _currentIndex = value;
    notifyListeners();
  }
}
import 'package:flutter/foundation.dart';

class SelectCountProvider extends ChangeNotifier {
  int _count = 0;

  int get count => _count;

  setCount(int count) {
    _count = count;
    notifyListeners();
  }
}
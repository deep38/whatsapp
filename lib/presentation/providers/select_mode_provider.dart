import 'package:flutter/foundation.dart';

class SelectModeProvider extends ChangeNotifier {
  bool _inSelectMode = false;

  bool get inSelectMode => _inSelectMode;

  void setInSelectMode(bool inSelectMode) {
    _inSelectMode = inSelectMode;
    notifyListeners();
  }

}
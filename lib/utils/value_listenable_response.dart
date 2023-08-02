import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ValueListenableResponse<T,V> {
  ValueListenableResponse({
    required this.valueListenable,
    required this.response,
  }) {
    valueListenable.addListener(_listen);
    this._curValue = valueListenable.value;
  }

  final ValueListenable<V> valueListenable;
  final T Function(V value) response;

  late V _curValue;

  void _listen() {
    if(_curValue != valueListenable.value) {
      _curValue = valueListenable.value;
      response(_curValue);
      debugPrint("Value changed");
    }
  }

  T build() {
    return response(_curValue);
  }
}
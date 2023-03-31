import 'package:flutter/material.dart';
import 'package:whatsapp/data/models/message.dart';
import 'package:whatsapp/utils/enums.dart';

class MessageChangeNotifier<Message> extends ValueNotifier {
  
  MessageChangeNotifier(super.value);

  void updateState(MessageState? state) {
    value.state = state;
    notifyListeners();
  }

  @override
  bool operator ==(covariant MessageChangeNotifier other) {
    return value.id == other.value.id && 
      value.time == other.value.time &&
      value.senderId == other.value.senderId;
  }

  @override
  int get hashCode => 
    value.id.hashCode ^ 
    value.data.hashCode ^
    value.time ^ value.senderId.hashCode;
}
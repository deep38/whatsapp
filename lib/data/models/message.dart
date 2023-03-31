// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:whatsapp/data/database/tables/message_table.dart';

import '../../../utils/enums.dart';

class Message {
  String id;
  String data;
  String senderId;
  int time;
  MessageState? state;

  Message({
    required this.id,
    required this.data,
    required this.senderId,
    required this.time,
    this.state,
  });

  Message.fromString({
    required this.id,
    required this.data,
    required this.time,
    required this.senderId,
    required String state,
  }) :
    state = _getMessageStateFromString(state);

  Message copyWith({
    String? id,
    String? data,
    String? senderId,
    int? time,
    MessageState? state,
  }) {
    return Message(
      id: id ?? this.id,
      data: data ?? this.data,
      senderId: senderId ?? this.senderId,
      time: time ?? this.time,
      state: state ?? this.state
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'data': data,
      'senderId': senderId,
      'time': time,
      'state': state?.name,
    };
  }

  Map<String, dynamic> toMapWithoutId() {
    return <String, dynamic>{
      'data': data,
      'senderId': senderId,
      'time': time,
      'state': state?.name,
    };
  }

  Map<String, dynamic> toMessageTableRow(String chatId) {
    return {
      MessageTable.id : id,
      MessageTable.senderId : senderId,
      MessageTable.data : data,
      MessageTable.time : time,
      MessageTable.state : state?.name ?? "null",
      MessageTable.chatId : chatId,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] as String,
      data: map['data'] as String,
      senderId: map['senderId'] as String,
      time: map['time'] as int,
      state: map['state']
    );
  }

  factory Message.fromMessageTableRow(Map<String, dynamic> row) {
    return Message.fromString(
      id: row[MessageTable.id], 
      senderId: row[MessageTable.senderId], 
      data: row[MessageTable.data], 
      time: row[MessageTable.time],
      state: row[MessageTable.state],
    );
  }

  factory Message.fromFirebaseMap(String id, Map<String, dynamic> row) {
    return Message.fromString(
      id: id, 
      senderId: row['senderId'], 
      data: row['data'], 
      time: row['time'],
      state: row['state'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Message.fromJson(String source) => Message.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Message(id: $id, data: $data, senderId: $senderId, time: $time, state: ${state?.name??"Null"})';
  }

  bool isUpdated(covariant Message other) {
    return other.data != data || other.state != state;
  }

  @override
  bool operator ==(covariant Message other) {
    if (identical(this, other)) return true;
  
    return 
      other.senderId == senderId &&
      other.time == time &&
      other.data == data;
  }

  @override
  int get hashCode {
    return
      senderId.hashCode ^
      time ^ 
      data.hashCode;
  }

  void setId(String id) {
    this.id = id;
  }

  void updateState(MessageState? state) {
    this.state = state;
  }

  static MessageState? _getMessageStateFromString(String state) {
    if(state.isEmpty || state == "null") return null;

    return MessageState.values.firstWhere(
      (messagegState) => messagegState.name == state,
    );
  }
}

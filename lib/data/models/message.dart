// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whatsapp/data/database/tables/message_table.dart';

import '../../../utils/enums.dart';

class Message {
  String id;
  String data;
  String senderId;
  int time;
  MessageStatus status;

  Message({
    required this.id,
    required this.data,
    required this.senderId,
    required this.time,
    required this.status,
  });

  Message copyWith({
    String? id,
    String? data,
    String? senderId,
    int? time,
    MessageStatus? status,
  }) {
    return Message(
      id: id ?? this.id,
      data: data ?? this.data,
      senderId: senderId ?? this.senderId,
      time: time ?? this.time,
      status: status ?? this.status
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'data': data,
      'senderId': senderId,
      'time': time,
      'status': status.name,
    };
  }

   Map<String, dynamic> toTableRow(String roomId) {
    return <String, dynamic>{
      'id': id,
      'data': data,
      'senderId': senderId,
      'time': time,
      'status': status.name,
      MessageTable.chatId: roomId,
    };
  }

  Map<String, dynamic> toFirebaseMap() {
    return <String, dynamic>{
      'data': data,
      'senderId': senderId,
      'time': FieldValue.serverTimestamp(),
      'status': status.name,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] as String,
      data: map['data'] as String,
      senderId: map['senderId'] as String,
      time: map['time'] as int,
      status: MessageStatus.values.firstWhere((element) => element.name == map['status'])
    );
  }

  factory Message.fromFirebaseMap(String id, Map<String, dynamic> map) {
    return Message(
      id: id,
      data: map['data'] as String,
      senderId: map['senderId'] as String,
      time: (map['time'] as Timestamp).toDate().millisecondsSinceEpoch,
      status: MessageStatus.values.firstWhere((element) => element.name == map['status'])
    );
  }

  String toJson() => json.encode(toMap());

  factory Message.fromJson(String source) => Message.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Message(id: $id, data: $data, senderId: $senderId, time: $time, state: $status)';
  }

  bool isUpdated(covariant Message other) {
    return other.data != data || other.status != status;
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

  void updateStatus(MessageStatus status) {
    this.status = status;
  }
}

// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:whatsapp/data/database/tables/chat_table.dart';
import 'package:whatsapp/data/models/user.dart';
import 'package:whatsapp/utils/enums.dart';

import 'message.dart';

class Chat {
  String id;
  List<WhatsAppUser> users;
  List<Message> messages;
  ChatType type;

  Chat({
    required this.id,
    required this.users,
    required this.messages,
    required this.type,
  });


  Chat copyWith({
    String? id,
    List<WhatsAppUser>? users,
    List<Message>? messages,
    ChatType? type,
  }) {
    return Chat(
      id: id ?? this.id,
      users: users ?? this.users,
      messages: messages ?? this.messages,
      type: type ?? this.type,
    );
  }

  void setId(String id) => this.id = id;

  void setUsers(List<WhatsAppUser> users) => this.users = users;
 
  void setMessages(List<Message> messages) => this.messages = messages;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'users': users.map((e) => e.uid).toList(),
      'messages': messages.map((x) => x.toMap()).toList(),
      'type': type.name,
    };
  }

  Map<String, dynamic> toChatTableRow() {
    return <String, dynamic>{
      ChatTable.id: id,
      ChatTable.type: type.name,
    };
  }

  factory Chat.fromMap(Map<String, dynamic> map) {
    return Chat(
      id: map['id'] as String,
      users: List<WhatsAppUser>.from((map['users'] as List<Map<String, dynamic>>).map((e) => WhatsAppUser.fromMap(e),),),
      messages: List<Message>.from((map['messages'] as List<Map<String, dynamic>>).map<Message>((x) => Message.fromMap(x),),),
      type: ChatType.values.firstWhere((element) => element.name == map['type']),
    );
  }

  factory Chat.fromChatTableRow(Map<String, dynamic> row) {
    return Chat(
      id: row[ChatTable.id],
      users: [],
      messages: [],
      type: ChatType.values.firstWhere((element) => element.name == row[ChatTable.type]),
    );
  }

  factory Chat.fromFirebaseMap(String id, Map<String, dynamic> data) {
    return Chat(
      id: id,
      users: data['users'] as List<String>,
      messages: [],
      type: ChatType.values.firstWhere((element) => element.name == row[ChatTable.type]),
    );
  }

  String toJson() => json.encode(toMap());

  factory Chat.fromJson(String source) => Chat.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Chat(id: $id, users: $users, messages: $messages, type: $type)';
  }

  // @override
  // int compareTo(Chat other) {
  //   if(messages.isEmpty && other.messages.isEmpty) return 0;
  //   if(messages.isNotEmpty && other.messages.isEmpty) return 1;
  //   if(messages.isEmpty && other.messages.isNotEmpty) return -1;
  //   return messages.last.time.compareTo(other.messages.last.time);
  // }

  @override
  bool operator ==(covariant Chat other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.type == type;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      users.hashCode ^
      messages.hashCode ^
      type.hashCode;
  }
}

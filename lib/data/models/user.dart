// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:whatsapp/data/database/tables/users_table.dart';
import 'package:whatsapp/utils/enums.dart';

class WhatsAppUser {
  final String id;
  final String phoneNo;
  final String? name;
  final String? profileUrl;
  final String about;
  final int? lastSeen;
  final UserStatus? status;

  WhatsAppUser({
    required this.id,
    required this.phoneNo,
    required this.name,
    required this.profileUrl,
    required this.about,
    required this.lastSeen,
    required this.status,
  });

  WhatsAppUser copyWith({
    String? id,
    String? phoneNo,
    String? name,
    String? profileUrl,
    String? about,
    int? lastSeen,
    UserStatus? status,
  }) {
    return WhatsAppUser(
      id: id ?? this.id,
      phoneNo: phoneNo ?? this.phoneNo,
      name: name ?? this.name,
      profileUrl: profileUrl ?? this.profileUrl,
      about: about ?? this.about,
      lastSeen: lastSeen ?? this.lastSeen,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'phoneNo': phoneNo,
      'name': name,
      'profileUrl': profileUrl,
      'about' : about,
      'lastSeen' : lastSeen,
      'status' : status?.name,
    };
  }

  Map<String, dynamic> toTableRow() {
    return <String, dynamic>{
      UserTable.id: id,
      UserTable.phone: phoneNo,
      UserTable.name: name,
      UserTable.profileUrl: profileUrl,
      UserTable.about: about,
    };
  }

  factory WhatsAppUser.fromMap(Map<String, dynamic> map) {
    return WhatsAppUser(
      id: map['id'] as String,
      phoneNo: map['phoneNo'] as String,
      name: map['name'] as String,
      profileUrl: map['profileUrl'] as String?,
      about: map['about'] as String,
      lastSeen: map['lastSeen'] as int?,
      status: map['status'] != null ? UserStatus.values.firstWhere((s) => s == map['status']) : null,
    );
  }

  factory WhatsAppUser.fromTableRow(Map<String, dynamic> map) {
    return WhatsAppUser(
      id: map[UserTable.id] as String,
      phoneNo: map[UserTable.phone] as String,
      name: map[UserTable.name] as String,
      profileUrl: map[UserTable.profileUrl] as String?,
      about: map[UserTable.about] as String,
      lastSeen: null,
      status: null,
    );
  }

  String toJson() => json.encode(toMap());

  factory WhatsAppUser.fromJson(String source) => WhatsAppUser.fromMap(json.decode(source) as Map<String, dynamic>);

  factory WhatsAppUser.fromFiebaseUser(User user) => WhatsAppUser(id: user.uid, phoneNo: user.phoneNumber!, name: user.displayName, profileUrl: user.photoURL, about: "Hey there! I am using WhatsApp.", lastSeen: null, status: null);

  @override
  String toString() {
    return 'WhatsAppUser(id: $id, phoneNo: $phoneNo, name: $name, profileUrl: $profileUrl)';
  }

  @override
  bool operator ==(covariant Object other) {
    if(other is! WhatsAppUser) return false;
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.phoneNo == phoneNo &&
      other.name == name &&
      other.profileUrl == profileUrl;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      phoneNo.hashCode ^
      name.hashCode ^
      profileUrl.hashCode;
  }
}

// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:whatsapp/data/database/tables/users_table.dart';

class WhatsAppUser {
  final String uid;
  final String phoneNo;
  final String? name;
  final String? profileUrl;

  WhatsAppUser({
    required this.uid,
    required this.phoneNo,
    required this.name,
    required this.profileUrl,
  });

  WhatsAppUser copyWith({
    String? uid,
    String? phoneNo,
    String? name,
    String? profileUrl,
  }) {
    return WhatsAppUser(
      uid: uid ?? this.uid,
      phoneNo: phoneNo ?? this.phoneNo,
      name: name ?? this.name,
      profileUrl: profileUrl ?? this.profileUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'phoneNo': phoneNo,
      'name': name,
      'profileUrl': profileUrl,
    };
  }

  Map<String, dynamic> toTableRow() {
    return <String, dynamic>{
      UserTable.uid: uid,
      UserTable.phone: phoneNo,
      UserTable.name: name,
      UserTable.profileUrl: profileUrl,
    };
  }

  factory WhatsAppUser.fromMap(Map<String, dynamic> map) {
    return WhatsAppUser(
      uid: map['uid'] as String,
      phoneNo: map['phoneNo'] as String,
      name: map['name'] as String,
      profileUrl: map['profileUrl'] as String?,
    );
  }

  factory WhatsAppUser.fromTableRow(Map<String, dynamic> map) {
    return WhatsAppUser(
      uid: map[UserTable.uid] as String,
      phoneNo: map[UserTable.phone] as String,
      name: map[UserTable.name] as String,
      profileUrl: map[UserTable.profileUrl] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory WhatsAppUser.fromJson(String source) => WhatsAppUser.fromMap(json.decode(source) as Map<String, dynamic>);

  factory WhatsAppUser.fromFiebaseUser(User user) => WhatsAppUser(uid: user.uid, phoneNo: user.phoneNumber!, name: user.displayName, profileUrl: user.photoURL);

  @override
  String toString() {
    return 'WhatsAppUser(uid: $uid, phoneNo: $phoneNo, name: $name, profileUrl: $profileUrl)';
  }

  @override
  bool operator ==(covariant WhatsAppUser other) {
    if (identical(this, other)) return true;
  
    return 
      other.uid == uid &&
      other.phoneNo == phoneNo &&
      other.name == name &&
      other.profileUrl == profileUrl;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
      phoneNo.hashCode ^
      name.hashCode ^
      profileUrl.hashCode;
  }
}

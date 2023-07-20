import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/Authentication/firebase_user_manager.dart';
import 'package:whatsapp/data/models/message.dart';
import 'package:whatsapp/data/models/user.dart';
import 'package:whatsapp/utils/enums.dart';

class FirestoreHelper {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<List<WhatsAppUser>> fetchUsersThatInContacts(
      List<String> contacts) async {
    List<WhatsAppUser> whatsAppUsers = [];
    if (contacts.length > 10) {
      for (int start = 0;
          start < contacts.length;
          start = min(start + 10, contacts.length)) {
        QuerySnapshot<Map<String, dynamic>> users = await _firestore
            .collection("users")
            .where('phoneNo',
                whereIn:
                    contacts.sublist(start, min(start + 10, contacts.length)))
            .get();
        debugPrint("FirebaseUser: ${users.docs.length}");
        for (QueryDocumentSnapshot<Map<String, dynamic>> userSnapshot
            in users.docs) {
          whatsAppUsers.add(WhatsAppUser.fromMap(userSnapshot.data()));
        }
      }
    } else {
      QuerySnapshot<Map<String, dynamic>> users = await _firestore
          .collection("users")
          .where('phoneNo', whereIn: contacts)
          .get();
      debugPrint("FirebaseUser: ${users.docs.length}");
      for (QueryDocumentSnapshot<Map<String, dynamic>> userSnapshot
          in users.docs) {
        whatsAppUsers.add(WhatsAppUser.fromMap(userSnapshot.data()));
      }
    }

    return whatsAppUsers;
  }

  static Future<WhatsAppUser?> fetchUserByPhoneNumber(String phone) async {
    DocumentSnapshot<Map<String, dynamic>> documentReference =
        await _firestore.collection("users").doc(phone).get();

    Map<String, dynamic>? userMap = documentReference.data();
    return userMap != null ? WhatsAppUser.fromMap(userMap) : null;
  }

  static Future<String> createChatRoom(String userId,
      [ChatType type = ChatType.onetoone]) async {
    return (await _firestore.collection('chats').add({
      'users': [userId],
      'type': type.name
    }))
        .id;
  }

  static Future<String> sendMessage(
      String roomId, Map<String, dynamic> message) async {
    return (await _firestore
            .collection('chats')
            .doc(roomId)
            .collection('messages')
            .add(message))
        .id;
  }

  static Future<void> updateMessageState(
      String roomId, String messageId, String messageState) async {
    await _firestore
        .collection('chats')
        .doc(roomId)
        .collection('messages')
        .doc(messageId)
        .update({'status': messageState});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getChatStream() {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: UserManager.uid)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getMessageStreamForRoom(
      String roomId) {
    return _firestore
        .collection('chats')
        .doc(roomId)
        .collection('messages')
        .where('status', isEqualTo: MessageStatus.sent.name)
        .orderBy('time')
        .snapshots();
  }

  static Future<List<Message>> getMessagesRoomId(String roomId) async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection('chats')
        .doc(roomId)
        .collection('messages')
        .where('status', isEqualTo: MessageStatus.sent.name)
        .orderBy('time')
        .get();

    return snapshot.docs
        .map((doc) => Message.fromMap(doc.data(), doc.id))
        .toList();
  }

  static Stream<DocumentSnapshot<Map<String, dynamic>>> getMessageStreamById(
      String roomId, String messageId) {
    return _firestore
        .collection('chats')
        .doc(roomId)
        .collection('messages')
        .doc(messageId)
        .snapshots();
  }
}

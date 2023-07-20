import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/Authentication/firebase_user_manager.dart';
import 'package:whatsapp/data/database/tables/chat_table.dart';
import 'package:whatsapp/data/database/tables/chat_users_table.dart';
import 'package:whatsapp/data/database/tables/message_table.dart';
import 'package:whatsapp/data/database/tables/users_table.dart';
import 'package:whatsapp/data/models/chat.dart';
import 'package:whatsapp/data/models/message.dart';
import 'package:whatsapp/data/models/user.dart';
import 'package:whatsapp/utils/enums.dart';

class ChatRepository {
  final _chatTable = ChatTable();
  final _messageTable = MessageTable();
  final _chatUserTable = ChatUsersTable();
  final _userTable = UserTable();

  final _chatFirestore = FirebaseFirestore.instance.collection('chats');
  final _userFirestore = FirebaseFirestore.instance.collection('users');

  Future<bool> startedByThisUser(String chatId) async {
    final messagesSnapshot = (await _chatFirestore
            .doc(chatId)
            .collection('messages')
            .orderBy('time', descending: true)
            .get())
        .docs;
    if (messagesSnapshot.isNotEmpty) {
      debugPrint("${messagesSnapshot.first.data()['senderId'] == UserManager.uid}");
      return messagesSnapshot.first.data()['senderId'] == UserManager.uid;
    }

    return false;
  }

  Future<void> createChatInLocal(Chat chat) async {
    await _chatTable.insert(chat.toMapForStore());

    for (final participant in chat.participants) {
      if (participant.id == UserManager.uid) continue;

      await _chatUserTable
          .insert({'chatId': chat.id, 'userId': participant.id});

      if (!(await _userTable.exists(participant.id))) {
        _userTable.insert(participant.toTableRow());
      }
    }
  }

  Future<String> createChatOnFirebase(Chat chat) async {
    return (await _chatFirestore.add({
      'type': chat.type.name,
      'participants': [UserManager.uid, ...(chat.participants.map((e) => e.id))]
    }))
        .id;
  }

  Future<List<Chat>> getChatsFromLocalDB() async {
    List<Chat> chatList = [];
    List<Message> messageList;
    List<WhatsAppUser> participants;
    final chatMapList = await _chatTable.getAll();

    for (final chatMap in chatMapList) {
      /// LOAD MESSAGES
      messageList = (await _messageTable.getAllForChat(chatMap['id']))
          .map((messageMap) => Message.fromMap(messageMap))
          .toList();

      /// LOAD ALL PARTICIPANTS
      List<String> participantsIdList =
          (await _chatUserTable.getUsersByChatId(chatMap['id']))
              .map((e) => e['userId'].toString())
              .toList();
      participants = [];
      for (String id in participantsIdList) {
        participants
            .add(WhatsAppUser.fromMap((await _userTable.getById(id)).first));
      }

      chatList.add(Chat(
          id: chatMap['id'],
          participants: participants,
          messages: messageList,
          type: ChatType.onetoone));
    }

    return chatList;
  }

  Future<Chat> getChatFromFirebase(String id) async {
    final chatMap = (await _chatFirestore.doc(id).get()).data();

    if (chatMap == null) throw Exception("No chat found on firebase with id = $id");

    Chat chat = Chat.fromFirebaseMap(id, chatMap);
    
    for (final userId in chatMap['participants'] as List<dynamic>) {
      final localUserMap = await _userTable.getById(userId as String);
      if (localUserMap.isNotEmpty) {
        chat.participants.add(WhatsAppUser.fromTableRow(localUserMap.first));
      } else {
        final userMapList =
            (await _userFirestore.where('id', isEqualTo: userId).get()).docs;
        if (userMapList.isNotEmpty) {
          chat.participants.add(WhatsAppUser.fromMap(userMapList.first.data()));
        }
      }
    }

    chat.messages = (await _chatFirestore
            .doc(id)
            .collection('messages')
            .orderBy('time')
            .get())
        .docs
        .map(
          (messageSnapshot) => Message.fromMap(
            messageSnapshot.data(),
            messageSnapshot.id,
          ),
        )
        .toList();

    return chat;
  }

  Future<void> addMessageInLocalDB(String chatId, Message message) async {
    await _messageTable.insert(message.toTableRow(chatId));
  }

  Future<String> sendMessageToFirebase(String chatId, Message message) async {
    return (await _chatFirestore
        .doc(chatId)
        .collection('messages')
        .add(message.toMapWithoutId())).id;
  }

  Future<void> updateChatId(String oldId, String newId) async {
    await _chatTable.updateId(oldId, newId);
    await _messageTable.updateChatId(oldId, newId);
    await _chatUserTable.updateChatId(oldId, newId);
  }

  Future<void> updateMessageId(String oldId, String newId) async {
    await _messageTable.updateId(oldId, newId);
  }
  Future<void> removeFieldsFromFirebaseChat(String chatId) async {
    await _chatFirestore.doc(chatId).set({});
  }


  Future<void> updateMessageStatus(String chatId, String messageId, MessageStatus status) async {
    await updateMessageStatusInLocalDB(chatId, messageId, status);
    await updateMessageStatusOnFirebase(chatId, messageId, status);
    // await _messageTable.updateStatus(chatId, messageId, status.name);
    // await _chatFirestore.doc(chatId).collection('messages').doc(messageId).set({'status': status.name}, SetOptions(merge: true));
  }

  Future<void> updateMessageStatusOnFirebase(String chatId, String messageId, MessageStatus status) async {
    await _chatFirestore.doc(chatId).collection('messages').doc(messageId).set({'status': status.name}, SetOptions(merge: true));
  }

  Future<void> updateMessageStatusInLocalDB(String chatId, String messageId, MessageStatus status) async {
    await _messageTable.updateStatus(chatId, messageId, status.name);
  }

  Future<void> clearData() async {
    _chatTable.deleteAll();
    _messageTable.deleteAll();
    _chatUserTable.deleteAll();
    _userTable.deleteAll();
  }
}

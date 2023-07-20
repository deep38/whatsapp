import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/Authentication/firebase_user_manager.dart';
import 'package:whatsapp/data/database/table_helper.dart';
import 'package:whatsapp/data/database/tables/chat_table.dart';
import 'package:whatsapp/data/database/tables/chat_users_table.dart';
import 'package:whatsapp/data/firebase/firestor_collection.dart';
import 'package:whatsapp/data/models/chat.dart';
import 'package:whatsapp/data/models/user.dart';
import 'package:whatsapp/utils/enums.dart';

abstract class ConversationCallbacks {
  void onNewChatCreated(Chat chat);
}

class ConversationHelper {

  ConversationHelper(this.chat, this.user);

  Chat? chat;
  WhatsAppUser? user;

  final ChatTable _chatTable = ChatTable();
  final ChatUsersTable _chatUsersTable = ChatUsersTable();
  final TableHelper _tableHelper = TableHelper();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Chat?> initChatIfExists() async {
    debugPrint("Conversations: Chat is null trying to init");
    if (user == null) return null;
    debugPrint("Conversations: User found $user");

    List<Map<String, dynamic>> chatsId = await _chatUsersTable.getChatsByUserId(user!.id);
    if (chatsId.isNotEmpty) {
      chat = (await _tableHelper.getChatById(chatsId[0][ChatUsersTable.chatId], ChatType.onetoone));
      return chat;
    }

    debugPrint("Conversations: Chat not found $chat");

    return null;
  }

  Future<Chat> createNewChatInLocal() async {
    int unsentCount = await _unsentChatCount;
    return chat = Chat(
      id: 'UNSENT_$unsentCount',
      participants: [user!],
      messages: [],
      type: ChatType.onetoone,
    );
  }
  Future<Chat?> createNewChat() async {
    debugPrint("Creating new chat");
    
    // _newChatCreated = true;
    await _tableHelper.createNewChat(chat!, user!);

    String id = (await _firestore.collection(FirestoreCollection.chats).add({'users': [user!.id, UserManager.uid], 'type': chat?.type.name})).id;
    chat!.setId(id);

    debugPrint("Conversations: chat created locally with id ${chat?.id}");
    return chat;
  }

  Future<int> get _unsentChatCount async {
    return await _chatTable.getUnsentCount();
  }
}
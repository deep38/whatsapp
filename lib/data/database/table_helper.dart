import 'package:flutter/material.dart';
import 'package:whatsapp/data/database/tables/chat_table.dart';
import 'package:whatsapp/data/database/tables/chat_users_table.dart';
import 'package:whatsapp/data/database/tables/message_table.dart';
import 'package:whatsapp/data/database/tables/users_table.dart';
import 'package:whatsapp/data/database/tables/waiting_message.dart';
import 'package:whatsapp/data/models/chat.dart';
import 'package:whatsapp/data/models/message.dart';
import 'package:whatsapp/data/models/user.dart';
import 'package:whatsapp/utils/enums.dart';

class TableHelper {
  final ChatTable _chatTable = ChatTable();
  final ChatUsersTable _chatUsersTable = ChatUsersTable();
  final MessageTable _messageTable = MessageTable();
  final WaitingMessageTable _waitingMessageTable = WaitingMessageTable();
  final UserTable _userTable = UserTable();



  Future<List<Chat>> getAllChats() async {
    List<Chat> chats = (await _chatTable.getAll()).map((e) => Chat.fromChatTableRow(e)).toList();
    
    for(Chat chat in chats) {
      Chat newChat = await getChatById(chat.id, chat.type);
      chat.setUsers(newChat.users);
      chat.setMessages(newChat.messages);
    }

    return chats;
  }

  Future<Chat> getChatById(String id, [ChatType? type]) async {
    List<String> userIds = (await _chatUsersTable.getUsersByChatId(id)).map((e) => e[ChatUsersTable.userId] as String).toList();
    List<WhatsAppUser> users = [];
    // debugPrint("Loading_chat id: $id, users: $userIds");
    for (var userId in userIds) {
      List<Map<String, dynamic>> foundedUsers = await _userTable.getById(userId);
      // debugPrint("Loading_chat foundUser: $foundedUsers, forId: $userId");
      if(foundedUsers.isNotEmpty) {
        users.add(WhatsAppUser.fromTableRow(foundedUsers[0]));
      }
    }

      List<Message> messages = (await _messageTable.getAllForChat(id)).map((e) => Message.fromMessageTableRow(e)).toList();
      List<Message> waitingMessages = (await _waitingMessageTable.getAllForChat(id)).map((e) => Message.fromMessageTableRow(e)).toList();
      debugPrint("Messages: ${messages.length}");
      debugPrint("WaitingMessages: ${waitingMessages.length}");
      int i = 0, j = 0;
      while(i < messages.length && j < waitingMessages.length) {
        if(messages[i].time > waitingMessages[j].time) {
          messages.insert(i, waitingMessages[j]);
          i++;
          j++;
        } else {
          i++;
        }
      }

      while(j < waitingMessages.length) {
        messages.add(waitingMessages[j]);
        j++;
      }
      return Chat(id: id, users: users, messages: messages, type: type ?? ChatType.onetoone);
  }

  Future<void> createNewChat(Chat chat, WhatsAppUser user) async {
    await _chatTable.insert(chat.toChatTableRow());
    await _chatUsersTable.insert({ChatUsersTable.chatId: chat.id, ChatUsersTable.userId: user.uid});
    await _userTable.insert(user.toTableRow());
  }

  Future<void> updateChatId(String oldId, String newId) async {
    await _chatTable.updateId(oldId, newId);
    await _chatUsersTable.updateChatId(oldId, newId);
    await _waitingMessageTable.updateChatId(oldId, newId);
  }

  Future<void> deleteChat(String chatId) async {
    await _chatTable.delete(chatId);
    await _chatUsersTable.deleteChat(chatId);
    await _messageTable.deleteMessages(chatId);
    await _waitingMessageTable.deleteMessages(chatId);
  }
  Future<int> insertChat(Map<String, dynamic> chat) async {
    return await _chatTable.insert(chat);
  }
}
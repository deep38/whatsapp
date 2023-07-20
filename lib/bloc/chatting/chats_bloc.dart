import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whatsapp/Authentication/firebase_user_manager.dart';
import 'package:whatsapp/bloc/chatting/chats_event.dart';
import 'package:whatsapp/bloc/chatting/chats_state.dart';
import 'package:whatsapp/data/database/tables/users_table.dart';
import 'package:whatsapp/data/firebase/firestore_helper.dart';
import 'package:whatsapp/data/models/chat.dart';
import 'package:whatsapp/data/models/message.dart';
import 'package:whatsapp/data/repository/chats_repository.dart';
import 'package:whatsapp/utils/enums.dart';

class ChattingBloc extends Bloc<ChattingEvent, ChattingState> {
  final ChatRepository _chatRepository;

  List<Chat> _chatList = [];

  List<Chat> get chatList => _chatList;

  ChattingBloc(this._chatRepository) : super(ChatsLoadingState()) {
    on<LoadChatsEvent>((event, emit) async {
      
      // await _chatRepository.clearData();
      // await UserTable().changeColumnName('phone', 'phoneNo');
      _chatList = await _chatRepository.getChatsFromLocalDB();
      debugPrint("Chat list loaded");
      emit(ChatsLoadedState(_chatList));
      debugPrint("Chat list emited");
      for (Chat chat in _chatList) {
        _listenForMessages(chat);
        _listenForMessageUpdateOfChat(chat.id, chat.messages);
      }

      FirestoreHelper.getChatStream().listen((event) async {
        for (final docChange in event.docChanges) {
          debugPrint("DocChanges: ${docChange.doc.id} ${docChange.type != DocumentChangeType.added}");
          if (!(docChange.type != DocumentChangeType.added ||
              chatIsInList(docChange.doc.id) || (await _chatRepository.startedByThisUser(docChange.doc.id)))) {
            debugPrint("New chat in firebase with id : ${docChange.doc.id}");
            add(NewFirebaseChatEvent(docChange.doc.id));
          }
        }
      });
    });

    on<NewLocalChatEvent>((event, emit) async {
      debugPrint("New local chat ${event.chat}");
      await _chatRepository.createChatInLocal(event.chat);
      event.chat.messages.add(event.firstMessage);
      _chatList.insert(0, event.chat);
      debugPrint("New local chat inserted");

      emit(NewChatState(event.chat));
      emit(NewMessageState(event.chat.id, event.firstMessage));
      debugPrint("New local chat emited");

      String newId = await _chatRepository.createChatOnFirebase(event.chat);
      String oldId = event.chat.id;
      event.chat.id = newId;
      debugPrint("New chat created on firebase: $newId, ${_chatList[0].id}");
      _listenForMessages(event.chat);

      await _chatRepository.updateChatId(oldId, newId);
      debugPrint("Chat id updated on database: ");

      await _chatRepository.addMessageInLocalDB(
          event.chat.id, event.firstMessage);
      debugPrint("First message created in local: $newId, ${event.chat.id}");

      String newMessageId = await _chatRepository.sendMessageToFirebase(
          event.chat.id, event.firstMessage);
      debugPrint("New message created on firebase: $newMessageId");
      
      emit(MessageStatusUpdateState(event.firstMessage.id, MessageStatus.sent));
      await _chatRepository.updateMessageId(event.firstMessage.id, newMessageId);
      event.firstMessage.id == newMessageId;

      _listenForMessageUpdate(event.chat.id, event.firstMessage);
      debugPrint("New local chat complete");
    });

    on<NewFirebaseChatEvent>((event, emit) async {
      
      final chat = await _chatRepository.getChatFromFirebase(event.id);
      _chatList.insert(0, chat);
      emit(NewChatState(chat));
      _listenForMessages(chat);

      await _chatRepository.createChatInLocal(chat);
      // await _chatRepository.removeFieldsFromFirebaseChat(event.chat.id);
    });

    on<NewLocalMessageEvent>((event, emit) async {
      debugPrint("Event occur of new messagge ${event.message}");
      int chatIndex = _chatList.indexWhere((chat) => chat.id == event.chatId);
      

      _chatList[chatIndex].messages.add(event.message);
      emit(NewMessageState(event.chatId, event.message));
      debugPrint("Message added to chat and emited");

      if (chatIndex != 0) {
        _chatList.removeAt(chatIndex);
        _chatList.insert(0, _chatList[chatIndex]);
        emit(NewChatState(_chatList[chatIndex], chatIndex));
      }

      await _chatRepository.addMessageInLocalDB(event.chatId, event.message);
      String newId = await _chatRepository.sendMessageToFirebase(event.chatId, event.message..status = MessageStatus.sent);
      debugPrint("New message created on firebase: $newId");
      await _chatRepository.updateMessageId(event.message.id, newId);
      event.message.id = newId;

      _listenForMessageUpdate(_chatList[chatIndex].id, event.message);
    });

    on<NewFirebaseMessageEvent>((event, emit) async {
      debugPrint("Event occur of new messagge ${event.message}");
      int chatIndex = _chatList.indexWhere((chat) => chat.id == event.chatId);
      Chat chat = _chatList[chatIndex];

      chat.messages.add(event.message);
      emit(NewMessageState(event.chatId, event.message));
      debugPrint("Message added to chat and emited");

      if (chatIndex != 0) {
        _chatList.removeAt(chatIndex);
        _chatList.insert(0, chat);
        emit(NewChatState(chat, chatIndex));
      }
      
      event.message.updateStatus(MessageStatus.received);
      debugPrint("Adding new firebase message to local");
      await _chatRepository.addMessageInLocalDB(event.chatId, event.message);
      debugPrint("Added");

      await _chatRepository.updateMessageStatusOnFirebase(event.chatId, event.message.id, MessageStatus.received);
      debugPrint("Updated on firebase");
    });

    on<LocalMessageUpdateEvent>((event, emit) async {
      await _chatRepository.updateMessageStatus(event.chatId, event.messageId, event.status);
    });

    on<FirebaseMessageUpdateEvent>((event, emit) async {
      debugPrint("Firebase message updated: ${event.chatId}, ${event.messageId}, ${event.status}");
      emit(MessageStatusUpdateState(event.messageId, event.status));
      await _chatRepository.updateMessageStatusInLocalDB(event.chatId, event.messageId, event.status);
    });
  }


  void _listenForMessages(Chat chat) {
    debugPrint("Listening for messages in chat id: $chat.id");
    FirestoreHelper.getMessageStreamForRoom(chat.id).listen((event) {
        debugPrint("Firbase: Message changes event from firebase");
      for (final docChange in event.docChanges) {
         debugPrint("Firbase: Message with value ${docChange.doc} changed");
         
        if (!(docChange.type != DocumentChangeType.added ||
            docChange.doc.data()!['senderId'] == UserManager.uid || chat.messages.indexWhere((m) => m.id == docChange.doc.id) != -1)) {
            debugPrint("Firbase: Message is new ${docChange.doc}");

          add(
            NewFirebaseMessageEvent(
              chat.id,
              Message.fromMap(
                docChange.doc.data()!,
                docChange.doc.id,
              ),
            ),
          );
        } else {
          debugPrint("Message is already exists: ${docChange.doc.id}: ${docChange.doc.data()!['data']}");
        }
      }
    });
  }

  void _listenForMessageUpdateOfChat(String chatId, List<Message> messages) {
    for(Message message in messages) {
      if(message.status == MessageStatus.seen || message.senderId == UserManager.uid) continue;

      _listenForMessageUpdate(chatId, message);
    }
  }

  void _listenForMessageUpdate(String chatId, Message message) {
    debugPrint("Listening for message: ${message.id}, ${message.data}");
    FirestoreHelper.getMessageStreamById(chatId, message.id).listen((event) {
        add(FirebaseMessageUpdateEvent(chatId, message.id, MessageStatus.values.firstWhere((status) => status.name == event.data()!['status'])));
      });
  }

  bool chatIsInList(String id) {
    bool inList = _chatList.indexWhere((element) => element.id == id) != -1;
    debugPrint("Chat already in list $inList");
    return inList;
  }
}

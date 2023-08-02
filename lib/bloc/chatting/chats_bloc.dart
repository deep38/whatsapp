import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whatsapp/Authentication/firebase_user_manager.dart';
import 'package:whatsapp/bloc/chatting/chats_event.dart';
import 'package:whatsapp/bloc/chatting/chats_state.dart';
import 'package:whatsapp/data/firebase/firestore_helper.dart';
import 'package:whatsapp/data/models/chat.dart';
import 'package:whatsapp/data/models/message.dart';
import 'package:whatsapp/data/repository/chats_repository.dart';
import 'package:whatsapp/utils/enums.dart';

class ChattingBloc extends Bloc<ChattingEvent, ChattingState> {
  final _tag = "ChattingBloc:";

  final Connectivity _connectivity = Connectivity();
  bool _isNotListening = true;
  bool _notSendingMessage = true;

  final ChatRepository _chatRepository;
  List<Chat> _chatList = [];

  StreamSubscription? _chatSubscription;
  final Map<String, StreamSubscription> _messageListSubscriptions = {};
  final Map<String, StreamSubscription> _messageSubscriptions = {};

  List<Chat> get chatList => _chatList;

  ChattingBloc(this._chatRepository) : super(ChatsLoadingState()) {
    on<LoadChatsEvent>((event, emit) async {
      // await _chatRepository.clearData();
      // await UserTable().changeColumnName('phone', 'phoneNo');
      _chatList = await _chatRepository.getChatsFromLocalDB();
      // _chatList = await FirestoreHelper.getAllChat();
      // debugPrint("$_tag Chat list loaded.: ${_chatList[0].id}");
      // debugPrint("$_tag .........In chat bloc printing messages of chat id: ${_chatList[0].id}...........");
      emit(ChatsLoadedState(_chatList));
      //debugprint("Chat list emited");

      _connectivity.onConnectivityChanged.listen((connectivityResult) {
          debugPrint("ChattinbBloc: in Connectivity");
        if (connectivityResult != ConnectivityResult.none) {
          debugPrint("ChattinbBloc: sending and listening");
           if(_notSendingMessage) _sendUnsentMessages();
          if(_isNotListening) _startListeners();

        }
      });

      // if (await _connectivity.checkConnectivity() != ConnectivityResult.none) {
      //   _startListeners();
      // }

    });

    on<NewLocalChatEvent>((event, emit) async {
      event.chat.messages
          .add(event.firstMessage); // adding first message to message list.
      _chatList.insert(0, event.chat);

      emit(NewChatState(event.chat));
      emit(NewMessageState(event.chat, event.firstMessage));

      await _chatRepository.createChatInLocal(event.chat);
      await _chatRepository.addMessageInLocalDB(
          event.chat.id, event.firstMessage,);

      //debugprint( "$_tag New Local Chat ${event.chat.id} with message ${event.firstMessage.id} created locally.");
      if(await _connectivity.checkConnectivity() == ConnectivityResult.none) return;
      String oldChatId = event.chat.id;
      event.chat.id = await _chatRepository.createChatOnFirebase(event.chat);
      debugPrint( "$_tag New Chat OldId: $oldChatId NewId: ${event.chat.id} in List: ${_chatList[0].id} with message ${event.firstMessage.id} created on firebase.");

      _listenForMessages(event.chat); // Listen for incoming messages of chat.

      await _chatRepository.updateChatId(oldChatId, event.chat.id);

      final oldMessageId = event.firstMessage.id;
      event.firstMessage.id = await _chatRepository.sendMessageToFirebase(
        event.chat.id,
        event.firstMessage.copyWith(status: MessageStatus.sent),
      );

      event.firstMessage.status = MessageStatus.sent;

      emit(MessageStatusUpdateState(event.firstMessage, MessageStatus.sent));
      await _chatRepository.updateMessageIdAndStatus(
        oldMessageId,
        event.firstMessage.id,
        MessageStatus.sent,
      );

      //debugprint("$_tag Message updated in local db");
      _listenForMessageUpdate(event.chat.id, event.firstMessage);
      //debugprint( "$_tag New Chat ${event.chat.id} with message ${event.firstMessage.id} created on firebase.");
    });

    on<NewLocalMessageEvent>((event, emit) async {
      int chatIndex = _chatList.indexWhere(
          (chat) => chat.id == event.chatId); // Find chat by chat id.

      _chatList[chatIndex].messages.add(event.message);
      emit(NewMessageState(_chatList[chatIndex], event.message));

      if (chatIndex != 0) {
        _chatList.removeAt(chatIndex);
        _chatList.insert(0, _chatList[chatIndex]);
        emit(NewChatState(_chatList[chatIndex], chatIndex));
      }

      await _chatRepository.addMessageInLocalDB(event.chatId, event.message);
      //debugprint( "$_tag Message created locally: ${event.chatId} ${event.message.id}");

      final oldId = event.message.id;
      event.message.id = await _chatRepository.sendMessageToFirebase(
        event.chatId,
        event.message.copyWith(status: MessageStatus.sent),
      );

      debugPrint("$_tag Message created on firebase: oldId $oldId, ${event.message.id}");

      event.message.status = MessageStatus.sent;
      emit(MessageStatusUpdateState(event.message, MessageStatus.sent));

      await _chatRepository.updateMessageIdAndStatus(
        oldId,
        event.message.id,
        MessageStatus.sent,
      );

      //debugprint("$_tag Message updated in local db");

      _listenForMessageUpdate(_chatList[chatIndex].id, event.message);
    });

    on<NewFirebaseChatEvent>((event, emit) async {
      debugPrint("$_tag New firebase chat ${event.id}");
      final chat = await _chatRepository.getChatFromFirebase(event.id);
      _chatList.insert(0, chat);

      emit(NewChatState(chat));
      for (final message in chat.messages) {
        message.status = MessageStatus.received;
        await _chatRepository.updateMessageStatus(
            chat.id, message.id, MessageStatus.received);
      }
      _listenForMessages(chat);

      await _chatRepository.createChatInLocal(chat);
      // await _chatRepository.removeFieldsFromFirebaseChat(event.chat.id);
    });

    on<NewFirebaseMessageEvent>((event, emit) async {
      
      int chatIndex = _chatList.indexWhere((chat) => chat.id == event.chatId);
      Chat chat = _chatList[chatIndex];

      chat.messages.add(event.message);
      emit(NewMessageState(chat, event.message));

      if (chatIndex != 0) {
        _chatList.removeAt(chatIndex);
        _chatList.insert(0, chat);
        emit(NewChatState(chat, chatIndex));
      }

      event.message.updateStatus(MessageStatus.received);

      //debugprint("Adding new firebase message to local: ${event.message.id}");
      await _chatRepository.addMessageInLocalDB(event.chatId, event.message);
      //debugprint("Added");

      await _chatRepository.updateMessageStatusOnFirebase(
        event.chatId,
        event.message.id,
        MessageStatus.received,
      );
      //debugprint("Updated on firebase");
    });

    on<LocalMessageUpdateEvent>((event, emit) async {
      debugPrint(".........Message update ${event.message.data} ${event.message.id}.........");
      event.message.status = event.status;

      await _chatRepository.updateMessageStatus(
        event.chatId,
        event.message.id,
        event.status,
      );
    });

    on<FirebaseMessageUpdateEvent>((event, emit) async {
      debugPrint( "..............Firebase message updated: ${event.chatId}, ${event.message}, ${event.status}");
      event.message.status = event.status;
      emit(MessageStatusUpdateState(event.message, event.status));
      await _chatRepository.updateMessageStatusInLocalDB(
        event.chatId,
        event.message.id,
        event.status,
      );
    });
  }

  void _sendUnsentMessages() async {
    _notSendingMessage = false;
    debugPrint("$_tag Sending unsent messages");
    
    for(Chat chat in _chatList) {

      if(_notValidId(chat.id)) {
        debugPrint("$_tag Chat id is not valid ${chat.id}");

        // Create chat.
        final oldChatId = chat.id;
        chat.id = await _chatRepository.createChatOnFirebase(chat);
        debugPrint("$_tag Chat created on firebase ${chat.id}");

        
        await _chatRepository.updateChatId(oldChatId, chat.id);
        debugPrint("$_tag Chat updated locally ${chat.id}");

        _listenForMessages(chat);
      }

      for(Message message in chat.messages) {
        if(message.status == MessageStatus.waiting) {
          debugPrint("$_tag Message is waiting: ${message.id} ${message.data} ${message.status.name}");
          message.data += " From chatbloc function";
          final oldMessageId = message.id;
          message.status = MessageStatus.sending;
          message.id = await _chatRepository.sendMessageToFirebase(chat.id, message.copyWith(status: MessageStatus.sent));
          debugPrint("$_tag Message is sent on firebase: ${message.id} ${message.data} ${message.status.name}");
          message.status = MessageStatus.sent;
          add(LocalMessageUpdateEvent(chat.id, message, message.status));
          await _chatRepository.updateMessageIdAndStatus(oldMessageId, message.id, message.status);
          debugPrint("$_tag Message updated locally: ${message.id} ${message.data} ${message.status.name}");

          _listenForMessageUpdate(chat.id, message);
        }
      }
    }
  }

  void _startListeners() {
    _isNotListening = false;
    debugPrint("ChattingBloc Listening");
    for (Chat chat in _chatList) {
      _listenForMessages(chat);
      _listenForMessageUpdateOfChat(chat.id, chat.messages);
    }

  FirestoreHelper.getChatStream().listen((event) async {
      for (final docChange in event.docChanges) {
        if (!(docChange.type != DocumentChangeType.added || chatIsInList(docChange.doc.id))) {
          debugPrint("$_tag .......Chat in list........");
          for(Chat chat in _chatList) {
            debugPrint("$_tag Chat in list: ${chat.id}");
          }
          debugPrint("$_tag New chat in firebase with id : ${docChange.doc.id}");
          add(NewFirebaseChatEvent(docChange.doc.id));
        }
      }
    });
  }

  void _listenForMessages(Chat chat) {
    //debugprint("Listening for messages in chat id: ${chat.id}");

    if (_notValidId(chat.id) || _messageListSubscriptions.containsKey(chat.id)) return;

    _messageListSubscriptions[chat.id] =
        FirestoreHelper.getMessageStreamForRoom(chat.id).listen((event) {
      //debugprint("Firbase: Message changes event from firebase");
      for (final docChange in event.docChanges) {
        //debugprint("Firbase: Message with value ${docChange.doc.id} changed");

        if (docChange.type == DocumentChangeType.added &&
            docChange.doc.data() != null) {
          //debugprint("Firbase: Message is new ${docChange.doc}");
          final messageIndex =
              chat.messages.indexWhere((m) => m.id == docChange.doc.id);
          final newMessage = Message.fromFirebaseMap(
            docChange.doc.id,
            docChange.doc.data()!,
          );
          if (newMessage.senderId != UserManager.uid && messageIndex == -1) {
            add(
              NewFirebaseMessageEvent(
                chat.id,
                newMessage,
              ),
            );
          } else if (messageIndex != -1 && newMessage.senderId == UserManager.uid &&
              chat.messages[messageIndex].status != newMessage.status) {
                debugPrint("........Update firebase message ${newMessage.data} ${newMessage.status}........");
            add(
              FirebaseMessageUpdateEvent(
                chat.id,
                newMessage,
                newMessage.status,
              ),
            );
          }
        } else {
          //debugprint( "Message is already exists: ${docChange.doc.id}: ${docChange.doc.data()!['data']}");
        }
      }
    });
  }

  void _listenForMessageUpdateOfChat(String chatId, List<Message> messages) {
    for (Message message in messages) {
      if (_notValidId(message.id) || message.status == MessageStatus.seen ||
          message.senderId != UserManager.uid) continue;

      _listenForMessageUpdate(chatId, message);
    }
  }

  void _listenForMessageUpdate(String chatId, Message message) {
    if (_notValidId(message.id) || _messageSubscriptions.containsKey(message.id)) return;

    //debugprint("Listening for message: ${message.id}, ${message.data}");
    _messageSubscriptions[message.id] =
        FirestoreHelper.getMessageStreamById(chatId, message.id)
            .listen((event) {
      if (event.data() != null) {
        add(
          FirebaseMessageUpdateEvent(
            chatId,
            message,
            MessageStatus.values.firstWhere(
              (status) => status.name == event.data()!['status'],
            ),
          ),
        );
      }
    });
  }

  bool chatIsInList(String id) {
    bool inList = _chatList.indexWhere((element) => element.id == id) != -1;
    //debugprint("Chat already in list $inList");
    return inList;
  }

  bool _notValidId(String id) {
    return id.length != 20;
  }

  void dispose() {
    //debugprint("Chat: Dispose stream: $_messageListSubscriptions");
    //debugprint("Chat: Dispose messages: $_messageSubscriptions");
    _chatSubscription?.cancel();

    for (String key in _messageListSubscriptions.keys) {
      _messageListSubscriptions[key]?.cancel();
      //debugprint("Chat: Stream cancel of messageList: $key");
    }

    for (String key in _messageSubscriptions.keys) {
      _messageSubscriptions[key]?.cancel();
      //debugprint("Chat: Stream cancel of message: $key");
    }
  }
}

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whatsapp/data/database/tables/message_table.dart';
import 'package:whatsapp/data/database/tables/waiting_message.dart';
import 'package:whatsapp/data/firebase/firestor_collection.dart';
import 'package:whatsapp/data/models/message.dart';
import 'package:whatsapp/utils/enums.dart';

abstract class MessageCallbacks {
  void onMessageSent(String id);
  void onMessageStateUpdate(MessageState? state);
  void onMessageDataUpdate(String data);
  void onMessageDeleted();
}

class MessageHelper {

  MessageHelper({required this.message, this.roomId, required this.messageCallbacks, this.roomIdStream}) {
    
    if(message.state == MessageState.waiting) {
      sendMessage();
    } else if(message.state != MessageState.sending) {
      _listenForUpdates();
    }
  }
  
  String? roomId;
  final Message message;
  final MessageCallbacks messageCallbacks;
  final StreamController<String>? roomIdStream;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final MessageTable _messageTable = MessageTable();
  final WaitingMessageTable _waitingMessageTable = WaitingMessageTable();

  void sendMessage() async {

    if(roomId == null) {
      _listenForRoomId();
      return;
    }
    _waitingMessageTable.insert(message.toMessageTableRow(roomId!));

    message.updateState(MessageState.sending);
    String messageId = (await _firestore.collection(FirestoreCollection.chats)
      .doc(roomId)
      .collection(FirestoreCollection.messages)
      .add(message.toMapWithoutId())).id;
    
    _waitingMessageTable.delete(message.id);
    message.setId(messageId);
    _messageTable.insert(message.toMessageTableRow(roomId!));
    messageCallbacks.onMessageSent(messageId);
    _listenForUpdates();
  }


  void _listenForRoomId() {
    roomIdStream?.stream.listen((roomId) {
      this.roomId = roomId;
      sendMessage();
    });
  }

  void _listenForUpdates() {
    _firestore.collection(FirestoreCollection.chats)
      .doc(roomId)
      .collection(FirestoreCollection.messages)
      .doc(message.id)
      .snapshots()
      .listen(_onUpdate);
  }

  void _onUpdate(messageSnapshot) {
    if(messageSnapshot.data() == null) return;

    Message message = Message.fromFirebaseMap(messageSnapshot.id, messageSnapshot.data()!);
    if(this.message.state != message.state) {
      _updateState(message.state);
    } else if(this.message.data != message.data) {
      messageCallbacks.onMessageDataUpdate(message.data);
    }
  }

  void _updateState(MessageState? state) {
    messageCallbacks.onMessageStateUpdate(state);
    message.updateState(state);
    _messageTable.updateState(message.id, state?.name ?? "null");
  }
}
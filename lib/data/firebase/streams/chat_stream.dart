import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whatsapp/Authentication/firebase_user_manager.dart';
import 'package:whatsapp/data/firebase/firestore_helper.dart';
import 'package:whatsapp/data/models/chat.dart';

class ChatStream {
  
  ChatStream() {
    _firebaseStream.listen(onNewChatStart);
  }

  final _firebaseStream = FirestoreHelper.getChatStream();
  final _controller = StreamController<List<Chat>>();

  List<Chat> _chats = [];

  Stream<List<Chat>> load() {
    _loadFromFirebase();
    return _controller.stream;
  }

  void _loadFromFirebase() {
    FirebaseFirestore.instance.collection('chats').where('users', arrayContains: UserManager.uid).get()
      .then((snapshot) {
        _chats = snapshot.docs.map((chatSnapshot) => Chat.fromFirebaseMap(chatSnapshot.id, chatSnapshot.data())).toList();
        _controller.add(_chats);
        _controller.sink.add(_chats);
      });
  }

  void onNewChatStart(QuerySnapshot<Map<String,dynamic>> chatsSnapshot) {
    _chats = chatsSnapshot.docs.map((chatSnapshot) => Chat.fromFirebaseMap(chatSnapshot.id, chatSnapshot.data())).toList();
    _controller.add(_chats);

  }

  void add(Chat chat) {
    _chats.add(chat);
    _controller.add(_chats);
  }
}
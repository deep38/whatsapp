import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whatsapp/Authentication/firebase_user_manager.dart';

class FirebaseChatStream {
  static Stream<QuerySnapshot<Map<String, dynamic>>> getChatsStream() {
    return FirebaseFirestore.instance.collection('chats').where('users', arrayContains: UserManager.uid).snapshots();
  }
  
  static List<Stream<QuerySnapshot<Map<String, dynamic>>>> getMessageStreams(List<String> chats) {
    List<Stream<QuerySnapshot<Map<String, dynamic>>>> messageStreams = [];
    for(String chatId in chats) {
      messageStreams.add(FirebaseFirestore.instance.collection('chats').doc(chatId).collection('messages').snapshots());
    }

    return messageStreams;
  }
}
import 'package:whatsapp/data/database/table_helper.dart';
import 'package:whatsapp/data/models/chat.dart';
import 'package:whatsapp/data/models/message.dart';

abstract class ChatCallbacks {
  void onNewChatAdded(Chat chat);
  void onNewMessageReceive(Message message);
}

class ChatHelper {
  final TableHelper _tableHelper = TableHelper();
  
  
}
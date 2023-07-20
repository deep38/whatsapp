import 'package:equatable/equatable.dart';
import 'package:whatsapp/data/models/chat.dart';
import 'package:whatsapp/data/models/message.dart';
import 'package:whatsapp/utils/enums.dart';

abstract class ChattingEvent extends Equatable {}

class LoadChatsEvent extends ChattingEvent {
  @override
  List<Object?> get props => [];
}

class NewLocalChatEvent extends ChattingEvent {
  final Chat chat;
  final Message firstMessage;

  NewLocalChatEvent(this.chat, this.firstMessage);

  @override
  List<Object?> get props => [chat, firstMessage];
}

class NewFirebaseChatEvent extends ChattingEvent {
  final String id;

  NewFirebaseChatEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class NewLocalMessageEvent extends ChattingEvent {
  final String chatId;
  final Message message;

  NewLocalMessageEvent(this.chatId, this.message);
  
  @override
  List<Object?> get props => [chatId, message];
}

class NewFirebaseMessageEvent extends ChattingEvent {
  final String chatId;
  final Message message;

  NewFirebaseMessageEvent(this.chatId, this.message);
  
  @override
  List<Object?> get props => [chatId, message];
}

class LocalMessageUpdateEvent extends ChattingEvent {
  final String chatId;
  final String messageId;
  final MessageStatus status;

  LocalMessageUpdateEvent(this.chatId, this.messageId, this.status);

  @override
  List<Object?> get props => [chatId, messageId, status];
}

class FirebaseMessageUpdateEvent extends ChattingEvent {
  final String chatId;
  final String messageId;
  final MessageStatus status;

  FirebaseMessageUpdateEvent(this.chatId, this.messageId, this.status);

  @override
  List<Object?> get props => [chatId, messageId, status]; 
}
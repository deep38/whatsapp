import 'package:equatable/equatable.dart';
import 'package:whatsapp/data/models/chat.dart';
import 'package:whatsapp/data/models/message.dart';
import 'package:whatsapp/utils/enums.dart';

abstract class ChattingState extends Equatable {}

class ChatsLoadingState extends ChattingState {
  @override
  List<Object?> get props => [];
}

class ChatsLoadedState extends ChattingState {
  final List<Chat> chatList;

  ChatsLoadedState(this.chatList);

    @override
  List<Object?> get props => [chatList];
}

class ChatsLoadFailedState extends ChattingState {
  final String error;

  ChatsLoadFailedState(this.error);
  
    @override
  List<Object?> get props => [error];
}

class NewChatState extends ChattingState {
  final Chat chat;
  final int? currentIndex;

  NewChatState(this.chat, [this.currentIndex]);

  @override
  List<Object?> get props => [chat];


  @override
  int get hashCode => chat.id.hashCode ^ chat.type.hashCode;
  
  @override
  bool operator ==(covariant Object other) {
    if (other is ! NewChatState) return false;

    if(identical(other, this)) return true;

    return other.chat.id == chat.id && other.chat.type == chat.type;
  }
}

class NewMessageState extends ChattingState {
  final String chatId;
  final Message message;

  NewMessageState(this.chatId, this.message);

  @override
  List<Object?> get props => [chatId, message];
}

class MessageStatusUpdateState extends ChattingState {
  final String messageId;
  final MessageStatus status;

  MessageStatusUpdateState(this.messageId, this.status);

  @override
  List<Object?> get props => [messageId, status];
}
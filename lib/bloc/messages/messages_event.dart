part of 'messages_bloc.dart';

abstract class MessagesEvent extends Equatable {}

class LoadMessagesEvent extends MessagesEvent {
  
  @override
  List<Object> get props => [];
}

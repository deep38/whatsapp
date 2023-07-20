part of 'messages_bloc.dart';

abstract class MessagesState {}

class MessagesLoadingState extends MessagesState {
  
}

class MessagesLoadedState extends MessagesState {
  
  @override
  List<Object> get props => [];
}

part of 'contacts_bloc.dart';

@immutable
abstract class ContactsEvent extends Equatable {}

class LoadContactsEvent extends ContactsEvent {
  @override
  List<Object?> get props => [];
}
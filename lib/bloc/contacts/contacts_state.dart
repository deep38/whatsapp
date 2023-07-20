part of 'contacts_bloc.dart';

@immutable
abstract class ContactsState extends Equatable{}

class ContactsLoadingState extends ContactsState {
  @override
  List<Object?> get props => [];
}

class ContactsLoadedState extends ContactsState {
  final List<WhatsAppUser> whatsappUsers;
  final List<Contact> otherContacts;

  ContactsLoadedState(this.whatsappUsers, this.otherContacts);

  @override
  List<Object?> get props => [whatsappUsers, otherContacts];
}

class ContactsErrorState extends ContactsState {
  final String error;

  ContactsErrorState(this.error);

  @override
  List<Object?> get props => [];
}

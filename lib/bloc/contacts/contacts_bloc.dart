import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:whatsapp/data/models/user.dart';
import 'package:whatsapp/data/repository/contacts_repository.dart';

part 'contacts_event.dart';
part 'contacts_state.dart';

class ContactsBloc extends Bloc<ContactsEvent, ContactsState> {
  final ContactsRepository _contactsRepository;

  ContactsBloc(this._contactsRepository) : super(ContactsLoadingState()) {
    on<LoadContactsEvent>((event, emit) async {
      debugPrint("Event trigers");
      emit(ContactsLoadingState());
      try {
        final data = await _contactsRepository.loadContacts();
        debugPrint("${data.whatsappUsers} ......... ${data.otherContacts}");
        emit(ContactsLoadedState(data.whatsappUsers, data.otherContacts));

      } on Exception catch(e) {
        emit(ContactsErrorState(e.toString()));
      }
    });
  }
}

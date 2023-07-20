import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whatsapp/Authentication/firebase_user_manager.dart';
import 'package:whatsapp/data/firebase/firestore_helper.dart';
import 'package:whatsapp/data/models/user.dart';

class ContactsRepository {
  Future<({List<WhatsAppUser> whatsappUsers, List<Contact> otherContacts})> loadContacts() async {
    if (!(await Permission.contacts.isGranted)) {
      Map<Permission, PermissionStatus> status =
          await [Permission.contacts].request();
      if (status[Permission.contacts] == PermissionStatus.granted) {
        return _getCommonUsers();
      } else {
        throw Exception("Permission denied");
      }
    } else {
      return _getCommonUsers();
    }
  }

  Future<({List<WhatsAppUser> whatsappUsers, List<Contact> otherContacts})> _getCommonUsers() async {
    debugPrint("Loading contacts....");
    List<Contact> deviceContacts = await ContactsService.getContacts();
    debugPrint("Loaded: $deviceContacts");
    List<String> stringContacts = List.empty(growable: true);
    for(Contact contact in deviceContacts) {
      debugPrint("Iterating contacts: $contact");
      if(contact.phones != null && contact.phones!.isNotEmpty && contact.phones!.first.value != null) {
        final number = _deformatPhoneNumber(contact.phones!.first.value!);
        if(number == UserManager.phoneNumber) continue;

        stringContacts.add(number);
      }
    }
    List<WhatsAppUser> whatsAppUsers =
        await FirestoreHelper.fetchUsersThatInContacts(stringContacts);
    debugPrint("Contacts loaded $whatsAppUsers");
    return (whatsappUsers: whatsAppUsers, otherContacts: deviceContacts);
  }

  String _deformatPhoneNumber(String phoneNo) {

    phoneNo = phoneNo.replaceAll(RegExp(r'\D'), "");
    phoneNo = phoneNo.length == 10 ? "+91$phoneNo" : "+$phoneNo";
    return phoneNo;
  }
}
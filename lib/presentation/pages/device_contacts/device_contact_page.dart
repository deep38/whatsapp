import 'dart:async';

import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whatsapp/data/firebase/firestore_helper.dart';
import 'package:whatsapp/data/models/chat.dart';
import 'package:whatsapp/data/models/user.dart';
import 'package:whatsapp/presentation/pages/conversation/conversation_page.dart';
import 'package:whatsapp/presentation/widgets/profile_photo.dart';
import 'package:whatsapp/utils/mapers/asset_images.dart';

class DeviceContactsPage extends StatelessWidget {
  const DeviceContactsPage({super.key});

  Future<List<WhatsAppUser>?> _loadContacts() async {
    if(!(await Permission.contacts.isGranted)) {
      Map<Permission, PermissionStatus> status = await [Permission.contacts].request();
      if(status[Permission.contacts] == PermissionStatus.granted) {
        
        return _getCommonUsers();
      }
    } else {
      
      return _getCommonUsers();
    }
    return null;
  }

  Future<List<WhatsAppUser>> _getCommonUsers() async {
    List<Contact> deviceContacts = await ContactsService.getContacts();
    List<String> stringContacts = deviceContacts.map((e) => _deformatPhoneNumber((e.phones ?? [])[0].value) ?? "").toList();
    List<WhatsAppUser> whatsAppUsers = await FirestoreHelper.fetchUsersThatInContacts(stringContacts);

    return whatsAppUsers;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder(
        future: _loadContacts(),
        builder: (context, snapshot) => Scaffold(
          appBar: AppBar(title: snapshot.data != null ? Text("${snapshot.data?.length} contacts") : null),
          body: snapshot.connectionState == ConnectionState.waiting
            ? _buildLoadingContacts()
            : snapshot.data == null || snapshot.data!.isEmpty
            ? _buildNoContatctsFound()
            : _buildContactList(snapshot.data!),
        ),
      )
    );
  }

  Widget _buildLoadingContacts() {
    return Container();
  }

  Widget _buildNoContatctsFound() {
    return const Center(
      child: Text("No contacts found"),
    );
  }

  Widget _buildContactList(List<WhatsAppUser> users) {
    return ListView.separated(
        itemCount: users.length,
        separatorBuilder: (context, index) => const SizedBox(),
        itemBuilder: (context, index) => ListTile(
          onTap: () => _openCoversation(context, users[index]),
          leading: ProfilePhoto(
            size: 40,
              placeholder: const AssetImage(AssetImages.default_profile),
              image: NetworkImage(users[index].profileUrl ?? "#"),
              //imageErrorBuilder: (context, error, stackTrace) => Image.asset(AssetImages.default_profile),
            ),
          title: Text(users[index].name ?? users[index].phoneNo),

        )
      );
  }

  void _openCoversation(BuildContext context, WhatsAppUser user) async {
    Navigator.pop(context, await Navigator.push(context, MaterialPageRoute(builder: (context)=> ConversationPage(user: user))));
  }

  String? _deformatPhoneNumber(String? phoneNo) {
    if(phoneNo == null) return null;

    phoneNo = phoneNo.replaceAll(RegExp(r'\D'), "");
    phoneNo = phoneNo.length == 10 ? "+91$phoneNo" : "+$phoneNo";
    return phoneNo;
  }
}

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/data/database/tables/users_table.dart';
import 'package:whatsapp/data/helpers/firebase_storage_helper.dart';
import 'package:whatsapp/data/models/user.dart';

// FirebaseAuth.instance.currentUser;
class UserManager {
  static final _firestoreUserCollection = FirebaseFirestore.instance.collection('users');
  static final _userTable = UserTable();

  static WhatsAppUser? whatsAppUser;

  static Future<void> initWhatsAppUser() async {
    final localUserData = await _userTable.getById(uid!);
    if(localUserData.isNotEmpty) {
      whatsAppUser = WhatsAppUser.fromMap(localUserData.first);
      debugPrint("Local user found: $whatsAppUser");
      return;
    }

    final availabelUser = (await _firestoreUserCollection.doc(uid).get());
    if(availabelUser.data() != null) {
      whatsAppUser = WhatsAppUser.fromMap(availabelUser.data()!);
      await _userTable.insert(whatsAppUser!.toTableRow());
    }
  }

  static User? get user => FirebaseAuth.instance.currentUser;

  
  static bool get isLoggedIn => user != null;

  static Future<void> createUser(Uint8List? profileImage, String name) async {
    if(user != null) {
      final profilePhotoUrl = profileImage != null ? await FirebaseStorageHelper.addProfilePhoto(profileImage) : null;
      
      await user?.updateDisplayName(name);
      await user?.updatePhotoURL(profilePhotoUrl);
      
      final availabelUser = (await _firestoreUserCollection.doc(uid).get());
      
      if(availabelUser.data() != null) {
        whatsAppUser = WhatsAppUser.fromMap(availabelUser.data()!);
        whatsAppUser!.name = name;
        whatsAppUser!.photoUrl = profilePhotoUrl;
        await _firestoreUserCollection.doc(uid).set({"name": name, "photoUrl": profilePhotoUrl}, SetOptions(merge: true));
      } else {
        whatsAppUser = WhatsAppUser.fromFiebaseUser(user!);
        await _firestoreUserCollection.doc(uid).set(whatsAppUser!.toMap());
      }
      await _userTable.insert(whatsAppUser!.toTableRow());
    } else {
      throw Exception("User not logged in");
    }
  }

  static Future<String?> setDisplayName(String name) async {
    if(user != null) {
      whatsAppUser?.name = name;
      await _userTable.updateName(uid!, name);
      await user?.updateDisplayName(name);
      await _firestoreUserCollection.doc(uid).set({"name": name}, SetOptions(merge: true));
      return null;
    } else {
      return "User not logged in";
    }
  }

  static Future<String?> setPhotoUrl(String url) async {
    if(user != null) {
      whatsAppUser?.photoUrl = url;
      await _userTable.updatePhotoUrl(uid!, url);
      await user?.updatePhotoURL(url);
      await _firestoreUserCollection.doc(uid).set({"photoUrl": url}, SetOptions(merge: true));
      return null;
    } else {
      return "User not logged in";
    }
  }

  static Future<String?> setAbout(String about) async {
    if(user != null) {
      whatsAppUser?.about = about;
      await _userTable.updateAbout(uid!, about);
      await _firestoreUserCollection.doc(uid).set({"about": about}, SetOptions(merge: true));
      return null;
    } else {
      return "User not logged in";
    }
  }

  static String? get uid => user?.uid;

  static String? get displayName => user?.displayName;

  static String? get phoneNumber => user?.phoneNumber;

  static String? get photoURL => user?.photoURL;
}
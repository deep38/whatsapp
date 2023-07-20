
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:whatsapp/data/models/user.dart';

// FirebaseAuth.instance.currentUser;
class UserManager {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  static User? get user => FirebaseAuth.instance.currentUser;
  
  static bool get isLoggedIn => user != null;

  static Future<void> createUser(Uint8List? profileImage, String name) async {
    if(user != null) {
      final profilePhotoUrl = profileImage != null ? await(await FirebaseStorage.instance.ref("profileimages/$phoneNumber").putData(profileImage)).ref.getDownloadURL() : null;
      await user?.updateDisplayName(name);
      await user?.updatePhotoURL(profilePhotoUrl);
      final availabelUser = (await _firestore.collection("users").where('phoneNo', isEqualTo: phoneNumber).get()).docs;
      if(availabelUser.isNotEmpty) {
        await _firestore.collection("users").doc(availabelUser.first.id).set(WhatsAppUser.fromFiebaseUser(user!).toMap(), SetOptions(merge: true));
      } else {
        await _firestore.collection("users").add(WhatsAppUser.fromFiebaseUser(user!).toMap());
      }
    } else {
      throw Exception("User not logged in");
    }
  }

  static Future<String?> setDisplayName(String name) async {
    if(user != null) {
      await user?.updateDisplayName(name);
      return null;
    } else {
      return "User not logged in";
    }
  }

  static Future<String?> setPhotoUrl(String url) async {
    if(user != null) {
      await user?.updatePhotoURL(url);
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
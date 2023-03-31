
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:whatsapp/data/models/user.dart';

// FirebaseAuth.instance.currentUser;
class UserManager {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  static User? get user => FirebaseAuth.instance.currentUser;
  
  static bool get isLoggedIn => user != null;

  static Future<String?> createUser(String name) async {
    if(user != null) {
      await user?.updateDisplayName(name);
      await _firestore.collection("users").doc(user!.phoneNumber).set(WhatsAppUser.fromFiebaseUser(user!).toMap());
      return null;
    } else {
      return "User not logged in";
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

  static String? get photoURL => user?.photoURL;
}
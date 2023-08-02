import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:whatsapp/Authentication/firebase_user_manager.dart';

class FirebaseStorageHelper {
  static Future<String> addProfilePhoto(Uint8List image) async {
    return await(await FirebaseStorage.instance.ref("profileimages/${UserManager.phoneNumber}").putData(image)).ref.getDownloadURL();
  }
}
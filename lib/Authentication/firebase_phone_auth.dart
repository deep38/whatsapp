import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirebasePhoneAuth {
  Function()? _onCodeSent;
  Function()? _onSuccess;
  Function(String?)? _onFailed;

  late String _verificationId;
  
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void login(String phoneNo, Function() onCodeSent) async {
    debugPrint("Try to login");
    _onCodeSent = onCodeSent;
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNo,
      verificationCompleted: _signIn,
      verificationFailed: _onVerificationFailed,
      codeSent: _codeSent,
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  void verifySMSCode(String smsCode, Function() onSuccess, Function(String?) onFailed) async {
    _onSuccess = onSuccess;
    _onFailed = onFailed;
    _firebaseAuth.authStateChanges().listen(_onAuthStateChanges);
    debugPrint("Try to signing in with vId $_verificationId sms: $smsCode");
    _signIn(PhoneAuthProvider.credential(verificationId: _verificationId, smsCode: smsCode));
  }

  void _signIn(PhoneAuthCredential credential) async {
    await _firebaseAuth.signInWithCredential(credential);
  }

  void _codeSent(String verificationId, int? resendToken) {
    _verificationId = verificationId;
    debugPrint("Code sent successfully $_verificationId");
    _onCodeSent?.call();
  }

  void _onVerificationFailed(FirebaseAuthException e) {
    _onFailed?.call(e.message);
  }

  void _onAuthStateChanges(User? user) {
    debugPrint("Auth states changes");
    if (user != null) {
      _onSuccess?.call();
      debugPrint("Login successfully");
    }
  }

  
}
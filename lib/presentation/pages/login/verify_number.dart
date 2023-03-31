import 'package:flutter/material.dart';
import 'package:whatsapp/Authentication/firebase_phone_auth.dart';
import 'package:whatsapp/presentation/pages/login/add_profile_info_page.dart';
import 'package:whatsapp/presentation/widgets/login_scaffold.dart';
import 'package:whatsapp/presentation/widgets/otp_field.dart';
import 'package:whatsapp/presentation/widgets/processing_dialog.dart';
import 'package:whatsapp/utils/global.dart';

class VerifyNumberPage extends StatefulWidget {
  final String phoneNumber;


  const VerifyNumberPage({super.key, required this.phoneNumber});

  @override
  State<VerifyNumberPage> createState() => _VerifyNumberPageState();
}

class _VerifyNumberPageState extends State<VerifyNumberPage> {
  final FirebasePhoneAuth _firebasePhoneAuth = FirebasePhoneAuth();

  @override
  void initState() {
    super.initState();
    // _requestForOtp();
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LoginScaffold(
        title: "Verifying your number",
        description: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: "Waiting to automatically detect an SMS to ",
            style: Theme.of(context).textTheme.bodyMedium,
            children: [
              TextSpan(
                text: widget.phoneNumber,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const TextSpan(
                text: ". "
              ),
              TextSpan(
                text: "Wrong number?",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.blue,
                )
              )
            ]
          ),
        ),
        body: TextField(
          maxLength: 6,
          keyboardType: TextInputType.number,
          onChanged: _onOtpChange,
        ),
        // body: OtpField(
        //   onFilled: (otp) => _verifyOtp(context, otp),
        // ),
        hint: "Enter 6-digit code",
        footer: TextButton(
          onPressed: _requestForOtp,
          child: Text(
            "Did not receive code?",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 14
            ),
          ),
        ),
      )
    );
  }

  void _onOtpChange(String otp) {
    debugPrint("Otp changes to length ${otp.length}: $otp");
    if(otp.length == 6) {
      _verifyOtp(context, otp);
    }
  }

  void _verifyOtp(BuildContext context, String otp) {
    debugPrint(otp);
    _showVerifyingDialog();
    _firebasePhoneAuth.verifySMSCode(
      otp,
      () => Navigator.push(context, MaterialPageRoute(
        builder: (context) => AddProfileInfoPage()
        )
      ),
      (error) {
        Navigator.pop(context);
        showSnackBar(context, error);
      }
    );
  }

  void _requestForOtp() {
    _firebasePhoneAuth.login(widget.phoneNumber, () => Navigator.pop(context));
    showDialog(
      context: context,
      builder: (context) => const ProcessingDialog(message: "Requesting an SMS...")
    );
  }

  void _showVerifyingDialog() {
    showDialog(
      context: context,
      builder: (context) => const ProcessingDialog(message: "Verifynig...")
    );
  }
}
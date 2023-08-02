import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:whatsapp/Authentication/firebase_phone_auth.dart';
import 'package:whatsapp/presentation/pages/login/verify_number.dart';
import 'package:whatsapp/presentation/widgets/login_scaffold.dart';
import 'package:whatsapp/presentation/widgets/processing_dialog.dart';
import 'package:whatsapp/presentation/widgets/whatsapp_elevated_button.dart';
import 'package:whatsapp/utils/global.dart';

class EnterPhoneNumberPage extends StatefulWidget {
  const EnterPhoneNumberPage({super.key});

  @override
  State<EnterPhoneNumberPage> createState() => _EnterPhoneNumberPageState();
}

class _EnterPhoneNumberPageState extends State<EnterPhoneNumberPage> {
  final TextEditingController _countryCodeFieldController =
      TextEditingController(text: "91");
  final TextEditingController _phoneNumberFieldController =
      TextEditingController();

  final ValueNotifier<bool> _validPhoneNumberNotifier = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LoginScaffold(
        title: "Enter your phone number",
        description: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
                text: "WhatsApp need to verify your phone number. ",
                style: Theme.of(context).textTheme.bodyMedium,
                children: [
                  TextSpan(
                      text: "What's my number?",
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.blue),
                      recognizer: TapGestureRecognizer()..onTap = () {})
                ])),
        body: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 70,
              child: TextField(
                controller: _countryCodeFieldController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.end,
                textInputAction: TextInputAction.next,
                maxLength: 3,
                enableSuggestions: false,
                decoration: InputDecoration(
                  prefixText: "+",
                  prefixStyle: Theme.of(context).textTheme.bodySmall,
                  counterText: "",
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 1)),
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            SizedBox(
              width: (MediaQuery.of(context).size.width * 0.7) - 80,
              child: TextField(
                controller: _phoneNumberFieldController,
                inputFormatters: [SpaceFormatter()],
                autofocus: true,
                onChanged: _validate,
                keyboardType: TextInputType.phone,
                maxLength: 11,
                decoration: InputDecoration(
                  hintText: "Phone number",
                  counterText: "",
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 1)),
                ),
              ),
            )
          ],
        ),
        hint: "Carrier charges may apply",
        bottom: ValueListenableBuilder(
          valueListenable: _validPhoneNumberNotifier,
          builder: (context, isValid, child) => WhatsAppElevatedButton(
            width: 90,
            onPressed: isValid ? _connectAndVerify : null,
            child: const Text("NEXT"),
          ),
        ),
      ),
    );
  }

  void _validate(String phoneNo) {
    _validPhoneNumberNotifier.value = phoneNo.length == 11;
  }

  void _connectAndVerify() {
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pop(context);
      _showNumberConfirmationDialog();
    });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const ProcessingDialog(message: "Connecting..."),
    );
  }

  void _showNumberConfirmationDialog() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "You entered the phone number:",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    "+${_countryCodeFieldController.text} ${_phoneNumberFieldController.text}",
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Is this OK, or would you like to edit the number?",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("EDIT")),
                TextButton(
                    onPressed: () {
                      popAndPush(
                        context,
                        VerifyNumberPage(
                          phoneNumber:
                              "+${_countryCodeFieldController.text} ${_phoneNumberFieldController.text}",
                        ),
                      );
                    },
                    child: const Text("OK"))
              ],
            ));
  }
}

class SpaceFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String formattedText = newValue.text.replaceAll(" ", "");
    int baseOffset = newValue.selection.baseOffset;
    debugPrint("$baseOffset");

    if (formattedText.length > 5) {
      formattedText =
          "${formattedText.substring(0, 5)} ${formattedText.substring(5)}";
    }

    if (baseOffset == 6) {
      if (newValue.text.length > oldValue.text.length) {
        baseOffset++;
      } else {
        baseOffset--;
      }
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.fromPosition(
        TextPosition(
          offset: baseOffset,
        ),
      ),
    );
  }
}

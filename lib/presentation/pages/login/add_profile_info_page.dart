import 'package:flutter/material.dart';
import 'package:whatsapp/Authentication/firebase_user_manager.dart';
import 'package:whatsapp/packages/whatsapp_icons/lib/whatsapp_icons.dart';
import 'package:whatsapp/presentation/pages/home/home.dart';
import 'package:whatsapp/presentation/widgets/login_scaffold.dart';
import 'package:whatsapp/presentation/widgets/processing_dialog.dart';
import 'package:whatsapp/presentation/widgets/whatsapp_elevated_button.dart';
import 'package:whatsapp/utils/global.dart';
import 'package:whatsapp/utils/mapers/asset_images.dart';

class AddProfileInfoPage extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _nameFieldController = TextEditingController();

  final UserManager _userManager = UserManager();

  AddProfileInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LoginScaffold(
        title: "Profile info",
        description: Text(
          "Please provide your name and an optional profile photo",
          style: Theme.of(context).textTheme.bodySmall,
        ),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () {
                
              },
              borderRadius: BorderRadius.circular(70),
              child: const CircleAvatar(
                radius: 70,
                backgroundColor: Colors.grey,
                backgroundImage: AssetImage(
                  AssetImages.add_a_photo,
                ),
              ),
            ),
            const SizedBox(
              height: 14,
            ),
            Row(
              children: [
                Form(
                  key: _formKey,
                  child: Expanded(
                    child: TextFormField(
                      controller: _nameFieldController,
                      validator: _nameValidator,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        suffixText: "25",
                        errorStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.red
                        ),
                        focusedErrorBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.red,
                            width: 2
                          ),
                        ),
                        errorBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.red,
                            width: 1
                          ),
                          
                        )
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    WhatsAppIcons.emoji
                  )
                )
              ],
            )
          ],
        ),
        bottom: WhatsAppElevatedButton(
          borderRadius: 50,
          onPressed: () => _onNext(context),
          child: const Text(
            "Next"
          ),
        ),
      ),
    );
  }

  void _onNext(BuildContext context) {
    if(_formKey.currentState?.validate() ?? false) {
      showDialog(context: context, builder: (context) => const ProcessingDialog(message: "Initializing"));
      UserManager.createUser(_nameFieldController.text).then(
        (value){
          Navigator.pop(context);
          if(value != null) {
            showSnackBar(context, value);
          } else {
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const Home()), (route) => false);
          }
        }
      );
    }
  }

  String? _nameValidator(String? value) {
    if(value == null || value.isEmpty) return "Please enter your name";
    return null;
  }
}
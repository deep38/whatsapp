import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whatsapp/Authentication/firebase_user_manager.dart';
import 'package:whatsapp/data/helpers/image_picker_helper.dart';
import 'package:whatsapp/packages/whatsapp_icons/lib/whatsapp_icons.dart';
import 'package:whatsapp/presentation/pages/home/home.dart';
import 'package:whatsapp/presentation/widgets/login_scaffold.dart';
import 'package:whatsapp/presentation/widgets/name_text_field.dart';
import 'package:whatsapp/presentation/widgets/processing_dialog.dart';
import 'package:whatsapp/presentation/widgets/whatsapp_elevated_button.dart';
import 'package:whatsapp/utils/global.dart';
import 'package:whatsapp/utils/mapers/asset_images.dart';

class AddProfileInfoPage extends StatefulWidget {
  const AddProfileInfoPage({super.key});

  @override
  State<AddProfileInfoPage> createState() => _AddProfileInfoPageState();
}

class _AddProfileInfoPageState extends State<AddProfileInfoPage> {
  // final GlobalKey<FormState> _formKey = GlobalKey();

  final TextEditingController _nameFieldController = TextEditingController();

  final ValueNotifier<bool> _nameValidationChangeNotifier = ValueNotifier(false);
  final ValueNotifier<Uint8List?> _imageFileChangeNotifier =
      ValueNotifier(null);

  final UserManager _userManager = UserManager();

  @override
  void dispose() {
    _nameFieldController.dispose();
    _nameValidationChangeNotifier.dispose();
    super.dispose();
  }

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
                onTap: _selectImageFromGallery,
                borderRadius: BorderRadius.circular(70),
                child: ValueListenableBuilder(
                  valueListenable: _imageFileChangeNotifier,
                  builder: (context, value, child) => CircleAvatar(
                    radius: 70,
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundImage: _getForegroundImage(value),
                  ),
                )),
            const SizedBox(
              height: 14,
            ),
            WhatsAppTextField(
              controller: _nameFieldController,
              onValidationChange: (isValid) => _nameValidationChangeNotifier.value = isValid,
            ),
          ],
        ),
        bottom: ValueListenableBuilder(
          valueListenable: _nameValidationChangeNotifier,
          builder: (context, value, child) {
            return WhatsAppElevatedButton(
              borderRadius: 50,
              // width: 150,
              onPressed: value ? () => _onNext(context) : null,
              child: const Text("Next"),
            );
          },
        ),
      ),
    );
  }

  ImageProvider _getForegroundImage(Uint8List? bytes) {
    if (bytes != null) {
      return MemoryImage(bytes);
    } else {
      return const AssetImage(AssetImages.add_a_photo);
    }
  }

  void _selectImageFromGallery() {
    ImagePickerHelper.selectImageFromGallery(context)
    .then((value) {
      if(value != null) {
        _imageFileChangeNotifier.value = value;
      }
    })
    .catchError((err) {
      showSnackBar(context, err);
    }
    );
  }
  
  void _onNext(BuildContext context) {
    // if(_formKey.currentState?.validate() ?? false) {
    showDialog(
        context: context,
        builder: (context) => const ProcessingDialog(message: "Initializing"));
      
    UserManager.createUser(_imageFileChangeNotifier.value, _nameFieldController.text)
    .then((value) {
      Navigator.pop(context);
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Home()),
            (route) => false);
    })
    .catchError((e) {
        showSnackBar(context, e.toString());
    });
    // }
  }

  String? _nameValidator(String? value) {
    if (value == null || value.isEmpty) return "Please enter your name";
    return null;
  }
}

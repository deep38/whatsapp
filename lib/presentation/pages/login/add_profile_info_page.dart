import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whatsapp/Authentication/firebase_user_manager.dart';
import 'package:whatsapp/packages/whatsapp_icons/lib/whatsapp_icons.dart';
import 'package:whatsapp/presentation/pages/home/home.dart';
import 'package:whatsapp/presentation/widgets/login_scaffold.dart';
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

  final ValueNotifier<int> _nameLengthChangeNotifier = ValueNotifier(0);
  final ValueNotifier<Uint8List?> _imageFileChangeNotifier =
      ValueNotifier(null);

  final UserManager _userManager = UserManager();

  @override
  void dispose() {
    _nameFieldController.dispose();
    _nameLengthChangeNotifier.dispose();
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
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _nameFieldController,
                    validator: _nameValidator,
                    // autovalidateMode: AutovalidateMode.onUserInteraction,
                    onChanged: (value) =>
                        _nameLengthChangeNotifier.value = value.length,
                    textCapitalization: TextCapitalization.words,
                    maxLength: 25,
                    decoration: InputDecoration(
                        counter: ValueListenableBuilder(
                          valueListenable: _nameLengthChangeNotifier,
                          builder: (context, value, child) {
                            return Transform.translate(
                              child: Text(
                                "${25 - value}",
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              offset: const Offset(0, -30),
                            );
                          },
                        ),
                        errorStyle: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.red),
                        focusedErrorBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.red, width: 2),
                        ),
                        errorBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.red, width: 1),
                        )),
                  ),
                ),
                IconButton(
                    onPressed: () {}, icon: const Icon(WhatsAppIcons.emoji))
              ],
            )
          ],
        ),
        bottom: ValueListenableBuilder(
          valueListenable: _nameLengthChangeNotifier,
          builder: (context, value, child) {
            return WhatsAppElevatedButton(
              borderRadius: 50,
              onPressed: value > 0 ? () => _onNext(context) : null,
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

  Future<void> _selectImageFromGallery() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      _cropAndCompressImage(File(pickedImage.path));
    } else {
      showSnackBar(context, "No image selected");
    }
  }

  Future<void> _cropAndCompressImage(File image) async {
    _imageFileChangeNotifier.value = await (await ImageCropper().cropImage(
      sourcePath: image.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 80,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Theme.of(context).colorScheme.surface,
          toolbarWidgetColor: Theme.of(context).colorScheme.onSurface,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
        ),
      ]
    ))?.readAsBytes();
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

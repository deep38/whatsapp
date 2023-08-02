import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whatsapp/Authentication/firebase_user_manager.dart';
import 'package:whatsapp/data/helpers/firebase_storage_helper.dart';
import 'package:whatsapp/data/helpers/image_picker_helper.dart';
import 'package:whatsapp/data/models/user.dart';
import 'package:whatsapp/packages/whatsapp_icons/lib/whatsapp_icons.dart';
import 'package:whatsapp/presentation/pages/profile/profile_photo/profile_photo_page.dart';
import 'package:whatsapp/presentation/widgets/edit_info_bottom_sheet.dart';
import 'package:whatsapp/presentation/widgets/name_text_field.dart';
import 'package:whatsapp/presentation/widgets/profile_photo.dart';
import 'package:whatsapp/utils/global.dart';
import 'package:whatsapp/utils/mapers/asset_images.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.user});

  final WhatsAppUser user;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ValueNotifier<Uint8List?> _imageFileChangeNotifier =
      ValueNotifier(null);
  final ValueNotifier<bool> _nameFieldValidationNotifier = ValueNotifier(true);
  final ValueNotifier<bool> _aboutFieldValidationNotifier = ValueNotifier(true);
  late final ValueNotifier<String> _nameChangeNotifier =
      ValueNotifier(widget.user.name ?? "UNKNOWN");
  late final ValueNotifier<String> _aboutChangeNotifier =
      ValueNotifier(widget.user.about);

  late final TextEditingController _nameFieldController =
      TextEditingController(text: widget.user.name);
  late final TextEditingController _aboutFieldController =
      TextEditingController(text: widget.user.about);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Profile"),
          systemOverlayStyle: systemUiOverlayStyle(themeMode),
        ),
        body: Column(
          children: [
            SizedBox(
              height: 24,
              width: MediaQuery.of(context).size.width,
            ),
            Hero(
              tag: widget.user.phoneNo,
              child: ValueListenableBuilder(
                valueListenable: _imageFileChangeNotifier,
                builder: (context, value, child) => ProfilePhoto(
                  onTap: _openFullPhoto,
                  showLoading: value != null,
                  placeholderPath: AssetImages.default_profile,
                  imageUrl: widget.user.photoUrl ?? "",
                  size: 150,
                  indicator: Container(
                    decoration: const BoxDecoration(
                      color: Colors.teal,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        WhatsAppIcons.camera_fill,
                        color: Colors.white,
                      ),
                      onPressed: _onChangePhoto,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            _buildTile(
              context: context,
              iconData: WhatsAppIcons.person,
              label: "Name",
              titleListnable: _nameChangeNotifier,
              subtitle: 'This is not your username or pin. This name will be'
                  'visible to your WhatsApp contacts.',
              onTap: _onEditName,
              isThreeLine: true,
            ),
            _divider(),
            _buildTile(
              context: context,
              iconData: Icons.info_outline_rounded,
              label: "About",
              titleListnable: _aboutChangeNotifier,
              onTap: _onEditAbout,
            ),
            _divider(),
            _buildTile(
              context: context,
              iconData: WhatsAppIcons.call,
              label: "Phone",
              title: widget.user.phoneNo,
              onTap: _onChangePhoneNo,
              showTrailing: false,
            ),
          ],
        ),
      ),
    );
  }

  ImageProvider _buildProfileImage(Uint8List? value) {
    if (value == null) {
      return NetworkImage(widget.user.photoUrl ?? "#");
    } else {
      return MemoryImage(value);
    }
  }

  void _openFullPhoto() {
    navigateWithoutTransition(
        context,
        ProfilePhotoPage(
          user: widget.user,
          showMini: false,
        ));
  }

  Divider _divider() {
    return const Divider(
      thickness: 0.1,
      indent: 56,
    );
  }

  ListTile _buildTile(
      {required BuildContext context,
      required IconData iconData,
      required String label,
      String? title,
      ValueNotifier<String>? titleListnable,
      VoidCallback? onTap,
      String? subtitle,
      bool isThreeLine = false,
      bool showTrailing = true}) {
    assert(title != null || titleListnable != null);
    return ListTile(
      onTap: onTap,
      isThreeLine: isThreeLine,
      subtitleTextStyle: Theme.of(context).textTheme.labelMedium,
      titleTextStyle: Theme.of(context).textTheme.bodyMedium,
      leading: Icon(iconData),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          title != null
              ? Text(title)
              : ValueListenableBuilder(
                  valueListenable: titleListnable!,
                  builder: (context, value, child) => Text(value),
                ),
          const SizedBox(
            height: 8,
          ),
        ],
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
            )
          : null,
      trailing: showTrailing
          ? const Icon(
              WhatsAppIcons.edit_pen,
              color: Colors.teal,
            )
          : null,
    );
  }

  void _onChangePhoto() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 8,
            ),
            Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).iconTheme.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Profile photo",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.delete_rounded),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                bottom: 16.0,
              ),
              child: Row(
                children: [
                  _buildPhotoOptionButton(
                      context, WhatsAppIcons.camera_fill, "Camera", () {}),
                  const SizedBox(
                    width: 40,
                  ),
                  _buildPhotoOptionButton(
                    context,
                    WhatsAppIcons.image,
                    "Gallery",
                    _selectImageFromGallery,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Column _buildPhotoOptionButton(BuildContext context, IconData iconData,
      String name, VoidCallback onTap) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context).iconTheme.color ?? Colors.grey,
              width: 0.5,
            ),
          ),
          child: IconButton(
            onPressed: onTap,
            icon: Icon(
              iconData,
              color: Colors.teal,
            ),
          ),
        ),
        Text(name)
      ],
    );
  }

  void _selectImageFromGallery() {
    Navigator.pop(context);
    ImagePickerHelper.selectImageFromGallery(context).then((value) {
      if (value != null) {
        _imageFileChangeNotifier.value = value;
        FirebaseStorageHelper.addProfilePhoto(value).then((value) {
          _imageFileChangeNotifier.value = null;
          if(widget.user.photoUrl == null) {
            widget.user.photoUrl = value;
            UserManager.setPhotoUrl(value);
          }
        });
      }
    }).catchError((err) {
      showSnackBar(context, err);
    });
  }

  void _onEditName() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: ValueListenableBuilder(
          valueListenable: _nameFieldValidationNotifier,
          builder: (context, value, child) => EditInfoBottomSheet(
            onCancel: () => Navigator.pop(context),
            onSave: value ? _changeName : null,
            title: "Enter your name",
            child: WhatsAppTextField(
              controller: _nameFieldController,
              onValidationChange: (isValid) =>
                  _nameFieldValidationNotifier.value = isValid,
            ),
          ),
        ),
      ),
    ).then((value) => _nameFieldController.text = widget.user.name ?? "");
  }

  void _onEditAbout() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      
      builder: (context) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: ValueListenableBuilder(
          valueListenable: _aboutFieldValidationNotifier,
          builder: (context, value, child) => EditInfoBottomSheet(
            onCancel: () => Navigator.pop(context),
            onSave: value ? _changeAbout : null,
            title: "Add About",
            child: WhatsAppTextField(
              maxLength: 139,
              controller: _aboutFieldController,
              onValidationChange: (isValid) =>
                  _aboutFieldValidationNotifier.value = isValid,
            ),
          ),
        ),
      ),
    ).then((value) => _aboutFieldController.text = widget.user.about);
  }

  void _onChangePhoneNo() {}

  void _changeName() async {
    widget.user.name = _nameFieldController.text;
    _nameChangeNotifier.value = _nameFieldController.text;
    Navigator.pop(context);

    await UserManager.setDisplayName(_nameFieldController.text);
  }

  void _changeAbout() async {
    widget.user.about = _aboutFieldController.text;
    _aboutChangeNotifier.value = _aboutFieldController.text;
    Navigator.pop(context);

    await UserManager.setAbout(_aboutFieldController.text);
  }
}

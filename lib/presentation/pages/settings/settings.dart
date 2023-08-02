import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/Authentication/firebase_user_manager.dart';
import 'package:whatsapp/data/models/user.dart';
import 'package:whatsapp/packages/whatsapp_icons/lib/whatsapp_icons.dart';
import 'package:whatsapp/presentation/pages/profile/profile_page.dart';
import 'package:whatsapp/presentation/pages/settings/sections/chats_settings/chats_settings.dart';
import 'package:whatsapp/presentation/widgets/list_tile.dart';
import 'package:whatsapp/presentation/widgets/profile_photo.dart';
import 'package:whatsapp/utils/global.dart';
import 'package:whatsapp/utils/mapers/asset_images.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

  late final WhatsAppUser _user;
  late final ValueNotifier<String?> _nameChangeNotifier;
  late final ValueNotifier<String> _aboutChangeNotifier;

  @override
  Widget build(BuildContext context) {
    _user = UserManager.whatsAppUser!;

    _nameChangeNotifier = ValueNotifier(_user.name);
    _aboutChangeNotifier = ValueNotifier(_user.about);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Settings"),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              WhatsAppListTile(
                onTap: () => _openProfile(context),
                leading: Hero(
                  tag: _user.phoneNo,
                  child: ProfilePhoto(
                    placeholderPath: AssetImages.default_profile,
                    imageUrl: _user.photoUrl ?? "#",
                  ),
                ),
                title: ValueListenableBuilder(
                  valueListenable: _nameChangeNotifier,
                  builder: (context, value, child) =>
                      Text(value ?? _user.phoneNo),
                ),
                subtitle: ValueListenableBuilder(
                  valueListenable: _aboutChangeNotifier,
                  builder: (context, value, child) => Text(value),
                ),
              ),
              const Divider(
                thickness: 0.1,
                height: 0.1,
              ),
              _buildTile(
                context,
                Icons.key_rounded,
                "Account",
                "Security notificatios, change number",
                () => navigateTo(
                  context,
                  const ChatsSettings(),
                ),
              ),
              _buildTile(
                context,
                WhatsAppIcons.lock,
                "Privacy",
                "Block contacts, disappearing messages",
                () => navigateTo(
                  context,
                  const ChatsSettings(),
                ),
              ),
              _buildTile(
                context,
                WhatsAppIcons.message,
                "Chats",
                "Theme, wallpapers, chat history",
                () => navigateTo(
                  context,
                  const ChatsSettings(),
                ),
              ),
              _buildTile(
                context,
                WhatsAppIcons.notification_bell,
                "Notifications",
                "Message, group & call tones",
                () => navigateTo(
                  context,
                  const ChatsSettings(),
                ),
              ),
              _buildTile(
                context,
                Icons.data_usage,
                "Storage and data",
                "Network usage, auto-download",
                () => navigateTo(
                  context,
                  const ChatsSettings(),
                ),
              ),
              _buildTile(
                context,
                Icons.language,
                "App language",
                "English (phone's language)",
                () => navigateTo(
                  context,
                  const ChatsSettings(),
                ),
              ),
              _buildTile(
                context,
                WhatsAppIcons.help,
                "Help",
                "Help center, contact us, privacy policy",
                () => navigateTo(
                  context,
                  const ChatsSettings(),
                ),
              ),
              _buildTile(
                context,
                WhatsAppIcons.group,
                "Invite a friend",
                null,
                () => navigateTo(
                  context,
                  const ChatsSettings(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ListTile _buildTile(
    BuildContext context,
    IconData icon,
    String title, [
    String? subtitle,
    VoidCallback? onTap,
  ]) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.grey,
      ),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      onTap: onTap,
    );
  }

  void _openProfile(BuildContext context) {
    navigateTo(context, ProfilePage(user: _user)).then(
      (value) {
        debugPrint("BACK to settings $_user");
        _nameChangeNotifier.value = _user.name;
        _aboutChangeNotifier.value = _user.about;
      },
    );
  }
}

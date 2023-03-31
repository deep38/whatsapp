import 'package:flutter/material.dart';
import 'package:whatsapp/packages/whatsapp_icons/lib/whatsapp_icons.dart';
import 'package:whatsapp/presentation/pages/settings/sections/chats_settings/chats_settings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Settings"),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: 1,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(
                      WhatsAppIcons.message,
                      color: Colors.grey,
                    ),
                    title: const Text("Chats"),
                    subtitle: const Text("Theme, wallpapers, chat history"),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatsSettings())),
                  );
                }
              ),
            )
          ],
        ),
      ),
    );
  }
}
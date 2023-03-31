import 'package:flutter/material.dart';
import 'package:whatsapp/main.dart';
import 'package:whatsapp/packages/whatsapp_icons/lib/whatsapp_icons.dart';
import 'package:whatsapp/presentation/widgets/theme_options.dart';
import '../../../../../../utils/global.dart';

class ChatsSettings extends StatelessWidget {
  
  const ChatsSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Chats"),
        ),
    
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16,),
            _title(context, "Display"),
            ListTile(
              leading: Icon(
                WhatsAppIcons.theme,
                color: Theme.of(context).iconTheme.color,
                size: 26,
              ),
              title: const Text("Theme"),
              subtitle: Text(themeMode.name),
              onTap: () => _showChangeThemeDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _title(BuildContext context, String titleText) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      child: Text(
        titleText,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }

  void _showChangeThemeDialog(BuildContext context) {
    ThemeMode selectedThemeMode = themeMode;

    showDialog(
      context: context,
      builder: (context) =>
        AlertDialog(
          title: const Text("Choose theme"),
          actions: [
            TextButton(
              onPressed:() => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => _changeTheme(context, selectedThemeMode),
              child: const Text("Ok")
            ),
          ],
          content: ThemeOptions(
            onOptionChange: (themeMode) => selectedThemeMode = themeMode,
          )
        )
    );
  }

  void _changeTheme(BuildContext context, ThemeMode? themeMode) {
    MyApp.of(context)?.changeTheme(themeMode);
    Navigator.pop(context);
  }
}
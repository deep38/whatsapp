import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:whatsapp/data/models/chat.dart';
import 'package:whatsapp/packages/whatsapp_icons/lib/whatsapp_icons.dart';
import 'package:whatsapp/presentation/pages/home/search_delegate.dart';
import 'package:whatsapp/presentation/theme/colors/colors.dart';
import 'package:whatsapp/presentation/theme/colors/dark_colors.dart';
import 'package:whatsapp/presentation/theme/colors/light_colors.dart';
import 'package:whatsapp/utils/enums.dart';

List<Chat> chats = [];

late Database db;

late ThemeMode themeMode;

SystemUiOverlayStyle systemUiOverlayStyle(ThemeMode themeMode) {
  ThemeColors themeColors =
      themeMode == ThemeMode.dark ? DarkThemeColors() : LightThemeColors();

  return SystemUiOverlayStyle(statusBarColor: themeColors.surface);
}

void showSnackBar(context, message, [SnackBarAction? action]) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message),
    action: action,
  ));
}

String convertTimeToString(int time) {
  TimeOfDay dateTime =
      TimeOfDay.fromDateTime(DateTime.fromMillisecondsSinceEpoch(time));
  final hour = "${dateTime.hourOfPeriod}".padLeft(2, '0');
  final minute = "${dateTime.minute}".padLeft(2, '0');
  return "$hour:$minute ${dateTime.period.name}";
}

Future<T?> navigateTo<T>(
  BuildContext context,
  Widget page,
) async {
  return await Navigator.push<T>(context, CupertinoPageRoute(builder: (context) => page));
}

void navigateWithoutTransition(BuildContext context, Widget page) {
  Navigator.push(
    context,
    PageRouteBuilder(
      opaque: false,
      pageBuilder: (context, _, __) => page,
    ),
  );
}

void popAndPush(BuildContext context, Widget page) {
  Navigator.pop(context);
  Navigator.push(context, CupertinoPageRoute(builder: (context) => page));
}

Icon buildMessageStatusIcon(MessageStatus status) {
  Color iconColor = Colors.grey.shade500;
  IconData icon = WhatsAppIcons.clock_rounded;
  double iconSize = 18;

  (IconData, Color, double) getPropertiesOfIcon(MessageStatus status) =>
      switch (status) {
        (MessageStatus.waiting || MessageStatus.sending) => (
            WhatsAppIcons.clock_rounded,
            iconColor,
            14
          ),
        MessageStatus.sent => (WhatsAppIcons.tick, iconColor, 14),
        MessageStatus.received => (
            WhatsAppIcons.double_tick,
            iconColor,
            iconSize
          ),
        MessageStatus.seen => (
            WhatsAppIcons.double_tick,
            Colors.blue,
            iconSize
          ),
        MessageStatus.failed => (
            WhatsAppIcons.warning_circle_outline,
            Colors.red,
            14
          ),
      };
  (icon, iconColor, iconSize) = getPropertiesOfIcon(status);

  return Icon(
    icon,
    size: iconSize,
    color: iconColor,
  );
}

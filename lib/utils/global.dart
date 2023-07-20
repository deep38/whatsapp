import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:whatsapp/data/models/chat.dart';
import 'package:whatsapp/presentation/pages/home/search_delegate.dart';
import 'package:whatsapp/presentation/theme/colors/colors.dart';
import 'package:whatsapp/presentation/theme/colors/dark_colors.dart';
import 'package:whatsapp/presentation/theme/colors/light_colors.dart';

List<Chat> chats = [];

late Database db;

late ThemeMode themeMode;

SystemUiOverlayStyle systemUiOverlayStyle(ThemeMode themeMode) {
    ThemeColors themeColors = themeMode == ThemeMode.dark ? DarkThemeColors() : LightThemeColors();

  return SystemUiOverlayStyle(
    statusBarColor: themeColors.surface
  );
}


void showSnackBar(context, message, [SnackBarAction? action]){
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      action: action,
    )
  );
}


  String convertTimeToString(int time) {
    TimeOfDay dateTime = TimeOfDay.fromDateTime(DateTime.fromMillisecondsSinceEpoch(time));

    return "${dateTime.hourOfPeriod}:${dateTime.minute} ${dateTime.period.name}";
  }

  void navigateTo(BuildContext context, Widget page) {
    Navigator.push(context, CupertinoPageRoute(builder: (context) => page));
  }

  void popAndPush(BuildContext context, Widget page) {
    Navigator.pop(context);
    Navigator.push(context, CupertinoPageRoute(builder: (context) => page));
  }
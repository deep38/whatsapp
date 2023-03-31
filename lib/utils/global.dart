import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:whatsapp/presentation/pages/home/search_delegate.dart';
import 'package:whatsapp/presentation/theme/colors/colors.dart';
import 'package:whatsapp/presentation/theme/colors/dark_colors.dart';
import 'package:whatsapp/presentation/theme/colors/light_colors.dart';

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
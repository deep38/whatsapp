import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:whatsapp/presentation/theme/colors/colors.dart';

class DarkThemeColors extends ThemeColors {

  @override
  Color get primaryDark => const Color(0xff005c4b);

  // @override
  // Color get canvas => const Color(0xff202c33);

  @override
  Color get canvas => const Color(0xff121b22);

  @override
  Color get surface => const Color(0xff202c33);

  @override
  Color get onSurface => const Color(0xff7d8c97);

  @override
  Color get selectModeSurface => const Color(0xff182229);

  @override
  Color get tabIndicator => const Color(0xff00a884);

  @override
  Color get tabHighlight => const Color(0xff049879);

  @override
  Color get unselectedLableColor => const Color(0xff7d8c97);

  @override
  Color get menuBackground => surface;
  
  @override
  Color get listTile => const Color(0xff121b22);

  @override
  Color get selectedTile => const Color(0xff182229);

  @override
  Color get text => Colors.white;

  @override
  Color get labelText => Colors.white;

  @override
  Color get dialogBackground => surface;

  @override
  Color get shadow => canvas;

  @override
  Color get chatBackground => canvas;

  
  @override
  Color get chatSentBubble => const Color(0xff005c4b);

  @override
  Color get chatReceivedBubble => surface;

  @override
  Color get touchedChatSentBubble => const Color(0xFF063F38);

  @override
  Color get touchedChatReceivedBubble => const Color(0xFF050608);

}
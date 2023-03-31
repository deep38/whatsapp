import 'package:flutter/material.dart';
import 'package:whatsapp/presentation/theme/colors/colors.dart';
import 'package:whatsapp/presentation/theme/colors/dark_colors.dart';
import 'package:whatsapp/presentation/theme/colors/light_colors.dart';

class AppTheme {
  final ThemeColors _themeColors;
  final Brightness _brightness;
  final ThemeMode mode;
  
  // AppTheme.from({});
  AppTheme(this.mode) :
    _themeColors = mode == ThemeMode.dark ? DarkThemeColors() : LightThemeColors(),
    _brightness = mode == ThemeMode.dark ? Brightness.dark : Brightness.light;


  ThemeData data() {

    return ThemeData(

      useMaterial3: true,

      canvasColor: _themeColors.canvas,
      shadowColor: _themeColors.shadow,

      colorScheme: ColorScheme(
        brightness: _brightness,
        primary: _themeColors.primary,
        onPrimary: _themeColors.onPrimary,
        secondary: _themeColors.selectModeSurface,
        onSecondary: _themeColors.selectModeOnSurface,
        error: Colors.transparent,
        onError: _themeColors.fail,
        background: _themeColors.canvas,
        onBackground: _themeColors.text,
        surface: _themeColors.surface,
        onSurface: _themeColors.onSurface
      ),

      extensions: <ThemeExtension>[
        WhatsAppComponents(
          chatScreenBackground: _themeColors.chatBackground,
          chatSentBubbleColor: _themeColors.chatSentBubble,
          chatReceivedBubbleColor: _themeColors.chatReceivedBubble,
          touchedChatSentBubbleColor: _themeColors.touchedChatSentBubble,
          touchedChatReceivedBubbleColor: _themeColors.touchedChatReceivedBubble,
        )
      ],
      
      listTileTheme: ListTileThemeData(
        tileColor: _themeColors.listTile,
        selectedColor: _themeColors.selectedTile,
        
      ),

      dialogTheme: DialogTheme(
        backgroundColor: _themeColors.dialogBackground,
      ),
      
      tabBarTheme: TabBarTheme(
        indicatorColor: _themeColors.tabIndicator,
        labelColor: _themeColors.tabHighlight,
        unselectedLabelColor: _themeColors.unselectedLableColor,
      ),

      iconTheme: IconThemeData(
        color: _themeColors.icon
      ),

      popupMenuTheme: PopupMenuThemeData(
        color: _themeColors.menuBackground,
        surfaceTintColor: _themeColors.menuBackground,
        
        labelTextStyle: MaterialStatePropertyAll(
          TextStyle(
          color: _themeColors.text
        )
        ),
      ),

      radioTheme: RadioThemeData(
        overlayColor: MaterialStatePropertyAll(_themeColors.secondaryText),
      ),

      textTheme: TextTheme(
        bodyLarge: TextStyle(     //* ListTile title
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: _themeColors.text,
        ),

        bodyMedium: TextStyle(     //* Text on normal body
          fontSize: 16,
          color: _themeColors.text,
        ),

        bodySmall: TextStyle(     //* ListTile subtitle
          fontSize: 14,
          color: _themeColors.secondaryText,
          fontWeight: FontWeight.normal
        ),

        labelMedium: TextStyle(
          
          fontSize: 12,
          color: _themeColors.secondaryText,
          fontWeight: FontWeight.normal,
          // color: Colors.red,
        ),

        labelSmall: TextStyle(
          fontSize: 8,
          color: _themeColors.secondaryText,
          // color: Colors.green
        ),
        
        headlineSmall: TextStyle(     //* Dialog title
          color: _themeColors.text,
          fontSize: 18,
        ),

        headlineMedium: TextStyle(
          color: Colors.red
        ),

        displaySmall: TextStyle(
          color: _themeColors.text,
          fontSize: 18,
          // color: Colors.purple
        )
      )
    );
  }
}



class WhatsAppComponents extends ThemeExtension<WhatsAppComponents> {

  WhatsAppComponents({
    this.chatScreenBackground = const Color(0xFFF3E5F5),
    this.chatSentBubbleColor = const Color(0xFFFFFDE7),
    this.chatReceivedBubbleColor = const Color(0xffffffff),
    this.touchedChatSentBubbleColor,
    this.touchedChatReceivedBubbleColor,
  });

  final Color? chatScreenBackground;
  final Color? chatSentBubbleColor;
  final Color? chatReceivedBubbleColor;
  final Color? touchedChatSentBubbleColor;
  final Color? touchedChatReceivedBubbleColor;

  @override
  ThemeExtension<WhatsAppComponents> copyWith({
    Color? chatScreenBackground,
    Color? chatSentBubbleColor,
    Color? chatReceivedBubbleColor,
    Color? touchedChatSentBubbleColor,
    Color? touchedChatReceivedBubbleColor,
  }) {
    return WhatsAppComponents(
      chatScreenBackground: chatScreenBackground ?? this.chatScreenBackground,
      chatSentBubbleColor: chatSentBubbleColor ?? this.chatSentBubbleColor,
      chatReceivedBubbleColor: chatReceivedBubbleColor ?? this.chatReceivedBubbleColor,
      touchedChatSentBubbleColor: touchedChatSentBubbleColor ?? this.touchedChatSentBubbleColor,
      touchedChatReceivedBubbleColor: touchedChatReceivedBubbleColor ?? this.touchedChatReceivedBubbleColor,
    );
  }

  @override
  ThemeExtension<WhatsAppComponents> lerp(covariant ThemeExtension<WhatsAppComponents>? other, double t) {
    if(other is !WhatsAppComponents) {
      return this;
    }
    return WhatsAppComponents(
      chatScreenBackground: Color.lerp(chatScreenBackground, other.chatScreenBackground, t),
      chatSentBubbleColor: Color.lerp(chatSentBubbleColor, other.chatSentBubbleColor, t),
      chatReceivedBubbleColor: Color.lerp(chatReceivedBubbleColor, other.chatReceivedBubbleColor, t),
      touchedChatSentBubbleColor: Color.lerp(touchedChatSentBubbleColor, other.touchedChatSentBubbleColor, t),
      touchedChatReceivedBubbleColor: Color.lerp(touchedChatReceivedBubbleColor, other.touchedChatReceivedBubbleColor, t),
      
    );
  }

}
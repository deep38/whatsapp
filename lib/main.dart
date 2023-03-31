import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp/Authentication/firebase_user_manager.dart';
import 'package:whatsapp/data/database/database_helper.dart';
import 'package:whatsapp/presentation/pages/home/home.dart';
import 'package:whatsapp/presentation/pages/login/welcome_page.dart';
import 'package:whatsapp/presentation/pages/settings/settings.dart';
import 'package:whatsapp/presentation/providers/select_count_provider.dart';
import '../utils/global.dart';
import '../utils/routes.dart';
import 'package:whatsapp/presentation/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  db = await DatabaseHelper().init();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  static MyAppState? of(BuildContext context) {
    return context.findRootAncestorStateOfType<MyAppState>();
  }
  
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void changeTheme(ThemeMode? mode) {
    if(mode != null && mode != _themeMode) {
      _themeMode = mode;
      themeMode = mode;
      setState(() {
        
      });
    }
  }

  @override
  void initState() {
    super.initState();
    themeMode = _themeMode;
  }

  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(
      systemUiOverlayStyle(_themeMode)
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SelectCountProvider()),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: AppTheme(_themeMode).data(),
        home: UserManager.isLoggedIn ? const Home() : const WelcomePage(),

        // initialRoute: ,
        routes: {
          
          Routes.settings:(context) => const SettingsScreen(),
        },
      ),
    );
  }
}
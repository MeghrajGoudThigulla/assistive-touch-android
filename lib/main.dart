import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'screens/language_selection_screen.dart';
import 'screens/customize_panel_screen.dart';
import 'screens/customize_icon_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final hasSelectedLang = prefs.getBool('has_selected_language') ?? false;
  
  runApp(AssistiveTouchApp(hasSelectedLang: hasSelectedLang));
}

class AssistiveTouchApp extends StatelessWidget {
  final bool hasSelectedLang;

  const AssistiveTouchApp({super.key, required this.hasSelectedLang});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Assistive Touch',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent, 
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      initialRoute: hasSelectedLang ? '/home' : '/language',
      routes: {
        '/language': (context) => LanguageSelectionScreen(),
        '/home': (context) => HomeScreen(),
        '/customize_panel': (context) => CustomizePanelScreen(),
        '/customize_icon': (context) => CustomizeIconScreen(),
        '/settings': (context) => SettingsScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

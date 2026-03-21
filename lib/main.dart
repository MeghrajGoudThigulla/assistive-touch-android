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
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0F172A), // Slate 900
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF3B82F6), // Blue 500
          onPrimary: Colors.white,
          surface: Color(0xFF0F172A),
          onSurface: Colors.white,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
          bodySmall: TextStyle(color: Color(0xFF94A3B8)), // Slate 400
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
        ),
      ),
      initialRoute: hasSelectedLang ? '/home' : '/language',
      routes: {
        '/language': (context) => const LanguageSelectionScreen(),
        '/home': (context) => const HomeScreen(),
        '/customize_panel': (context) => const CustomizePanelScreen(),
        '/customize_icon': (context) => const CustomizeIconScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

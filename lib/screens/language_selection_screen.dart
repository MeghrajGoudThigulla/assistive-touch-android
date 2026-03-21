import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/app_scaffold.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String _selectedLanguage = 'System Default';
  
  final List<String> _languages = [
    'System Default',
    'English',
    'Hindi (हिंदी)',
    'Telugu (తెలుగు)',
    'Tamil (தமிழ்)',
    'Bengali (বাংলা)',
    'Marathi (मराठी)',
    'Spanish (Español)',
    'French (Français)',
    'Mandarin (中文)',
    'Arabic (العربية)',
    'German (Deutsch)',
  ];

  Future<void> _saveAndContinue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_selected_language', true);
    await prefs.setString('preferred_language', _selectedLanguage);
    
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Select Language',
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Welcome! Please choose your preferred language to continue.',
              style: TextStyle(fontSize: 16, color: Color(0xFF94A3B8)), // Slate 400
              textAlign: TextAlign.center,
            ),
          ).animate().fade(duration: 400.ms).slideY(begin: 0.2),
          
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _languages.length,
              itemBuilder: (context, index) {
                final lang = _languages[index];
                return RadioListTile<String>(
                  title: Text(lang, style: const TextStyle(fontSize: 16, color: Colors.white)),
                  value: lang,
                  groupValue: _selectedLanguage,
                  onChanged: (val) => setState(() => _selectedLanguage = val!),
                  activeColor: Theme.of(context).colorScheme.primary,
                  contentPadding: EdgeInsets.zero,
                ).animate(delay: (50 * index).ms).fade().slideX(begin: 0.1);
              },
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveAndContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Continue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ).animate().fade(delay: 600.ms).scale(),
            ),
          ),
        ],
      ),
    );
  }
}

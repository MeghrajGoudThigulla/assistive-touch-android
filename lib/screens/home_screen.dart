import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/app_scaffold.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'meghraj.thigulla@gmail.com',
      queryParameters: {'subject': 'Assistive Touch App Feedback'},
    );
    if (!await launchUrl(emailLaunchUri)) {
      debugPrint('Could not launch email client.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Assistive Touch',
      body: Column(
        children: [
          const SizedBox(height: 20),
          _buildNavButton(
            context, 
            'Customize Touch Panel', 
            Icons.grid_view, 
            '/customize_panel',
            100,
          ),
          _buildNavButton(
            context, 
            'Customize App Icon', 
            Icons.touch_app, 
            '/customize_icon',
            200,
          ),
          _buildNavButton(
            context, 
            'Settings', 
            Icons.settings, 
            '/settings',
            300,
          ),
          const Spacer(),
          TextButton(
            onPressed: _launchEmail,
            child: const Text(
              'meghraj.thigulla@gmail.com', 
              style: TextStyle(
                decoration: TextDecoration.underline,
                color: Color(0xFF94A3B8), // Slate 400
              ),
            ),
          ).animate().fade(delay: 500.ms),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildNavButton(BuildContext context, String title, IconData icon, String route, int delayMs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: const Color(0x1AFFFFFF), // Slight 10% white for premium card effect
        leading: Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white)),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
        onTap: () => Navigator.pushNamed(context, route),
      ).animate().fade(delay: delayMs.ms).slideX(begin: -0.1),
    );
  }
}

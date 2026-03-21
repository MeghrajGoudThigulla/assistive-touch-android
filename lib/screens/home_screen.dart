import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@meghraj.com',
      queryParameters: {'subject': 'Assistive Touch App Feedback'},
    );
    if (!await launchUrl(emailLaunchUri)) {
      debugPrint('Could not launch email client.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistive Touch'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          _buildNavButton(
            context, 
            'Customize Panel', 
            Icons.grid_view, 
            '/customize_panel'
          ),
          _buildNavButton(
            context, 
            'Customize Icon', 
            Icons.touch_app, 
            '/customize_icon'
          ),
          _buildNavButton(
            context, 
            'Settings', 
            Icons.settings, 
            '/settings'
          ),
          const Spacer(),
          TextButton(
            onPressed: _launchEmail,
            child: const Text('Contact Support', style: TextStyle(decoration: TextDecoration.underline)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildNavButton(BuildContext context, String title, IconData icon, String route) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: Theme.of(context).colorScheme.secondaryContainer,
        leading: Icon(icon, size: 32, color: Theme.of(context).colorScheme.onSecondaryContainer),
        title: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSecondaryContainer)),
        trailing: Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSecondaryContainer),
        onTap: () => Navigator.pushNamed(context, route),
      ),
    );
  }
}

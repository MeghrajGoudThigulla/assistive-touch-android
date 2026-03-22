import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/app_scaffold.dart';

class PermissionGuidanceScreen extends StatefulWidget {
  const PermissionGuidanceScreen({super.key});

  @override
  State<PermissionGuidanceScreen> createState() => _PermissionGuidanceScreenState();
}

class _PermissionGuidanceScreenState extends State<PermissionGuidanceScreen> {
  Future<void> _grantPermission() async {
    // Phase 2 will wrap this in a MethodChannel call and await result:
    // await OverlayChannel.openOverlaySettings();
    
    // For Phase 1 Flutter UI, we simulate success and set the flag:
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Setup Required',
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          children: [
            const Spacer(),
            const Icon(Icons.layers, size: 80, color: Color(0xFF3B82F6))
                .animate().scale(delay: 200.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 24),
            const Text(
              'Floating Overlay Permission',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ).animate().fade().slideY(begin: 0.1),
            const SizedBox(height: 16),
            const Text(
              'To show the floating touch button across all apps, Assistive Touch needs permission to display over other apps.',
              style: TextStyle(fontSize: 16, color: Color(0xFF94A3B8)),
              textAlign: TextAlign.center,
            ).animate().fade().slideY(begin: 0.1, delay: 100.ms),
            const SizedBox(height: 48),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0x33000000), // Dark translucent background
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0x33FFFFFF)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBulletPoint('Shows the assistive button anywhere.', true),
                  const SizedBox(height: 16),
                  _buildBulletPoint('Does NOT monitor what you type.', false),
                  const SizedBox(height: 16),
                  _buildBulletPoint('Does NOT track your screen content.', false),
                ],
              ),
            ).animate().fade(delay: 300.ms).slideY(begin: 0.1),
            const Spacer(flex: 2),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _grantPermission,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                ),
                child: const Text('Open Settings to Grant', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ).animate().scale(delay: 500.ms),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text, bool isPositive) {
    return Row(
      children: [
        Icon(
          isPositive ? Icons.check_circle : Icons.cancel,
          color: isPositive ? Colors.greenAccent : Colors.redAccent,
          size: 24,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.4)),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/app_scaffold.dart';
import '../services/overlay_channel.dart';

class CustomizeIconScreen extends StatefulWidget {
  const CustomizeIconScreen({super.key});

  @override
  State<CustomizeIconScreen> createState() => _CustomizeIconScreenState();
}

class _CustomizeIconScreenState extends State<CustomizeIconScreen> {
  String _selectedIcon = 'default';
  
  final List<Map<String, dynamic>> _icons = [
    {'id': 'icon_default', 'asset': 'assets/icons/icon_default.png', 'label': 'Minimal'},
    {'id': 'icon_glow_strong', 'asset': 'assets/icons/icon_glow_strong.png', 'label': 'Glow Max'},
    {'id': 'icon_glow_soft', 'asset': 'assets/icons/icon_glow_soft.png', 'label': 'Glow Min'},
    {'id': 'icon_minimal_border', 'asset': 'assets/icons/icon_minimal_border.png', 'label': 'Border'},
    {'id': 'icon_clean_border', 'asset': 'assets/icons/icon_clean_border.png', 'label': 'Clean'},
    {'id': 'icon_frosted_ring', 'asset': 'assets/icons/icon_frosted_ring.png', 'label': 'Frosted'},
    {'id': 'icon_glass_minimal', 'asset': 'assets/icons/icon_glass_minimal.png', 'label': 'Glass'},
    {'id': 'icon_inverted', 'asset': 'assets/icons/icon_inverted.png', 'label': 'Inverted'},
    {'id': 'icon_flat_dark', 'asset': 'assets/icons/icon_flat_dark.png', 'label': 'Flat Dark'},
    {'id': 'icon_premium_opal', 'asset': 'assets/icons/icon_premium_opal.png', 'label': 'Opal'},
    {'id': 'icon_panel_9dot', 'asset': 'assets/icons/icon_panel_9dot.png', 'label': '9-Dot'},
    {'id': 'icon_panel_flat', 'asset': 'assets/icons/icon_panel_flat.png', 'label': 'Panel'},
    {'id': 'icon_panel_4dot', 'asset': 'assets/icons/icon_panel_4dot.png', 'label': '4-Dot'},
    {'id': 'icon_ripple_2ring', 'asset': 'assets/icons/icon_ripple_2ring.png', 'label': '2-Ring'},
    {'id': 'icon_ripple_glow', 'asset': 'assets/icons/icon_ripple_glow.png', 'label': 'Ripple'},
    {'id': 'icon_squircle_dot', 'asset': 'assets/icons/icon_squircle_dot.png', 'label': 'Squircle'},
    {'id': 'icon_home', 'asset': 'assets/icons/icon_home.png', 'label': 'Home'},
    {'id': 'icon_power', 'asset': 'assets/icons/icon_power.png', 'label': 'Power'},
    {'id': 'icon_menu', 'asset': 'assets/icons/icon_menu.png', 'label': 'Menu'},
    {'id': 'icon_menu_3d', 'asset': 'assets/icons/icon_menu_3d.png', 'label': 'Menu 3D'},
  ];

  @override
  void initState() {
    super.initState();
    _loadIcon();
  }

  Future<void> _loadIcon() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedIcon = prefs.getString('floating_icon_id') ?? 'default';
    });
  }

  Future<void> _saveIcon(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('floating_icon_id', id);
    setState(() {
      _selectedIcon = id;
    });

    await OverlayChannel.updateConfig();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Icon saved successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Customize Icon',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Choose the floating button icon for Assistive Touch.',
              style: TextStyle(fontSize: 16, color: Color(0xFF94A3B8)),
              textAlign: TextAlign.center,
            ).animate().fade().slideY(begin: -0.1),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                itemCount: _icons.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  final iconData = _icons[index];
                  final isSelected = _selectedIcon == iconData['id'];
                  
                  return InkWell(
                    onTap: () => _saveIcon(iconData['id']),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? Theme.of(context).colorScheme.primary : const Color(0x1AFFFFFF),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x40000000),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          iconData['asset'] != null
                              ? Image.asset(
                                  iconData['asset'],
                                  width: 48,
                                  height: 48,
                                )
                              : Icon(
                                  iconData['icon'], 
                                  size: 48,
                                  color: Colors.white,
                                ),
                          const SizedBox(height: 12),
                          Text(
                            iconData['label'],
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate(delay: (index * 50).ms).scale(curve: Curves.easeOutBack);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

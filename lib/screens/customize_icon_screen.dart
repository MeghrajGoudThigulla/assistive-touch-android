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
    {'id': 'assistive_orb', 'asset': 'assets/icons/assistive_orb.svg', 'label': 'Orb'},
    {'id': 'floating_control_core', 'asset': 'assets/icons/floating_control_core.svg', 'label': 'Core'},
    {'id': 'touch_pulse', 'asset': 'assets/icons/touch_pulse.svg', 'label': 'Pulse'},
    {'id': 'default', 'icon': Icons.touch_app, 'label': 'Default'},
    {'id': 'circle', 'icon': Icons.circle, 'label': 'Circle'},
    {'id': 'star', 'icon': Icons.star, 'label': 'Star'},
    {'id': 'diamond', 'icon': Icons.diamond, 'label': 'Diamond'},
    {'id': 'bolt', 'icon': Icons.bolt, 'label': 'Bolt'},
    {'id': 'favorite', 'icon': Icons.favorite, 'label': 'Heart'},
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
                              ? SvgPicture.asset(
                                  iconData['asset'],
                                  width: 48,
                                  height: 48,
                                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)
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

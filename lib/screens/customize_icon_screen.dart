import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomizeIconScreen extends StatefulWidget {
  const CustomizeIconScreen({super.key});

  @override
  State<CustomizeIconScreen> createState() => _CustomizeIconScreenState();
}

class _CustomizeIconScreenState extends State<CustomizeIconScreen> {
  String _selectedIcon = 'default';
  
  final List<Map<String, dynamic>> _icons = [
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
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Icon saved successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customize Icon')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Choose the floating button icon for Assistive Touch.',
              style: TextStyle(fontSize: 16),
            ),
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
                        color: isSelected 
                            ? Theme.of(context).colorScheme.primaryContainer 
                            : Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected 
                            ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            iconData['icon'], 
                            size: 48,
                            color: isSelected 
                                ? Theme.of(context).colorScheme.onPrimaryContainer
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            iconData['label'],
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected 
                                  ? Theme.of(context).colorScheme.onPrimaryContainer
                                  : Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

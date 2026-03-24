import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/app_scaffold.dart';
import '../services/overlay_channel.dart';

class CustomizePanelScreen extends StatefulWidget {
  const CustomizePanelScreen({super.key});

  @override
  State<CustomizePanelScreen> createState() => _CustomizePanelScreenState();
}

class _CustomizePanelScreenState extends State<CustomizePanelScreen> {
  final PageController _pageController = PageController();

  final List<String> _page1Actions = List.filled(9, 'none');
  final List<String> _page2Actions = List.filled(9, 'none');

  final Map<String, List<String>> _actionCategories = {
    'Navigation': ['home', 'back', 'recents', 'open_menu'],
    'System': ['notifications', 'power_dialog', 'quick_settings', 'open_settings', 'lock_screen', 'screenshot', 'flashlight'],
    'Media': ['volume_up', 'volume_down'],
    'Display': ['none'],
  };

  @override
  void initState() {
    super.initState();
    _loadActions();
  }

  Future<void> _loadActions() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      for (int i = 0; i < 9; i++) {
        _page1Actions[i] = prefs.getString('panel.main_$i') ?? _getDefaultPage1(i);
        _page2Actions[i] = prefs.getString('panel.setting_$i') ?? _getDefaultPage2(i);
      }
    });
  }

  String _getDefaultPage1(int i) {
    const defaults = ["home", "back", "recents", "notifications", "power_dialog", "quick_settings", "none", "none", "open_settings"];
    return i < defaults.length ? defaults[i] : "none";
  }

  String _getDefaultPage2(int i) {
    const defaults = ["volume_up", "volume_down", "lock_screen", "flashlight", "screenshot", "none", "none", "none", "none"];
    return i < defaults.length ? defaults[i] : "none";
  }

  Future<void> _saveAction(bool isPage1, int index, String actionId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = isPage1 ? 'panel.main_$index' : 'panel.setting_$index';
    await prefs.setString(key, actionId);
    
    setState(() {
      if (isPage1) {
        _page1Actions[index] = actionId;
      } else {
        _page2Actions[index] = actionId;
      }
    });
    
    await OverlayChannel.updateConfig();
  }

  void _showActionPicker(bool isPage1, int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: _actionCategories.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                  child: Text(
                    entry.key,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                  ),
                ),
                ...entry.value.map((action) {
                  return ListTile(
                    title: Text(action.split('_').join(' ').toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 13)),
                    onTap: () {
                      _saveAction(isPage1, index, action);
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ],
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Customize Panel',
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Swipe to manage both pages of your floating panel. Tap a slot to reassign an action.',
              style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
              textAlign: TextAlign.center,
            ),
          ).animate().fade().slideY(begin: -0.1),
          Expanded(
            child: PageView(
              controller: _pageController,
              children: [
                _buildGrid(true, 'Page 1', 100),
                _buildGrid(false, 'Page 2', 200),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(bool isPage1, String title, int delayMs) {
    final actions = isPage1 ? _page1Actions : _page2Actions;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 24),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          decoration: BoxDecoration(
            color: const Color(0x1AFFFFFF),
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 9,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () => _showActionPicker(isPage1, index),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0x33FFFFFF),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      actions[index].split('_').join('\n').toUpperCase(),
                      style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ).animate(delay: (delayMs + index * 50).ms).scale(curve: Curves.easeOutBack),
              );
            },
          ),
        ),
      ],
    );
  }
}

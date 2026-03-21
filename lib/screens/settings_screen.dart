import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/app_scaffold.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _opacity = 0.8;
  double _size = 50.0;
  bool _autoStart = false;
  bool _singleTapAction = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _opacity = prefs.getDouble('panel_opacity') ?? 0.8;
      _size = prefs.getDouble('panel_size') ?? 50.0;
      _autoStart = prefs.getBool('auto_start') ?? false;
      _singleTapAction = prefs.getBool('single_tap') ?? true;
    });
  }

  Future<void> _saveDouble(String key, double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(key, value);
  }

  Future<void> _saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Settings',
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSlider(
            'Panel Opacity', 
            _opacity, 
            0.1, 
            1.0, 
            (val) => setState(() => _opacity = val),
            (val) => _saveDouble('panel_opacity', val),
            100,
          ),
          const Divider(color: Color(0x33FFFFFF)),
          _buildSlider(
            'Icon Size', 
            _size, 
            30.0, 
            100.0, 
            (val) => setState(() => _size = val),
            (val) => _saveDouble('panel_size', val),
            200,
          ),
          const Divider(color: Color(0x33FFFFFF)),
          SwitchListTile(
            title: const Text('Auto-start on Boot', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Automatically launch the floating icon when device restarts.', style: TextStyle(color: Color(0xFF94A3B8))),
            value: _autoStart,
            onChanged: (val) {
              setState(() => _autoStart = val);
              _saveBool('auto_start', val);
            },
            activeColor: Theme.of(context).colorScheme.primary,
          ).animate(delay: 300.ms).fade().slideX(begin: 0.1),
          const Divider(color: Color(0x33FFFFFF)),
          SwitchListTile(
            title: const Text('Single Tap to Open', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Open the panel with a single tap instead of double tap.', style: TextStyle(color: Color(0xFF94A3B8))),
            value: _singleTapAction,
            onChanged: (val) {
              setState(() => _singleTapAction = val);
              _saveBool('single_tap', val);
            },
            activeColor: Theme.of(context).colorScheme.primary,
          ).animate(delay: 400.ms).fade().slideX(begin: 0.1),
        ],
      ),
    );
  }

  Widget _buildSlider(String title, double value, double min, double max, ValueChanged<double> onChanged, ValueChanged<double> onChangeEnd, int delayMs) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: value,
                  min: min,
                  max: max,
                  divisions: 20,
                  label: value.toStringAsFixed(2),
                  onChanged: onChanged,
                  onChangeEnd: onChangeEnd,
                  activeColor: Theme.of(context).colorScheme.primary,
                  inactiveColor: const Color(0x33FFFFFF),
                ),
              ),
              Text(value.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
        ],
      ),
    ).animate(delay: delayMs.ms).fade().slideX(begin: 0.1);
  }
}

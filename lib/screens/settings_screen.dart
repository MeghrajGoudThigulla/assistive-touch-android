import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSlider(
            'Panel Opacity', 
            _opacity, 
            0.1, 
            1.0, 
            (val) {
              setState(() => _opacity = val);
            },
            (val) => _saveDouble('panel_opacity', val),
          ),
          const Divider(),
          _buildSlider(
            'Icon Size', 
            _size, 
            30.0, 
            100.0, 
            (val) {
              setState(() => _size = val);
            },
            (val) => _saveDouble('panel_size', val),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Auto-start on Boot'),
            subtitle: const Text('Automatically launch the floating icon when device restarts.'),
            value: _autoStart,
            onChanged: (val) {
              setState(() => _autoStart = val);
              _saveBool('auto_start', val);
            },
            activeColor: Theme.of(context).colorScheme.primary,
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Single Tap to Open'),
            subtitle: const Text('Open the panel with a single tap instead of double tap.'),
            value: _singleTapAction,
            onChanged: (val) {
              setState(() => _singleTapAction = val);
              _saveBool('single_tap', val);
            },
            activeColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(String title, double value, double min, double max, ValueChanged<double> onChanged, ValueChanged<double> onChangeEnd) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
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
                ),
              ),
              Text(value.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

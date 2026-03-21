import 'package:flutter/material.dart';

class CustomizePanelScreen extends StatefulWidget {
  const CustomizePanelScreen({super.key});

  @override
  State<CustomizePanelScreen> createState() => _CustomizePanelScreenState();
}

class _CustomizePanelScreenState extends State<CustomizePanelScreen> {
  final PageController _pageController = PageController();

  final List<String> page1Actions = [
    'Home', 'Back', 'Recents',
    'Volume Up', 'Volume Down', 'Lock Screen',
    'Flashlight', 'Screenshot', 'Settings'
  ];

  final List<String> page2Actions = [
    'Notifications', 'Quick Settings', 'Power Dialog',
    'Split Screen', 'Brightness Up', 'Brightness Down',
    'None', 'None', 'None'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customize Panel')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Swipe to manage both pages of your floating panel. Tap a slot to reassign an action.',
              style: TextStyle(fontSize: 14),
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              children: [
                _buildGrid(page1Actions, 'Page 1'),
                _buildGrid(page2Actions, 'Page 2'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(List<String> actions, String title) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest ?? Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(24),
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
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    actions[index].split(' ').join('\n'), 
                    style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onPrimaryContainer),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

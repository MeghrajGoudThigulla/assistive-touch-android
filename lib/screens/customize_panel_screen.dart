import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/app_scaffold.dart';

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
    'Split', 'Brightness Up', 'Brightness Down',
    'None', 'None', 'None'
  ];

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
              style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)), // Slate 400
              textAlign: TextAlign.center,
            ),
          ).animate().fade().slideY(begin: -0.1),
          Expanded(
            child: PageView(
              controller: _pageController,
              children: [
                _buildGrid(page1Actions, 'Page 1', 100),
                _buildGrid(page2Actions, 'Page 2', 200),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(List<String> actions, String title, int delayMs) {
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
                color: Color(0x40000000), // rgba(0,0,0,0.25)
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
              return Container(
                decoration: const BoxDecoration(
                  color: Color(0x33FFFFFF),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    actions[index].split(' ').join('\n'), 
                    style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                ),
              ).animate(delay: (delayMs + index * 50).ms).scale(curve: Curves.easeOutBack);
            },
          ),
        ),
      ],
    );
  }
}

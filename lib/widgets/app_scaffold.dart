import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final String title;

  const AppScaffold({
    super.key, 
    required this.body, 
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Slate 900 fallback
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F172A), // Slate 900
              Color(0xFF020617), // Slate 950
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
              ),
              Expanded(child: body),
            ],
          ),
        ),
      ),
    );
  }
}

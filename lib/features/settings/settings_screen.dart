import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pengaturan"),
        backgroundColor: Color(0xff1c1c1e),
        foregroundColor: Colors.white,
      ),
      body: Center(child: Text("Settings")),
    );
  }
}

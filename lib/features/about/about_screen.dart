import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tentang Aplikasi"),
        backgroundColor: Color(0xff1c1c1e),
        foregroundColor: Colors.white,
      ),
      body: Center(child: Text("About App")),
    );
  }
}

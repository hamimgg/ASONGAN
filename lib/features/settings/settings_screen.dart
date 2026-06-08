import 'package:asongan_app/main.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDark, child) {
        final Color scaffoldBg = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF8F9FA);
        final Color appBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
        final Color textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
        final Color cardBorderColor = isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE2E8F0);

        return Scaffold(
          backgroundColor: scaffoldBg,
          appBar: AppBar(
            backgroundColor: appBg,
            elevation: 0,
            title: Text(
              "Pengaturan",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor,
                fontSize: 17,
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
            iconTheme: IconThemeData(color: textColor),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                color: cardBorderColor,
                height: 1,
              ),
            ),
          ),
          body: Center(
            child: Text(
              "Pengaturan Aplikasi",
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
          ),
        );
      },
    );
  }
}

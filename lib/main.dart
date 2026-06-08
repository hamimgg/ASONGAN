import 'package:asongan_app/features/auth/presentation/pages/splash_screen.dart';
import 'package:flutter/material.dart';

final ValueNotifier<bool> isDarkModeNotifier = ValueNotifier<bool>(false);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDarkMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: isDarkMode ? Brightness.dark : Brightness.light,
            fontFamily: "Plus Jakarta Sans",
            scaffoldBackgroundColor: isDarkMode
                ? const Color(0xFF1C1C1E)
                : Colors.white,
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}

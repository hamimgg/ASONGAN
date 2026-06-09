import 'package:asongan_app/core/animations/animation_background.dart';
import 'package:asongan_app/features/auth/data/auth_service.dart';
import 'package:asongan_app/features/auth/presentation/pages/login_screen.dart';
import 'package:asongan_app/features/auth/presentation/pages/wrapper/main_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();

    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 3));

    final user = await AuthService.getUserSession();
    if (!mounted) return;

    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainWrapper()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFf5a623),
      body: Stack(
        children: [
          const AnimationBackground(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Spacer(),
                SvgPicture.asset(
                  'assets/images/logo_asongan.svg',

                  // height: 100,
                  // width: 100,
                ),
                SizedBox(height: 20),
                LoadingAnimationWidget.waveDots(
                  color: Color(0xffaaaaaa),
                  size: 32,
                ),
                // Text(
                //   "ASONGAN",
                //   style: TextStyle(
                //     color: Color(0xffffffff),
                //     fontSize: 64,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
                // Spacer(flex: 32),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Text(
                    "Version 1.0.0",
                    style: TextStyle(
                      color: Color(0xffaaaaaa),
                      fontSize: 12,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

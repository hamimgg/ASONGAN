import 'package:flutter/material.dart';

class AnimationBackground extends StatefulWidget {
  const AnimationBackground({super.key});

  @override
  State<AnimationBackground> createState() => _AnimationBackgroundState();
}

class _AnimationBackgroundState extends State<AnimationBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              left: -100 + (_controller.value * 50),
              bottom: -100 + (_controller.value * 10),
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xfff5a623),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xfff5a623),
                      blurRadius: 120,
                      spreadRadius: 50,
                    ),
                  ],
                ),
              ),
            ),

            // GLOW KANAN ATAS
            Positioned(
              right: -100 + (_controller.value * 80),
              top: -100 + (_controller.value * -200),
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xfff5a100),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xfff5a600),
                      blurRadius: 120,
                      spreadRadius: 50,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

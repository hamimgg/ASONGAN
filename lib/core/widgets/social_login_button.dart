import 'package:flutter/material.dart';

/// Reusable social login button (Google, Facebook, etc.)
/// used on the Login screen.
class SocialLoginButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  final Color fillColor;
  final Color borderColor;

  const SocialLoginButton({
    super.key,
    required this.onTap,
    required this.child,
    required this.fillColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Center(child: child),
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Dot grid background painter used on Login and Register screens.
class DotGridPainter extends CustomPainter {
  final bool isDark;
  const DotGridPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark ? const Color(0xFF2E2E30) : const Color(0xFFE2E8F0)
      ..strokeWidth = 1;

    const spacing = 24.0;
    const radius = 1.2;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant DotGridPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

/// Fallback grid painter for the map area on the Explore screen.
class MapGridPainter extends CustomPainter {
  final bool isDark;
  const MapGridPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = isDark ? const Color(0xFF2E2E30) : const Color(0xFFD0D8E0)
      ..strokeWidth = 0.8;

    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant MapGridPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

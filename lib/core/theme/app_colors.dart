import 'package:flutter/material.dart';

/// Centralized color palette for the Asongan app.
/// Call each method with `isDark` to get the appropriate color for the current theme.
class AppColors {
  AppColors._(); // prevent instantiation

  // --- Brand ---
  static const Color accent = Color(0xFFF5A623);
  static const Color accentDark = Color(0xFF1C1C1E);

  // --- appBar ---
  static Color appBarBg(bool isDark) =>
      isDark ? const Color(0xFF1C1C1E) : const Color(0xFFFFFfff);

  // --- Scaffold / Background ---
  static Color scaffoldBg(bool isDark) =>
      isDark ? const Color(0xFF1C1C1E) : const Color(0xFFFFF8F4);

  static Color scaffoldBgPure(bool isDark) =>
      isDark ? const Color(0xFF1C1C1E) : Colors.white;

  // --- Card ---
  static Color cardBg(bool isDark) =>
      isDark ? const Color(0xFF2A2A2C) : Colors.white;

  static Color cardBorder(bool isDark) =>
      isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE2E8F0);

  // --- Text ---
  static Color textPrimary(bool isDark) =>
      isDark ? Colors.white : const Color(0xFF1C1C1E);

  static Color textSubtitle(bool isDark) =>
      isDark ? const Color(0xFF9A9A9A) : const Color(0xFF7A7A7C);

  static Color textHint(bool isDark) =>
      isDark ? const Color(0xFF5A5A5C) : const Color(0xFF9E9E9E);

  // --- Input ---
  static Color inputFill(bool isDark) =>
      isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF1F5F9);

  static Color inputBorder(bool isDark) =>
      isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE2E8F0);

  // --- Icon ---
  static Color icon(bool isDark) =>
      isDark ? Colors.white : const Color(0xFF1C1C1E);

  static Color iconSecondary(bool isDark) =>
      isDark ? const Color(0xFF7A7A7C) : const Color(0xFF9E9E9E);

  // --- Divider ---
  static Color divider(bool isDark) =>
      isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE2E8F0);

  // --- Status ---
  static const Color statusActive = Color(0xFF4CD964);
  static const Color statusClosed = Color(0xFFFF3B30);

  // --- Social / Misc ---
  static Color socialBg(bool isDark) =>
      isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF1F5F9);

  static Color roleToggleBg(bool isDark) =>
      isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF1F5F9);
}

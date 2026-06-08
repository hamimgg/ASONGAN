import 'package:asongan_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Reusable text input field used across Login and Register screens.
///
/// Provides consistent styling (fill color, border, hint, prefix icon)
/// with dark/light mode support.
class AsonganTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData prefixIcon;
  final bool isDark;
  final bool obscureText;
  final Widget? suffixWidget;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const AsonganTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.prefixIcon,
    required this.isDark,
    this.obscureText = false,
    this.suffixWidget,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final Color fillColor = AppColors.inputFill(isDark);
    final Color borderColor = AppColors.inputBorder(isDark);
    final Color textColor = AppColors.textPrimary(isDark);
    final Color hintColor = AppColors.textHint(isDark);
    final Color iconColor = AppColors.iconSecondary(isDark);

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(
        color: textColor,
        fontSize: 14,
        fontFamily: 'Plus Jakarta Sans',
      ),
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return "$hint tidak boleh kosong";
            }
            return null;
          },
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: hintColor,
          fontSize: 14,
          fontFamily: 'Plus Jakarta Sans',
        ),
        prefixIcon: Icon(
          prefixIcon,
          color: iconColor,
          size: 20,
        ),
        suffixIcon: suffixWidget != null
            ? Padding(
                padding: const EdgeInsets.only(right: 12),
                child: suffixWidget,
              )
            : null,
        suffixIconConstraints: const BoxConstraints(),
        filled: true,
        fillColor: fillColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class AppInputDecoration {
  static InputDecoration standard({
    required BuildContext context,
    required String labelText,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    Color? borderColor,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final defaultBorderColor = isDarkMode ? Colors.white54 : Colors.black45;
    final focusedBorderColor = isDarkMode ? Colors.white : Colors.black;

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: borderColor ?? defaultBorderColor,
      ),
    );

    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: focusedBorderColor,
        width: 2.0,
      ),
    );

    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: isDarkMode ? Colors.grey[850] : Colors.grey[200],
      border: border,
      enabledBorder: border,
      focusedBorder: focusedBorder,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

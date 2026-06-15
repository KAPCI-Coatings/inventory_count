import 'package:flutter/material.dart';

// ignore: unused_field
class AppColors {
  AppColors._();

  static const Color primaryColor = Color.fromARGB(255, 111, 197, 219);

  static const Color primaryBlue = Color(0xFF6BC2F0);

  static const Color primaryYellow = Color(0xFFFFEE00);

  static const Color incomeGreen = Color(0xFF2ED573);

  static const Color expenseRed = Color(0xFFFF5463);

  static const Color successGreen =  Color.fromARGB(255, 86, 195, 89);
  static const Color successGreenLight = Color(0xFFC8E6C9);
  static const Color successGreenDark = Color(0xFF388E3C);

  static const Color errorRed = Colors.red;
  static const Color errorRedLight = Color(0xFFFFCDD2);
  static const Color errorRedMedium = Color(0xFFE57373);
  static const Color errorRedDark = Color(0xFFD32F2F);

  static const Color warningYellow = Colors.yellow;
  static const Color warningYellowLight = Color(0xFFFFF9C4);
  static const Color warningYellowMedium = Color(0xFFFFF59D);
  static const Color warningYellowDark = Color(0xFFFBC02D);
  static const Color warningOrange = Colors.orange;

  static const Color infoBlue = Colors.blue;
  static const Color infoPurple = Colors.deepPurple;
  static const Color infoTeal = Colors.teal;

  static const Color white = Colors.white;

  static const Color black = Colors.black;

  static const Color black87 = Colors.black87;
  static const Color black54 = Colors.black54;
  static const Color black26 = Colors.black26;

  static const Color grey = Colors.grey;
  static const Color greyLight100 = Color(0xFFF5F5F5);
  static const Color greyLight200 = Color(0xFFEEEEEE);
  static const Color greyLight300 = Color(0xFFE0E0E0);
  static const Color greyMedium400 = Color(0xFFBDBDBD);
  static const Color greyMedium600 = Color(0xFF757575);
  static const Color greyDark700 = Color(0xFF616161);
  static const Color greyDark800 = Color(0xFF424242);

  static const Color backgroundLight = Color(0xFFF8F9FA);

  static const Color backgroundYellowLight = Color(0xFFFFF9C4);

  static Color getTransactionColor(bool isDebit) {
    return isDebit ? incomeGreen : expenseRed;
  }

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return warningYellowMedium;
      case 'approved':
        return successGreenLight;
      case 'rejected':
        return errorRedLight;
      default:
        return greyLight200;
    }
  }

  static Color getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return warningYellowDark;
      case 'approved':
        return successGreenDark;
      case 'rejected':
        return errorRedDark;
      default:
        return greyDark700;
    }
  }

  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }

  static Color getShadowColor(bool hasPendingEdit) {
    return hasPendingEdit
        ? warningYellowDark.withValues(alpha: 0.3)
        : black.withValues(alpha: 0.5);
  }

  static Color getBackgroundColor(bool hasPendingEdit) {
    return hasPendingEdit ? backgroundYellowLight : backgroundLight;
  }

  static Color getBorderColor(bool hasPendingEdit) {
    return hasPendingEdit ? warningYellowDark : Colors.transparent;
  }
}

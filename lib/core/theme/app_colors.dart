import 'package:flutter/material.dart';

abstract class AppColors {
  static const Color primaryBlue = Color(0xFF2C597D);
  static const Color primaryBlueLight = Color(0xFF37688F);
  static const Color primaryBlueDark = Color(0xFF1E3A5F);

  static const Color darkBlueBackground = Color(0xFF1A1A2E);
  static const Color goldAccent = Color(0xFFFFD54F);
  static const Color darkBlueSurface = Color(0xFF16213E);

  static const Color dashboardBlue = Color(0xFF2C597D);

  static const Color scanButtonGold = Color(0xFFFFD54F);

  static const Color scannerBackground = Color(0xFF1A1A2E);
  static const Color scannerSurface = Color(0xFF16213E);
  static const Color viewfinderBracket = Color(0xFF26A69A);
  static const Color controlChip = Color(0xFF2A2A3E);
  static const Color hintBubble = Color(0xCC2A2A3E);

  static const Color resultBackground = Color(0xFFF5F5F5);

  static const Color homeBackground = Color(0xFFF4F6F8);

  static const Color cardBackground = Colors.white;

  static const Color authentic = Color(0xFF26A69A);
  static const Color suspicious = Color(0xFFFFA726);
  static const Color counterfeit = Color(0xFFEF5350);

  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textOnDark = Colors.white;
  static const Color textOnPrimary = Colors.white;

  static const Color divider = Color(0xFFE0E0E0);
  static const Color shadow = Color(0x1A000000);
}

abstract class AppTextStyles {
  static const TextStyle screenTitle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnDark,
    letterSpacing: 0.2,
  );

  static const TextStyle resultVerdict = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: AppColors.textOnDark,
    letterSpacing: 2,
  );

  static const TextStyle resultSubtitle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textOnDark,
  );

  static const TextStyle sectionLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.1,
  );

  static const TextStyle detailKey = TextStyle(
    fontSize: 13,
    color: AppColors.textSecondary,
  );

  static const TextStyle detailValue = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle hintText = TextStyle(
    fontSize: 13,
    color: AppColors.textOnDark,
  );

  static const TextStyle controlLabel = TextStyle(
    fontSize: 11,
    color: AppColors.textOnDark,
  );
}

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary gradient colors
  static const Color primaryStart = Color(0xFF667EEA);
  static const Color primaryEnd = Color(0xFF764BA2);

  // Category colors
  static const Color workColor = Color(0xFFFF9800);
  static const Color personalColor = Color(0xFF4CAF50);
  static const Color ideasColor = Color(0xFF9C27B0);
  static const Color shoppingColor = Color(0xFF03A9F4);
  static const Color importantColor = Color(0xFFF44336);
  static const Color archiveColor = Color(0xFF757575);

  // Light theme
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCardBg = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF333333);
  static const Color lightTextSecondary = Color(0xFF666666);
  static const Color lightTextHint = Color(0xFF999999);
  static const Color lightDivider = Color(0xFFE0E0E0);
  static const Color lightInputBg = Color(0xFFF0F0F0);

  // Dark theme
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCardBg = Color(0xFF2C2C2C);
  static const Color darkTextPrimary = Color(0xFFEEEEEE);
  static const Color darkTextSecondary = Color(0xFFAAAAAA);
  static const Color darkTextHint = Color(0xFF666666);
  static const Color darkDivider = Color(0xFF3A3A3A);
  static const Color darkInputBg = Color(0xFF2A2A2A);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryStart, primaryEnd],
  );
}

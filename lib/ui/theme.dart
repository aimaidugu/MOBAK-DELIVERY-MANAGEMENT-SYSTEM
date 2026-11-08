import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF0F6B3C);
  static const primaryDark = Color(0xFF093E25);
  static const secondary = Color(0xFF1DBE7C);
  static const accent = Color(0xFFF4B942);
  static const background = Color(0xFFF4F7F2);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF10251B);
  static const textSecondary = Color(0xFF587160);
  static const success = Color(0xFF16A34A);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFDC2626);
  static const info = Color(0xFF0EA5E9);
  static const border = Color(0xFFD9E6DB);
}

final ThemeData appTheme = ThemeData(
  fontFamily: 'Roboto',
  colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.background,
  appBarTheme: const AppBarTheme(
    elevation: 0,
    backgroundColor: AppColors.surface,
    foregroundColor: AppColors.textPrimary,
    centerTitle: false,
  ),
  cardColor: AppColors.surface,
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      letterSpacing: -0.4,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      letterSpacing: -0.2,
    ),
    bodyLarge: TextStyle(fontSize: 14, color: AppColors.textPrimary),
    bodyMedium: TextStyle(fontSize: 13, color: AppColors.textSecondary),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
);

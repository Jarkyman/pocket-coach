import 'package:flutter/material.dart';

abstract class AppColors {
  // Brand
  static const Color brandPrimary = Color(0xFF2D6A4F); // Deep calming green
  static const Color brandSecondary = Color(0xFFD8F3DC); // Light minty green

  // Neutrals (Light)
  static const Color lightSurface = Color(0xFFF8F9FA);
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF1B1B1B);
  static const Color lightTextSecondary = Color(0xFF5A5A5A);
  static const Color lightBorder = Color(0xFFE0E0E0);
  static const Color lightSurfaceElevated = Color(0xFFFFFFFF);

  // Neutrals (Dark)
  static const Color darkSurface = Color(0xFF1C1C1E);
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkTextPrimary = Color(0xFFF2F2F7);
  static const Color darkTextSecondary = Color(0xFF8E8E93);
  static const Color darkBorder = Color(0xFF38383A);
  static const Color darkSurfaceElevated = Color(0xFF2C2C2E);

  // Functional
  static const Color error = Color(0xFFB00020);
  static const Color success = Color(0xFF2E7D32);
}

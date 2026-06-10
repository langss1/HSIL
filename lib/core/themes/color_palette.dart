import 'package:flutter/material.dart';

/// HSIL Attendance — Modern color palette & design tokens
class AppColors {
  const AppColors._();

  // Primary brand colors
  static const Color deepNavy = Color(0xFF0B1D3A);
  static const Color safetyOrange = Color(0xFFFF6B35);
  static const Color white = Color(0xFFFFFFFF);

  // Background palette
  static const Color bgDark = Color(0xFF0B1D3A);
  static const Color bgDarker = Color(0xFF0A1728);
  static const Color bgCard = Color(0xFF1A2E47);
  static const Color bgCardLight = Color(0xFF253D5C);
  static const Color bgLight = Color(0xFFF7F9FC);
  static const Color bgLightCard = Color(0xFFFFFFFF);
  static const Color bgLightGray = Color(0xFFF0F3F7);

  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textPrimaryDark = Color(0xFF0B1D3A);
  static const Color textSecondary = Color(0xFF6B8AA8);
  static const Color textTertiary = Color(0xFF9BA9B8);
  static const Color textHint = Color(0xFFADB5BE);

  // Status & semantic
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Attendance status
  static const Color statusHadir = Color(0xFF10B981);
  static const Color statusTelat = Color(0xFFFF6B35); // Orange
  static const Color statusIzin = Color(0xFF3B82F6);
  static const Color statusAlpha = Color(0xFFE50000); // Merah menyala

  // Gradient helpers
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [deepNavy, Color(0xFF1a3a52)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [safetyOrange, Color(0xFFE85A23)],
  );
}

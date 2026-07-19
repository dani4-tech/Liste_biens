import 'package:flutter/material.dart';

/// Palette et thème centralisés de l'application, pour une cohérence visuelle
/// sur tous les écrans sans dupliquer les couleurs partout.
class AppColors {
  static const primary = Color(0xFF7C3AED); // violet profond
  static const primaryLight = Color(0xFFA78BFA);
  static const accent = Color(0xFFEC4899); // rose, pour les favoris/prix
  static const background = Color(0xFFFAFAFC);
  static const surface = Colors.white;
  static const textDark = Color(0xFF1F1B2E);
  static const textGrey = Color(0xFF8B8699);
}

class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.surface,
      ),
      scaffoldBackgroundColor: AppColors.background,
    );

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        headlineSmall: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textDark, letterSpacing: -0.5),
        titleLarge: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textDark),
        titleMedium: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDark),
        bodyLarge: const TextStyle(color: AppColors.textDark, height: 1.5),
        bodyMedium: const TextStyle(color: AppColors.textGrey, height: 1.4),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: AppColors.textDark,
        titleTextStyle: TextStyle(color: AppColors.textDark, fontSize: 20, fontWeight: FontWeight.w700),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF2F0F7),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
        ),
        labelStyle: const TextStyle(color: AppColors.textGrey),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          elevation: 0,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: const Color(0xFFF2F0F7),
        selectedColor: AppColors.primary,
        labelStyle: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w600),
        secondaryLabelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      ),
    );
  }
}
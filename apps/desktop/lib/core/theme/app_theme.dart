import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Tema principal de la aplicación AmbuTrack
///
/// Utiliza el sistema de diseño IAutomat para crear un tema médico profesional
/// basado en azul médico y verde salud.
class AppTheme {
  AppTheme._();

  /// ColorScheme claro personalizado para AmbuTrack
  static ColorScheme get lightColorScheme {
    return ColorScheme.fromSeed(
      seedColor: AppColors.primary,        // Azul médico
      secondary: AppColors.secondary,      // Verde médico
    );
  }

  /// ColorScheme oscuro personalizado para AmbuTrack
  static ColorScheme get darkColorScheme {
    return ColorScheme.fromSeed(
      seedColor: AppColors.primary,        // Azul médico
      secondary: AppColors.secondary,      // Verde médico
      brightness: Brightness.dark,
    );
  }

  /// Tema claro personalizado para AmbuTrack
  static ThemeData get lightTheme {
    return ThemeData.from(
      colorScheme: lightColorScheme,
    ).copyWith(
      // Configuraciones adicionales específicas para ambulancias
      scaffoldBackgroundColor: AppColors.backgroundLight,

      // AppBar personalizado
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 2,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Botones personalizados
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
      ),

      // Botón secundario
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      // Botón de floating action
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
      ),

      // Cards
      cardTheme: const CardThemeData(
        color: AppColors.surfaceLight,
        elevation: 2,
        shadowColor: AppColors.gray200,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),

      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.gray300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.gray300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.emergency, width: 2),
        ),
        filled: true,
        fillColor: AppColors.surfaceLight,
      ),

      // Chips (para tags de prioridad)
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.gray100,
        selectedColor: AppColors.primarySurface,
        labelStyle: const TextStyle(fontSize: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  /// Tema oscuro personalizado para AmbuTrack
  static ThemeData get darkTheme {
    return ThemeData.from(
      colorScheme: darkColorScheme,
    ).copyWith(
      scaffoldBackgroundColor: AppColors.backgroundDark,

      // AppBar para modo oscuro
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.textPrimaryDark,
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 2,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimaryDark,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Cards en modo oscuro
      cardTheme: const CardThemeData(
        color: AppColors.surfaceDark,
        elevation: 4,
        shadowColor: AppColors.gray800,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),

      // Input fields en modo oscuro
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.gray600),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.gray600),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.emergency, width: 2),
        ),
        filled: true,
        fillColor: AppColors.surfaceDark,
      ),
    );
  }

  /// Obtiene el tema según el modo
  static ThemeData getTheme({required bool isDarkMode}) {
    return isDarkMode ? darkTheme : lightTheme;
  }
}
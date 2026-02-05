import 'package:flutter/material.dart';

/// Colores centralizados de AmbuTrack Mobile
///
/// Define los colores específicos para el sector de ambulancias y emergencias médicas.
class AppColors {
  const AppColors._();

  // ===== COLORES PRIMARIOS =====

  /// Color principal - Azul médico profesional
  static const Color primary = Color(0xFF1E40AF);

  /// Color secundario - Verde médico
  static const Color secondary = Color(0xFF059669);

  // ===== VARIANTES DEL PRIMARIO =====

  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1E3A8A);
  static const Color primarySurface = Color(0xFFF0F4FF);

  // ===== VARIANTES DEL SECUNDARIO =====

  static const Color secondaryLight = Color(0xFF10B981);
  static const Color secondaryDark = Color(0xFF047857);
  static const Color secondarySurface = Color(0xFFF0FDF4);

  // ===== COLORES DE ESTADO =====

  static const Color success = Color(0xFF10B981); // Verde
  static const Color warning = Color(0xFFF59E0B); // Amarillo/Naranja
  static const Color error = Color(0xFFEF4444); // Rojo
  static const Color info = Color(0xFF3B82F6); // Azul

  // ===== COLORES ESPECÍFICOS DE AMBULANCIAS =====

  static const Color emergency = Color(0xFFDC2626); // Rojo emergencia
  static const Color highPriority = Color(0xFFEA580C); // Naranja
  static const Color mediumPriority = Color(0xFFD97706); // Amarillo
  static const Color lowPriority = Color(0xFF059669); // Verde
  static const Color inactive = Color(0xFF6B7280); // Gris

  // ===== ESCALA DE GRISES =====

  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);

  // ===== COLORES DE SUPERFICIE =====

  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF111827);
  static const Color surfaceLight = Color(0xFFF9FAFB);
  static const Color surfaceDark = Color(0xFF1F2937);

  // ===== COLORES DE TEXTO =====

  static const Color textPrimaryLight = Color(0xFF111827);
  static const Color textPrimaryDark = Color(0xFFF9FAFB);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);
}

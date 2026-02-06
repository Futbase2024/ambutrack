import 'package:flutter/material.dart';

/// Colores centralizados de la aplicación AmbuTrack
///
/// Define colores específicos para el sector de ambulancias y emergencias médicas.
class AppColors {
  AppColors._();

  // === COLORES PRIMARIOS ===

  /// Color principal - Azul médico profesional para confianza y serenidad
  static const Color primary = Color(0xFF1E40AF); // Azul médico

  /// Color secundario - Verde médico para salud y estados positivos
  static const Color secondary = Color(0xFF059669); // Verde médico

  // === VARIANTES DEL PRIMARIO ===

  /// Variante clara del color primario
  static const Color primaryLight = Color(0xFF3B82F6);

  /// Variante oscura del color primario
  static const Color primaryDark = Color(0xFF1E3A8A);

  /// Superficie con tinte primario
  static const Color primarySurface = Color(0xFFF0F4FF);

  // === VARIANTES DEL SECUNDARIO ===

  /// Variante clara del color secundario
  static const Color secondaryLight = Color(0xFF10B981);

  /// Variante oscura del color secundario
  static const Color secondaryDark = Color(0xFF047857);

  /// Superficie con tinte secundario
  static const Color secondarySurface = Color(0xFFF0FDF4);

  // === COLORES DE ESTADO ===

  /// Color de éxito - Verde
  static const Color success = Color(0xFF10B981);

  /// Color de advertencia - Amarillo/Naranja
  static const Color warning = Color(0xFFF59E0B);

  /// Color de error - Rojo
  static const Color error = Color(0xFFEF4444);

  /// Color informativo - Azul
  static const Color info = Color(0xFF3B82F6);

  // === COLORES ESPECÍFICOS DE AMBULANCIAS ===

  /// Rojo emergencia para alertas críticas
  static const Color emergency = Color(0xFFDC2626);

  /// Naranja precaución/alta prioridad
  static const Color highPriority = Color(0xFFEA580C);

  /// Amarillo media prioridad
  static const Color mediumPriority = Color(0xFFD97706);

  /// Verde baja prioridad (mismo que secondary)
  static const Color lowPriority = Color(0xFF059669);

  /// Gris neutral para estados inactivos
  static const Color inactive = Color(0xFF6B7280);

  // === ESCALA DE GRISES ===

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

  // === COLORES DE SUPERFICIE ===

  /// Fondo principal modo claro
  static const Color backgroundLight = Color(0xFFFFFFFF);

  /// Fondo principal modo oscuro
  static const Color backgroundDark = Color(0xFF111827);

  /// Superficie de cards modo claro
  static const Color surfaceLight = Color(0xFFF9FAFB);

  /// Superficie de cards modo oscuro
  static const Color surfaceDark = Color(0xFF1F2937);

  // === COLORES DE TEXTO ===

  /// Texto principal modo claro
  static const Color textPrimaryLight = Color(0xFF111827);

  /// Texto principal modo oscuro
  static const Color textPrimaryDark = Color(0xFFF9FAFB);

  /// Texto secundario modo claro
  static const Color textSecondaryLight = Color(0xFF6B7280);

  /// Texto secundario modo oscuro
  static const Color textSecondaryDark = Color(0xFF9CA3AF);

  /// Texto terciario modo claro
  static const Color textTertiaryLight = Color(0xFF9CA3AF);

  // === COLORES PROFESIONALES PARA BADGES ===

  /// Badge disponible - fondo
  static const Color badgeDisponibleBg = Color(0xFFF0FDF4); // green-50

  /// Badge disponible - texto
  static const Color badgeDisponibleText = Color(0xFF166534); // green-800

  /// Badge disponible - borde
  static const Color badgeDisponibleBorder = Color(0xFFBBF7D0); // green-200

  /// Badge en servicio - fondo
  static const Color badgeServicioBg = Color(0xFFEFF6FF); // blue-50

  /// Badge en servicio - texto
  static const Color badgeServicioText = Color(0xFF1E40AF); // blue-800

  /// Badge en servicio - borde
  static const Color badgeServicioBorder = Color(0xFFBFDBFE); // blue-200

  /// Badge mantenimiento - fondo
  static const Color badgeMantenimientoBg = Color(0xFFFFFBEB); // amber-50

  /// Badge mantenimiento - texto
  static const Color badgeMantenimientoText = Color(0xFF92400E); // amber-800

  /// Badge mantenimiento - borde
  static const Color badgeMantenimientoBorder = Color(0xFFFDE68A); // amber-200

  /// Badge inactivo - fondo
  static const Color badgeInactivoBg = Color(0xFFF9FAFB); // gray-50

  /// Badge inactivo - texto
  static const Color badgeInactivoText = Color(0xFF4B5563); // gray-600

  /// Badge inactivo - borde
  static const Color badgeInactivoBorder = Color(0xFFE5E7EB); // gray-200

  // === COLORES PARA ACCIONES ===

  /// Color de iconos de acción por defecto
  static const Color actionIconDefault = Color(0xFF9CA3AF); // gray-400

  /// Color de iconos de acción en hover
  static const Color actionIconHover = Color(0xFF6B7280); // gray-500

  /// Color de fondo hover para editar
  static const Color actionEditHoverBg = Color(0xFFEFF6FF); // blue-50

  /// Color de icono hover para editar
  static const Color actionEditHoverIcon = Color(0xFF1E40AF); // blue-800

  /// Color de fondo hover para eliminar
  static const Color actionDeleteHoverBg = Color(0xFFFEF2F2); // red-50

  /// Color de icono hover para eliminar
  static const Color actionDeleteHoverIcon = Color(0xFFDC2626); // red-600

  // === MÉTODOS DE UTILIDAD ===

  /// Obtiene el color de prioridad según el nivel
  static Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return highPriority;
      case 2:
        return mediumPriority;
      case 3:
        return lowPriority;
      default:
        return inactive;
    }
  }

  /// Obtiene el color con opacidad
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }
}
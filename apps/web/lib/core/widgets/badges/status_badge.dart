import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Badge de estado profesional con colores suaves
///
/// Diseñado siguiendo principios de diseño corporativo:
/// - Fondos muy suaves (50-level colors)
/// - Texto oscuro para buen contraste
/// - Bordes sutiles opcionales
/// - Aspecto minimalista y discreto
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    required this.label,
    required this.type,
    this.showBorder = true,
    super.key,
  });

  final String label;
  final StatusBadgeType type;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final StatusBadgeColors colors = _getColors(type);

    return IntrinsicWidth(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(6),
          border: showBorder ? Border.all(color: colors.border) : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: colors.text,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  StatusBadgeColors _getColors(StatusBadgeType type) {
    switch (type) {
      case StatusBadgeType.disponible:
        return const StatusBadgeColors(
          background: AppColors.badgeDisponibleBg,
          text: AppColors.badgeDisponibleText,
          border: AppColors.badgeDisponibleBorder,
        );
      case StatusBadgeType.enServicio:
        return const StatusBadgeColors(
          background: AppColors.badgeServicioBg,
          text: AppColors.badgeServicioText,
          border: AppColors.badgeServicioBorder,
        );
      case StatusBadgeType.mantenimiento:
        return const StatusBadgeColors(
          background: AppColors.badgeMantenimientoBg,
          text: AppColors.badgeMantenimientoText,
          border: AppColors.badgeMantenimientoBorder,
        );
      case StatusBadgeType.inactivo:
        return const StatusBadgeColors(
          background: AppColors.badgeInactivoBg,
          text: AppColors.badgeInactivoText,
          border: AppColors.badgeInactivoBorder,
        );
      case StatusBadgeType.success:
        return const StatusBadgeColors(
          background: AppColors.badgeDisponibleBg,
          text: AppColors.badgeDisponibleText,
          border: AppColors.badgeDisponibleBorder,
        );
      case StatusBadgeType.warning:
        return const StatusBadgeColors(
          background: AppColors.badgeMantenimientoBg,
          text: AppColors.badgeMantenimientoText,
          border: AppColors.badgeMantenimientoBorder,
        );
      case StatusBadgeType.error:
        return const StatusBadgeColors(
          background: Color(0xFFFEF2F2), // red-50
          text: Color(0xFF991B1B), // red-800
          border: Color(0xFFFECACA), // red-200
        );
    }
  }
}

/// Tipos de badge disponibles
enum StatusBadgeType {
  disponible,
  enServicio,
  mantenimiento,
  inactivo,
  success,
  warning,
  error,
}

/// Colores del badge
class StatusBadgeColors {
  const StatusBadgeColors({
    required this.background,
    required this.text,
    required this.border,
  });

  final Color background;
  final Color text;
  final Color border;
}

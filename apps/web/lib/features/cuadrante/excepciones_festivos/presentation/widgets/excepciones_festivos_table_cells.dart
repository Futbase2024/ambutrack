import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Celda de fecha formateada (dd/MM/yyyy)
class ExcepcionFechaCell extends StatelessWidget {
  const ExcepcionFechaCell({super.key, required this.item});

  final ExcepcionFestivoEntity item;

  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    return Text(
      _dateFormat.format(item.fecha),
      style: GoogleFonts.inter(
        fontSize: 14,
        color: AppColors.textPrimaryLight,
      ),
    );
  }
}

/// Celda de nombre con descripción opcional
class ExcepcionNombreCell extends StatelessWidget {
  const ExcepcionNombreCell({super.key, required this.item});

  final ExcepcionFestivoEntity item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          item.nombre,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        if (item.descripcion != null && item.descripcion!.isNotEmpty)
          Text(
            item.descripcion!,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.textSecondaryLight,
            ),
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }
}

/// Celda de tipo (FESTIVO, EXCEPCION, ESPECIAL)
class ExcepcionTipoCell extends StatelessWidget {
  const ExcepcionTipoCell({super.key, required this.item});

  final ExcepcionFestivoEntity item;

  @override
  Widget build(BuildContext context) {
    return Text(
      item.tipo,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimaryLight,
      ),
    );
  }
}

/// Celda de badge booleano (Sí/No) reutilizable
class ExcepcionBooleanBadge extends StatelessWidget {
  const ExcepcionBooleanBadge({
    super.key,
    required this.value,
    required this.activeColor,
  });

  final bool value;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    final Color color = value ? activeColor : AppColors.gray400;
    final String label = value ? 'Sí' : 'No';

    return Align(
      child: IntrinsicWidth(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

/// Celda de estado activo/inactivo
class ExcepcionEstadoCell extends StatelessWidget {
  const ExcepcionEstadoCell({super.key, required this.item});

  final ExcepcionFestivoEntity item;

  @override
  Widget build(BuildContext context) {
    final Color color = item.activo ? AppColors.success : AppColors.gray400;
    final String label = item.activo ? 'Activo' : 'Inactivo';

    return Align(
      child: IntrinsicWidth(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:ambutrack_web/core/theme/app_colors.dart';
import 'package:ambutrack_web/core/theme/app_sizes.dart';
import 'package:ambutrack_web/features/alertas_caducidad/presentation/widgets/helpers/alerta_helpers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tarjeta individual de un mantenimiento próximo/vencido dentro del popup.
///
/// Muestra el tipo, descripción, fecha programada, badge de días restantes
/// (color/texto reutilizados de [getDiasRestantesColor] / [getDiasRestantesText])
/// y un botón "Visto".
class MantenimientoProximoCard extends StatelessWidget {
  const MantenimientoProximoCard({
    required this.mantenimiento,
    required this.dias,
    required this.onVisto,
    super.key,
  });

  final MantenimientoEntity mantenimiento;
  final int dias;
  final VoidCallback onVisto;

  @override
  Widget build(BuildContext context) {
    final Color color = getDiasRestantesColor(dias);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: <Widget>[
            _CardBarraLateral(color: color),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _CardCabecera(
                      mantenimiento: mantenimiento,
                      dias: dias,
                      color: color,
                    ),
                    const SizedBox(height: AppSizes.spacingSmall),
                    _CardDescripcion(descripcion: mantenimiento.descripcion),
                    if (mantenimiento.fechaProgramada != null) ...<Widget>[
                      const SizedBox(height: 4),
                      _CardFechaProgramada(
                          fecha: mantenimiento.fechaProgramada!),
                    ],
                    const SizedBox(height: AppSizes.spacing),
                    _CardBotonVisto(onVisto: onVisto),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardBarraLateral extends StatelessWidget {
  const _CardBarraLateral({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 5,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSizes.radiusMedium),
          bottomLeft: Radius.circular(AppSizes.radiusMedium),
        ),
      ),
    );
  }
}

class _CardCabecera extends StatelessWidget {
  const _CardCabecera({
    required this.mantenimiento,
    required this.dias,
    required this.color,
  });

  final MantenimientoEntity mantenimiento;
  final int dias;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(AppSizes.spacingSmall),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          child: Icon(
            Icons.build_circle_outlined,
            size: AppSizes.iconMedium,
            color: color,
          ),
        ),
        const SizedBox(width: AppSizes.spacingSmall),
        Flexible(
          child: Text(
            mantenimiento.tipoMantenimiento.displayName.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: AppSizes.fontXs,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: AppSizes.spacingSmall),
        IntrinsicWidth(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.spacingSmall,
              vertical: 3,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            ),
            child: Text(
              getDiasRestantesText(dias),
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CardDescripcion extends StatelessWidget {
  const _CardDescripcion({required this.descripcion});

  final String descripcion;

  @override
  Widget build(BuildContext context) {
    return Text(
      descripcion.isNotEmpty ? descripcion : 'Mantenimiento programado',
      style: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.gray900,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _CardFechaProgramada extends StatelessWidget {
  const _CardFechaProgramada({required this.fecha});

  final DateTime fecha;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Icon(Icons.event_outlined, size: 14, color: AppColors.gray500),
        const SizedBox(width: 4),
        Text(
          'Programado: ${_formatFecha(fecha)}',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppColors.gray600,
          ),
        ),
      ],
    );
  }

  String _formatFecha(DateTime fecha) {
    final String dia = fecha.day.toString().padLeft(2, '0');
    final String mes = fecha.month.toString().padLeft(2, '0');
    return '$dia/$mes/${fecha.year}';
  }
}

class _CardBotonVisto extends StatelessWidget {
  const _CardBotonVisto({required this.onVisto});

  final VoidCallback onVisto;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onVisto,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.success,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spacingSmall,
          vertical: 6,
        ),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          side: BorderSide(color: AppColors.success.withValues(alpha: 0.3)),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.check_circle_outline, size: 15),
          const SizedBox(width: AppSizes.spacingXs),
          Text(
            'Visto',
            style: GoogleFonts.inter(
              fontSize: AppSizes.fontXs,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
